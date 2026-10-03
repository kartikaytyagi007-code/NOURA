import { randomUUID } from 'node:crypto';
import pg from 'pg';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { createTestApp } from './support/app.js';
import { createTestKeys, signToken, startJwksServer, type TestKeys } from './support/auth.js';
import { expectMatchesContract } from './support/contract.js';

const admin = new pg.Pool({ connectionString: process.env.DATABASE_URL, max: 4 });
let keys: TestKeys;
let jwks: Awaited<ReturnType<typeof startJwksServer>>;
let ctx: Awaited<ReturnType<typeof createTestApp>>;

beforeAll(async () => {
  keys = await createTestKeys();
  jwks = await startJwksServer([keys.jwk]);
  ctx = await createTestApp(jwks.url);
});

afterAll(async () => {
  await ctx.close();
  await jwks.close();
  await admin.end();
});

// Seed recipe ids from supabase/migrations/20261001001000_catalog_test_fixture.sql.
const KHICHDI = '00000000-0000-4000-a002-000000000001'; // vegan, lunch+dinner
const TOFU_STIR_FRY = '00000000-0000-4000-a002-000000000008'; // vegan, lunch+dinner

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type ApiBody = any;

interface Caller {
  id: string;
  token: string;
  call: (
    method: 'GET' | 'PATCH' | 'PUT' | 'POST' | 'DELETE',
    url: string,
    body?: unknown,
    options?: { key?: string | null; token?: string },
  ) => Promise<{ status: number; body: ApiBody }>;
}

function callerFor(id: string, token: string): Caller {
  return {
    id,
    token,
    async call(method, url, body, options = {}) {
      const headers: Record<string, string> = {
        authorization: `Bearer ${options.token ?? token}`,
      };
      if (options.key !== null && method !== 'GET')
        headers['idempotency-key'] = options.key ?? randomUUID();
      const res = await ctx.app.inject({
        method,
        url,
        headers,
        ...(body === undefined ? {} : { payload: body as object }),
      });
      return { status: res.statusCode, body: res.json() };
    },
  };
}

async function newUser(): Promise<Caller> {
  const id = randomUUID();
  await admin.query('insert into auth.users (id, email) values ($1, $2)', [
    id,
    `${id}@test.invalid`,
  ]);
  const token = await signToken(keys, { sub: id });
  return callerFor(id, token);
}

async function newEligibleUser(): Promise<Caller> {
  const u = await newUser();
  await admin.query(
    `insert into app.profiles
       (user_id, display_name, age_years, calculation_sex, height_cm, weight_kg, activity_band,
        timezone, unit_system, onboarding_status, onboarding_step, eligibility_status,
        screening_answered_at, revision)
     values ($1, 'Test User', 30, 'female', 165, 60, 'moderate', 'UTC', 'metric', 'completed', 'review',
             'eligible', now(), 1)`,
    [u.id],
  );
  await admin.query(
    `insert into app.user_preferences
       (user_id, diet_type, allergy_ids, exclusion_ids, dislikes, meals_per_day, revision)
     values ($1, 'vegan', '{}', '{}', '{}', 3, 1)`,
    [u.id],
  );
  await admin.query(
    `insert into app.target_snapshots
       (user_id, profile_revision, policy_version, policy_status, estimated_energy_kcal_min,
        estimated_energy_kcal_max, selected_targets, method, eligibility)
     values ($1, 1, 'test-v0', 'test', 2000, 2000, $2::jsonb, 'policy', 'eligible')`,
    [
      u.id,
      JSON.stringify({
        basis: 'point',
        targets: { energy_kcal: 2000, protein_g: 72, fibre_g: 28, carbohydrate_g: 250, fat_g: 67 },
        warnings: [],
      }),
    ],
  );
  return u;
}

function todayIso(): string {
  return new Date().toISOString().slice(0, 10);
}

