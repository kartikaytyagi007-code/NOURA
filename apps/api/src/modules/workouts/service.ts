import {
  AppError,
  loadCatalogExercises,
  loadExerciseSubstitutions,
  loadWorkoutPlanningInputs,
  substitutionsFor,
  type CatalogExercise,
  type Queryable,
} from '@noura/domain';
import type { components } from '@noura/contracts';

type Schemas = components['schemas'];

const conflict = (what: string) =>
  new AppError(
    'REVISION_CONFLICT',
    `Your ${what} changed since you loaded it. Reload and try again.`,
  );

const UNAVAILABLE = new AppError(
  'CONSTRAINT_CONFLICT',
  'Automated workout plans are not available for this account.',
);

function exerciseRef(exercise: CatalogExercise | null): Schemas['ExerciseRef'] | null {
  return exercise ? { id: exercise.id, name: exercise.name } : null;
}

// ---------------------------------------------------------------- generateWorkoutPlan

export async function requestWorkoutPlanGeneration(
  client: Queryable,
  userId: string,
  body: Schemas['GeneratePlanRequest'],
): Promise<Schemas['JobAccepted']> {
  const inputs = await loadWorkoutPlanningInputs(client, userId);
  if (inputs.eligibilityStatus !== 'eligible' || !inputs.hasCompleteTrainingPreferences) {
    throw UNAVAILABLE;
  }
  if (inputs.trainingRevision !== body.profile_revision) {
    throw conflict('training preferences');
  }

  // Always request_type 'workout_plan': 'plan_regeneration' is already claimed by the diet-plan
  // queue mapping (docs/decisions.md D-029), so regenerations reuse the same request type.
  const inserted = await client.query<{ id: string }>(
    `insert into app.generation_requests (user_id, request_type, input_revision)
     values ($1, 'workout_plan', $2)
     on conflict do nothing
     returning id`,
    [userId, body.profile_revision],
  );
  const id =
    inserted.rows[0]?.id ??
    (
      await client.query<{ id: string }>(
        `select id from app.generation_requests
           where user_id = $1 and request_type = 'workout_plan' and status in ('queued', 'running')
           order by created_at desc limit 1`,
        [userId],
      )
    ).rows[0]?.id;
  if (!id) throw new AppError('INTERNAL_ERROR', 'The workout plan request could not be recorded.');
  return { job_id: id };
}

// ---------------------------------------------------------------- getCurrentWorkoutPlan

interface WorkoutPlanRow {
  id: string;
  version: number;
  starts_on: Date;
  status: 'draft' | 'active' | 'superseded' | 'cancelled';
  revision: number;
}

interface SessionRow {
  id: string;
  session_date: Date;
  session_order: number;
  title: string;
  status: Schemas['WorkoutSession']['status'];
}

interface ExerciseRow {
  id: string;
  session_id: string;
  exercise_id: string;
  ordinal: number;
  sets: number;
  reps_min: number;
  reps_max: number;
  rest_sec: number;
  effort_cue: string | null;
  prescription_snapshot: unknown;
}

function isoDate(d: Date): string {
  return d.toISOString().slice(0, 10);
}

export async function getCurrentWorkoutPlan(
  client: Queryable,
  userId: string,
): Promise<Schemas['WorkoutPlan']> {
  const plan = (
    await client.query<WorkoutPlanRow>(
      `select id, version, starts_on, status, revision from app.workout_plans
         where user_id = $1 and status = 'active' order by version desc limit 1`,
      [userId],
    )
  ).rows[0];
  if (!plan) throw new AppError('NOT_FOUND', 'No active workout plan.');

  const sessions = (
    await client.query<SessionRow>(
      `select id, session_date, session_order, title, status from app.workout_plan_sessions
         where user_id = $1 and plan_id = $2 order by session_order`,
      [userId, plan.id],
    )
  ).rows;
  const sessionIds = sessions.map((s) => s.id);
  const exercises = sessionIds.length
    ? (
        await client.query<ExerciseRow>(
          `select id, session_id, exercise_id, ordinal, sets, reps_min, reps_max, rest_sec, effort_cue,
                  prescription_snapshot
             from app.workout_plan_exercises where user_id = $1 and session_id = any($2::uuid[])
             order by session_id, ordinal`,
          [userId, sessionIds],
        )
      ).rows
    : [];
  const bySession = new Map<string, ExerciseRow[]>();
  for (const ex of exercises) {
    const list = bySession.get(ex.session_id) ?? [];
    list.push(ex);
    bySession.set(ex.session_id, list);
  }

  return {
    id: plan.id,
    version: plan.version,
    starts_on: isoDate(plan.starts_on),
    revision: plan.revision,
    sessions: sessions.map((s) => ({
      id: s.id,
      date: isoDate(s.session_date),
      order: s.session_order,
      title: s.title,
      status: s.status,
      exercises: (bySession.get(s.id) ?? []).map((ex) => {
        const snapshot = ex.prescription_snapshot as { exercise_name?: string } | null;
        return {
          id: ex.id,
          exercise: {
            id: ex.exercise_id,
            name: snapshot?.exercise_name ?? 'Exercise',
          },
          ordinal: ex.ordinal,
          sets: ex.sets,
          reps_min: ex.reps_min,
          reps_max: ex.reps_max,
          rest_sec: ex.rest_sec,
          effort_cue: ex.effort_cue,
        };
      }),
    })),
  };
}

