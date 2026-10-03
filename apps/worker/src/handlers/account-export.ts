import { randomUUID } from 'node:crypto';
import {
  withUserTransaction,
  type MediaStorage,
  type PoolLike,
  type Queryable,
  type QueuePayloads,
} from '@noura/domain';
import type { Job } from 'pg-boss';
import type { Logger } from 'pino';

interface ExportRow {
  id: string;
  state: string;
}

async function collect<T>(client: Queryable, sql: string, userId: string): Promise<T[]> {
  return (await client.query<T>(sql, [userId])).rows;
}

/**
 * Builds the account-data export manifest (blueprint §14: "profile, plans, meal/workout/weight logs
 * and photo files/manifest, excluding secrets/provider internals"). Photo *bytes* are intentionally
 * not re-packaged here — the manifest lists each owned photo's capture date/angle/object path so the
 * user knows what is stored; downloading the private bucket itself is unrelated to this job and was
 * never in scope for any prior milestone either. This is a documented scope limit, not an oversight —
 * see docs/decisions.md and docs/milestones.md's M10 "known limitations".
 */
async function buildManifest(client: Queryable, userId: string): Promise<Record<string, unknown>> {
  // Sequential, not Promise.all: `client` is a single connection (one in-flight query at a time).
  const profile = await collect(client, 'select * from app.profiles where user_id = $1', userId);
  const preferences = await collect(
    client,
    'select * from app.user_preferences where user_id = $1',
    userId,
  );
  const training = await collect(
    client,
    'select * from app.training_preferences where user_id = $1',
    userId,
  );
  const goals = await collect(
    client,
    'select * from app.goals where user_id = $1 order by active_from',
    userId,
  );
  const dietPlans = await collect(
    client,
    'select * from app.diet_plans where user_id = $1 order by starts_on',
    userId,
  );
  const dietPlanMeals = await collect(
    client,
    'select * from app.diet_plan_meals where user_id = $1 order by meal_date',
    userId,
  );
  const workoutPlans = await collect(
    client,
    'select * from app.workout_plans where user_id = $1',
    userId,
  );
  const workoutLogs = await collect(
    client,
    'select * from app.workout_logs where user_id = $1 order by started_at',
    userId,
  );
  const mealLogs = await collect(
    client,
    'select * from app.meal_logs where user_id = $1 order by consumed_at',
    userId,
  );
  const weightLogs = await collect(
    client,
    'select * from app.weight_logs where user_id = $1 order by measured_at',
    userId,
  );
  const progressPhotos = await collect(
    client,
    `select p.id, p.captured_at, p.angle, m.bucket, m.object_path
       from app.progress_photos p join app.media_assets m on m.id = p.media_asset_id
      where p.user_id = $1 order by p.captured_at`,
    userId,
  );
  return {
    exported_at: new Date().toISOString(),
    user_id: userId,
    profile: profile[0] ?? null,
    preferences: preferences[0] ?? null,
    training_preferences: training[0] ?? null,
    goals,
    diet_plans: dietPlans,
    diet_plan_meals: dietPlanMeals,
    workout_plans: workoutPlans,
    workout_logs: workoutLogs,
    meal_logs: mealLogs,
    weight_logs: weightLogs,
    progress_photos_manifest: progressPhotos,
    note:
      'This is a data manifest, not a media archive: photo bytes are not included (private-Storage ' +
      'object paths are listed instead). Secrets, provider API keys and billing-provider internals ' +
      'are excluded.',
  };
}

/** Handles `account.export` (blueprint §14). Idempotent on the export_request id, same crash-recovery
 * shape as every other handler: a request already past `queued`/`running` is a no-op. */
export async function handleAccountExport(
  [job]: Job<QueuePayloads['account.export']>[],
  pool: PoolLike,
  storage: MediaStorage,
  log: Logger,
): Promise<{ status: string }> {
  if (!job) throw new Error('account.export handler received an empty batch');
  const { export_request_id: requestId, user_id: userId } = job.data;

  return withUserTransaction(pool, 'noura_worker', userId, async (client) => {
    const row = (
      await client.query<ExportRow>(
        'select id, state from app.export_requests where id = $1 and user_id = $2',
        [requestId, userId],
      )
    ).rows[0];
    if (!row) {
      log.warn({ requestId }, 'account.export: request not found for this user, skipping');
      return { status: 'skipped_missing' };
    }
    if (row.state === 'completed' || row.state === 'failed' || row.state === 'expired') {
      return { status: 'already_terminal' };
    }

    await client.query(`update app.export_requests set state = 'running' where id = $1`, [
      requestId,
    ]);

    // A query failure here aborts this transaction; letting it propagate (rather than writing another
    // query on the now-aborted connection) lets `withUserTransaction` roll back to 'queued' so pg-boss
    // retries the whole job, exactly like every other handler's transient-failure path.
    const manifest = await buildManifest(client, userId);

    const bytes = new TextEncoder().encode(JSON.stringify(manifest, null, 2));
    const mediaId = randomUUID();
    const objectPath = `${userId}/${mediaId}.json`;
    await client.query(
      `insert into app.media_assets
         (id, user_id, purpose, bucket, object_path, declared_mime, verified_mime, byte_size, status)
       values ($1, $2, 'export', 'exports', $3, 'application/json', 'application/json', $4, 'verified')`,
      [mediaId, userId, objectPath, bytes.byteLength],
    );
    await storage.writeObject('exports', objectPath, bytes, 'application/json');

    await client.query(
      `update app.export_requests set state = 'completed', result_media_id = $2, completed_at = now()
         where id = $1`,
      [requestId, mediaId],
    );
    log.info({ requestId, userId }, 'account.export completed');
    return { status: 'completed' };
  });
}
