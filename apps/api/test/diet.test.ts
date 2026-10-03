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
const CHICKEN_BOWL = '00000000-0000-4000-a002-000000000004'; // non_vegetarian, lunch+dinner
const PORRIDGE = '00000000-0000-4000-a002-000000000010'; // vegan, breakfast

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type ApiBody = any;

interface Caller {
  id: string;
  call: (
    method: 'GET' | 'PATCH' | 'PUT' | 'POST',
    url: string,
    body?: unknown,
    options?: { key?: string | null },
  ) => Promise<{ status: number; body: ApiBody }>;
}

function callerFor(id: string, token: string): Caller {
  return {
    id,
    async call(method, url, body, options = {}) {
      const headers: Record<string, string> = { authorization: `Bearer ${token}` };
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

/** Seeds a profile, preferences and a "point" target snapshot directly, bypassing onboarding. */
async function newEligibleUser(
  overrides: {
    diet_type?: string | null;
    allergy_ids?: string[];
    exclusion_ids?: string[];
    dislikes?: string[];
    meals_per_day?: number;
    profileRevision?: number;
  } = {},
): Promise<Caller> {
  const id = randomUUID();
  await admin.query('insert into auth.users (id, email) values ($1, $2)', [
    id,
    `${id}@test.invalid`,
  ]);
  const revision = overrides.profileRevision ?? 3;
  await admin.query(
    `insert into app.profiles
       (user_id, display_name, age_years, calculation_sex, height_cm, weight_kg, activity_band,
        timezone, unit_system, onboarding_status, onboarding_step, eligibility_status,
        screening_answered_at, revision)
     values ($1, 'Test User', 30, 'female', 165, 60, 'moderate', 'UTC', 'metric', 'completed', 'review',
             'eligible', now(), $2)`,
    [id, revision],
  );
  await admin.query(
    `insert into app.user_preferences
       (user_id, diet_type, allergy_ids, exclusion_ids, dislikes, meals_per_day, revision)
     values ($1, $2, $3, $4, $5, $6, 1)`,
    [
      id,
      overrides.diet_type ?? 'vegan',
      overrides.allergy_ids ?? [],
      overrides.exclusion_ids ?? [],
      overrides.dislikes ?? [],
      overrides.meals_per_day ?? 3,
    ],
  );
  await admin.query(
    `insert into app.target_snapshots
       (user_id, profile_revision, policy_version, policy_status, estimated_energy_kcal_min,
        estimated_energy_kcal_max, selected_targets, method, eligibility)
     values ($1, $2, 'test-v0', 'test', 2000, 2000, $3::jsonb, 'policy', 'eligible')`,
    [
      id,
      revision,
      JSON.stringify({
        basis: 'point',
        targets: { energy_kcal: 2000, protein_g: 72, fibre_g: 28, carbohydrate_g: 250, fat_g: 67 },
        warnings: [],
      }),
    ],
  );
  const token = await signToken(keys, { sub: id });
  return callerFor(id, token);
}

async function insertActivePlan(
  userId: string,
  options: { version?: number; startsOn?: string } = {},
): Promise<{ planId: string; startsOn: string }> {
  const startsOn = options.startsOn ?? '2026-10-05';
  const snapshot = await admin.query<{ id: string }>(
    'select id from app.target_snapshots where user_id = $1 and valid_to is null',
    [userId],
  );
  const plan = await admin.query<{ id: string }>(
    `insert into app.diet_plans (user_id, version, profile_revision, target_snapshot_id, starts_on, status)
     values ($1, $2, 1, $3, $4, 'active') returning id`,
    [userId, options.version ?? 1, snapshot.rows[0]!.id, startsOn],
  );
  const planId = plan.rows[0]!.id;
  const nutrition = (recipeKcal: number) =>
    JSON.stringify({
      nutrients: {
        energy_kcal: recipeKcal,
        protein_g: 10,
        carbohydrate_g: 40,
        fat_g: 10,
        fibre_g: 5,
      },
      coverage: { items_total: 2, items_with_nutrition: 2, complete: true },
    });
  const portions = (recipeId: string) =>
    JSON.stringify({
      grams_scale: 1,
      portions: [
        { food_id: null, recipe_id: recipeId, label: 'meal', grams_min: 300, grams_max: 300 },
      ],
    });

  for (const [slot, recipeId, kcal] of [
    ['breakfast', PORRIDGE, 320],
    ['lunch', KHICHDI, 450],
    ['dinner', KHICHDI, 450],
  ] as const) {
    await admin.query(
      `insert into app.diet_plan_meals
         (user_id, plan_id, meal_date, slot, slot_ordinal, recipe_id, portions_snapshot, nutrition_snapshot)
       values ($1, $2, $3, $4, 1, $5, $6::jsonb, $7::jsonb)`,
      [userId, planId, startsOn, slot, recipeId, portions(recipeId), nutrition(kcal)],
    );
  }
  return { planId, startsOn };
}

describe('POST /v1/diet-plans/generate', () => {
  it('accepts a request and records a durable generation_requests row (first for this user => diet_plan)', async () => {
    const u = await newEligibleUser();
    const res = await u.call('POST', '/v1/diet-plans/generate', {
      start_date: '2026-10-05',
      profile_revision: 3,
    });
    expect(res.status).toBe(202);
    expectMatchesContract('generateDietPlan', 202, res.body);
    const row = await admin.query(
      'select request_type, status from app.generation_requests where id = $1',
      [res.body.data.job_id],
    );
    expect(row.rows[0]).toMatchObject({ request_type: 'diet_plan', status: 'queued' });
  });

  it('is idempotent: a replay with the same key and body returns the same job and writes nothing new', async () => {
    const u = await newEligibleUser();
    const key = randomUUID();
    const body = { start_date: '2026-10-05', profile_revision: 3 };
    const first = await u.call('POST', '/v1/diet-plans/generate', body, { key });
    const second = await u.call('POST', '/v1/diet-plans/generate', body, { key });
    expect(second.body.data.job_id).toBe(first.body.data.job_id);
    const count = await admin.query(
      'select count(*)::int as n from app.generation_requests where user_id = $1',
      [u.id],
    );
    expect(count.rows[0]!.n).toBe(1);
  });

  it('conflicts on a stale profile revision', async () => {
    const u = await newEligibleUser({ profileRevision: 5 });
    const res = await u.call('POST', '/v1/diet-plans/generate', {
      start_date: '2026-10-05',
      profile_revision: 1,
    });
    expect(res.status).toBe(409);
  });

  it('requests a regeneration once the user already has an active plan', async () => {
    const u = await newEligibleUser();
    await insertActivePlan(u.id);
    const res = await u.call('POST', '/v1/diet-plans/generate', {
      start_date: '2026-10-05',
      profile_revision: 3,
    });
    expect(res.status).toBe(202);
    const row = await admin.query(
      'select request_type from app.generation_requests where id = $1',
      [res.body.data.job_id],
    );
    expect(row.rows[0]!.request_type).toBe('plan_regeneration');
  });

  it('refuses to request a plan for a tracking-only (not eligible) account', async () => {
    const u = await newEligibleUser();
    await admin.query(
      "update app.profiles set eligibility_status = 'tracking_only' where user_id = $1",
      [u.id],
    );
    const res = await u.call('POST', '/v1/diet-plans/generate', {
      start_date: '2026-10-05',
      profile_revision: 3,
    });
    expect(res.status).toBe(422);
  });

  it('requires authentication', async () => {
    const res = await ctx.app.inject({
      method: 'POST',
      url: '/v1/diet-plans/generate',
      payload: { start_date: '2026-10-05', profile_revision: 1 },
    });
    expect(res.statusCode).toBe(401);
  });
});

describe('GET /v1/diet-plans/current', () => {
  it('returns the active plan with days, meals and totals that reconcile exactly', async () => {
    const u = await newEligibleUser();
    const { startsOn } = await insertActivePlan(u.id);
    const res = await u.call('GET', '/v1/diet-plans/current');
    expect(res.status).toBe(200);
    expectMatchesContract('getCurrentDietPlan', 200, res.body);
    const day = res.body.data.days.find((d: ApiBody) => d.date === startsOn);
    expect(day.meals).toHaveLength(3);
    const expectedEnergy = day.meals.reduce(
      (s: number, m: ApiBody) => s + m.nutrition.nutrients.energy_kcal,
      0,
    );
    expect(day.totals.nutrients.energy_kcal).toBe(expectedEnergy);
  });

  it('404s when there is no active plan', async () => {
    const u = await newEligibleUser();
    const res = await u.call('GET', '/v1/diet-plans/current');
    expect(res.status).toBe(404);
  });
});

describe('POST /v1/diet-plan-meals/{id}/swap-options', () => {
  it('offers eligible candidates for the same slot with a recomputed daily preview', async () => {
    const u = await newEligibleUser();
    await insertActivePlan(u.id);
    const meal = await admin.query(
      "select id, revision from app.diet_plan_meals where user_id = $1 and slot = 'lunch'",
      [u.id],
    );
    const res = await u.call('POST', `/v1/diet-plan-meals/${meal.rows[0]!.id}/swap-options`, {
      expected_revision: meal.rows[0]!.revision,
    });
    expect(res.status).toBe(200);
    expectMatchesContract('getSwapOptions', 200, res.body);
    expect(res.body.data.candidates.length).toBeGreaterThan(0);
    for (const c of res.body.data.candidates) expect(c.candidate_id).not.toBe(KHICHDI);
  });

  it('never offers a candidate unsafe for the user (diet-type filtering)', async () => {
    const u = await newEligibleUser({ diet_type: 'vegan' });
    await insertActivePlan(u.id);
    const meal = await admin.query(
      "select id, revision from app.diet_plan_meals where user_id = $1 and slot = 'lunch'",
      [u.id],
    );
    const res = await u.call('POST', `/v1/diet-plan-meals/${meal.rows[0]!.id}/swap-options`, {
      expected_revision: meal.rows[0]!.revision,
    });
    expect(res.body.data.candidates.map((c: ApiBody) => c.candidate_id)).not.toContain(
      CHICKEN_BOWL,
    );
  });

  it('conflicts on a stale revision', async () => {
    const u = await newEligibleUser();
    await insertActivePlan(u.id);
    const meal = await admin.query(
      "select id from app.diet_plan_meals where user_id = $1 and slot = 'lunch'",
      [u.id],
    );
    const res = await u.call('POST', `/v1/diet-plan-meals/${meal.rows[0]!.id}/swap-options`, {
      expected_revision: 99,
    });
    expect(res.status).toBe(409);
  });
});

describe('PUT /v1/diet-plan-meals/{id}', () => {
  it('replaces the slot, increments the revision, and is idempotent', async () => {
    const u = await newEligibleUser();
    await insertActivePlan(u.id);
    const meal = await admin.query(
      "select id, revision from app.diet_plan_meals where user_id = $1 and slot = 'dinner'",
      [u.id],
    );
    const options = await u.call('POST', `/v1/diet-plan-meals/${meal.rows[0]!.id}/swap-options`, {
      expected_revision: meal.rows[0]!.revision,
    });
    const candidateId = options.body.data.candidates[0].candidate_id;
    const key = randomUUID();
    const body = { expected_revision: meal.rows[0]!.revision, candidate_id: candidateId };
    const first = await u.call('PUT', `/v1/diet-plan-meals/${meal.rows[0]!.id}`, body, { key });
    expect(first.status).toBe(200);
    expectMatchesContract('replacePlanMeal', 200, first.body);
    expect(first.body.data.recipe.id).toBe(candidateId);
    expect(first.body.data.revision).toBe(meal.rows[0]!.revision + 1);

    const replay = await u.call('PUT', `/v1/diet-plan-meals/${meal.rows[0]!.id}`, body, { key });
    expect(replay.body.data.revision).toBe(first.body.data.revision);
    const count = await admin.query('select revision from app.diet_plan_meals where id = $1', [
      meal.rows[0]!.id,
    ]);
    expect(count.rows[0]!.revision).toBe(meal.rows[0]!.revision + 1);
  });

  it('rejects a candidate that is not an eligible option for that slot', async () => {
    const u = await newEligibleUser({ diet_type: 'vegan' });
    await insertActivePlan(u.id);
    const meal = await admin.query(
      "select id, revision from app.diet_plan_meals where user_id = $1 and slot = 'lunch'",
      [u.id],
    );
    const res = await u.call('PUT', `/v1/diet-plan-meals/${meal.rows[0]!.id}`, {
      expected_revision: meal.rows[0]!.revision,
      candidate_id: CHICKEN_BOWL,
    });
    expect(res.status).toBe(422);
  });

  it('conflicts on a stale revision', async () => {
    const u = await newEligibleUser();
    await insertActivePlan(u.id);
    const meal = await admin.query(
      "select id from app.diet_plan_meals where user_id = $1 and slot = 'lunch'",
      [u.id],
    );
    const res = await u.call('PUT', `/v1/diet-plan-meals/${meal.rows[0]!.id}`, {
      expected_revision: 99,
      candidate_id: KHICHDI,
    });
    expect(res.status).toBe(409);
  });
});
