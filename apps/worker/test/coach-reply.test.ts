import { randomUUID } from 'node:crypto';
import type { AiProvider, AiResult } from '@noura/ai';
import { MockAiProvider } from '@noura/ai';
import pg from 'pg';
import { pino } from 'pino';
import { afterAll, describe, expect, it } from 'vitest';
import { handleCoachReply } from '../src/handlers/coach-reply.js';

const log = pino({ level: 'silent' });
const admin = new pg.Pool({ connectionString: process.env.DATABASE_URL, max: 4 });
const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL, max: 4 });
const ai = new MockAiProvider();

afterAll(async () => {
  await admin.end();
  await pool.end();
});

// Seed recipe ids from supabase/migrations/20261001001000_catalog_test_fixture.sql.
const KHICHDI = '00000000-0000-4000-a002-000000000001'; // vegan, lunch+dinner
const TOFU_STIR_FRY = '00000000-0000-4000-a002-000000000008'; // vegan, lunch+dinner

function todayIso(): string {
  return new Date().toISOString().slice(0, 10);
}

async function newUser(): Promise<string> {
  const id = randomUUID();
  await admin.query('insert into auth.users (id, email) values ($1, $2)', [
    id,
    `${id}@test.invalid`,
  ]);
  return id;
}

async function makeEligible(userId: string): Promise<void> {
  await admin.query(
    `insert into app.profiles
       (user_id, display_name, age_years, calculation_sex, height_cm, weight_kg, activity_band,
        timezone, unit_system, onboarding_status, onboarding_step, eligibility_status,
        screening_answered_at, revision)
     values ($1, 'Test User', 30, 'female', 165, 60, 'moderate', 'UTC', 'metric', 'completed', 'review',
             'eligible', now(), 1)`,
    [userId],
  );
  await admin.query(
    `insert into app.user_preferences
       (user_id, diet_type, allergy_ids, exclusion_ids, dislikes, meals_per_day, revision)
     values ($1, 'vegan', '{}', '{}', '{}', 3, 1)`,
    [userId],
  );
  await admin.query(
    `insert into app.target_snapshots
       (user_id, profile_revision, policy_version, policy_status, estimated_energy_kcal_min,
        estimated_energy_kcal_max, selected_targets, method, eligibility)
     values ($1, 1, 'test-v0', 'test', 2000, 2000, $2::jsonb, 'policy', 'eligible')`,
    [
      userId,
      JSON.stringify({
        basis: 'point',
        targets: { energy_kcal: 2000, protein_g: 72, fibre_g: 28, carbohydrate_g: 250, fat_g: 67 },
        warnings: [],
      }),
    ],
  );
}

async function insertActivePlanForToday(userId: string): Promise<void> {
  const snapshot = await admin.query<{ id: string }>(
    'select id from app.target_snapshots where user_id = $1 and valid_to is null',
    [userId],
  );
  const plan = await admin.query<{ id: string }>(
    `insert into app.diet_plans (user_id, version, profile_revision, target_snapshot_id, starts_on, status)
     values ($1, 1, 1, $2, $3, 'active') returning id`,
    [userId, snapshot.rows[0]!.id, todayIso()],
  );
  const nutrition = JSON.stringify({
    nutrients: { energy_kcal: 400, protein_g: 15, carbohydrate_g: 50, fat_g: 10, fibre_g: 5 },
    coverage: { items_total: 2, items_with_nutrition: 2, complete: true },
  });
  const portions = JSON.stringify({
    grams_scale: 1,
    portions: [
      { food_id: null, recipe_id: KHICHDI, label: 'meal', grams_min: 300, grams_max: 300 },
    ],
  });
  await admin.query(
    `insert into app.diet_plan_meals
       (user_id, plan_id, meal_date, slot, slot_ordinal, recipe_id, portions_snapshot, nutrition_snapshot)
     values ($1, $2, $3, 'lunch', 1, $4, $5::jsonb, $6::jsonb)`,
    [userId, plan.rows[0]!.id, todayIso(), KHICHDI, portions, nutrition],
  );
}

