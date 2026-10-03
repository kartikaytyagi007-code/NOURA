import {
  buildPrescriptionSnapshot,
  catalogGate,
  filterEligibleExercises,
  generateWorkoutPlan,
  loadCatalogExercises,
  loadWorkoutPlanningInputs,
  withUserTransaction,
  type AppEnv,
  type PoolLike,
  type QueuePayloads,
  type Queryable,
} from '@noura/domain';
import type { Job } from 'pg-boss';
import type { Logger } from 'pino';

interface RequestRow {
  id: string;
  user_id: string;
  status: 'queued' | 'running' | 'completed' | 'failed' | 'cancelled';
}

async function markTerminal(
  client: Queryable,
  requestId: string,
  patch: {
    status: 'completed' | 'failed';
    code?: string;
    message?: string;
    resultIds?: Record<string, string>;
  },
): Promise<void> {
  await client.query(
    `update app.generation_requests
       set status = $2, safe_error_code = $3, safe_error_message = $4, result_ids = $5::jsonb,
           completed_at = now()
       where id = $1`,
    [
      requestId,
      patch.status,
      patch.code ?? null,
      patch.message ?? null,
      JSON.stringify(patch.resultIds ?? {}),
    ],
  );
}

/**
 * Handles `workout-plan.generate` (docs/decisions.md D-029, mirroring D-025/D-017's diet-plan
 * handler). Idempotent on `generation_request_id`: everything is reloaded fresh under the user's own
 * transaction context, never trusted from the job payload, and a request that is already terminal (or
 * whose plan already exists) is a no-op.
 */
export async function handleWorkoutPlanGenerate(
  [job]: Job<QueuePayloads['workout-plan.generate']>[],
  pool: PoolLike,
  appEnv: AppEnv,
  log: Logger,
): Promise<{ status: string }> {
  if (!job) throw new Error('workout-plan.generate handler received an empty batch');
  const { generation_request_id: requestId, user_id: userId } = job.data;

  return withUserTransaction(pool, 'noura_worker', userId, async (client) => {
    const request = (
      await client.query<RequestRow>(
        `select id, user_id, status from app.generation_requests where id = $1 and user_id = $2`,
        [requestId, userId],
      )
    ).rows[0];
    if (!request) {
      log.warn({ requestId }, 'workout-plan.generate: request not found for this user, skipping');
      return { status: 'skipped_missing' };
    }
    if (
      request.status === 'completed' ||
      request.status === 'failed' ||
      request.status === 'cancelled'
    ) {
      return { status: 'already_terminal' };
    }

    const existingPlan = (
      await client.query<{ id: string }>(
        'select id from app.workout_plans where user_id = $1 and generation_request_id = $2',
        [userId, requestId],
      )
    ).rows[0];
    if (existingPlan) {
      await markTerminal(client, requestId, {
        status: 'completed',
        resultIds: { workout_plan_id: existingPlan.id },
      });
      return { status: 'already_generated' };
    }

    await client.query(
      `update app.generation_requests
         set status = 'running', attempts = attempts + 1, started_at = coalesce(started_at, now())
         where id = $1`,
      [requestId],
    );

    const inputs = await loadWorkoutPlanningInputs(client, userId);
    if (inputs.eligibilityStatus !== 'eligible' || !inputs.hasCompleteTrainingPreferences) {
      await markTerminal(client, requestId, {
        status: 'failed',
        code: 'planning_unavailable',
        message: 'Automated workout plans are not available for this account.',
      });
      return { status: 'failed_unavailable' };
    }

    const catalog = await loadCatalogExercises(client);
    const gate = catalogGate(appEnv, catalog);
    if (!gate.allowed) {
      await markTerminal(client, requestId, {
        status: 'failed',
        code: 'catalog_unavailable',
        message:
          gate.reason === 'no_catalog'
            ? 'No exercise catalog is available yet.'
            : 'A reviewed exercise catalog is required before workout plans can be generated here.',
      });
      return { status: 'failed_catalog_unavailable' };
    }

    const eligible = filterEligibleExercises(catalog, inputs.constraints);
    const result = generateWorkoutPlan({
      startsOn: new Date().toISOString().slice(0, 10),
      weekdays: inputs.weekdays,
      daysPerWeek: inputs.daysPerWeek ?? 0,
      durationMinutes: inputs.durationMinutes ?? 30,
      eligibleExercises: eligible,
    });
    if (!result.ok) {
      await markTerminal(client, requestId, {
        status: 'failed',
        code: result.reason === 'no_eligible_exercises' ? 'plan_infeasible' : 'plan_infeasible',
        message:
          result.reason === 'no_eligible_exercises'
            ? 'No eligible exercise is available for your equipment, location and limitations. Adjust your training preferences and try again.'
            : 'Not enough available training days are selected. Adjust your weekdays and try again.',
      });
      return { status: 'failed_infeasible' };
    }

    const previousActive = (
      await client.query<{ id: string; version: number }>(
        "select id, version from app.workout_plans where user_id = $1 and status = 'active' order by version desc limit 1",
        [userId],
      )
    ).rows[0];
    if (previousActive) {
      await client.query("update app.workout_plans set status = 'superseded' where id = $1", [
        previousActive.id,
      ]);
    }
    const version = (previousActive?.version ?? 0) + 1;

    const plan = (
      await client.query<{ id: string }>(
        `insert into app.workout_plans
           (user_id, version, profile_revision, starts_on, status, supersedes_id, generation_request_id)
         values ($1, $2, $3, $4, 'active', $5, $6)
         returning id`,
        [
          userId,
          version,
          inputs.trainingRevision ?? 1,
          result.plan.sessions[0]?.date ?? new Date().toISOString().slice(0, 10),
          previousActive?.id ?? null,
          requestId,
        ],
      )
    ).rows[0]!;

    for (const session of result.plan.sessions) {
      const sessionRow = (
        await client.query<{ id: string }>(
          `insert into app.workout_plan_sessions (user_id, plan_id, session_date, session_order, title)
           values ($1, $2, $3, $4, $5)
           returning id`,
          [userId, plan.id, session.date, session.session_order, session.title],
        )
      ).rows[0]!;

      for (const ex of session.exercises) {
        const snapshot = buildPrescriptionSnapshot(ex.exercise);
        await client.query(
          `insert into app.workout_plan_exercises
             (user_id, session_id, exercise_id, ordinal, sets, reps_min, reps_max, rest_sec, effort_cue, prescription_snapshot)
           values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10::jsonb)`,
          [
            userId,
            sessionRow.id,
            ex.exercise.id,
            ex.ordinal,
            ex.sets,
            ex.reps_min,
            ex.reps_max,
            ex.rest_sec,
            ex.effort_cue,
            JSON.stringify(snapshot),
          ],
        );
      }
    }

    await markTerminal(client, requestId, {
      status: 'completed',
      resultIds: { workout_plan_id: plan.id },
    });
    log.info({ requestId, userId, planId: plan.id, version }, 'workout-plan.generate completed');
    return { status: 'completed' };
  });
}
