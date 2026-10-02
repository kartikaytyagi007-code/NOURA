import { randomUUID } from 'node:crypto';
import pg from 'pg';
import { afterAll, afterEach, beforeAll, describe, expect, it, vi } from 'vitest';
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

afterEach(() => {
  vi.useRealTimers();
});

// Seed recipe ids from supabase/migrations/20261001001000_catalog_test_fixture.sql.
const KHICHDI = '00000000-0000-4000-a002-000000000001'; // vegan, lunch+dinner
const PANEER_BOWL = '00000000-0000-4000-a002-000000000002'; // vegetarian, lunch+dinner
const CHICKEN_BOWL = '00000000-0000-4000-a002-000000000004'; // non_vegetarian, lunch+dinner
const PORRIDGE = '00000000-0000-4000-a002-000000000010'; // vegan, breakfast
const FRUIT_SALAD = '00000000-0000-4000-a002-000000000016'; // vegan, snack

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type ApiBody = any;

interface Caller {
  id: string;
  call: (
    method: 'GET' | 'PATCH' | 'PUT' | 'POST' | 'DELETE',
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

async function newEligibleUser(
  overrides: {
    diet_type?: string | null;
    allergy_ids?: string[];
    timezone?: string;
  } = {},
): Promise<Caller> {
  const id = randomUUID();
  await admin.query('insert into auth.users (id, email) values ($1, $2)', [
    id,
    `${id}@test.invalid`,
  ]);
  await admin.query(
    `insert into app.profiles
       (user_id, display_name, age_years, calculation_sex, height_cm, weight_kg, activity_band,
        timezone, unit_system, onboarding_status, onboarding_step, eligibility_status,
        screening_answered_at, revision)
     values ($1, 'Test User', 30, 'female', 165, 60, 'moderate', $2, 'metric', 'completed', 'review',
             'eligible', now(), 3)`,
    [id, overrides.timezone ?? 'UTC'],
  );
  await admin.query(
    `insert into app.user_preferences
       (user_id, diet_type, allergy_ids, exclusion_ids, dislikes, meals_per_day, revision)
     values ($1, $2, $3, '{}', '{}', 3, 1)`,
    [id, overrides.diet_type ?? 'vegan', overrides.allergy_ids ?? []],
  );
  await admin.query(
    `insert into app.target_snapshots
       (user_id, profile_revision, policy_version, policy_status, estimated_energy_kcal_min,
        estimated_energy_kcal_max, selected_targets, method, eligibility)
     values ($1, 3, 'test-v0', 'test', 2000, 2000, $2::jsonb, 'policy', 'eligible')`,
    [
      id,
      JSON.stringify({
        basis: 'point',
        targets: { energy_kcal: 2000, protein_g: 100, fibre_g: 30, carbohydrate_g: 250, fat_g: 67 },
        warnings: [],
      }),
    ],
  );
  const token = await signToken(keys, { sub: id });
  return callerFor(id, token);
}

async function insertActivePlan(
  userId: string,
  startsOn: string,
  meals: readonly { slot: string; recipeId: string }[] = [
    { slot: 'breakfast', recipeId: PORRIDGE },
    { slot: 'lunch', recipeId: KHICHDI },
    { slot: 'dinner', recipeId: KHICHDI },
  ],
): Promise<string> {
  const snapshot = await admin.query<{ id: string }>(
    'select id from app.target_snapshots where user_id = $1 and valid_to is null',
    [userId],
  );
  const plan = await admin.query<{ id: string }>(
    `insert into app.diet_plans (user_id, version, profile_revision, target_snapshot_id, starts_on, status)
     values ($1, 1, 3, $2, $3, 'active') returning id`,
    [userId, snapshot.rows[0]!.id, startsOn],
  );
  const planId = plan.rows[0]!.id;
  const nutrition = JSON.stringify({
    nutrients: { energy_kcal: 400, protein_g: 15, carbohydrate_g: 50, fat_g: 10, fibre_g: 5 },
    coverage: { items_total: 2, items_with_nutrition: 2, complete: true },
  });
  for (const { slot, recipeId } of meals) {
    const portions = JSON.stringify({
      grams_scale: 1,
      portions: [
        { food_id: null, recipe_id: recipeId, label: 'meal', grams_min: 300, grams_max: 300 },
      ],
    });
    await admin.query(
      `insert into app.diet_plan_meals
         (user_id, plan_id, meal_date, slot, slot_ordinal, recipe_id, portions_snapshot, nutrition_snapshot)
       values ($1, $2, $3, $4, 1, $5, $6::jsonb, $7::jsonb)`,
      [userId, planId, startsOn, slot, recipeId, portions, nutrition],
    );
  }
  return planId;
}

async function insertMealLog(
  userId: string,
  localDate: string,
  slot: string,
  options: { complete?: boolean; proteinG?: number; fibreG?: number } = {},
): Promise<string> {
  const complete = options.complete ?? true;
  const totals = complete
    ? {
        nutrients: {
          energy_kcal: 400,
          protein_g: options.proteinG ?? 20,
          carbohydrate_g: 40,
          fat_g: 10,
          fibre_g: options.fibreG ?? 5,
        },
        coverage: { items_total: 1, items_with_nutrition: 1, complete: true },
      }
    : {
        nutrients: {
          energy_kcal: null,
          protein_g: null,
          carbohydrate_g: null,
          fat_g: null,
          fibre_g: null,
        },
        coverage: { items_total: 1, items_with_nutrition: 0, complete: false },
      };
  const row = await admin.query<{ id: string }>(
    `insert into app.meal_logs (user_id, client_id, consumed_at, local_date, timezone, slot, totals_snapshot)
     values ($1, gen_random_uuid(), $2::date + time '12:00', $2, 'UTC', $3, $4::jsonb)
     returning id`,
    [userId, localDate, slot, JSON.stringify(totals)],
  );
  return row.rows[0]!.id;
}

describe('GET /v1/recommendations/next-meal', () => {
  it('recommends the next unlogged plan slot, grounded in the active plan', async () => {
    const u = await newEligibleUser();
    await insertActivePlan(u.id, '2026-10-05');
    const res = await u.call('GET', '/v1/recommendations/next-meal?date=2026-10-05&slot=lunch');
    expect(res.status).toBe(200);
    expectMatchesContract('getNextMeal', 200, res.body);
    expect(res.body.data.options[0].source).toBe('plan');
    expect(res.body.data.options[0].recipe.id).toBe(KHICHDI);
    expect(res.body.data.options[0].reason).toMatch(/next unlogged slot in your plan/);
  });

  it('falls back to a catalog option when there is no active plan', async () => {
    const u = await newEligibleUser();
    const res = await u.call('GET', '/v1/recommendations/next-meal?date=2026-10-05&slot=lunch');
    expect(res.status).toBe(200);
    expect(res.body.data.options[0].source).toBe('catalog');
  });

  it('never suggests an allergen/diet-incompatible food (vegan constraint excludes chicken)', async () => {
    const u = await newEligibleUser({ diet_type: 'vegan' });
    const res = await u.call('GET', '/v1/recommendations/next-meal?date=2026-10-05&slot=lunch');
    expect(res.status).toBe(200);
    const ids = res.body.data.options.map((o: ApiBody) => o.candidate_id);
    expect(ids).not.toContain(CHICKEN_BOWL);
    expect(ids).not.toContain(PANEER_BOWL);
  });

  it('flags limited_context and withholds a gap-based reason when nothing is logged yet', async () => {
    const u = await newEligibleUser();
    const res = await u.call('GET', '/v1/recommendations/next-meal?date=2026-10-05&slot=lunch');
    expect(res.body.data.limited_context).toBe(true);
    expect(res.body.data.logged_meals).toBe(0);
    expect(res.body.data.options[0].reason).not.toMatch(/low on/);
  });

  it('reports already-logged for a requested slot that was already logged, rather than re-suggesting it', async () => {
    const u = await newEligibleUser();
    await insertMealLog(u.id, '2026-10-05', 'breakfast');
    const res = await u.call('GET', '/v1/recommendations/next-meal?date=2026-10-05&slot=breakfast');
    expect(res.body.data.options).toEqual([]);
    expect(res.body.data.explanation).toMatch(/already logged/);
  });

  it('requires authentication', async () => {
    const res = await ctx.app.inject({
      method: 'GET',
      url: '/v1/recommendations/next-meal?date=2026-10-05',
    });
    expect(res.statusCode).toBe(401);
  });
});

describe('POST /v1/recommendations/next-meal/actions', () => {
  it('add: creates a new plan slot for a date/slot the plan does not yet cover', async () => {
    const u = await newEligibleUser();
    await insertActivePlan(u.id, '2026-10-05'); // no snack slot planned
    const res = await u.call('POST', '/v1/recommendations/next-meal/actions', {
      date: '2026-10-05',
      slot: 'snack',
      action: 'add',
      candidate_id: FRUIT_SALAD,
    });
    expect(res.status).toBe(200);
    expectMatchesContract('nextMealAction', 200, res.body);
    expect(res.body.data.plan_meal.slot).toBe('snack');
    expect(res.body.data.plan_meal.recipe.id).toBe(FRUIT_SALAD);

    const row = await admin.query(
      "select count(*)::int as n from app.diet_plan_meals where user_id = $1 and slot = 'snack'",
      [u.id],
    );
    expect(row.rows[0]!.n).toBe(1);
  });

  it('add: refuses without an active diet plan', async () => {
    const u = await newEligibleUser();
    const res = await u.call('POST', '/v1/recommendations/next-meal/actions', {
      date: '2026-10-05',
      slot: 'snack',
      action: 'add',
      candidate_id: FRUIT_SALAD,
    });
    expect(res.status).toBe(422);
  });

  it('add: rejects a candidate outside diet/allergy constraints', async () => {
    const u = await newEligibleUser({ diet_type: 'vegan' });
    await insertActivePlan(u.id, '2026-10-05');
    const res = await u.call('POST', '/v1/recommendations/next-meal/actions', {
      date: '2026-10-05',
      slot: 'snack',
      action: 'add',
      candidate_id: CHICKEN_BOWL,
    });
    expect(res.status).toBe(422);
  });

  it('swap: delegates to the same replacePlanMeal logic the diet-plan screen uses', async () => {
    const u = await newEligibleUser({ diet_type: 'non_vegetarian' });
    await insertActivePlan(u.id, '2026-10-05');
    const current = await admin.query<{ id: string; revision: number }>(
      "select id, revision from app.diet_plan_meals where user_id = $1 and slot = 'lunch'",
      [u.id],
    );
    const res = await u.call('POST', '/v1/recommendations/next-meal/actions', {
      date: '2026-10-05',
      slot: 'lunch',
      action: 'swap',
      candidate_id: CHICKEN_BOWL,
      target_plan_meal_id: current.rows[0]!.id,
      expected_revision: current.rows[0]!.revision,
    });
    expect(res.status).toBe(200);
    expect(res.body.data.plan_meal.recipe.id).toBe(CHICKEN_BOWL);
  });

  it('swap: 409s on a stale expected_revision', async () => {
    const u = await newEligibleUser({ diet_type: 'non_vegetarian' });
    await insertActivePlan(u.id, '2026-10-05');
    const current = await admin.query<{ id: string }>(
      "select id from app.diet_plan_meals where user_id = $1 and slot = 'lunch'",
      [u.id],
    );
    const res = await u.call('POST', '/v1/recommendations/next-meal/actions', {
      date: '2026-10-05',
      slot: 'lunch',
      action: 'swap',
      candidate_id: CHICKEN_BOWL,
      target_plan_meal_id: current.rows[0]!.id,
      expected_revision: 999,
    });
    expect(res.status).toBe(409);
  });

  it("swap: 404s on another user's plan meal", async () => {
    const owner = await newEligibleUser({ diet_type: 'non_vegetarian' });
    const attacker = await newEligibleUser({ diet_type: 'non_vegetarian' });
    await insertActivePlan(owner.id, '2026-10-05');
    const current = await admin.query<{ id: string; revision: number }>(
      "select id, revision from app.diet_plan_meals where user_id = $1 and slot = 'lunch'",
      [owner.id],
    );
    const res = await attacker.call('POST', '/v1/recommendations/next-meal/actions', {
      date: '2026-10-05',
      slot: 'lunch',
      action: 'swap',
      candidate_id: CHICKEN_BOWL,
      target_plan_meal_id: current.rows[0]!.id,
      expected_revision: current.rows[0]!.revision,
    });
    expect(res.status).toBe(404);
  });

  it('dismiss: is sticky, and a later GET honestly reports the dismissal', async () => {
    const u = await newEligibleUser();
    const res = await u.call('POST', '/v1/recommendations/next-meal/actions', {
      date: '2026-10-05',
      slot: 'lunch',
      action: 'dismiss',
    });
    expect(res.status).toBe(200);
    expect(res.body.data.dismissed).toBe(true);

    const followUp = await u.call(
      'GET',
      '/v1/recommendations/next-meal?date=2026-10-05&slot=lunch',
    );
    expect(followUp.body.data.options).toEqual([]);
    expect(followUp.body.data.explanation).toMatch(/dismissed/);
  });

  it('is idempotent: identical Idempotency-Key + body replays the same result and writes nothing twice', async () => {
    const u = await newEligibleUser();
    await insertActivePlan(u.id, '2026-10-05');
    const key = randomUUID();
    const body = { date: '2026-10-05', slot: 'snack', action: 'add', candidate_id: FRUIT_SALAD };
    const first = await u.call('POST', '/v1/recommendations/next-meal/actions', body, { key });
    const second = await u.call('POST', '/v1/recommendations/next-meal/actions', body, { key });
    expect(second.body.data.plan_meal.id).toBe(first.body.data.plan_meal.id);
    const row = await admin.query(
      "select count(*)::int as n from app.diet_plan_meals where user_id = $1 and slot = 'snack'",
      [u.id],
    );
    expect(row.rows[0]!.n).toBe(1);
  });

  it('requires authentication', async () => {
    const res = await ctx.app.inject({
      method: 'POST',
      url: '/v1/recommendations/next-meal/actions',
      payload: { date: '2026-10-05', slot: 'lunch', action: 'dismiss' },
    });
    expect(res.statusCode).toBe(401);
  });
});

describe('GET /v1/home', () => {
  it('wires next_meal and nutrition from real plan/log data', async () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date('2026-10-05T12:00:00Z'));
    const u = await newEligibleUser();
    await insertActivePlan(u.id, '2026-10-05');
    const res = await u.call('GET', '/v1/home?date=2026-10-05');
    expect(res.status).toBe(200);
    expectMatchesContract('getHome', 200, res.body);
    expect(res.body.data.next_meal.slot).toBe('breakfast');
    expect(res.body.data.nutrition.coverage.complete).toBe(false); // nothing logged yet today
  });

  it('requires authentication', async () => {
    const res = await ctx.app.inject({ method: 'GET', url: '/v1/home' });
    expect(res.statusCode).toBe(401);
  });
});