async function seedCoachMessage(
  userId: string,
  userText: string,
): Promise<{ requestId: string; threadId: string; assistantId: string }> {
  const thread = await admin.query<{ id: string }>(
    'insert into app.coach_threads (user_id) values ($1) returning id',
    [userId],
  );
  const threadId = thread.rows[0]!.id;
  const userMsg = await admin.query<{ id: string }>(
    `insert into app.coach_messages (user_id, thread_id, client_id, role, content, status)
       values ($1, $2, gen_random_uuid(), 'user', $3, 'completed') returning id`,
    [userId, threadId, userText],
  );
  const assistantMsg = await admin.query<{ id: string }>(
    `insert into app.coach_messages (user_id, thread_id, client_id, role, content, status)
       values ($1, $2, gen_random_uuid(), 'assistant', 'Thinking…', 'pending') returning id`,
    [userId, threadId],
  );
  const request = await admin.query<{ id: string }>(
    `insert into app.generation_requests (user_id, request_type, result_ids)
       values ($1, 'coach_reply', $2::jsonb) returning id`,
    [
      userId,
      JSON.stringify({
        coach_message_id: assistantMsg.rows[0]!.id,
        user_message_id: userMsg.rows[0]!.id,
      }),
    ],
  );
  return { requestId: request.rows[0]!.id, threadId, assistantId: assistantMsg.rows[0]!.id };
}

function job(requestId: string, userId: string) {
  return [{ id: requestId, data: { generation_request_id: requestId, user_id: userId } } as never];
}

async function assistantMessage(id: string) {
  const row = await admin.query(
    'select content, status, failure_code from app.coach_messages where id = $1',
    [id],
  );
  return row.rows[0] as { content: string; status: string; failure_code: string | null };
}

class FailingProvider implements AiProvider {
  readonly name = 'failing-mock';
  recognizeMeal(): Promise<AiResult<unknown>> {
    return Promise.reject(new Error('not used'));
  }
  explainMeal(): Promise<AiResult<unknown>> {
    return Promise.reject(new Error('not used'));
  }
  rankDietCandidates(): Promise<AiResult<unknown>> {
    return Promise.reject(new Error('not used'));
  }
  explainWeeklyInsights(): Promise<AiResult<unknown>> {
    return Promise.reject(new Error('not used'));
  }
  coachReply(): Promise<AiResult<unknown>> {
    return Promise.reject(new Error('simulated upstream timeout'));
  }
}

class MalformedProvider implements AiProvider {
  readonly name = 'malformed-mock';
  recognizeMeal(): Promise<AiResult<unknown>> {
    return Promise.reject(new Error('not used'));
  }
  explainMeal(): Promise<AiResult<unknown>> {
    return Promise.reject(new Error('not used'));
  }
  rankDietCandidates(): Promise<AiResult<unknown>> {
    return Promise.reject(new Error('not used'));
  }
  explainWeeklyInsights(): Promise<AiResult<unknown>> {
    return Promise.reject(new Error('not used'));
  }
  coachReply(): Promise<AiResult<unknown>> {
    return Promise.resolve({
      // Missing required answer_text, plus an adversarial extra field.
      output: { evidence_refs: [], drop_table: 'users' },
      meta: {
        provider: 'malformed-mock',
        model_id: 'x',
        prompt_version: 'x',
        latency_ms: 0,
        input_tokens: null,
        output_tokens: null,
        mock: true,
      },
    });
  }
}

