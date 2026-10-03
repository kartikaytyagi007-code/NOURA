import {
  AppError,
  buildAdherenceSummary,
  isUuid,
  localDateInTimezone,
  subtractDays,
  todayInTimezone,
  validateWeightEntry,
  type MediaStorage,
  type Queryable,
} from '@noura/domain';
import type { components } from '@noura/contracts';
import { deleteMedia } from '../media/service.js';

type Schemas = components['schemas'];

const PAGE_SIZE_DEFAULT = 20;

function encodeCursor(measuredAtIso: string, id: string): string {
  return Buffer.from(JSON.stringify({ t: measuredAtIso, id })).toString('base64url');
}

function decodeCursor(cursor: string | undefined): { t: string; id: string } | null {
  if (!cursor) return null;
  try {
    const parsed = JSON.parse(Buffer.from(cursor, 'base64url').toString('utf8')) as {
      t?: unknown;
      id?: unknown;
    };
    if (typeof parsed.t === 'string' && typeof parsed.id === 'string') {
      return { t: parsed.t, id: parsed.id };
    }
    return null;
  } catch {
    return null;
  }
}

// -------------------------------------------------------------------- weight logs

interface WeightLogRow {
  id: string;
  client_id: string;
  measured_at: Date;
  weight_kg: string;
}

function toWeightLog(row: WeightLogRow): Schemas['WeightLog'] {
  return {
    id: row.id,
    client_id: row.client_id,
    measured_at: row.measured_at.toISOString(),
    weight_kg: Number(row.weight_kg),
  };
}

export async function createWeightLog(
  client: Queryable,
  userId: string,
  body: Schemas['CreateWeightLogRequest'],
): Promise<Schemas['WeightLog']> {
  const errors = validateWeightEntry({ measuredAtIso: body.measured_at, weightKg: body.weight_kg });
  if (errors.length) {
    throw new AppError('VALIDATION_ERROR', 'Invalid weight entry.', { fieldErrors: errors });
  }

  const existing = (
    await client.query<WeightLogRow>(
      `select id, client_id, measured_at, weight_kg::text as weight_kg
         from app.weight_logs where user_id = $1 and client_id = $2`,
      [userId, body.client_id],
    )
  ).rows[0];
  if (existing) return toWeightLog(existing); // idempotent replay by client_id

  const inserted = (
    await client.query<WeightLogRow>(
      `insert into app.weight_logs (user_id, client_id, measured_at, weight_kg)
       values ($1, $2, $3, $4)
       returning id, client_id, measured_at, weight_kg::text as weight_kg`,
      [userId, body.client_id, body.measured_at, body.weight_kg],
    )
  ).rows[0]!;
  return toWeightLog(inserted);
}

export async function listWeightLogs(
  client: Queryable,
  userId: string,
  cursor: string | undefined,
  limit: number | undefined,
): Promise<Schemas['WeightLogList']> {
  const pageSize = limit ?? PAGE_SIZE_DEFAULT;
  const decoded = decodeCursor(cursor);
  const params: unknown[] = [userId];
  let where = 'user_id = $1';
  if (decoded) {
    params.push(decoded.t, decoded.id);
    where += ` and (measured_at, id) < ($2, $3)`;
  }
  params.push(pageSize + 1);
  const { rows } = await client.query<WeightLogRow>(
    `select id, client_id, measured_at, weight_kg::text as weight_kg
       from app.weight_logs where ${where}
       order by measured_at desc, id desc limit $${params.length}`,
    params,
  );
  const hasMore = rows.length > pageSize;
  const page = hasMore ? rows.slice(0, pageSize) : rows;
  const last = page[page.length - 1];
  return {
    items: page.map(toWeightLog),
    next_cursor: hasMore && last ? encodeCursor(last.measured_at.toISOString(), last.id) : null,
  };
}

export async function deleteWeightLog(
  client: Queryable,
  userId: string,
  id: string,
): Promise<Schemas['Deleted']> {
  if (!isUuid(id)) throw new AppError('NOT_FOUND', 'Resource not found.');
  const deleted = await client.query('delete from app.weight_logs where id = $1 and user_id = $2', [
    id,
    userId,
  ]);
  if (deleted.rowCount === 0) throw new AppError('NOT_FOUND', 'Resource not found.');
  return { id, deleted: true };
}

// -------------------------------------------------------------------- progress photos

interface ProgressPhotoRow {
  id: string;
  media_id: string;
  captured_at: Date;
  angle: Schemas['PhotoAngle'];
}

function toProgressPhoto(row: ProgressPhotoRow): Schemas['ProgressPhoto'] {
  return {
    id: row.id,
    media_id: row.media_id,
    captured_at: row.captured_at.toISOString(),
    angle: row.angle,
  };
}

