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

// Seed exercise ids from supabase/migrations/20261001001200_m7_exercise_test_fixture.sql.
const BODYWEIGHT_SQUAT = '00000000-0000-4000-b001-000000000001'; // squat, no equipment
const GOBLET_SQUAT = '00000000-0000-4000-b001-000000000002'; // squat, dumbbell
const BARBELL_SQUAT = '00000000-0000-4000-b001-000000000003'; // squat, barbell, advanced
const DUMBBELL_ROW = '00000000-0000-4000-b001-000000000018'; // pull, dumbbell + bench

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

/** Seeds a profile and complete training preferences directly, bypassing onboarding. */
async function newTrainingUser(
  overrides: {
    location?: 'home' | 'gym' | 'both';
    experience?: 'beginner' | 'intermediate' | 'advanced';
    equipment_ids?: string[];
    weekdays?: number[];
    days_per_week?: number;
    duration_minutes?: number;
    limitation_tags?: string[];
    eligibility_status?: string;
    skipTraining?: boolean;
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
     values ($1, 'Test User', 30, 'female', 165, 60, 'moderate', 'UTC', 'metric', 'completed', 'review',
             $2, now(), 1)`,
    [id, overrides.eligibility_status ?? 'eligible'],
  );
  if (!overrides.skipTraining) {
    await admin.query(
      `insert into app.training_preferences
         (user_id, experience, location, equipment_ids, weekdays, days_per_week, duration_minutes, limitation_tags)
       values ($1, $2, $3, $4, $5, $6, $7, $8)`,
      [
        id,
        overrides.experience ?? 'intermediate',
        overrides.location ?? 'home',
        overrides.equipment_ids ?? ['dumbbell', 'bench'],
        overrides.weekdays ?? [1, 2, 3, 4, 5],
        overrides.days_per_week ?? 3,
        overrides.duration_minutes ?? 45,
        overrides.limitation_tags ?? [],
      ],
    );
  }
  const token = await signToken(keys, { sub: id });
  return callerFor(id, token);
}

async function insertActiveWorkoutPlan(
  userId: string,
  options: { startsOn?: string } = {},
): Promise<{ planId: string; sessionId: string; startsOn: string }> {
  const startsOn = options.startsOn ?? '2026-10-05';
  const plan = await admin.query<{ id: string }>(
    `insert into app.workout_plans (user_id, version, profile_revision, starts_on, status)
     values ($1, 1, 1, $2, 'active') returning id`,
    [userId, startsOn],
  );
  const planId = plan.rows[0]!.id;
  const session = await admin.query<{ id: string }>(
    `insert into app.workout_plan_sessions (user_id, plan_id, session_date, session_order, title)
     values ($1, $2, $3, 1, 'Full-body session') returning id`,
    [userId, planId, startsOn],
  );
  const sessionId = session.rows[0]!.id;
  await admin.query(
    `insert into app.workout_plan_exercises
       (user_id, session_id, exercise_id, ordinal, sets, reps_min, reps_max, rest_sec, effort_cue)
     values ($1, $2, $3, 1, 3, 10, 12, 60, 'Controlled tempo.')`,
    [userId, sessionId, BODYWEIGHT_SQUAT],
  );
  return { planId, sessionId, startsOn };
}

describe('POST /v1/workout-plans/generate', () => {
  it('accepts a request and records a durable generation_requests row of type workout_plan', async () => {
    const u = await newTrainingUser();
    const res = await u.call('POST', '/v1/workout-plans/generate', {
      start_date: '2026-10-05',
      profile_revision: 1,
    });
    expect(res.status).toBe(202);
    expectMatchesContract('generateWorkoutPlan', 202, res.body);
    const row = await admin.query(
      'select request_type, status from app.generation_requests where id = $1',
      [res.body.data.job_id],
    );
    expect(row.rows[0]).toMatchObject({ request_type: 'workout_plan', status: 'queued' });
  });

  it('is idempotent: a replay with the same key and body returns the same job and writes nothing new', async () => {
    const u = await newTrainingUser();
    const key = randomUUID();
    const body = { start_date: '2026-10-05', profile_revision: 1 };
    const first = await u.call('POST', '/v1/workout-plans/generate', body, { key });
    const second = await u.call('POST', '/v1/workout-plans/generate', body, { key });
    expect(second.body.data.job_id).toBe(first.body.data.job_id);
    const count = await admin.query(
      'select count(*)::int as n from app.generation_requests where user_id = $1',
      [u.id],
    );
    expect(count.rows[0]!.n).toBe(1);
  });

  it('conflicts on a stale training-preferences revision', async () => {
    const u = await newTrainingUser();
    const res = await u.call('POST', '/v1/workout-plans/generate', {
      start_date: '2026-10-05',
      profile_revision: 99,
    });
    expect(res.status).toBe(409);
  });

  it('refuses when training preferences are incomplete', async () => {
    const u = await newTrainingUser({ skipTraining: true });
    const res = await u.call('POST', '/v1/workout-plans/generate', {
      start_date: '2026-10-05',
      profile_revision: 1,
    });
    expect(res.status).toBe(422);
  });

  it('refuses for a tracking-only (not eligible) account', async () => {
    const u = await newTrainingUser({ eligibility_status: 'tracking_only' });
    const res = await u.call('POST', '/v1/workout-plans/generate', {
      start_date: '2026-10-05',
      profile_revision: 1,
    });
    expect(res.status).toBe(422);
  });

  it('requires authentication', async () => {
    const res = await ctx.app.inject({
      method: 'POST',
      url: '/v1/workout-plans/generate',
      payload: { start_date: '2026-10-05', profile_revision: 1 },
    });
    expect(res.statusCode).toBe(401);
  });
});

describe('GET /v1/workout-plans/current', () => {
  it('returns the active plan with sessions and exercises', async () => {
    const u = await newTrainingUser();
    const { startsOn } = await insertActiveWorkoutPlan(u.id);
    const res = await u.call('GET', '/v1/workout-plans/current');
    expect(res.status).toBe(200);
    expectMatchesContract('getCurrentWorkoutPlan', 200, res.body);
    expect(res.body.data.starts_on).toBe(startsOn);
    expect(res.body.data.sessions).toHaveLength(1);
    expect(res.body.data.sessions[0].exercises[0].exercise.id).toBe(BODYWEIGHT_SQUAT);
  });

  it('404s when there is no active plan', async () => {
    const u = await newTrainingUser();
    const res = await u.call('GET', '/v1/workout-plans/current');
    expect(res.status).toBe(404);
  });

  it('cannot read another user plan (ownership)', async () => {
    const owner = await newTrainingUser();
    await insertActiveWorkoutPlan(owner.id);
    const stranger = await newTrainingUser();
    const res = await stranger.call('GET', '/v1/workout-plans/current');
    expect(res.status).toBe(404);
  });
});

describe('GET /v1/exercises/{id}/substitutions', () => {
  it('offers only catalog-declared, currently-eligible substitutes', async () => {
    const u = await newTrainingUser({ location: 'home', equipment_ids: ['dumbbell'] });
    const res = await u.call('GET', `/v1/exercises/${BODYWEIGHT_SQUAT}/substitutions`);
    expect(res.status).toBe(200);
    expectMatchesContract('getExerciseSubstitutions', 200, res.body);
    const ids = res.body.data.candidates.map((c: ApiBody) => c.exercise.id);
    expect(ids).toContain(GOBLET_SQUAT);
    expect(ids).not.toContain(BARBELL_SQUAT); // home-only, no barbell, not advanced
  });

  it('404s for an unknown exercise id', async () => {
    const u = await newTrainingUser();
    const res = await u.call('GET', `/v1/exercises/${randomUUID()}/substitutions`);
    expect(res.status).toBe(404);
  });
});

describe('workout logging', () => {
  it('starts a log, is idempotent by client_id, and 404s for a session that is not the caller’s own', async () => {
    const u = await newTrainingUser();
    const { sessionId } = await insertActiveWorkoutPlan(u.id);
    const clientId = randomUUID();
    const first = await u.call('POST', '/v1/workout-logs', {
      client_id: clientId,
      session_id: sessionId,
    });
    expect(first.status).toBe(201);
    expectMatchesContract('createWorkoutLog', 201, first.body);
    const second = await u.call('POST', '/v1/workout-logs', {
      client_id: clientId,
      session_id: sessionId,
    });
    expect(second.body.data.id).toBe(first.body.data.id);
    const count = await admin.query(
      'select count(*)::int as n from app.workout_logs where user_id = $1',
      [u.id],
    );
    expect(count.rows[0]!.n).toBe(1);

    const stranger = await newTrainingUser();
    const res = await stranger.call('POST', '/v1/workout-logs', {
      client_id: randomUUID(),
      session_id: sessionId,
    });
    expect(res.status).toBe(404);
  });

  it('saves sets, increments revision, rejects an exercise outside the session, and conflicts on a stale revision', async () => {
    const u = await newTrainingUser();
    const { sessionId } = await insertActiveWorkoutPlan(u.id);
    const log = await u.call('POST', '/v1/workout-logs', {
      client_id: randomUUID(),
      session_id: sessionId,
    });
    const logId = log.body.data.id;

    const bad = await u.call('PUT', `/v1/workout-logs/${logId}/sets`, {
      expected_revision: 1,
      sets: [{ exercise_id: DUMBBELL_ROW, set_ordinal: 1, reps: 10, load_kg: 5, skipped: false }],
    });
    expect(bad.status).toBe(422);

    const good = await u.call('PUT', `/v1/workout-logs/${logId}/sets`, {
      expected_revision: 1,
      sets: [
        { exercise_id: BODYWEIGHT_SQUAT, set_ordinal: 1, reps: 12, load_kg: null, skipped: false },
        { exercise_id: BODYWEIGHT_SQUAT, set_ordinal: 2, reps: null, load_kg: null, skipped: true },
      ],
    });
    expect(good.status).toBe(200);
    expectMatchesContract('putWorkoutSets', 200, good.body);
    expect(good.body.data.revision).toBe(2);
    expect(good.body.data.sets).toHaveLength(2);

    const stale = await u.call('PUT', `/v1/workout-logs/${logId}/sets`, {
      expected_revision: 1,
      sets: [],
    });
    expect(stale.status).toBe(409);
  });

  it('marks a log completed and conflicts on a stale revision', async () => {
    const u = await newTrainingUser();
    const { sessionId } = await insertActiveWorkoutPlan(u.id);
    const log = await u.call('POST', '/v1/workout-logs', {
      client_id: randomUUID(),
      session_id: sessionId,
    });
    const logId = log.body.data.id;

    const res = await u.call('PATCH', `/v1/workout-logs/${logId}`, {
      expected_revision: 1,
      status: 'completed',
    });
    expect(res.status).toBe(200);
    expectMatchesContract('patchWorkoutLog', 200, res.body);
    expect(res.body.data.status).toBe('completed');
    expect(res.body.data.completed_at).not.toBeNull();

    const stale = await u.call('PATCH', `/v1/workout-logs/${logId}`, {
      expected_revision: 1,
      status: 'completed',
    });
    expect(stale.status).toBe(409);
  });

  it('cannot act on another user’s log (ownership)', async () => {
    const owner = await newTrainingUser();
    const { sessionId } = await insertActiveWorkoutPlan(owner.id);
    const log = await owner.call('POST', '/v1/workout-logs', {
      client_id: randomUUID(),
      session_id: sessionId,
    });
    const logId = log.body.data.id;

    const stranger = await newTrainingUser();
    const patch = await stranger.call('PATCH', `/v1/workout-logs/${logId}`, {
      expected_revision: 1,
      status: 'completed',
    });
    expect(patch.status).toBe(404);
    const put = await stranger.call('PUT', `/v1/workout-logs/${logId}/sets`, {
      expected_revision: 1,
      sets: [],
    });
    expect(put.status).toBe(404);
  });
});