class UnsafeOutputProvider implements AiProvider {
  readonly name = 'unsafe-mock';
  recognizeMeal(): Promise<AiResult<unknown>> {
    return Promise.reject(new Error('not used'));
  }
  explainMeal(): Promise<AiResult<unknown>> {
    return Promise.reject(new Error('not used'));
  }
  rankDietCandidates(): Promise<AiResult<unknown>> {
    return Promise.reject(new Error('not used'));
  }
  explainWeeklyInsights(): Promise<AiResult<unknown>> {
    return Promise.reject(new Error('not used'));
  }
  coachReply(): Promise<AiResult<unknown>> {
    return Promise.resolve({
      output: {
        answer_text: 'Based on your symptoms I can diagnose you with early-stage diabetes.',
        evidence_refs: [],
        proposed_action: null,
      },
      meta: {
        provider: 'unsafe-mock',
        model_id: 'x',
        prompt_version: 'x',
        latency_ms: 0,
        input_tokens: null,
        output_tokens: null,
        mock: true,
      },
    });
  }
}

describe('handleCoachReply', () => {
  it('honestly says there is no active diet/workout plan when none exists', async () => {
    const userId = await newUser();
    await makeEligible(userId);
    const { requestId, assistantId } = await seedCoachMessage(userId, 'How am I doing today?');

    const result = await handleCoachReply(job(requestId, userId), pool, ai, log);
    expect(result).toEqual({ status: 'completed' });

    const message = await assistantMessage(assistantId);
    expect(message.status).toBe('completed');
    expect(message.content).toMatch(/don't have an active diet plan/i);
    expect(message.content).toMatch(/don't have an active workout plan/i);

    const request = await admin.query('select status from app.generation_requests where id = $1', [
      requestId,
    ]);
    expect(request.rows[0]!.status).toBe('completed');
  });

  it('grounds the reply in real plan data when an active plan exists', async () => {
    const userId = await newUser();
    await makeEligible(userId);
    await insertActivePlanForToday(userId);
    const { requestId, assistantId } = await seedCoachMessage(userId, 'What is my lunch today?');

    const result = await handleCoachReply(job(requestId, userId), pool, ai, log);
    expect(result).toEqual({ status: 'completed' });
    const message = await assistantMessage(assistantId);
    expect(message.content).toMatch(/logged 0 meal/i);

    const cardsRow = await admin.query<{
      cards: { type: string; title: string; ref_id: string }[];
    }>('select cards from app.coach_messages where id = $1', [assistantId]);
    const cards = cardsRow.rows[0]!.cards;
    expect(cards).toHaveLength(1);
    expect(cards[0]).toMatchObject({ type: 'meal', ref_id: expect.any(String) });
    expect(cards[0]!.title).toContain('lunch');
  });

  it('declines an out-of-scope diagnosis request BEFORE ever calling the provider (pre-check)', async () => {
    const userId = await newUser();
    await makeEligible(userId);
    const { requestId, assistantId } = await seedCoachMessage(
      userId,
      'Can you diagnose why my stomach hurts after every meal?',
    );

    const result = await handleCoachReply(job(requestId, userId), pool, ai, log);
    expect(result).toEqual({ status: 'declined_pre_check' });
    const message = await assistantMessage(assistantId);
    expect(message.status).toBe('completed');
    expect(message.content).toMatch(/doctor|clinician|emergency/i);
    expect(message.content).not.toMatch(/mock provider/i);
  });

  it('declines a medication-dosing request', async () => {
    const userId = await newUser();
    await makeEligible(userId);
    const { requestId, assistantId } = await seedCoachMessage(
      userId,
      'How much insulin should I take with this meal?',
    );
    const result = await handleCoachReply(job(requestId, userId), pool, ai, log);
    expect(result).toEqual({ status: 'declined_pre_check' });
    const message = await assistantMessage(assistantId);
    expect(message.content).toMatch(/doctor|pharmacist/i);
  });

  it('overrides an unsafe provider response with a safe decline (post-check defence in depth)', async () => {
    const userId = await newUser();
    await makeEligible(userId);
    const { requestId, assistantId } = await seedCoachMessage(
      userId,
      'What should I eat for lunch?',
    );

    const result = await handleCoachReply(
      job(requestId, userId),
      pool,
      new UnsafeOutputProvider(),
      log,
    );
    expect(result).toEqual({ status: 'declined_post_check' });
    const message = await assistantMessage(assistantId);
    expect(message.content).not.toMatch(/early-stage diabetes/i);
    expect(message.content).toMatch(/doctor|clinician/i);
  });

  it('handles a provider failure gracefully: a clear failed message, never a crash', async () => {
    const userId = await newUser();
    await makeEligible(userId);
    const { requestId, assistantId } = await seedCoachMessage(
      userId,
      'What should I eat for lunch?',
    );

    const result = await handleCoachReply(job(requestId, userId), pool, new FailingProvider(), log);
    expect(result).toEqual({ status: 'failed_provider' });
    const message = await assistantMessage(assistantId);
    expect(message.status).toBe('failed');
    expect(message.failure_code).toBe('provider_unavailable');

    const request = await admin.query(
      'select status, safe_error_code from app.generation_requests where id = $1',
      [requestId],
    );
    expect(request.rows[0]).toMatchObject({
      status: 'failed',
      safe_error_code: 'provider_unavailable',
    });
  });

  it('rejects a malformed/adversarial provider response instead of trusting it', async () => {
    const userId = await newUser();
    await makeEligible(userId);
    const { requestId, assistantId } = await seedCoachMessage(
      userId,
      'What should I eat for lunch?',
    );

    const result = await handleCoachReply(
      job(requestId, userId),
      pool,
      new MalformedProvider(),
      log,
    );
    expect(result).toEqual({ status: 'failed_invalid_response' });
    const message = await assistantMessage(assistantId);
    expect(message.status).toBe('failed');
    expect(message.failure_code).toBe('invalid_provider_response');
  });

  it('creates a real, re-validated swap_meal action proposal when the user asks for a swap', async () => {
    const userId = await newUser();
    await makeEligible(userId);
    await insertActivePlanForToday(userId);
    const { requestId, assistantId, threadId } = await seedCoachMessage(
      userId,
      'Can you swap my lunch today?',
    );

    const result = await handleCoachReply(job(requestId, userId), pool, ai, log);
    expect(result).toEqual({ status: 'completed' });
    const message = await assistantMessage(assistantId);
    expect(message.content).toMatch(/swap it for/i);

    const proposal = await admin.query(
      `select proposal_type, status, payload, expected_plan_revision from app.action_proposals
         where user_id = $1 and thread_id = $2 and message_id = $3`,
      [userId, threadId, assistantId],
    );
    expect(proposal.rows).toHaveLength(1);
    expect(proposal.rows[0]!.proposal_type).toBe('swap_meal');
    expect(proposal.rows[0]!.status).toBe('pending');
    expect(proposal.rows[0]!.payload.candidate_recipe_id).toBe(TOFU_STIR_FRY);
  });

  it('is idempotent: an already-completed message is never overwritten by a redelivered job', async () => {
    const userId = await newUser();
    await makeEligible(userId);
    const { requestId, assistantId } = await seedCoachMessage(userId, 'Hello coach');
    await handleCoachReply(job(requestId, userId), pool, ai, log);
    const first = await assistantMessage(assistantId);

    const result = await handleCoachReply(job(requestId, userId), pool, ai, log);
    expect(result).toEqual({ status: 'already_terminal' });
    const second = await assistantMessage(assistantId);
    expect(second).toEqual(first);
  });

  it('is a no-op for a request belonging to a different user (never cross-user processing)', async () => {
    const userId = await newUser();
    const otherUserId = await newUser();
    await makeEligible(userId);
    const { requestId } = await seedCoachMessage(userId, 'Hello coach');

    const result = await handleCoachReply(job(requestId, otherUserId), pool, ai, log);
    expect(result).toEqual({ status: 'skipped_missing' });
  });
});