describe('GET /v1/insights', () => {
  it('averages only over usable days and names excluded ones, never counting a missing day as zero', async () => {
    const u = await newEligibleUser();
    vi.useFakeTimers();
    vi.setSystemTime(new Date('2026-10-02T12:00:00Z'));
    // Window is 2026-09-26..2026-10-02. Seed 5 complete days, leave 2 with nothing logged.
    for (const date of ['2026-09-26', '2026-09-27', '2026-09-30', '2026-10-01', '2026-10-02']) {
      await insertMealLog(u.id, date, 'lunch', { proteinG: 90, fibreG: 28 });
    }
    const res = await u.call('GET', '/v1/insights?period=7d');
    expect(res.status).toBe(200);
    expectMatchesContract('getInsights', 200, res.body);
    expect(res.body.data.usable_days).toBe(5);
    expect(res.body.data.excluded_days).toEqual(['2026-09-28', '2026-09-29']);
    expect(res.body.data.coverage_uncertain).toBe(true);
  });

  it('never claims a protein/fibre gap for a day with incomplete coverage', async () => {
    const u = await newEligibleUser();
    vi.useFakeTimers();
    vi.setSystemTime(new Date('2026-10-02T12:00:00Z'));
    for (const date of [
      '2026-09-26',
      '2026-09-27',
      '2026-09-28',
      '2026-09-29',
      '2026-09-30',
      '2026-10-01',
    ]) {
      await insertMealLog(u.id, date, 'lunch', { proteinG: 10, fibreG: 5 }); // well below target
    }
    // The 7th day has a logged meal but incomplete nutrition — must not be treated as a zero.
    await insertMealLog(u.id, '2026-10-02', 'lunch', { complete: false });
    const res = await u.call('GET', '/v1/insights?period=7d');
    expect(res.body.data.usable_days).toBe(6);
    expect(res.body.data.excluded_days).toEqual(['2026-10-02']);
    // A gap IS expected here since the 6 usable days are genuinely low — but it must be based on
    // those 6 real days, not on 7 days including a fabricated zero for the uncertain one.
    expect(res.body.data.insights.some((i: ApiBody) => i.key === 'protein_gap')).toBe(true);
  });

  it('withholds a weekly gap claim and reports full uncertainty when there are zero usable days', async () => {
    const u = await newEligibleUser();
    vi.useFakeTimers();
    vi.setSystemTime(new Date('2026-10-02T12:00:00Z'));
    const res = await u.call('GET', '/v1/insights?period=7d');
    expect(res.body.data.usable_days).toBe(0);
    expect(res.body.data.insights.some((i: ApiBody) => i.key.endsWith('_gap'))).toBe(false);
    expect(res.body.data.coverage_uncertain).toBe(true);
  });

  it('requires authentication', async () => {
    const res = await ctx.app.inject({ method: 'GET', url: '/v1/insights?period=7d' });
    expect(res.statusCode).toBe(401);
  });
});

