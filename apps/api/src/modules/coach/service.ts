import { randomUUID } from 'node:crypto';
import { AppError, isUuid, type Queryable } from '@noura/domain';
import type { components } from '@noura/contracts';
import { replacePlanMeal } from '../diet/service.js';

type Schemas = components['schemas'];

/** Provisional daily cap (blueprint §13 "five coach replies/day"); release-gate item alongside the
 * other quota numbers in docs/decisions.md. */
const COACH_REPLY_DAILY_QUOTA = 5;

const conflict = (what: string) =>
  new AppError(
    'REVISION_CONFLICT',
    `Your ${what} changed since you loaded it. Reload and try again.`,
  );

// -------------------------------------------------------------------- threads

export async function createCoachThread(
  client: Queryable,
  userId: string,
): Promise<Schemas['CoachThread']> {
  const row = (
    await client.query<{ id: string; created_at: Date }>(
      `insert into app.coach_threads (user_id) values ($1) returning id, created_at`,
      [userId],
    )
  ).rows[0]!;
  return { id: row.id, created_at: row.created_at.toISOString() };
}

export async function deleteCoachThread(
  client: Queryable,
  userId: string,
  id: string,
): Promise<Schemas['Deleted']> {
  if (!isUuid(id)) throw new AppError('NOT_FOUND', 'Resource not found.');
  // Cascades to coach_messages/action_proposals (supabase/migrations/20261001000600_insights_coach.sql).
  const deleted = await client.query(
    'delete from app.coach_threads where id = $1 and user_id = $2',
    [id, userId],
  );
  if (deleted.rowCount === 0) throw new AppError('NOT_FOUND', 'Resource not found.');
  return { id, deleted: true };
}

async function requireOwnedThread(
  client: Queryable,
  userId: string,
  threadId: string,
): Promise<void> {
  if (!isUuid(threadId)) throw new AppError('NOT_FOUND', 'Resource not found.');
  const row = (
    await client.query('select 1 from app.coach_threads where id = $1 and user_id = $2', [
      threadId,
      userId,
    ])
  ).rows[0];
  if (!row) throw new AppError('NOT_FOUND', 'Resource not found.');
}

// -------------------------------------------------------------------- messages

interface MessageRow {
  id: string;
  role: Schemas['CoachMessage']['role'];
  content: string;
  status: Schemas['CoachMessage']['status'];
  failure_code: string | null;
  cards: Schemas['CoachCard'][];
  created_at: Date;
}

interface ProposalRow {
  id: string;
  message_id: string;
  proposal_type: Schemas['ActionProposal']['type'];
  status: Schemas['ActionProposal']['status'];
  expected_plan_revision: number;
  expires_at: Date;
  applied_at: Date | null;
  payload: Record<string, unknown>;
}

const SAFE_FAILURE_MESSAGES: Record<string, string> = {
  provider_unavailable: 'The coach is temporarily unavailable. Please try again shortly.',
  invalid_provider_response: 'The coach could not form a reply. Please try again.',
};

function proposalSummary(p: ProposalRow): string {
  if (p.proposal_type === 'swap_meal') {
    const name =
      typeof p.payload['candidate_recipe_name'] === 'string'
        ? p.payload['candidate_recipe_name']
        : 'an alternative';
    return `Swap today's ${p.payload['slot'] ?? 'meal'} for ${name}.`;
  }
  return 'Proposed plan change.';
}

function toActionProposal(p: ProposalRow): Schemas['ActionProposal'] {
  return {
    id: p.id,
    type: p.proposal_type,
    status: p.status,
    expected_revision: p.expected_plan_revision,
    expires_at: p.expires_at.toISOString(),
    applied_at: p.applied_at ? p.applied_at.toISOString() : null,
    summary: proposalSummary(p),
  };
}

function toCoachMessage(row: MessageRow, proposal: ProposalRow | null): Schemas['CoachMessage'] {
  return {
    id: row.id,
    role: row.role,
    content: row.content,
    status: row.status,
    error: row.failure_code
      ? {
          code: row.failure_code,
          message: SAFE_FAILURE_MESSAGES[row.failure_code] ?? 'The coach could not reply.',
        }
      : null,
    cards: row.cards,
    action_proposal: proposal ? toActionProposal(proposal) : null,
    created_at: row.created_at.toISOString(),
  };
}

function encodeCursor(createdAtIso: string, id: string): string {
  return Buffer.from(JSON.stringify({ t: createdAtIso, id })).toString('base64url');
}

function decodeCursor(cursor: string | undefined): { t: string; id: string } | null {
  if (!cursor) return null;
  try {
    const parsed = JSON.parse(Buffer.from(cursor, 'base64url').toString('utf8')) as {
      t?: unknown;
      id?: unknown;
    };
    return typeof parsed.t === 'string' && typeof parsed.id === 'string'
      ? { t: parsed.t, id: parsed.id }
      : null;
  } catch {
    return null;
  }
}

