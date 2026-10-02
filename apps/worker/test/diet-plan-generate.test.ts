import { randomUUID } from 'node:crypto';
import pg from 'pg';
import { pino } from 'pino';
import { afterAll, describe, expect, it } from 'vitest';
import { handleDietPlanGenerate } from '../src/handlers/diet-plan-generate.js';

const log = pino({ level: 'silent' });
const admin = new pg.Pool({ connectionString: process.env.DATABASE_URL, max: 4 });
const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL, max: 4 });

afterAll(async () => {
  await admin.end();
  await pool.end();
});

async function eligibleUser(
  overrides: { diet_type?: string | null; allergy_ids?: string[] } = {},
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
             'eligible', now(), 3)`,
    [id],
  );
  await admin.query(
    `insert into app.user_preferences (user_id, diet_type, allergy_ids, meals_per_day, revision)
     values ($1, $2, $3, 3, 1)`,
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
        targets: { energy_kcal: 2000, protein_g: 70, fibre_g: 28, carbohydrate_g: 250, fat_g: 65 },
        warnings: [],
      }),
    ],
  );
  return id;
}

async function requestRow(userId: string, type = 'diet_plan'): Promise<string> {
  const { rows } = await admin.query<{ id: string }>(
    'insert into app.generation_requests (user_id, request_type, input_revision) values ($1, $2, 3) returning id',
    [userId, type],
  );
  return rows[0]!.id;
}

describe('handleDietPlanGenerate', () => {
  it('generates a 7-day active plan and marks the request completed', async () => {
    const userId = await eligibleUser();
    const requestId = await requestRow(userId);
    const result = await handleDietPlanGenerate(
      [{ id: requestId, data: { generation_request_id: requestId, user_id: userId } } as never],
      pool,
      'test',
      log,
    );
    expect(result).toEqual({ status: 'completed' });

    const request = await admin.query(
      'select status, result_ids from app.generation_requests where id = $1',
      [requestId],
    );
    expect(request.rows[0]!.status).toBe('completed');
    const planId = request.rows[0]!.result_ids.diet_plan_id;
    expect(planId).toBeTruthy();

    const plan = await admin.query('select status, version from app.diet_plans where id = $1', [
      planId,
    ]);
    expect(plan.rows[0]).toMatchObject({ status: 'active', version: 1 });

    const meals = await admin.query(
      'select count(*)::int as n from app.diet_plan_meals where plan_id = $1',
      [planId],
    );
    expect(meals.rows[0]!.n).toBe(21); // 7 days x 3 meals (breakfast/lunch/dinner)
  });

  it('is idempotent on generation_request_id: redelivery never creates a second plan', async () => {
    const userId = await eligibleUser();
    const requestId = await requestRow(userId);
    const job = [
      { id: requestId, data: { generation_request_id: requestId, user_id: userId } } as never,
    ];
    await handleDietPlanGenerate(job, pool, 'test', log);
    // The first run already marked the request completed, so redelivery is caught by the terminal
    // check; a separate test below covers the crash-before-marked-terminal path explicitly.
    const second = await handleDietPlanGenerate(job, pool, 'test', log);
    expect(second.status).toBe('already_terminal');
    const plans = await admin.query(
      'select count(*)::int as n from app.diet_plans where user_id = $1',
      [userId],
    );
    expect(plans.rows[0]!.n).toBe(1);
  });

  it('recovers from a crash between committing the plan and marking the request terminal', async () => {
    const userId = await eligibleUser();
    const requestId = await requestRow(userId);
    const job = [
      { id: requestId, data: { generation_request_id: requestId, user_id: userId } } as never,
    ];
    await handleDietPlanGenerate(job, pool, 'test', log);
    // Simulate the crash: the plan is committed, but roll the request back to queued/unstarted.
    await admin.query(
      "update app.generation_requests set status = 'queued', completed_at = null, safe_error_code = null, result_ids = '{}' where id = $1",
      [requestId],
    );
    const result = await handleDietPlanGenerate(job, pool, 'test', log);
    expect(result).toEqual({ status: 'already_generated' });
    const plans = await admin.query(
      'select count(*)::int as n from app.diet_plans where user_id = $1',
      [userId],
    );
    expect(plans.rows[0]!.n).toBe(1);
    const row = await admin.query('select status from app.generation_requests where id = $1', [
      requestId,
    ]);
    expect(row.rows[0]!.status).toBe('completed');
  });

  it('is a no-op once the request is already terminal', async () => {
    const userId = await eligibleUser();
    const requestId = await requestRow(userId);
    await admin.query(
      "update app.generation_requests set status = 'cancelled', completed_at = now() where id = $1",
      [requestId],
    );
    const result = await handleDietPlanGenerate(
      [{ id: requestId, data: { generation_request_id: requestId, user_id: userId } } as never],
      pool,
      'test',
      log,
    );
    expect(result).toEqual({ status: 'already_terminal' });
  });

  it('supersedes the previous active plan on regeneration, keeping exactly one active version', async () => {
    const userId = await eligibleUser();
    const first = await requestRow(userId);
    await handleDietPlanGenerate(
      [{ id: first, data: { generation_request_id: first, user_id: userId } } as never],
      pool,
      'test',
      log,
    );
    const second = await requestRow(userId, 'plan_regeneration');
    await handleDietPlanGenerate(
      [{ id: second, data: { generation_request_id: second, user_id: userId } } as never],
      pool,
      'test',
      log,
    );
    const plans = await admin.query<{ status: string; version: number }>(
      'select status, version from app.diet_plans where user_id = $1 order by version',
      [userId],
    );
    expect(plans.rows).toEqual([
      { status: 'superseded', version: 1 },
      { status: 'active', version: 2 },
    ]);
  });

  it('records an honest infeasibility result rather than fabricating a plan', async () => {
    // Every breakfast recipe in the fixture carries one of these allergens, so none is eligible.
    const userId = await eligibleUser({
      allergy_ids: ['egg', 'gluten', 'tree_nut', 'soy', 'milk'],
    });
    const requestId = await requestRow(userId);
    const result = await handleDietPlanGenerate(
      [{ id: requestId, data: { generation_request_id: requestId, user_id: userId } } as never],
      pool,
      'test',
      log,
    );
    expect(result).toEqual({ status: 'failed_infeasible' });
    const row = await admin.query(
      'select status, safe_error_code from app.generation_requests where id = $1',
      [requestId],
    );
    expect(row.rows[0]).toEqual({ status: 'failed', safe_error_code: 'plan_infeasible' });
  });

  it('refuses to plan from a test_fixture-only catalog in a deployed environment (D-025)', async () => {
    const userId = await eligibleUser();
    const requestId = await requestRow(userId);
    const result = await handleDietPlanGenerate(
      [{ id: requestId, data: { generation_request_id: requestId, user_id: userId } } as never],
      pool,
      'production',
      log,
    );
    expect(result).toEqual({ status: 'failed_catalog_unavailable' });
    const row = await admin.query(
      'select status, safe_error_code from app.generation_requests where id = $1',
      [requestId],
    );
    expect(row.rows[0]).toEqual({ status: 'failed', safe_error_code: 'catalog_unavailable' });
    const plans = await admin.query(
      'select count(*)::int as n from app.diet_plans where user_id = $1',
      [userId],
    );
    expect(plans.rows[0]!.n).toBe(0);
  });

  it('fails honestly when the account is not eligible for automated plans', async () => {
    const userId = await eligibleUser();
    await admin.query(
      "update app.profiles set eligibility_status = 'tracking_only' where user_id = $1",
      [userId],
    );
    const requestId = await requestRow(userId);
    const result = await handleDietPlanGenerate(
      [{ id: requestId, data: { generation_request_id: requestId, user_id: userId } } as never],
      pool,
      'test',
      log,
    );
    expect(result).toEqual({ status: 'failed_unavailable' });
  });
});
