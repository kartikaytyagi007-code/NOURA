import { AppError, isUuid, type Queryable } from '@noura/domain';
import type { MediaStorage } from '@noura/domain';
import type { components } from '@noura/contracts';

type Schemas = components['schemas'];

/** How recently the access token must have been issued for DELETE /account (blueprint §11). */
const RECENT_AUTH_MAX_AGE_SECONDS = 15 * 60;

export function requireRecentAuth(issuedAt: number | null): void {
  if (issuedAt === null || Date.now() / 1000 - issuedAt > RECENT_AUTH_MAX_AGE_SECONDS) {
    throw new AppError('VALIDATION_ERROR', 'Please sign in again to confirm account deletion.', {
      fieldErrors: [{ field: 'headers.authorization', code: 'stale', message: 'sign in again' }],
    });
  }
}

// -------------------------------------------------------------------- export

export async function requestAccountExport(
  client: Queryable,
  userId: string,
): Promise<Schemas['ExportAccepted']> {
  const inFlight = (
    await client.query<{ id: string }>(
      `select id from app.export_requests where user_id = $1 and state in ('queued', 'running')
         order by requested_at desc limit 1`,
      [userId],
    )
  ).rows[0];
  if (inFlight) {
    throw new AppError('QUOTA_EXCEEDED', 'An export is already in progress.', {
      retryable: true,
    });
  }
  const row = (
    await client.query<{ id: string }>(
      `insert into app.export_requests (user_id, state) values ($1, 'queued') returning id`,
      [userId],
    )
  ).rows[0]!;
  return { export_id: row.id, job_id: row.id };
}

interface ExportRow {
  id: string;
  state: Schemas['AccountExport']['state'];
  result_media_id: string | null;
}

export async function getAccountExport(
  client: Queryable,
  storage: MediaStorage,
  userId: string,
  id: string,
): Promise<Schemas['AccountExport']> {
  if (!isUuid(id)) throw new AppError('NOT_FOUND', 'Resource not found.');
  const row = (
    await client.query<ExportRow>(
      `select id, state, result_media_id from app.export_requests where id = $1 and user_id = $2`,
      [id, userId],
    )
  ).rows[0];
  if (!row) throw new AppError('NOT_FOUND', 'Resource not found.');
  if (row.state !== 'completed' || !row.result_media_id) {
    return { id: row.id, state: row.state, download_url: null, expires_at: null };
  }
  const media = (
    await client.query<{ bucket: string; object_path: string }>(
      `select bucket, object_path from app.media_assets where id = $1 and user_id = $2`,
      [row.result_media_id, userId],
    )
  ).rows[0];
  if (!media) return { id: row.id, state: row.state, download_url: null, expires_at: null };
  const signed = await storage.createDownloadUrl(media.bucket, media.object_path);
  return { id: row.id, state: row.state, download_url: signed.url, expires_at: signed.expiresAt };
}

// -------------------------------------------------------------------- deletion

export async function requestAccountDeletion(
  client: Queryable,
  userId: string,
): Promise<Schemas['DeletionAccepted']> {
  const existing = (
    await client.query<{ id: string; state: Schemas['DeletionAccepted']['state'] }>(
      `select id, state from app.deletion_requests
         where user_id = $1 and state in ('requested', 'in_progress')`,
      [userId],
    )
  ).rows[0];
  if (existing) return { deletion_request_id: existing.id, state: existing.state };

  const row = (
    await client.query<{ id: string }>(
      `insert into app.deletion_requests (user_id, state) values ($1, 'requested') returning id`,
      [userId],
    )
  ).rows[0]!;
  return { deletion_request_id: row.id, state: 'requested' };
}