/** Plants an active diet plan covering today, with one lunch slot, so coach context has a real meal. */
async function insertActivePlanForToday(
  userId: string,
): Promise<{ planMealId: string; revision: number }> {
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
  const mealRow = await admin.query<{ id: string; revision: number }>(
    `insert into app.diet_plan_meals
       (user_id, plan_id, meal_date, slot, slot_ordinal, recipe_id, portions_snapshot, nutrition_snapshot)
     values ($1, $2, $3, 'lunch', 1, $4, $5::jsonb, $6::jsonb) returning id, revision`,
    [userId, plan.rows[0]!.id, todayIso(), KHICHDI, portions, nutrition],
  );
  return { planMealId: mealRow.rows[0]!.id, revision: mealRow.rows[0]!.revision };
}

async function insertPendingSwapProposal(
  userId: string,
  threadId: string,
  messageId: string,
  planMealId: string,
  revision: number,
  options: { expiresInMinutes?: number; candidateId?: string } = {},
): Promise<string> {
  const row = await admin.query<{ id: string }>(
    `insert into app.action_proposals
       (user_id, thread_id, message_id, proposal_type, payload, expected_plan_revision, expires_at)
     values ($1, $2, $3, 'swap_meal', $4::jsonb, $5, now() + ($6 || ' minutes')::interval)
     returning id`,
    [
      userId,
      threadId,
      messageId,
      JSON.stringify({
        plan_meal_id: planMealId,
        candidate_recipe_id: options.candidateId ?? TOFU_STIR_FRY,
        reason: 'test',
      }),
      revision,
      String(options.expiresInMinutes ?? 15),
    ],
  );
  return row.rows[0]!.id;
}

async function createThreadAndMessage(u: Caller): Promise<{ threadId: string; messageId: string }> {
  const thread = await u.call('POST', '/v1/coach/threads');
  const threadId = thread.body.data.id as string;
  const msgId = await admin.query<{ id: string }>(
    `insert into app.coach_messages (user_id, thread_id, client_id, role, content, status)
       values ($1, $2, gen_random_uuid(), 'assistant', 'placeholder', 'completed') returning id`,
    [u.id, threadId],
  );
  return { threadId, messageId: msgId.rows[0]!.id };
}

describe('coach thread/message authorization', () => {
  it('rejects every coach route without a token', async () => {
    const noAuth = async (method: 'GET' | 'POST' | 'DELETE', url: string) => {
      const res = await ctx.app.inject({ method, url });
      expect(res.statusCode).toBe(401);
    };
    await noAuth('POST', '/v1/coach/threads');
    await noAuth('GET', `/v1/coach/threads/${randomUUID()}/messages`);
    await noAuth('POST', `/v1/coach/threads/${randomUUID()}/messages`);
    await noAuth('DELETE', `/v1/coach/threads/${randomUUID()}`);
    await noAuth('POST', `/v1/action-proposals/${randomUUID()}/apply`);
    await noAuth('POST', `/v1/action-proposals/${randomUUID()}/cancel`);
  });

  it('a user cannot read, message, or delete another user’s thread (404, not leaked)', async () => {
    const owner = await newUser();
    const attacker = await newUser();
    const thread = await owner.call('POST', '/v1/coach/threads');
    expect(thread.status).toBe(201);
    const threadId = thread.body.data.id;

    const list = await attacker.call('GET', `/v1/coach/threads/${threadId}/messages`);
    expect(list.status).toBe(404);

    const send = await attacker.call('POST', `/v1/coach/threads/${threadId}/messages`, {
      client_id: randomUUID(),
      message: 'hi',
    });
    expect(send.status).toBe(404);

    const del = await attacker.call('DELETE', `/v1/coach/threads/${threadId}`);
    expect(del.status).toBe(404);
  });

  it('a user cannot apply or cancel another user’s action proposal (404)', async () => {
    const owner = await newEligibleUser();
    const attacker = await newUser();
    const { planMealId, revision } = await insertActivePlanForToday(owner.id);
    const { threadId, messageId } = await createThreadAndMessage(owner);
    const proposalId = await insertPendingSwapProposal(
      owner.id,
      threadId,
      messageId,
      planMealId,
      revision,
    );

    const apply = await attacker.call('POST', `/v1/action-proposals/${proposalId}/apply`, {
      expected_revision: revision,
    });
    expect(apply.status).toBe(404);
    const cancel = await attacker.call('POST', `/v1/action-proposals/${proposalId}/cancel`);
    expect(cancel.status).toBe(404);
  });
});