// ---------------------------------------------------------------- getExerciseSubstitutions

interface ExistsRow {
  id: string;
}

export async function getExerciseSubstitutions(
  client: Queryable,
  userId: string,
  exerciseId: string,
): Promise<Schemas['Substitutions']> {
  const exists = (
    await client.query<ExistsRow>('select id from app.exercises where id = $1', [exerciseId])
  ).rows[0];
  if (!exists) throw new AppError('NOT_FOUND', 'Exercise not found.');

  const inputs = await loadWorkoutPlanningInputs(client, userId);
  const [exercises, relationships] = await Promise.all([
    loadCatalogExercises(client),
    loadExerciseSubstitutions(client),
  ]);
  const candidates = substitutionsFor({
    exerciseId,
    exercises,
    relationships,
    constraints: inputs.constraints,
  });

  return {
    exercise_id: exerciseId,
    candidates: candidates.map((c) => ({
      exercise: exerciseRef(c.exercise) as Schemas['ExerciseRef'],
      equipment_tags: c.exercise.equipment_tags,
      reason: c.reason,
    })),
  };
}

// ---------------------------------------------------------------- workout logs

interface SetLogRow {
  exercise_id: string;
  set_ordinal: number;
  reps: number | null;
  load_kg: string | null;
  skipped: boolean;
}

interface LogRow {
  id: string;
  client_id: string;
  session_id: string;
  status: Schemas['WorkoutLog']['status'];
  started_at: Date | null;
  completed_at: Date | null;
  revision: number;
}

async function loadSets(client: Queryable, userId: string, logId: string): Promise<SetLogRow[]> {
  const { rows } = await client.query<SetLogRow>(
    `select exercise_id, set_ordinal, reps, load_kg::text as load_kg, skipped
       from app.workout_set_logs where user_id = $1 and workout_log_id = $2
       order by exercise_id, set_ordinal`,
    [userId, logId],
  );
  return rows;
}

async function toWorkoutLog(
  client: Queryable,
  userId: string,
  row: LogRow,
): Promise<Schemas['WorkoutLog']> {
  const sets = await loadSets(client, userId, row.id);
  return {
    id: row.id,
    client_id: row.client_id,
    session_id: row.session_id,
    status: row.status,
    started_at: row.started_at?.toISOString() ?? null,
    completed_at: row.completed_at?.toISOString() ?? null,
    sets: sets.map((s) => ({
      exercise_id: s.exercise_id,
      set_ordinal: s.set_ordinal,
      reps: s.reps,
      load_kg: s.load_kg === null ? null : Number(s.load_kg),
      skipped: s.skipped,
    })),
    revision: row.revision,
  };
}

