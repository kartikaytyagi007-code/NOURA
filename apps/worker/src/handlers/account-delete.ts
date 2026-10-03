import type { AuthAdminProvider } from '@noura/billing';
import {
  withUserTransaction,
  type MediaStorage,
  type PoolLike,
  type QueuePayloads,
} from '@noura/domain';
import type { Job } from 'pg-boss';
import type { Logger } from 'pino';

interface DeletionRow {
  id: string;
  state: string;
}

/**
 * Handles `account.delete` (blueprint §14: "revokes app access, cancels queued jobs, removes Storage
 * objects and owned domain rows, then deletes the auth identity; retries incomplete steps").
 *
 * This runs as three SEPARATE transactions, not one, and that separation is load-bearing, not
 * cosmetic: `deleteUser` happens over the network (a real deployment) or on a second pooled
 * connection (the dev/test shim hook), and every app-owned table cascades off `auth.users(id) on
 * delete cascade`. Deleting the identity while this handler still held an open transaction that had
 * touched those same cascading rows would make the identity-delete's cascade block on this
 * transaction's own uncommitted row locks — a real deadlock risk, not merely a style preference.
 * Committing the cleanup transaction first, then calling `deleteUser` with no transaction open, then
 * opening a fresh transaction to record completion avoids that entirely. Each step reloads its own
 * state fresh and is a no-op once already done, so pg-boss's at-least-once retry of the whole handler
 * is always safe.
 *
 * `app.deletion_requests` carries `user_id` with no FK to `auth.users` specifically so this row (the
 * deletion tombstone, blueprint §14) — and the final "mark completed" transaction below — still work
 * after the identity is gone.
 */
export async function handleAccountDelete(
  [job]: Job<QueuePayloads['account.delete']>[],
  pool: PoolLike,
  storage: MediaStorage,
  authAdmin: AuthAdminProvider,
  log: Logger,
): Promise<{ status: string }> {
  if (!job) throw new Error('account.delete handler received an empty batch');
  const { deletion_request_id: requestId, user_id: userId } = job.data;

  const precheck = await withUserTransaction(pool, 'noura_worker', userId, async (client) => {
    const row = (
      await client.query<DeletionRow>(
        'select id, state from app.deletion_requests where id = $1 and user_id = $2',
        [requestId, userId],
      )
    ).rows[0];
    if (!row) return 'skipped_missing' as const;
    if (row.state === 'completed') return 'already_terminal' as const;
    return 'proceed' as const;
  });
  if (precheck !== 'proceed') {
    if (precheck === 'skipped_missing') {
      log.warn({ requestId }, 'account.delete: request not found for this user, skipping');
    }
    return { status: precheck };
  }

  // Step 1: cancel queued work and remove Storage objects, all inside one transaction that is fully
  // committed (and its locks released) before the identity is ever touched.
  await withUserTransaction(pool, 'noura_worker', userId, async (client) => {
    await client.query(`update app.deletion_requests set state = 'in_progress' where id = $1`, [
      requestId,
    ]);
    await client.query(
      `update app.generation_requests set status = 'cancelled', completed_at = now()
         where user_id = $1 and status in ('queued', 'running')`,
      [userId],
    );
    const media = (
      await client.query<{ bucket: string; object_path: string }>(
        `select bucket, object_path from app.media_assets where user_id = $1 and deleted_at is null`,
        [userId],
      )
    ).rows;
    for (const object of media) {
      try {
        await storage.deleteObject(object.bucket, object.object_path);
      } catch (error) {
        // Throwing rolls this transaction back to 'requested', so a retry tries Storage again before
        // ever reaching the identity delete below.
        log.error(
          { requestId, userId, err: error },
          'account.delete: storage object delete failed',
        );
        throw error;
      }
    }
    if (media.length > 0) {
      await client.query(
        `update app.media_assets set status = 'deleted', deleted_at = now()
           where user_id = $1 and deleted_at is null`,
        [userId],
      );
    }
  });

  // Step 2: delete the auth identity, with no open transaction on this connection pool holding locks
  // on the rows its cascade is about to remove.
  try {
    await authAdmin.deleteUser(userId);
  } catch (error) {
    log.error({ requestId, userId, err: error }, 'account.delete: auth identity delete failed');
    throw error;
  }

  // Step 3: record completion. `user_id` on deletion_requests has no FK, so this still succeeds even
  // though `auth.users` no longer has a matching row.
  await withUserTransaction(pool, 'noura_worker', userId, (client) =>
    client.query(
      `update app.deletion_requests set state = 'completed', completed_at = now() where id = $1`,
      [requestId],
    ),
  );
  log.info({ requestId, userId }, 'account.delete completed');
  return { status: 'completed' };
}
