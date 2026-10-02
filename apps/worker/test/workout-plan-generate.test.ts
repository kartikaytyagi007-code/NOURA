import { randomUUID } from 'node:crypto';
import pg from 'pg';
import { pino } from 'pino';
import { afterAll, describe, expect, it } from 'vitest';
import { handleWorkoutPlanGenerate } from '../src/handlers/workout-plan-generate.js';

const log = pino({ level: 'silent' });
const admin = new pg.Pool({ connectionString: process.env.DATABASE_URL, max: 4 });
const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL, max: 4 });

afterAll(async () => {
  await admin.end();
  await pool.end();
});

async function trainingUser(
  overrides: {
    location?: string;
    equipment_ids?: string[];
    weekdays?: number[];
    days_per_week?: number;
    duration_minutes?: number;
    limitation_tags?: string[];
    experience?: string;
  } = {},
): Promise<string> {
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
             'eligible', now(), 1)`,
    [id],
  );
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
  return id;
}

async function requestRow(userId: string): Promise<string> {
  const { rows } = await admin.query<{ id: string }>(
    `insert into app.generation_requests (user_id, request_type, input_revision)
     values ($1, 'workout_plan', 1) returning id`,
    [userId],
  );
  return rows[0]!.id;
}

function job(requestId: string, userId: string) {
  return [{ id: requestId, data: { generation_request_id: requestId, user_id: userId } } as never];
}

describe('handleWorkoutPlanGenerate', () => {
  it('generates a weekly active plan and marks the request completed', async () => {
    const userId = await trainingUser();
    const requestId = await requestRow(userId);
    const result = await handleWorkoutPlanGenerate(job(requestId, userId), pool, 'test', log);
    expect(result).toEqual({ status: 'completed' });

    const request = await admin.query(
      'select status, result_ids from app.generation_requests where id = $1',
      [requestId],
    );
    expect(request.rows[0]!.status).toBe('completed');
    const planId = request.rows[0]!.result_ids.workout_plan_id;
    expect(planId).toBeTruthy();

    const plan = await admin.query('select status, version from app.workout_plans where id = $1', [
      planId,
    ]);
    expect(plan.rows[0]).toMatchObject({ status: 'active', version: 1 });

    const sessions = await admin.query(
      'select count(*)::int as n from app.workout_plan_sessions where plan_id = $1',
      [planId],
    );
    expect(sessions.rows[0]!.n).toBe(3); // days_per_week = 3

    const exercises = await admin.query<{ n: string }>(
      `select count(*)::int as n from app.workout_plan_exercises wpe
         join app.workout_plan_sessions wps on wps.id = wpe.session_id
        where wps.plan_id = $1`,
      [planId],
    );
    expect(Number(exercises.rows[0]!.n)).toBeGreaterThan(0);
  });

  it('never prescribes a barbell exercise for a home-only user without a barbell', async () => {
    const userId = await trainingUser({ location: 'home', equipment_ids: ['dumbbell'] });
    const requestId = await requestRow(userId);
    await handleWorkoutPlanGenerate(job(requestId, userId), pool, 'test', log);
    const request = await admin.query(
      'select result_ids from app.generation_requests where id = $1',
      [requestId],
    );
    const planId = request.rows[0]!.result_ids.workout_plan_id;
    const rows = await admin.query<{ equipment_tags: string[] }>(
      `select e.equipment_tags from app.workout_plan_exercises wpe
         join app.workout_plan_sessions wps on wps.id = wpe.session_id
         join app.exercises e on e.id = wpe.exercise_id
        where wps.plan_id = $1`,
      [planId],
    );
    for (const row of rows.rows) expect(row.equipment_tags).not.toContain('barbell');
  });

  it('is idempotent on generation_request_id: redelivery never creates a second plan', async () => {
    const userId = await trainingUser();
    const requestId = await requestRow(userId);
    const theJob = job(requestId, userId);
    await handleWorkoutPlanGenerate(theJob, pool, 'test', log);
    const second = await handleWorkoutPlanGenerate(theJob, pool, 'test', log);
    expect(second.status).toBe('already_terminal');
    const plans = await admin.query(
      'select count(*)::int as n from app.workout_plans where user_id = $1',
      [userId],
    );
    expect(plans.rows[0]!.n).toBe(1);
  });

  it('recovers from a crash between committing the plan and marking the request terminal', async () => {
    const userId = await trainingUser();
    const requestId = await requestRow(userId);
    const theJob = job(requestId, userId);
    await handleWorkoutPlanGenerate(theJob, pool, 'test', log);
    await admin.query(
      "update app.generation_requests set status = 'queued', completed_at = null, safe_error_code = null, result_ids = '{}' where id = $1",
      [requestId],
    );
    const result = await handleWorkoutPlanGenerate(theJob, pool, 'test', log);
    expect(result).toEqual({ status: 'already_generated' });
    const plans = await admin.query(
      'select count(*)::int as n from app.workout_plans where user_id = $1',
      [userId],
    );
    expect(plans.rows[0]!.n).toBe(1);
  });

  it('supersedes the previous active plan on regeneration, keeping exactly one active version', async () => {
    const userId = await trainingUser();
    const first = await requestRow(userId);
    await handleWorkoutPlanGenerate(job(first, userId), pool, 'test', log);
    const second = await requestRow(userId);
    await handleWorkoutPlanGenerate(job(second, userId), pool, 'test', log);
    const plans = await admin.query<{ status: string; version: number }>(
      'select status, version from app.workout_plans where user_id = $1 order by version',
      [userId],
    );
    expect(plans.rows).toEqual([
      { status: 'superseded', version: 1 },
      { status: 'active', version: 2 },
    ]);
  });

  it('records an honest infeasibility result when no exercise matches the equipment/location/limitations', async () => {
    // Every catalog exercise with no equipment requirement is tagged for at least one of these
    // contraindications in the test fixture; combined with no declared equipment, nothing is eligible.
    const userId = await trainingUser({
      location: 'home',
      equipment_ids: [],
      limitation_tags: ['knee', 'lower_back', 'shoulder', 'wrist'],
    });
    const requestId = await requestRow(userId);
    const result = await handleWorkoutPlanGenerate(job(requestId, userId), pool, 'test', log);
    expect(result).toEqual({ status: 'failed_infeasible' });
    const row = await admin.query(
      'select status, safe_error_code from app.generation_requests where id = $1',
      [requestId],
    );
    expect(row.rows[0]).toEqual({ status: 'failed', safe_error_code: 'plan_infeasible' });
  });

  it('refuses to plan from a test_fixture-only exercise catalog in a deployed environment (D-029)', async () => {
    const userId = await trainingUser();
    const requestId = await requestRow(userId);
    const result = await handleWorkoutPlanGenerate(job(requestId, userId), pool, 'production', log);
    expect(result).toEqual({ status: 'failed_catalog_unavailable' });
    const row = await admin.query(
      'select status, safe_error_code from app.generation_requests where id = $1',
      [requestId],
    );
    expect(row.rows[0]).toEqual({ status: 'failed', safe_error_code: 'catalog_unavailable' });
    const plans = await admin.query(
      'select count(*)::int as n from app.workout_plans where user_id = $1',
      [userId],
    );
    expect(plans.rows[0]!.n).toBe(0);
  });

  it('fails honestly when the account is not eligible for automated plans', async () => {
    const userId = await trainingUser();
    await admin.query(
      "update app.profiles set eligibility_status = 'tracking_only' where user_id = $1",
      [userId],
    );
    const requestId = await requestRow(userId);
    const result = await handleWorkoutPlanGenerate(job(requestId, userId), pool, 'test', log);
    expect(result).toEqual({ status: 'failed_unavailable' });
  });

  it('fails honestly when training preferences are missing entirely', async () => {
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
               'eligible', now(), 1)`,
      [id],
    );
    const requestId = await requestRow(id);
    const result = await handleWorkoutPlanGenerate(job(requestId, id), pool, 'test', log);
    expect(result).toEqual({ status: 'failed_unavailable' });
  });
});
