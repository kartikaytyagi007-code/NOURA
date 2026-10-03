import {
  checkSafety,
  loadCoachContext,
  safeDeclineMessage,
  withUserTransaction,
  type CoachContext,
  type PoolLike,
  type QueuePayloads,
  type Queryable,
} from '@noura/domain';
import {
  InvalidCoachProviderInput,
  InvalidCoachProviderOutput,
  validateCoachContextInput,
  validateCoachProviderOutput,
  type AiProvider,
  type CoachProviderOutput,
} from '@noura/ai';
import type { Job } from 'pg-boss';
import type { Logger } from 'pino';

interface RequestRow {
  id: string;
  status: 'queued' | 'running' | 'completed' | 'failed' | 'cancelled';
  result_ids: { coach_message_id?: string; user_message_id?: string };
}

interface MessageStatusRow {
  status: 'pending' | 'completed' | 'failed';
}

const SAFE_MESSAGES: Record<string, string> = {
  provider_unavailable: 'The coach is temporarily unavailable. Please try again shortly.',
  invalid_provider_response: 'The coach could not form a reply. Please try again.',
};

async function markTerminal(
  client: Queryable,
  requestId: string,
  status: 'completed' | 'failed',
  failureCode?: string,
): Promise<void> {
  await client.query(
    `update app.generation_requests
       set status = $2, safe_error_code = $3, safe_error_message = $4, completed_at = now()
       where id = $1 and status in ('queued', 'running')`,
    [
      requestId,
      status,
      failureCode ?? null,
      failureCode ? (SAFE_MESSAGES[failureCode] ?? 'The coach could not reply.') : null,
    ],
  );
}

interface CoachCardOut {
  type: 'meal' | 'workout' | 'insight';
  title: string;
  ref_id: string | null;
}

async function completeMessage(
  client: Queryable,
  messageId: string,
  content: string,
  cards: CoachCardOut[] = [],
): Promise<void> {
  await client.query(
    `update app.coach_messages
       set content = $2, status = 'completed', failure_code = null, cards = $3::jsonb
       where id = $1`,
    [messageId, content, JSON.stringify(cards)],
  );
}

/**
 * Cards are always built here, directly from the already-loaded, real `CoachContext` — never parsed
 * out of the AI's free text (blueprint §16 "grounded responses/cards"; this milestone's scope note 6:
 * the model never sources a nutrition/exercise fact). At most one card per available surface.
 */
function buildCards(context: CoachContext): CoachCardOut[] {
  const cards: CoachCardOut[] = [];
  if (context.diet.today) {
    cards.push({
      type: 'meal',
      title: `Today's ${context.diet.today.slot}: ${context.diet.today.recipe_name}`,
      ref_id: context.diet.today.plan_meal_id,
    });
  }
  if (context.workout.today_session_id && context.workout.today_session_title) {
    cards.push({
      type: 'workout',
      title: `Today's workout: ${context.workout.today_session_title}`,
      ref_id: context.workout.today_session_id,
    });
  }
  return cards;
}

async function failMessage(
  client: Queryable,
  messageId: string,
  failureCode: string,
): Promise<void> {
  await client.query(
    `update app.coach_messages
       set status = 'failed', failure_code = $2,
           content = $3
       where id = $1`,
    [messageId, failureCode, SAFE_MESSAGES[failureCode] ?? 'The coach could not reply.'],
  );
}

/**
 * Creates the action_proposals row for a validated `swap_meal` proposal, re-checking the proposed
 * plan meal/candidate against a freshly loaded context rather than trusting the provider's ids as-is
 * (blueprint §2 "model text has no direct database authority"; scope note 7 "no silent actions").
 */
async function createSwapProposal(
  client: Queryable,
  userId: string,
  threadId: string,
  messageId: string,
  output: Extract<CoachProviderOutput['proposed_action'], { type: 'swap_meal' }>,
  freshToday: {
    plan_meal_id: string;
    plan_meal_revision: number;
    alternate_candidate_id: string | null;
  },
): Promise<void> {
  // The proposal must reference the SAME plan meal / candidate this request's own context just
  // loaded; a provider referencing stale or invented ids is silently dropped (no proposal created),
  // never trusted.
  if (
    output.plan_meal_id !== freshToday.plan_meal_id ||
    output.candidate_recipe_id !== freshToday.alternate_candidate_id
  ) {
    return;
  }
  await client.query(
    `insert into app.action_proposals
       (user_id, thread_id, message_id, proposal_type, payload, expected_plan_revision, expires_at)
     values ($1, $2, $3, 'swap_meal', $4::jsonb, $5, now() + interval '15 minutes')`,
    [
      userId,
      threadId,
      messageId,
      JSON.stringify({
        plan_meal_id: output.plan_meal_id,
        candidate_recipe_id: output.candidate_recipe_id,
        reason: output.reason,
      }),
      freshToday.plan_meal_revision,
    ],
  );
}

/**
 * Handles `coach.reply` (blueprint §12; docs/decisions.md D-031). Idempotent on the generation
 * request id, following the exact crash-recovery shape as `meal-scan-analyze.ts`: an already-terminal
 * request or an already-resolved assistant message is a no-op, so at-least-once delivery can never
 * send two replies to one user message.
 *
 * Safety is enforced twice (ticket requirement): `checkSafety` on the user's own message, before the
 * provider is ever called, and again on the provider's returned text as defence in depth.
 */