export async function listCoachMessages(
  client: Queryable,
  userId: string,
  threadId: string,
  cursor: string | undefined,
  limit: number | undefined,
): Promise<Schemas['CoachMessageList']> {
  await requireOwnedThread(client, userId, threadId);
  const pageSize = limit ?? 50;
  const decoded = decodeCursor(cursor);
  const params: unknown[] = [userId, threadId];
  let where = 'user_id = $1 and thread_id = $2';
  if (decoded) {
    params.push(decoded.t, decoded.id);
    where += ` and (created_at, id) > ($3, $4)`;
  }
  params.push(pageSize + 1);
  const { rows } = await client.query<MessageRow>(
    `select id, role, content, status, failure_code, cards, created_at from app.coach_messages
       where ${where} order by created_at asc, id asc limit $${params.length}`,
    params,
  );
  const hasMore = rows.length > pageSize;
  const page = hasMore ? rows.slice(0, pageSize) : rows;
  const messageIds = page.map((r) => r.id);
  const proposalsByMessage = new Map<string, ProposalRow>();
  if (messageIds.length) {
    const { rows: proposals } = await client.query<ProposalRow>(
      `select id, message_id, proposal_type, status, expected_plan_revision, expires_at, applied_at, payload
         from app.action_proposals where user_id = $1 and message_id = any($2::uuid[])`,
      [userId, messageIds],
    );
    for (const p of proposals) proposalsByMessage.set(p.message_id, p);
  }
  const last = page[page.length - 1];
  return {
    items: page.map((row) => toCoachMessage(row, proposalsByMessage.get(row.id) ?? null)),
    next_cursor: hasMore && last ? encodeCursor(last.created_at.toISOString(), last.id) : null,
  };
}

/**
 * Creates the user message and a pending assistant placeholder in one transaction, then enqueues the
 * reply job through the usual transactional-outbox `generation_requests` row (D-017) — the API never
 * talks to pg-boss directly, exactly like M3/M4/M7's generation requests.
 */
export async function sendCoachMessage(
  client: Queryable,
  userId: string,
  threadId: string,
  body: Schemas['SendCoachMessageRequest'],
): Promise<Schemas['CoachMessageAccepted']> {
  await requireOwnedThread(client, userId, threadId);

  // Idempotent on client_id: a retried submission returns the same accepted job, never a duplicate.
  const existingUser = (
    await client.query<{ id: string }>(
      `select id from app.coach_messages where user_id = $1 and client_id = $2`,
      [userId, body.client_id],
    )
  ).rows[0];
  if (existingUser) {
    const existingRequest = (
      await client.query<{ id: string; coach_message_id: string | null }>(
        `select id, result_ids->>'coach_message_id' as coach_message_id from app.generation_requests
           where user_id = $1 and request_type = 'coach_reply'
             and result_ids->>'user_message_id' = $2 limit 1`,
        [userId, existingUser.id],
      )
    ).rows[0];
    if (existingRequest?.coach_message_id) {
      const assistant = (
        await client.query<MessageRow>(
          `select id, role, content, status, failure_code, cards, created_at from app.coach_messages
             where id = $1 and user_id = $2`,
          [existingRequest.coach_message_id, userId],
        )
      ).rows[0];
      if (assistant) {
        return { job_id: existingRequest.id, message: toCoachMessage(assistant, null) };
      }
    }
  }

  const today = new Date().toISOString().slice(0, 10);
  const used = (
    await client.query<{ count: string }>(
      `select count(*) from app.usage_reservations
         where user_id = $1 and feature = 'coach_reply' and quota_period = $2
           and state in ('reserved', 'consumed')`,
      [userId, today],
    )
  ).rows[0]!;
  if (Number(used.count) >= COACH_REPLY_DAILY_QUOTA) {
    throw new AppError(
      'QUOTA_EXCEEDED',
      "You've reached today's coach-reply limit. Try again tomorrow.",
      {
        retryable: false,
      },
    );
  }

  // created_at uses clock_timestamp() (not the transaction-frozen now()) so the user message and its
  // paired assistant placeholder below get strictly increasing timestamps even when inserted in the
  // same millisecond-resolution transaction, keeping listCoachMessages' chronological order stable.
  const userMessage = (
    await client.query<{ id: string; created_at: Date }>(
      `insert into app.coach_messages (user_id, thread_id, client_id, role, content, status, created_at)
         values ($1, $2, $3, 'user', $4, 'completed', clock_timestamp()) returning id, created_at`,
      [userId, threadId, body.client_id, body.message],
    )
  ).rows[0]!;

  const request = (
    await client.query<{ id: string }>(
      `insert into app.generation_requests (user_id, request_type) values ($1, 'coach_reply') returning id`,
      [userId],
    )
  ).rows[0]!;

  const assistantClientId = randomUUID();
  const assistant = (
    await client.query<{ id: string; created_at: Date }>(
      `insert into app.coach_messages (user_id, thread_id, client_id, role, content, status, created_at)
         values ($1, $2, $3, 'assistant', 'Thinking…', 'pending', clock_timestamp()) returning id, created_at`,
      [userId, threadId, assistantClientId],
    )
  ).rows[0]!;

  await client.query(
    `update app.generation_requests set result_ids = jsonb_build_object(
        'coach_message_id', $2::text, 'user_message_id', $3::text) where id = $1`,
    [request.id, assistant.id, userMessage.id],
  );

  await client.query(
    `insert into app.usage_reservations (user_id, feature, quota_period, request_id, state, expires_at)
       values ($1, 'coach_reply', $2, $3, 'reserved', now() + interval '1 day')`,
    [userId, today, request.id],
  );

  return {
    job_id: request.id,
    message: {
      id: assistant.id,
      role: 'assistant',
      content: 'Thinking…',
      status: 'pending',
      error: null,
      cards: [],
      action_proposal: null,
      created_at: assistant.created_at.toISOString(),
    },
  };
}