export async function createProgressPhoto(
  client: Queryable,
  userId: string,
  body: Schemas['CreateProgressPhotoRequest'],
): Promise<Schemas['ProgressPhoto']> {
  // The media asset must be the caller's own, uploaded for this exact purpose, and verified — the
  // same ownership gate M4 applies before a meal photo is used for anything (docs/decisions.md D-026).
  const media = (
    await client.query<{ id: string }>(
      `select id from app.media_assets
         where id = $1 and user_id = $2 and purpose = 'progress_photo' and status = 'verified'`,
      [body.media_id, userId],
    )
  ).rows[0];
  if (!media) {
    throw new AppError('NOT_FOUND', 'That media is not a verified progress-photo upload of yours.');
  }

  const existing = (
    await client.query<ProgressPhotoRow>(
      `select id, media_asset_id as media_id, captured_at, angle
         from app.progress_photos where user_id = $1 and media_asset_id = $2`,
      [userId, body.media_id],
    )
  ).rows[0];
  if (existing) return toProgressPhoto(existing); // idempotent replay by media_id

  const inserted = (
    await client.query<ProgressPhotoRow>(
      `insert into app.progress_photos (user_id, media_asset_id, captured_at, angle)
       values ($1, $2, $3, $4)
       returning id, media_asset_id as media_id, captured_at, angle`,
      [userId, body.media_id, body.captured_at, body.angle],
    )
  ).rows[0]!;
  return toProgressPhoto(inserted);
}

export async function listProgressPhotos(
  client: Queryable,
  userId: string,
  cursor: string | undefined,
  limit: number | undefined,
): Promise<Schemas['ProgressPhotoList']> {
  const pageSize = limit ?? PAGE_SIZE_DEFAULT;
  const decoded = decodeCursor(cursor);
  const params: unknown[] = [userId];
  let where = 'user_id = $1';
  if (decoded) {
    params.push(decoded.t, decoded.id);
    where += ` and (captured_at, id) < ($2, $3)`;
  }
  params.push(pageSize + 1);
  const { rows } = await client.query<ProgressPhotoRow>(
    `select id, media_asset_id as media_id, captured_at, angle
       from app.progress_photos where ${where}
       order by captured_at desc, id desc limit $${params.length}`,
    params,
  );
  const hasMore = rows.length > pageSize;
  const page = hasMore ? rows.slice(0, pageSize) : rows;
  const last = page[page.length - 1];
  return {
    items: page.map(toProgressPhoto),
    next_cursor: hasMore && last ? encodeCursor(last.captured_at.toISOString(), last.id) : null,
  };
}

export async function deleteProgressPhoto(
  client: Queryable,
  storage: MediaStorage,
  userId: string,
  id: string,
): Promise<Schemas['Deleted']> {
  if (!isUuid(id)) throw new AppError('NOT_FOUND', 'Resource not found.');
  const row = (
    await client.query<{ media_asset_id: string }>(
      'select media_asset_id from app.progress_photos where id = $1 and user_id = $2',
      [id, userId],
    )
  ).rows[0];
  if (!row) throw new AppError('NOT_FOUND', 'Resource not found.');

  await client.query('delete from app.progress_photos where id = $1 and user_id = $2', [
    id,
    userId,
  ]);
  // Deletion actually removes access: the backing media object is deleted too, not merely unlinked.
  await deleteMedia(client, storage, userId, row.media_asset_id).catch(() => {
    // The progress-photo reference is already gone either way; best-effort on the underlying media.
  });
  return { id, deleted: true };
}

// -------------------------------------------------------------------- GET /v1/progress

interface ProfileRow {
  weight_kg: string | null;
  timezone: string;
}

interface GoalRow {
  target_weight_kg: string | null;
}

interface PlanMealRow {
  id: string;
  meal_date: Date;
}

interface SessionRow {
  id: string;
  session_date: Date;
}

function isoDate(d: Date): string {
  return d.toISOString().slice(0, 10);
}

/**
 * Weight trends and honest consistency summaries (blueprint §6, §16 "M8 Progress"; D-030). Every
 * count here is read-only and computed purely from already-recorded app data: no inference from
 * missing data, and no claim of causation between weight change and adherence.
 */