describe('POST /v1/coach/threads', () => {
  it('creates an owned thread', async () => {
    const u = await newUser();
    const res = await u.call('POST', '/v1/coach/threads');
    expect(res.status).toBe(201);
    expectMatchesContract('createCoachThread', 201, res.body);
  });
});

describe('POST /v1/coach/threads/{id}/messages', () => {
  it('accepts a message and creates a pending assistant placeholder (202)', async () => {
    const u = await newUser();
    const thread = await u.call('POST', '/v1/coach/threads');
    const res = await u.call('POST', `/v1/coach/threads/${thread.body.data.id}/messages`, {
      client_id: randomUUID(),
      message: 'What should I eat next?',
    });
    expect(res.status).toBe(202);
    expectMatchesContract('sendCoachMessage', 202, res.body);
    expect(res.body.data.message.status).toBe('pending');
    expect(res.body.data.message.role).toBe('assistant');
  });

  it('is idempotent on client_id even across different Idempotency-Key headers (e.g. a dropped response)', async () => {
    const u = await newUser();
    const thread = await u.call('POST', '/v1/coach/threads');
    const clientId = randomUUID();
    const first = await u.call(
      'POST',
      `/v1/coach/threads/${thread.body.data.id}/messages`,
      { client_id: clientId, message: 'hello' },
      { key: randomUUID() },
    );
    const second = await u.call(
      'POST',
      `/v1/coach/threads/${thread.body.data.id}/messages`,
      { client_id: clientId, message: 'hello' },
      { key: randomUUID() },
    );
    expect(second.status).toBe(first.status);
    expect(second.body.data.job_id).toBe(first.body.data.job_id);
    expect(second.body.data.message.id).toBe(first.body.data.message.id);

    // And only one user message/request was ever created for this client_id.
    const count = await admin.query<{ count: string }>(
      'select count(*) from app.coach_messages where user_id = $1 and client_id = $2',
      [u.id, clientId],
    );
    expect(Number(count.rows[0]!.count)).toBe(1);
  });

  it('enforces the daily coach-reply quota (429 once exceeded)', async () => {
    const u = await newUser();
    const thread = await u.call('POST', '/v1/coach/threads');
    let last;
    for (let i = 0; i < 6; i++) {
      last = await u.call('POST', `/v1/coach/threads/${thread.body.data.id}/messages`, {
        client_id: randomUUID(),
        message: `message ${i}`,
      });
    }
    expect(last!.status).toBe(429);
  });

  it('rejects an empty message (422)', async () => {
    const u = await newUser();
    const thread = await u.call('POST', '/v1/coach/threads');
    const res = await u.call('POST', `/v1/coach/threads/${thread.body.data.id}/messages`, {
      client_id: randomUUID(),
      message: '',
    });
    expect(res.status).toBe(422);
  });
});

describe('GET /v1/coach/threads/{id}/messages', () => {
  it('lists messages oldest-first, including cards/action_proposal shape', async () => {
    const u = await newUser();
    const thread = await u.call('POST', '/v1/coach/threads');
    await u.call('POST', `/v1/coach/threads/${thread.body.data.id}/messages`, {
      client_id: randomUUID(),
      message: 'first',
    });
    const res = await u.call('GET', `/v1/coach/threads/${thread.body.data.id}/messages`);
    expect(res.status).toBe(200);
    expectMatchesContract('listCoachMessages', 200, res.body);
    expect(res.body.data.items.length).toBeGreaterThanOrEqual(2); // user + pending assistant
    expect(res.body.data.items[0].role).toBe('user');
  });
});

describe('DELETE /v1/coach/threads/{id}', () => {
  it('deletes an owned thread and its messages (cascade)', async () => {
    const u = await newUser();
    const thread = await u.call('POST', '/v1/coach/threads');
    await u.call('POST', `/v1/coach/threads/${thread.body.data.id}/messages`, {
      client_id: randomUUID(),
      message: 'hello',
    });
    const del = await u.call('DELETE', `/v1/coach/threads/${thread.body.data.id}`);
    expect(del.status).toBe(200);
    expect(del.body.data).toEqual({ id: thread.body.data.id, deleted: true });

    const after = await u.call('GET', `/v1/coach/threads/${thread.body.data.id}/messages`);
    expect(after.status).toBe(404);

    const { rows } = await admin.query('select 1 from app.coach_messages where thread_id = $1', [
      thread.body.data.id,
    ]);
    expect(rows.length).toBe(0);
  });

  it('returns 404 for a thread that does not exist', async () => {
    const u = await newUser();
    const res = await u.call('DELETE', `/v1/coach/threads/${randomUUID()}`);
    expect(res.status).toBe(404);
  });
});