describe('timezone boundary handling (date/time-zone boundaries)', () => {
  it("computes 'today' from the caller's own profile timezone, not server UTC", async () => {
    const u = await newEligibleUser({ timezone: 'Asia/Kolkata' });
    // 23:30 UTC on Oct 1 is already Oct 2 in Asia/Kolkata (+05:30).
    vi.useFakeTimers();
    vi.setSystemTime(new Date('2026-10-01T23:30:00Z'));
    const res = await u.call('GET', '/v1/home');
    expect(res.status).toBe(200);
    expect(res.body.data.date).toBe('2026-10-02');
  });

  it('buckets a meal logged near local midnight into the correct local day, honoured by next-meal', async () => {
    const u = await newEligibleUser({ timezone: 'Asia/Kolkata' });
    // Log directly at the boundary: 18:29 UTC = 23:59 IST (Oct 5); 18:31 UTC = 00:01 IST (Oct 6).
    const before = await u.call('POST', '/v1/meal-logs', {
      client_id: randomUUID(),
      consumed_at: '2026-10-05T18:29:00Z',
      timezone: 'Asia/Kolkata',
      slot: 'dinner',
      items: [{ label: 'White rice', grams: 100 }],
    });
    const after = await u.call('POST', '/v1/meal-logs', {
      client_id: randomUUID(),
      consumed_at: '2026-10-05T18:31:00Z',
      timezone: 'Asia/Kolkata',
      slot: 'breakfast',
      items: [{ label: 'White rice', grams: 100 }],
    });
    expect(before.body.data.local_date).toBe('2026-10-05');
    expect(after.body.data.local_date).toBe('2026-10-06');

    const resOct5 = await u.call(
      'GET',
      '/v1/recommendations/next-meal?date=2026-10-05&slot=dinner',
    );
    expect(resOct5.body.data.options).toEqual([]); // already logged that day

    const resOct6 = await u.call(
      'GET',
      '/v1/recommendations/next-meal?date=2026-10-06&slot=breakfast',
    );
    expect(resOct6.body.data.options).toEqual([]); // already logged the next day
  });
});