// -------------------------------------------------------------------- action proposals

async function loadOwnedProposal(
  client: Queryable,
  userId: string,
  id: string,
): Promise<ProposalRow> {
  if (!isUuid(id)) throw new AppError('NOT_FOUND', 'Resource not found.');
  const row = (
    await client.query<ProposalRow>(
      `select id, message_id, proposal_type, status, expected_plan_revision, expires_at, applied_at, payload
         from app.action_proposals where id = $1 and user_id = $2`,
      [id, userId],
    )
  ).rows[0];
  if (!row) throw new AppError('NOT_FOUND', 'Resource not found.');
  return row;
}

/**
 * Applies a pending proposal exactly once (blueprint §16 "apply once"). This never performs the plan
 * mutation itself: `swap_meal` is applied by calling the exact same `replacePlanMeal` the user-facing
 * swap endpoint uses (apps/api/src/modules/diet/service.ts), so the coach can never take an action the
 * normal confirmed-swap UI could not already take. `regenerate_day`/`reschedule_workout` are valid
 * schema values (forward-compatible with the blueprint's allowed-proposal list) but this milestone
 * never creates them and refuses to apply them — see docs/decisions.md D-031.
 */
export async function applyActionProposal(
  client: Queryable,
  userId: string,
  id: string,
  body: Schemas['RevisionRequest'],
): Promise<Schemas['ActionProposalResponse']['data']> {
  const proposal = await loadOwnedProposal(client, userId, id);
  if (proposal.status !== 'pending') {
    throw new AppError('CONSTRAINT_CONFLICT', `This suggestion is already ${proposal.status}.`);
  }
  if (proposal.expires_at.getTime() < Date.now()) {
    await client.query(`update app.action_proposals set status = 'expired' where id = $1`, [
      proposal.id,
    ]);
    throw new AppError('CONSTRAINT_CONFLICT', 'This suggestion has expired.');
  }
  if (body.expected_revision !== proposal.expected_plan_revision) throw conflict('suggestion');

  if (proposal.proposal_type !== 'swap_meal') {
    throw new AppError(
      'CONSTRAINT_CONFLICT',
      'This kind of suggestion cannot be applied automatically yet.',
    );
  }

  const planMealId = String(proposal.payload['plan_meal_id']);
  const candidateId = String(proposal.payload['candidate_recipe_id']);
  try {
    await replacePlanMeal(client, userId, planMealId, {
      expected_revision: proposal.expected_plan_revision,
      candidate_id: candidateId,
    });
  } catch (error) {
    if (error instanceof AppError && error.code === 'VALIDATION_ERROR') {
      throw new AppError('CONSTRAINT_CONFLICT', 'That meal swap is no longer available.');
    }
    throw error;
  }

  const updated = (
    await client.query<ProposalRow>(
      `update app.action_proposals set status = 'applied', applied_at = now()
         where id = $1 returning id, message_id, proposal_type, status, expected_plan_revision, expires_at, applied_at, payload`,
      [proposal.id],
    )
  ).rows[0]!;
  return toActionProposal(updated);
}

export async function cancelActionProposal(
  client: Queryable,
  userId: string,
  id: string,
): Promise<Schemas['ActionProposalResponse']['data']> {
  const proposal = await loadOwnedProposal(client, userId, id);
  if (proposal.status !== 'pending') {
    return toActionProposal(proposal);
  }
  const updated = (
    await client.query<ProposalRow>(
      `update app.action_proposals set status = 'cancelled'
         where id = $1 returning id, message_id, proposal_type, status, expected_plan_revision, expires_at, applied_at, payload`,
      [proposal.id],
    )
  ).rows[0]!;
  return toActionProposal(updated);
}