describe('POST /v1/action-proposals/{id}/apply', () => {
  it('applies a pending swap_meal proposal exactly once, via the same replacePlanMeal as the swap UI', async () => {
    const u = await newEligibleUser();
    const { planMealId, revision } = await insertActivePlanForToday(u.id);
    const { threadId, messageId } = await createThreadAndMessage(u);
    const proposalId = await insertPendingSwapProposal(
      u.id,
      threadId,
      messageId,
      planMealId,
      revision,
    );

    const apply = await u.call('POST', `/v1/action-proposals/${proposalId}/apply`, {
      expected_revision: revision,
    });
    expect(apply.status).toBe(200);
    expectMatchesContract('applyActionProposal', 200, apply.body);
    expect(apply.body.data.status).toBe('applied');
    expect(apply.body.data.applied_at).not.toBeNull();

    const mealRow = await admin.query<{ recipe_id: string; revision: number }>(
      'select recipe_id, revision from app.diet_plan_meals where id = $1',
      [planMealId],
    );
    expect(mealRow.rows[0]!.recipe_id).toBe(TOFU_STIR_FRY);
    expect(mealRow.rows[0]!.revision).toBe(revision + 1);

    // Applying again fails: it is no longer pending (apply-once).
    const second = await u.call('POST', `/v1/action-proposals/${proposalId}/apply`, {
      expected_revision: revision,
    });
    expect(second.status).toBe(422);
  });

  it('rejects an expired proposal (422)', async () => {
    const u = await newEligibleUser();
    const { planMealId, revision } = await insertActivePlanForToday(u.id);
    const { threadId, messageId } = await createThreadAndMessage(u);
    const proposalId = await insertPendingSwapProposal(
      u.id,
      threadId,
      messageId,
      planMealId,
      revision,
      {
        expiresInMinutes: -1,
      },
    );
    const apply = await u.call('POST', `/v1/action-proposals/${proposalId}/apply`, {
      expected_revision: revision,
    });
    expect(apply.status).toBe(422);
  });

  it('rejects a stale expected_revision (409)', async () => {
    const u = await newEligibleUser();
    const { planMealId, revision } = await insertActivePlanForToday(u.id);
    const { threadId, messageId } = await createThreadAndMessage(u);
    const proposalId = await insertPendingSwapProposal(
      u.id,
      threadId,
      messageId,
      planMealId,
      revision,
    );
    const apply = await u.call('POST', `/v1/action-proposals/${proposalId}/apply`, {
      expected_revision: revision + 5,
    });
    expect(apply.status).toBe(409);
  });

  it('returns 404 for a nonexistent proposal', async () => {
    const u = await newUser();
    const res = await u.call('POST', `/v1/action-proposals/${randomUUID()}/apply`, {
      expected_revision: 1,
    });
    expect(res.status).toBe(404);
  });
});

describe('POST /v1/action-proposals/{id}/cancel', () => {
  it('cancels a pending proposal', async () => {
    const u = await newEligibleUser();
    const { planMealId, revision } = await insertActivePlanForToday(u.id);
    const { threadId, messageId } = await createThreadAndMessage(u);
    const proposalId = await insertPendingSwapProposal(
      u.id,
      threadId,
      messageId,
      planMealId,
      revision,
    );

    const cancel = await u.call('POST', `/v1/action-proposals/${proposalId}/cancel`);
    expect(cancel.status).toBe(200);
    expectMatchesContract('cancelActionProposal', 200, cancel.body);
    expect(cancel.body.data.status).toBe('cancelled');

    // A cancelled proposal can never be applied.
    const apply = await u.call('POST', `/v1/action-proposals/${proposalId}/apply`, {
      expected_revision: revision,
    });
    expect(apply.status).toBe(422);
  });
});
