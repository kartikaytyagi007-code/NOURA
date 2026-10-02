import { randomUUID } from 'node:crypto';
import pg from 'pg';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { createTestApp } from './support/app.js';
import { createTestKeys, signToken, startJwksServer, type TestKeys } from './support/auth.js';
import { expectMatchesContract } from './support/contract.js';

const admin = new pg.Pool({ connectionString: process.env.DATABASE_URL, max: 2 });
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

// Responses are checked against the OpenAPI contract separately; here they are navigated loosely.
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

async function newUser(): Promise<Caller> {
  const id = randomUUID();
  await admin.query('insert into auth.users (id, email) values ($1, $2)', [
    id,
    `${id}@test.invalid`,
  ]);
  const token = await signToken(keys, { sub: id });
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

const ANSWERS_NO = {
  pregnancy_or_breastfeeding: 'no',
  eating_disorder_concern: 'no',
  medical_diet_condition: 'no',
} as const;

const PREFS = {
  diet_type: 'vegetarian',
  allergy_ids: ['peanut'],
  exclusion_ids: [],
  dislikes: ['Okra'],
  cuisines: ['north_indian'],
  budget_band: 'medium',
  cooking_time: 'moderate',
  meals_per_day: 4,
} as const;

const TRAINING = {
  experience: 'beginner',
  location: 'home',
  equipment_ids: ['bodyweight'],
  weekdays: [1, 3, 5],
  days_per_week: 3,
  duration_minutes: 45,
  limitation_tags: [],
} as const;

const CONSENTS = ['terms', 'privacy', 'health_data_processing'].map((consent_type) => ({
  consent_type,
  version: 'v0-draft',
}));

/** Walks a user through every step up to (not including) completion. Returns the profile revision. */
async function fillOnboarding(
  u: Caller,
  overrides: {
    age?: number;
    screening?: Record<string, string>;
    sex?: 'female' | 'male' | null;
  } = {},
): Promise<number> {
  const basics = await u.call('PATCH', '/v1/me', {
    expected_revision: 1,
    display_name: '  Asha   Rao ',
    age_years: overrides.age ?? 30,
    calculation_sex: overrides.sex === undefined ? 'female' : (overrides.sex ?? 'declined'),
    height_cm: 162.5,
    weight_kg: 62,
    activity_band: 'moderate',
    timezone: 'Asia/Kolkata',
    onboarding_step: 'goals',
  });
  expect(basics.status).toBe(200);
  const goals = await u.call('PATCH', '/v1/me', {
    expected_revision: basics.body.data.profile.revision,
    primary_goal: { goal_type: 'lose_fat', target_weight_kg: 58 },
    onboarding_step: 'diet',
  });
  expect(goals.status).toBe(200);
  expect(
    (await u.call('PUT', '/v1/me/preferences', { expected_revision: 0, ...PREFS })).status,
  ).toBe(200);
  expect(
    (await u.call('PUT', '/v1/me/training-preferences', { expected_revision: 0, ...TRAINING }))
      .status,
  ).toBe(200);
  const screening = await u.call('PATCH', '/v1/me', {
    expected_revision: goals.body.data.profile.revision,
    screening: { ...ANSWERS_NO, ...overrides.screening },
    onboarding_step: 'review',
  });
  expect(screening.status).toBe(200);
  return screening.body.data.profile.revision;
}

describe('PATCH /v1/me', () => {
  it('saves a step, normalizes input, bumps the revision and resumes at the saved step', async () => {
    const u = await newUser();
    const res = await u.call('PATCH', '/v1/me', {
      expected_revision: 1,
      display_name: '  Asha   Rao ',
      age_years: 30,
      height_cm: 162.5,
      weight_kg: 62.25,
      timezone: 'Asia/Kolkata',
      unit_system: 'imperial',
      onboarding_step: 'goals',
    });
    expect(res.status).toBe(200);
    expectMatchesContract('patchMe', 200, res.body);
    expect(res.body.data.profile).toMatchObject({
      display_name: 'Asha Rao',
      age_years: 30,
      height_cm: 162.5,
      weight_kg: 62.25,
      timezone: 'Asia/Kolkata',
      unit_system: 'imperial',
      revision: 2,
    });
    expect(res.body.data.onboarding).toEqual({ status: 'in_progress', step: 'goals' });

    // A fresh read (an app restart) returns the same resumable state.
    const again = await u.call('GET', '/v1/me');
    expect(again.body.data.onboarding).toEqual({ status: 'in_progress', step: 'goals' });
    expect(again.body.data.profile.display_name).toBe('Asha Rao');
  });

  it('validates ranges, timezone, blank names and goal direction with field errors', async () => {
    const u = await newUser();
    const bad = await u.call('PATCH', '/v1/me', {
      expected_revision: 1,
      weight_kg: 5000,
      height_cm: 10,
      age_years: 0,
    });
    expect(bad.status).toBe(422);
    expectMatchesContract('patchMe', 422, bad.body);
    const fields = bad.body.error.field_errors.map((e: { field: string }) => e.field);
    expect(fields).toEqual(
      expect.arrayContaining(['body.weight_kg', 'body.height_cm', 'body.age_years']),
    );

    const tz = await u.call('PATCH', '/v1/me', { expected_revision: 1, timezone: 'Mars/Olympus' });
    expect(tz.status).toBe(422);
    expect(tz.body.error.field_errors[0]).toMatchObject({
      field: 'body.timezone',
      code: 'invalid_timezone',
    });

    const name = await u.call('PATCH', '/v1/me', { expected_revision: 1, display_name: '   ' });
    expect(name.body.error.field_errors[0]).toMatchObject({
      field: 'body.display_name',
      code: 'required',
    });

    await u.call('PATCH', '/v1/me', { expected_revision: 1, weight_kg: 60 });
    const goal = await u.call('PATCH', '/v1/me', {
      expected_revision: 2,
      primary_goal: { goal_type: 'lose_fat', target_weight_kg: 70 },
    });
    expect(goal.status).toBe(422);
    expect(goal.body.error.field_errors[0].field).toBe('body.primary_goal.target_weight_kg');

    const extra = await u.call('PATCH', '/v1/me', { expected_revision: 2, user_id: randomUUID() });
    expect(extra.status).toBe(422);
    const empty = await u.call('PATCH', '/v1/me', { expected_revision: 2 });
    expect(empty.status).toBe(422);

    // Nothing from the rejected requests was saved; the revision is untouched.
    const me = await u.call('GET', '/v1/me');
    expect(me.body.data.profile).toMatchObject({
      revision: 2,
      timezone: 'UTC',
      display_name: null,
    });
  });

  it('rejects stale revisions with REVISION_CONFLICT and keeps the first write', async () => {
    const u = await newUser();
    const first = await u.call('PATCH', '/v1/me', { expected_revision: 1, age_years: 31 });
    expect(first.status).toBe(200);
    const stale = await u.call('PATCH', '/v1/me', { expected_revision: 1, age_years: 40 });
    expect(stale.status).toBe(409);
    expectMatchesContract('patchMe', 409, stale.body);
    expect(stale.body.error.code).toBe('REVISION_CONFLICT');
    expect((await u.call('GET', '/v1/me')).body.data.profile).toMatchObject({
      age_years: 31,
      revision: 2,
    });
  });

  it('replays an identical retry once, and rejects a reused key with a different body', async () => {
    const u = await newUser();
    const key = randomUUID();
    const body = { expected_revision: 1, age_years: 29 };
    const first = await u.call('PATCH', '/v1/me', body, { key });
    const replay = await u.call('PATCH', '/v1/me', body, { key });
    expect(replay.status).toBe(200);
    expect(replay.body.data).toEqual(first.body.data);
    expect(replay.body.data.profile.revision).toBe(2); // not 3: the retry did not write again

    const reused = await u.call(
      'PATCH',
      '/v1/me',
      { expected_revision: 1, age_years: 33 },
      { key },
    );
    expect(reused.status).toBe(422);
    expect(reused.body.error.field_errors[0].code).toBe('key_reused');
  });

  it('requires an Idempotency-Key', async () => {
    const u = await newUser();
    const res = await u.call(
      'PATCH',
      '/v1/me',
      { expected_revision: 1, age_years: 29 },
      { key: null },
    );
    expect(res.status).toBe(422);
  });

  it('changes of current weight, goals and screening keep one active goal', async () => {
    const u = await newUser();
    await u.call('PATCH', '/v1/me', { expected_revision: 1, weight_kg: 80 });
    await u.call('PATCH', '/v1/me', {
      expected_revision: 2,
      primary_goal: { goal_type: 'maintain' },
    });
    await u.call('PATCH', '/v1/me', {
      expected_revision: 3,
      primary_goal: { goal_type: 'lose_fat', target_weight_kg: 72 },
    });
    const me = await u.call('GET', '/v1/me');
    expect(me.body.data.goal).toEqual({ goal_type: 'lose_fat', target_weight_kg: 72 });
    const { rows } = await admin.query(
      'select count(*)::int as n, count(*) filter (where active_to is null)::int as active from app.goals where user_id = $1',
      [u.id],
    );
    expect(rows[0]).toEqual({ n: 2, active: 1 });
  });
});

describe('eligibility', () => {
  const cases: Array<[string, { age?: number; screening?: Record<string, string> }, string]> = [
    ['an adult with no flags', {}, 'eligible'],
    ['a minor', { age: 16 }, 'tracking_only'],
    [
      'pregnancy or breastfeeding',
      { screening: { pregnancy_or_breastfeeding: 'yes' } },
      'tracking_only',
    ],
    [
      'an eating-disorder concern',
      { screening: { eating_disorder_concern: 'yes' } },
      'tracking_only',
    ],
    ['a medical diet condition', { screening: { medical_diet_condition: 'yes' } }, 'tracking_only'],
    [
      'a declined answer',
      { screening: { medical_diet_condition: 'prefer_not_to_say' } },
      'needs_review',
    ],
  ];
  it.each(cases)('derives the status for %s', async (_name, input, expected) => {
    const u = await newUser();
    await fillOnboarding(u, input);
    const me = await u.call('GET', '/v1/me');
    expect(me.body.data.eligibility_status).toBe(expected);
    expect(me.body.data.screening).toMatchObject({ ...ANSWERS_NO, ...input.screening });
  });

  it('stores only minimal flags, never free text', async () => {
    const u = await newUser();
    await fillOnboarding(u, { screening: { eating_disorder_concern: 'prefer_not_to_say' } });
    const { rows } = await admin.query(
      'select screening_flags from app.profiles where user_id = $1',
      [u.id],
    );
    expect(rows[0].screening_flags).toEqual(['eating_disorder_concern:declined']);
  });
});

describe('PUT /v1/me/preferences and /training-preferences', () => {
  it('creates at revision 1, increments on edit, and conflicts when stale', async () => {
    const u = await newUser();
    const created = await u.call('PUT', '/v1/me/preferences', { expected_revision: 0, ...PREFS });
    expect(created.status).toBe(200);
    expectMatchesContract('putPreferences', 200, created.body);
    expect(created.body.data).toMatchObject({ revision: 1, dislikes: ['Okra'] });

    const edited = await u.call('PUT', '/v1/me/preferences', {
      expected_revision: 1,
      ...PREFS,
      dislikes: ['okra', 'OKRA', ' Bitter  gourd '],
      meals_per_day: 3,
    });
    expect(edited.body.data).toMatchObject({
      revision: 2,
      meals_per_day: 3,
      dislikes: ['okra', 'Bitter gourd'],
    });

    const stale = await u.call('PUT', '/v1/me/preferences', { expected_revision: 1, ...PREFS });
    expect(stale.status).toBe(409);
    const doubleCreate = await u.call('PUT', '/v1/me/preferences', {
      expected_revision: 0,
      ...PREFS,
    });
    expect(doubleCreate.status).toBe(409);
  });

  it('rejects unknown tags and out-of-range values', async () => {
    const u = await newUser();
    const res = await u.call('PUT', '/v1/me/preferences', {
      expected_revision: 0,
      ...PREFS,
      allergy_ids: ['unobtainium'],
      meals_per_day: 12,
    });
    expect(res.status).toBe(422);
    expectMatchesContract('putPreferences', 422, res.body);
  });

  it('validates training coherence and sorts weekdays', async () => {
    const u = await newUser();
    const tooFew = await u.call('PUT', '/v1/me/training-preferences', {
      expected_revision: 0,
      ...TRAINING,
      weekdays: [2],
    });
    expect(tooFew.status).toBe(422);
    expect(tooFew.body.error.field_errors[0]).toMatchObject({
      field: 'body.weekdays',
      code: 'fewer_than_days_per_week',
    });

    const noEquipment = await u.call('PUT', '/v1/me/training-preferences', {
      expected_revision: 0,
      ...TRAINING,
      equipment_ids: [],
    });
    expect(noEquipment.body.error.field_errors[0].field).toBe('body.equipment_ids');

    const ok = await u.call('PUT', '/v1/me/training-preferences', {
      expected_revision: 0,
      ...TRAINING,
      weekdays: [5, 1, 3],
    });
    expect(ok.status).toBe(200);
    expectMatchesContract('putTrainingPreferences', 200, ok.body);
    expect(ok.body.data.weekdays).toEqual([1, 3, 5]);
    const stale = await u.call('PUT', '/v1/me/training-preferences', {
      expected_revision: 0,
      ...TRAINING,
    });
    expect(stale.status).toBe(409);
  });
});

describe('POST /v1/onboarding/complete', () => {
  it('lists every missing input without writing anything', async () => {
    const u = await newUser();
    const res = await u.call('POST', '/v1/onboarding/complete', {
      expected_revision: 1,
      consents: CONSENTS,
    });
    expect(res.status).toBe(422);
    expectMatchesContract('completeOnboarding', 422, res.body);
    const fields = res.body.error.field_errors.map((e: { field: string }) => e.field);
    expect(fields).toEqual(
      expect.arrayContaining([
        'profile.display_name',
        'profile.weight_kg',
        'goal',
        'screening',
        'preferences',
        'training_preferences',
      ]),
    );
    const { rows } = await admin.query(
      'select onboarding_status from app.profiles where user_id = $1',
      [u.id],
    );
    // The rejected request rolled back entirely (even the lazily created profile row).
    expect(rows.every((r) => r.onboarding_status === 'not_started')).toBe(true);
    expect(
      (await admin.query('select 1 from app.consent_records where user_id = $1', [u.id])).rowCount,
    ).toBe(0);
  });

  it('requires published consent versions for the required consent types', async () => {
    const u = await newUser();
    const revision = await fillOnboarding(u);
    const missing = await u.call('POST', '/v1/onboarding/complete', {
      expected_revision: revision,
      consents: CONSENTS.slice(0, 2),
    });
    expect(missing.status).toBe(422);
    expect(missing.body.error.field_errors[0]).toMatchObject({ code: 'consent_required' });

    const unknown = await u.call('POST', '/v1/onboarding/complete', {
      expected_revision: revision,
      consents: CONSENTS.map((c) => ({ ...c, version: 'v999' })),
    });
    expect(
      unknown.body.error.field_errors.some((e: { code: string }) => e.code === 'unknown_version'),
    ).toBe(true);
    const dup = await u.call('POST', '/v1/onboarding/complete', {
      expected_revision: revision,
      consents: [...CONSENTS, CONSENTS[0]],
    });
    expect(dup.body.error.field_errors.some((e: { code: string }) => e.code === 'duplicate')).toBe(
      true,
    );
  });

  it('completes atomically for an eligible user: snapshot, consents and one generation request', async () => {
    const u = await newUser();
    const revision = await fillOnboarding(u);
    const res = await u.call('POST', '/v1/onboarding/complete', {
      expected_revision: revision,
      consents: CONSENTS,
    });
    expect(res.status).toBe(200);
    expectMatchesContract('completeOnboarding', 200, res.body);
    const { me, job_ids } = res.body.data;
    expect(me.onboarding.status).toBe('completed');
    expect(me.eligibility_status).toBe('eligible');
    expect(me.profile.revision).toBe(revision + 1);
    expect(job_ids).toHaveLength(1);
    expect(me.planning).toEqual({ status: 'requested', job_id: job_ids[0] });

    const job = await u.call('GET', `/v1/jobs/${job_ids[0]}`);
    expect(job.status).toBe(200);
    expect(job.body.data).toMatchObject({ status: 'queued' });

    const targets = await u.call('GET', '/v1/targets');
    expect(targets.status).toBe(200);
    expectMatchesContract('getTargets', 200, targets.body);
    expect(targets.body.data).toMatchObject({
      profile_revision: revision + 1,
      policy_status: 'test',
      basis: 'point',
      eligibility: 'eligible',
    });
    expect(targets.body.data.targets.energy_kcal).toBeGreaterThan(0);

    const { rows } = await admin.query(
      `select (select count(*)::int from app.consent_records where user_id = $1) as consents,
              (select count(*)::int from app.generation_requests where user_id = $1) as requests,
              (select input_revision from app.generation_requests where user_id = $1) as input_revision,
              (select queue_job_id from app.generation_requests where user_id = $1) as queue_job_id`,
      [u.id],
    );
    expect(rows[0]).toEqual({
      consents: 3,
      requests: 1,
      input_revision: revision + 1,
      queue_job_id: null,
    });
  });

  it('creates a single generation request for duplicate submits (same key, new key, stale revision)', async () => {
    const u = await newUser();
    const revision = await fillOnboarding(u);
    const key = randomUUID();
    const body = { expected_revision: revision, consents: CONSENTS };
    const [a, b] = await Promise.all([
      u.call('POST', '/v1/onboarding/complete', body, { key }),
      u.call('POST', '/v1/onboarding/complete', body, { key }),
    ]);
    expect([a.status, b.status]).toEqual([200, 200]);
    expect(a.body.data.job_ids).toEqual(b.body.data.job_ids);

    const otherKey = await u.call('POST', '/v1/onboarding/complete', body);
    expect(otherKey.status).toBe(422);
    expect(otherKey.body.error.code).toBe('CONSTRAINT_CONFLICT');
    const stale = await u.call('POST', '/v1/onboarding/complete', {
      ...body,
      expected_revision: 1,
    });
    expect([409, 422]).toContain(stale.status);

    const { rows } = await admin.query(
      'select (select count(*)::int from app.generation_requests where user_id = $1) as requests, (select count(*)::int from app.consent_records where user_id = $1) as consents',
      [u.id],
    );
    expect(rows[0]).toEqual({ requests: 1, consents: 3 });
  });

  it('refuses a stale revision', async () => {
    const u = await newUser();
    const revision = await fillOnboarding(u);
    const res = await u.call('POST', '/v1/onboarding/complete', {
      expected_revision: revision - 1,
      consents: CONSENTS,
    });
    expect(res.status).toBe(409);
    expect((await u.call('GET', '/v1/me')).body.data.onboarding.status).toBe('in_progress');
  });

  it.each([
    ['a minor', { age: 16 }, 'unavailable_tracking_only'],
    [
      'a screening flag',
      { screening: { eating_disorder_concern: 'yes' } },
      'unavailable_tracking_only',
    ],
    [
      'a declined answer',
      { screening: { pregnancy_or_breastfeeding: 'prefer_not_to_say' } },
      'unavailable_needs_review',
    ],
  ])('completes but never reaches planning for %s', async (_name, input, planning) => {
    const u = await newUser();
    const revision = await fillOnboarding(u, input);
    const res = await u.call('POST', '/v1/onboarding/complete', {
      expected_revision: revision,
      consents: CONSENTS,
    });
    expect(res.status).toBe(200);
    expect(res.body.data.job_ids).toEqual([]);
    expect(res.body.data.me.planning).toEqual({ status: planning, job_id: null });
    const targets = await u.call('GET', '/v1/targets');
    expect(targets.body.data).toMatchObject({
      basis: 'not_calculated',
      estimated_energy_kcal: null,
    });
    expect(Object.values(targets.body.data.targets).every((v) => v === null)).toBe(true);
    expect(
      (await admin.query('select 1 from app.generation_requests where user_id = $1', [u.id]))
        .rowCount,
    ).toBe(0);
  });

  it('offers an energy range, not a point target, when the calculation sex is declined', async () => {
    const u = await newUser();
    const revision = await fillOnboarding(u, { sex: null });
    const res = await u.call('POST', '/v1/onboarding/complete', {
      expected_revision: revision,
      consents: CONSENTS,
    });
    expect(res.body.data.job_ids).toHaveLength(1);
    const { data } = (await u.call('GET', '/v1/targets')).body;
    expect(data.basis).toBe('range');
    expect(data.estimated_energy_kcal.min).toBeLessThan(data.estimated_energy_kcal.max);
    expect(data.targets.energy_kcal).toBeNull();
  });

  it('fails closed without a request when no approved policy exists (deployed-like policy gate)', async () => {
    // A deployed environment with no approved policy configured.
    const noPolicy = await createTestApp(jwks.url, { APP_ENV: 'staging', ...stagingEnv() });
    try {
      const id = randomUUID();
      await admin.query('insert into auth.users (id, email) values ($1, $2)', [
        id,
        `${id}@test.invalid`,
      ]);
      const token = await signToken(keys, { sub: id });
      const call = async (method: 'PATCH' | 'PUT' | 'POST', url: string, payload: object) => {
        const res = await noPolicy.app.inject({
          method,
          url,
          headers: { authorization: `Bearer ${token}`, 'idempotency-key': randomUUID() },
          payload,
        });
        return { status: res.statusCode, body: res.json() };
      };
      const p1 = await call('PATCH', '/v1/me', {
        expected_revision: 1,
        display_name: 'Asha',
        age_years: 30,
        height_cm: 160,
        weight_kg: 60,
        activity_band: 'light',
        primary_goal: { goal_type: 'maintain' },
        screening: ANSWERS_NO,
      });
      await call('PUT', '/v1/me/preferences', { expected_revision: 0, ...PREFS });
      await call('PUT', '/v1/me/training-preferences', { expected_revision: 0, ...TRAINING });
      const done = await call('POST', '/v1/onboarding/complete', {
        expected_revision: p1.body.data.profile.revision,
        consents: CONSENTS,
      });
      expect(done.status).toBe(200);
      expect(done.body.data.job_ids).toEqual([]);
      expect(done.body.data.me.planning).toEqual({ status: 'unavailable_policy', job_id: null });
      expect(done.body.data.me.eligibility_status).toBe('eligible');
    } finally {
      await noPolicy.close();
    }
  });
});

describe('edits after onboarding', () => {
  it('refreshes the target snapshot for the new revision and keeps history', async () => {
    const u = await newUser();
    const revision = await fillOnboarding(u);
    await u.call('POST', '/v1/onboarding/complete', {
      expected_revision: revision,
      consents: CONSENTS,
    });
    const before = (await u.call('GET', '/v1/targets')).body.data;
    const me = (await u.call('GET', '/v1/me')).body.data;

    const edit = await u.call('PATCH', '/v1/me', {
      expected_revision: me.profile.revision,
      weight_kg: 70,
    });
    expect(edit.status).toBe(200);
    expect(edit.body.data.profile.revision).toBe(me.profile.revision + 1);
    const after = (await u.call('GET', '/v1/targets')).body.data;
    expect(after.id).not.toBe(before.id);
    expect(after.profile_revision).toBe(me.profile.revision + 1);
    const { rows } = await admin.query(
      'select count(*)::int as n, count(*) filter (where valid_to is null)::int as current from app.target_snapshots where user_id = $1',
      [u.id],
    );
    expect(rows[0]).toEqual({ n: 2, current: 1 });
  });

  it('cannot move the onboarding step after completion, and age edits re-gate eligibility', async () => {
    const u = await newUser();
    const revision = await fillOnboarding(u);
    await u.call('POST', '/v1/onboarding/complete', {
      expected_revision: revision,
      consents: CONSENTS,
    });
    let me = (await u.call('GET', '/v1/me')).body.data;
    const step = await u.call('PATCH', '/v1/me', {
      expected_revision: me.profile.revision,
      onboarding_step: 'basics',
    });
    expect(step.status).toBe(422);

    const minor = await u.call('PATCH', '/v1/me', {
      expected_revision: me.profile.revision,
      age_years: 15,
    });
    expect(minor.body.data.eligibility_status).toBe('tracking_only');
    expect(minor.body.data.planning).toEqual({ status: 'unavailable_tracking_only', job_id: null });
    me = (await u.call('GET', '/v1/targets')).body;
    expect(me.data.basis).toBe('not_calculated');
  });
});

describe('authorization and ownership', () => {
  it('requires a bearer token on every M2 route', async () => {
    const routes: Array<['PATCH' | 'PUT' | 'POST' | 'GET', string]> = [
      ['PATCH', '/v1/me'],
      ['PUT', '/v1/me/preferences'],
      ['PUT', '/v1/me/training-preferences'],
      ['POST', '/v1/onboarding/complete'],
      ['GET', '/v1/targets'],
    ];
    for (const [method, url] of routes) {
      const res = await ctx.app.inject({
        method,
        url,
        headers: { 'idempotency-key': randomUUID() },
        payload: method === 'GET' ? undefined : {},
      });
      expect(res.statusCode, `${method} ${url}`).toBe(401);
    }
  });

  it("never reads or writes another user's data and ignores client-supplied identity", async () => {
    const a = await newUser();
    const b = await newUser();
    await fillOnboarding(a);
    const bSees = await b.call('GET', '/v1/me');
    expect(bSees.body.data.user_id).toBe(b.id);
    expect(bSees.body.data.preferences).toBeNull();
    expect(bSees.body.data.goal).toBeNull();
    expect((await b.call('GET', '/v1/targets')).status).toBe(404);

    const spoof = await b.call('PATCH', '/v1/me', {
      expected_revision: 1,
      age_years: 22,
      user_id: a.id,
    });
    expect(spoof.status).toBe(422);
    const premium = await b.call('PATCH', '/v1/me', { expected_revision: 1, is_premium: true });
    expect(premium.status).toBe(422);

    // The same idempotency key used by two users is two independent records.
    const key = randomUUID();
    const [x, y] = await Promise.all([
      a.call(
        'PUT',
        '/v1/me/preferences',
        { expected_revision: 1, ...PREFS, meals_per_day: 5 },
        { key },
      ),
      b.call(
        'PUT',
        '/v1/me/preferences',
        { expected_revision: 0, ...PREFS, meals_per_day: 2 },
        { key },
      ),
    ]);
    expect(x.body.data.meals_per_day).toBe(5);
    expect(y.body.data.meals_per_day).toBe(2);
  });

  it('exposes generation jobs only to the owner', async () => {
    const a = await newUser();
    const b = await newUser();
    const revision = await fillOnboarding(a);
    const done = await a.call('POST', '/v1/onboarding/complete', {
      expected_revision: revision,
      consents: CONSENTS,
    });
    const jobId = done.body.data.job_ids[0];
    expect((await b.call('GET', `/v1/jobs/${jobId}`)).status).toBe(404);
  });
});

function stagingEnv(): Record<string, string> {
  return {
    SUPABASE_URL: 'https://project.supabase.co',
    AI_PROVIDER: 'gemini',
    AI_API_KEY: 'placeholder-ai-key',
    AI_MODEL_ID: 'placeholder-model',
    BILLING_PROVIDER: 'revenuecat',
    REVENUECAT_SECRET_API_KEY: 'placeholder-rc-key',
    REVENUECAT_WEBHOOK_AUTH: 'placeholder-webhook-authorization',
    SUPABASE_SERVICE_ROLE_KEY: 'placeholder-service-role-key',
  };
}