export async function getProgress(client: Queryable, userId: string): Promise<Schemas['Progress']> {
  const profile = (
    await client.query<ProfileRow>(
      'select weight_kg::text as weight_kg, timezone from app.profiles where user_id = $1',
      [userId],
    )
  ).rows[0];
  const timezone = profile?.timezone ?? 'UTC';
  const today = todayInTimezone(timezone);
  const periodStart = subtractDays(today, 29); // 30-day window, inclusive (blueprint "period=30d").

  const goal = (
    await client.query<GoalRow>(
      'select target_weight_kg::text as target_weight_kg from app.goals where user_id = $1 and active_to is null',
      [userId],
    )
  ).rows[0];

  const allWeights = (
    await client.query<WeightLogRow>(
      `select id, client_id, measured_at, weight_kg::text as weight_kg
         from app.weight_logs where user_id = $1 order by measured_at asc`,
      [userId],
    )
  ).rows;
  const profileWeightKg =
    profile?.weight_kg !== null && profile?.weight_kg !== undefined
      ? Number(profile.weight_kg)
      : null;
  const startingWeightKg = allWeights[0] ? Number(allWeights[0].weight_kg) : profileWeightKg;
  const currentWeightKg =
    allWeights.length > 0 ? Number(allWeights[allWeights.length - 1]!.weight_kg) : profileWeightKg;
  const goalWeightKg =
    goal?.target_weight_kg !== null && goal?.target_weight_kg !== undefined
      ? Number(goal.target_weight_kg)
      : null;

  const weightPoints: Schemas['WeightPoint'][] = allWeights
    .map((row) => ({
      date: localDateInTimezone(row.measured_at, timezone),
      weight_kg: Number(row.weight_kg),
    }))
    .filter((p) => p.date >= periodStart && p.date <= today);

  const mealLoggedDays = (
    await client.query<{ n: number }>(
      `select count(distinct local_date)::int as n from app.meal_logs
         where user_id = $1 and local_date between $2 and $3`,
      [userId, periodStart, today],
    )
  ).rows[0]!.n;

  // Meal-plan adherence: only meaningful against the user's own active plan, over days already elapsed.
  const activeDietPlan = (
    await client.query<{ id: string }>(
      "select id from app.diet_plans where user_id = $1 and status = 'active' order by version desc limit 1",
      [userId],
    )
  ).rows[0];
  const dietAdherence = activeDietPlan
    ? await (async () => {
        const planned = (
          await client.query<PlanMealRow>(
            `select id, meal_date from app.diet_plan_meals
               where user_id = $1 and plan_id = $2 and meal_date between $3 and $4`,
            [userId, activeDietPlan.id, periodStart, today],
          )
        ).rows;
        const plannedIds = planned.map((r) => r.id);
        const logged = plannedIds.length
          ? (
              await client.query<{ n: number }>(
                'select count(*)::int as n from app.meal_logs where user_id = $1 and plan_meal_id = any($2::uuid[])',
                [userId, plannedIds],
              )
            ).rows[0]!.n
          : 0;
        return buildAdherenceSummary(
          true,
          planned.map((r) => isoDate(r.meal_date)),
          today,
          logged,
        );
      })()
    : buildAdherenceSummary(false, [], today, 0);

  // Workout consistency: scheduled sessions already elapsed, excluding future sessions and
  // rest days (no session row exists for a rest day), mirroring the blueprint's own wording.
  const activeWorkoutPlan = (
    await client.query<{ id: string }>(
      "select id from app.workout_plans where user_id = $1 and status = 'active' order by version desc limit 1",
      [userId],
    )
  ).rows[0];
  let workoutsScheduledElapsed = 0;
  let workoutsCompleted = 0;
  const workoutAdherence = activeWorkoutPlan
    ? await (async () => {
        const sessions = (
          await client.query<SessionRow>(
            `select id, session_date from app.workout_plan_sessions
               where user_id = $1 and plan_id = $2 and status <> 'cancelled'
                 and session_date between $3 and $4`,
            [userId, activeWorkoutPlan.id, periodStart, today],
          )
        ).rows;
        const sessionIds = sessions.map((s) => s.id);
        workoutsScheduledElapsed = sessions.length;
        workoutsCompleted = sessionIds.length
          ? (
              await client.query<{ n: number }>(
                `select count(distinct session_id)::int as n from app.workout_logs
                   where user_id = $1 and session_id = any($2::uuid[]) and status = 'completed'`,
                [userId, sessionIds],
              )
            ).rows[0]!.n
          : 0;
        return buildAdherenceSummary(
          true,
          sessions.map((s) => isoDate(s.session_date)),
          today,
          workoutsCompleted,
        );
      })()
    : buildAdherenceSummary(false, [], today, 0);

  return {
    period_start: periodStart,
    period_end: today,
    weight_points: weightPoints,
    starting_weight_kg: startingWeightKg,
    current_weight_kg: currentWeightKg,
    goal_weight_kg: goalWeightKg,
    meal_logged_days: mealLoggedDays,
    diet_adherence: dietAdherence,
    workouts_completed: workoutsCompleted,
    workouts_scheduled_elapsed: workoutsScheduledElapsed,
    workout_adherence: workoutAdherence,
  };
}