export async function handleCoachReply(
  [job]: Job<QueuePayloads['coach.reply']>[],
  pool: PoolLike,
  ai: AiProvider,
  log: Logger,
): Promise<{ status: string }> {
  if (!job) throw new Error('coach.reply handler received an empty batch');
  const { generation_request_id: requestId, user_id: userId } = job.data;

  return withUserTransaction(pool, 'noura_worker', userId, async (client) => {
    const request = (
      await client.query<RequestRow>(
        'select id, status, result_ids from app.generation_requests where id = $1 and user_id = $2',
        [requestId, userId],
      )
    ).rows[0];
    if (!request) {
      log.warn({ requestId }, 'coach.reply: request not found for this user, skipping');
      return { status: 'skipped_missing' };
    }
    if (
      request.status === 'completed' ||
      request.status === 'failed' ||
      request.status === 'cancelled'
    ) {
      return { status: 'already_terminal' };
    }

    const messageId = request.result_ids.coach_message_id;
    const threadRow = messageId
      ? (
          await client.query<{ thread_id: string }>(
            'select thread_id from app.coach_messages where id = $1 and user_id = $2',
            [messageId, userId],
          )
        ).rows[0]
      : undefined;
    const userMessageRow = request.result_ids.user_message_id
      ? (
          await client.query<{ content: string }>(
            'select content from app.coach_messages where id = $1 and user_id = $2',
            [request.result_ids.user_message_id, userId],
          )
        ).rows[0]
      : undefined;
    if (!messageId || !threadRow || !userMessageRow) {
      log.warn({ requestId }, 'coach.reply: message rows missing, skipping');
      return { status: 'skipped_missing' };
    }

    const current = (
      await client.query<MessageStatusRow>('select status from app.coach_messages where id = $1', [
        messageId,
      ])
    ).rows[0];
    if (!current || current.status !== 'pending') {
      // Already resolved by a previous delivery: repair the request row only, never resend a reply.
      await markTerminal(client, requestId, current?.status === 'failed' ? 'failed' : 'completed');
      return { status: 'already_processed' };
    }

    await client.query(
      `update app.generation_requests
         set status = 'running', attempts = attempts + 1, started_at = coalesce(started_at, now())
         where id = $1`,
      [requestId],
    );

    const userMessageText = userMessageRow.content;

    // 1) Pre-check: an out-of-scope/medical request never reaches the provider at all.
    const preCheck = checkSafety(userMessageText);
    if (preCheck.flagged) {
      await completeMessage(client, messageId, safeDeclineMessage(preCheck.flags));
      await markTerminal(client, requestId, 'completed');
      log.info({ requestId, userId, flags: preCheck.flags }, 'coach.reply: declined (pre-check)');
      return { status: 'declined_pre_check' };
    }

    const context = await loadCoachContext(client, userId);

    let contextInput;
    try {
      contextInput = validateCoachContextInput({
        user_message: userMessageText,
        profile: context.profile,
        diet: {
          has_active_plan: context.diet.has_active_plan,
          today: context.diet.today,
          today_logged_meal_count: context.diet.today_logged_meal_count,
        },
        workout: {
          has_active_plan: context.workout.has_active_plan,
          today_session_title: context.workout.today_session_title,
          today_session_status: context.workout.today_session_status,
        },
      });
    } catch (error) {
      if (error instanceof InvalidCoachProviderInput) {
        log.error({ requestId, err: error.issues }, 'coach.reply: invalid context payload (bug)');
        await failMessage(client, messageId, 'invalid_provider_response');
        await markTerminal(client, requestId, 'failed', 'invalid_provider_response');
        return { status: 'failed_invalid_context' };
      }
      throw error;
    }

    let rawOutput: unknown;
    try {
      const result = await ai.coachReply(contextInput as unknown as Record<string, unknown>, [
        'swap_meal',
      ]);
      rawOutput = result.output;
    } catch (error) {
      log.warn({ requestId, err: error }, 'coach.reply: provider call failed');
      await failMessage(client, messageId, 'provider_unavailable');
      await markTerminal(client, requestId, 'failed', 'provider_unavailable');
      return { status: 'failed_provider' };
    }

    let output: CoachProviderOutput;
    try {
      output = validateCoachProviderOutput(rawOutput);
    } catch (error) {
      if (error instanceof InvalidCoachProviderOutput) {
        log.error({ requestId, err: error.issues }, 'coach.reply: invalid provider output');
        await failMessage(client, messageId, 'invalid_provider_response');
        await markTerminal(client, requestId, 'failed', 'invalid_provider_response');
        return { status: 'failed_invalid_response' };
      }
      throw error;
    }

    // 2) Post-check: defence in depth against the (real or mock) model producing unsafe text anyway.
    const postCheck = checkSafety(output.answer_text);
    if (postCheck.flagged) {
      await completeMessage(client, messageId, safeDeclineMessage(postCheck.flags));
      await markTerminal(client, requestId, 'completed');
      log.warn(
        { requestId, userId, flags: postCheck.flags },
        'coach.reply: provider output flagged post-check, overridden',
      );
      return { status: 'declined_post_check' };
    }

    await completeMessage(client, messageId, output.answer_text, buildCards(context));

    if (
      output.proposed_action &&
      output.proposed_action.type === 'swap_meal' &&
      context.diet.today
    ) {
      await createSwapProposal(
        client,
        userId,
        threadRow.thread_id,
        messageId,
        output.proposed_action,
        {
          plan_meal_id: context.diet.today.plan_meal_id,
          plan_meal_revision: context.diet.today.plan_meal_revision,
          alternate_candidate_id: context.diet.today.alternate_candidate_id,
        },
      );
    }

    await markTerminal(client, requestId, 'completed');
    log.info({ requestId, userId }, 'coach.reply completed');
    return { status: 'completed' };
  });
}