export async function createWorkoutLog(
  client: Queryable,
  userId: string,
  body: Schemas['CreateWorkoutLogRequest'],
): Promise<Schemas['WorkoutLog']> {
  const session = (
    await client.query<ExistsRow>(
      'select id from app.workout_plan_sessions where user_id = $1 and id = $2',
      [userId, body.session_id],
    )
  ).rows[0];
  if (!session) throw new AppError('NOT_FOUND', 'Workout session not found.');

  const existing = (
    await client.query<{ id: string }>(
      'select id from app.workout_logs where user_id = $1 and client_id = $2',
      [userId, body.client_id],
    )
  ).rows[0];
  const row = existing
    ? (
        await client.query<LogRow>(
          `select id, client_id, session_id, status, started_at, completed_at, revision
             from app.workout_logs where id = $1 and user_id = $2`,
          [existing.id, userId],
        )
      ).rows[0]!
    : (
        await client.query<LogRow>(
          `insert into app.workout_logs (user_id, client_id, session_id, started_at)
           values ($1, $2, $3, coalesce($4, now()))
           returning id, client_id, session_id, status, started_at, completed_at, revision`,
          [userId, body.client_id, body.session_id, body.started_at ?? null],
        )
      ).rows[0]!;

  return toWorkoutLog(client, userId, row);
}

async function loadOwnedLog(client: Queryable, userId: string, id: string): Promise<LogRow> {
  const row = (
    await client.query<LogRow>(
      `select id, client_id, session_id, status, started_at, completed_at, revision
         from app.workout_logs where user_id = $1 and id = $2`,
      [userId, id],
    )
  ).rows[0];
  if (!row) throw new AppError('NOT_FOUND', 'Workout log not found.');
  return row;
}

export async function putWorkoutSets(
  client: Queryable,
  userId: string,
  id: string,
  body: Schemas['PutWorkoutSetsRequest'],
): Promise<Schemas['WorkoutLog']> {
  const log = await loadOwnedLog(client, userId, id);
  if (log.revision !== body.expected_revision) throw conflict('workout log');

  // Every logged exercise must belong to this log's own session (ownership/consistency, not the
  // user's catalog at large) — the ticket's "authorization and ownership" requirement extended to
  // the exercise identity within a session, not just the log row itself.
  const sessionExerciseIds = new Set(
    (
      await client.query<{ exercise_id: string }>(
        'select exercise_id from app.workout_plan_exercises where user_id = $1 and session_id = $2',
        [userId, log.session_id],
      )
    ).rows.map((r) => r.exercise_id),
  );
  for (const set of body.sets) {
    if (!sessionExerciseIds.has(set.exercise_id)) {
      throw new AppError('VALIDATION_ERROR', 'That exercise is not part of this session.', {
        fieldErrors: [
          { field: 'body.sets.exercise_id', code: 'invalid', message: 'not in this session' },
        ],
      });
    }
  }

  const updated = await client.query<{ revision: number }>(
    `update app.workout_logs set revision = revision + 1 where user_id = $1 and id = $2 and revision = $3
       returning revision`,
    [userId, id, body.expected_revision],
  );
  if (!updated.rows[0]) throw conflict('workout log');

  await client.query(
    'delete from app.workout_set_logs where user_id = $1 and workout_log_id = $2',
    [userId, id],
  );
  for (const set of body.sets) {
    await client.query(
      `insert into app.workout_set_logs (user_id, workout_log_id, exercise_id, set_ordinal, reps, load_kg, skipped)
       values ($1, $2, $3, $4, $5, $6, $7)`,
      [userId, id, set.exercise_id, set.set_ordinal, set.reps, set.load_kg, set.skipped],
    );
  }

  const refreshed = await loadOwnedLog(client, userId, id);
  return toWorkoutLog(client, userId, refreshed);
}

export async function patchWorkoutLog(
  client: Queryable,
  userId: string,
  id: string,
  body: Schemas['PatchWorkoutLogRequest'],
): Promise<Schemas['WorkoutLog']> {
  const log = await loadOwnedLog(client, userId, id);
  if (log.revision !== body.expected_revision) throw conflict('workout log');

  const completedAt =
    body.status === 'completed' || body.status === 'abandoned'
      ? (body.completed_at ?? new Date().toISOString())
      : null;

  const updated = await client.query<{ revision: number }>(
    `update app.workout_logs
       set status = $3, completed_at = $4, revision = revision + 1
       where user_id = $1 and id = $2 and revision = $5
       returning revision`,
    [userId, id, body.status, completedAt, body.expected_revision],
  );
  if (!updated.rows[0]) throw conflict('workout log');

  const refreshed = await loadOwnedLog(client, userId, id);
  return toWorkoutLog(client, userId, refreshed);
}
