import { randomUUID } from 'node:crypto';
import {
  AppError,
  isUuid,
  validateImageBytes,
  type MediaStorage,
  type Queryable,
} from '@noura/domain';
import type { components } from '@noura/contracts';

type Schemas = components['schemas'];

const BUCKET_BY_PURPOSE: Record<string, string> = {
  meal: 'meal-images',
  progress_photo: 'progress-photos',
};
const MAX_BYTES = 10 * 1024 * 1024;
/** Images are kept only as long as needed to support recognition and review (docs/decisions.md D-026). */
const RETENTION_DAYS = 30;
/**
 * Progress photos are retained until the user deletes them, not auto-expired like meal images — the
 * blueprint states this explicitly ("progress photos until user deletion", §14), distinct from its
 * 90-day default for other media. See docs/decisions.md D-030.
 */
const PURPOSES_WITH_NO_AUTO_EXPIRY = new Set(['progress_photo']);

function extFor(mime: string): string {
  if (mime === 'image/png') return 'png';
  if (mime === 'image/webp') return 'webp';
  return 'jpg';
}

interface MediaRow {
  id: string;
  purpose: string;
  bucket: string;
  object_path: string;
  declared_mime: string;
  status: string;
  verified_mime: string | null;
  byte_size: number | string | null;
  created_at: Date;
}

function toMediaAsset(row: MediaRow): Schemas['MediaAsset'] {
  return {
    id: row.id,
    purpose: row.purpose as Schemas['MediaAsset']['purpose'],
    status: row.status as Schemas['MediaAsset']['status'],
    verified_mime: row.verified_mime,
    byte_size: row.byte_size === null ? null : Number(row.byte_size),
    created_at: row.created_at.toISOString(),
  };
}

export async function createUploadSlot(
  client: Queryable,
  storage: MediaStorage,
  userId: string,
  body: Schemas['UploadSlotRequest'],
): Promise<Schemas['UploadSlot']> {
  if (body.size_bytes > MAX_BYTES) {
    throw new AppError('VALIDATION_ERROR', 'The file is too large.', {
      fieldErrors: [
        { field: 'body.size_bytes', code: 'too_large', message: `must be <= ${MAX_BYTES}` },
      ],
    });
  }
  const bucket = BUCKET_BY_PURPOSE[body.purpose];
  if (!bucket) {
    throw new AppError('VALIDATION_ERROR', 'Unsupported upload purpose.', {
      fieldErrors: [{ field: 'body.purpose', code: 'invalid', message: 'unsupported purpose' }],
    });
  }

  // The id is generated here (not by the DB default) because the owner-scoped path constraint
  // (`media_assets_owner_path`) requires the path to embed the row's own id from the first insert.
  const mediaId = randomUUID();
  const objectPath = `${userId}/${mediaId}.${extFor(body.mime)}`;
  const retentionDays = PURPOSES_WITH_NO_AUTO_EXPIRY.has(body.purpose) ? null : RETENTION_DAYS;
  await client.query(
    `insert into app.media_assets (id, user_id, purpose, bucket, object_path, declared_mime, status, expires_at)
     values ($1, $2, $3, $4, $5, $6, 'awaiting_upload',
             case when $7::int is null then null else now() + make_interval(days => $7) end)`,
    [mediaId, userId, body.purpose, bucket, objectPath, body.mime, retentionDays],
  );

  const slot = await storage.createUploadUrl(bucket, objectPath, body.mime);
  return { media_id: mediaId, upload_url: slot.url, expires_at: slot.expiresAt };
}

async function loadOwnedMedia(client: Queryable, userId: string, id: string): Promise<MediaRow> {
  if (!isUuid(id)) throw new AppError('NOT_FOUND', 'Resource not found.');
  const row = (
    await client.query<MediaRow>(
      `select id, purpose, bucket, object_path, declared_mime, status, verified_mime, byte_size, created_at
         from app.media_assets where id = $1 and user_id = $2`,
      [id, userId],
    )
  ).rows[0];
  if (!row) throw new AppError('NOT_FOUND', 'Resource not found.');
  return row;
}

export async function completeUpload(
  client: Queryable,
  storage: MediaStorage,
  userId: string,
  mediaId: string,
): Promise<Schemas['MediaAsset']> {
  const media = await loadOwnedMedia(client, userId, mediaId);
  if (media.status === 'verified' || media.status === 'rejected') {
    // Idempotent replay: verification already ran (at-least-once-safe for a retried confirm call).
    return toMediaAsset(media);
  }
  if (media.status !== 'awaiting_upload' && media.status !== 'uploaded') {
    throw new AppError('VALIDATION_ERROR', 'This media cannot be completed.', {
      fieldErrors: [{ field: 'params.id', code: 'invalid_state', message: media.status }],
    });
  }

  const bytes = await storage.readObject(media.bucket, media.object_path);
  if (!bytes) {
    await client.query("update app.media_assets set status = 'rejected' where id = $1", [media.id]);
    throw new AppError('VALIDATION_ERROR', 'No file was found at the reserved upload slot.', {
      fieldErrors: [
        { field: 'params.id', code: 'missing_upload', message: 'upload the file first' },
      ],
    });
  }

  const result = validateImageBytes(bytes, {
    declaredMime: media.declared_mime,
    maxBytes: MAX_BYTES,
  });
  if (!result.ok) {
    await client.query("update app.media_assets set status = 'rejected' where id = $1", [media.id]);
    throw new AppError('VALIDATION_ERROR', 'The uploaded file is not a valid, supported image.', {
      fieldErrors: [{ field: 'params.id', code: result.reason, message: result.reason }],
    });
  }

  const updated = (
    await client.query<MediaRow>(
      `update app.media_assets
         set status = 'verified', verified_mime = $2, byte_size = $3, width_px = $4, height_px = $5
         where id = $1
         returning id, purpose, bucket, object_path, declared_mime, status, verified_mime, byte_size, created_at`,
      [media.id, result.sniffed.mime, bytes.length, result.sniffed.width, result.sniffed.height],
    )
  ).rows[0]!;
  return toMediaAsset(updated);
}

export async function getMediaDownload(
  client: Queryable,
  storage: MediaStorage,
  userId: string,
  mediaId: string,
): Promise<Schemas['MediaDownload']> {
  const media = await loadOwnedMedia(client, userId, mediaId);
  if (media.status !== 'verified') throw new AppError('NOT_FOUND', 'Resource not found.');
  const signed = await storage.createDownloadUrl(media.bucket, media.object_path);
  return { url: signed.url, expires_at: signed.expiresAt };
}

export async function deleteMedia(
  client: Queryable,
  storage: MediaStorage,
  userId: string,
  mediaId: string,
): Promise<Schemas['MediaAsset']> {
  const media = await loadOwnedMedia(client, userId, mediaId);
  if (media.status !== 'deleted') {
    await storage.deleteObject(media.bucket, media.object_path).catch(() => {
      // Best-effort: the DB record is the source of truth for ownership/visibility either way.
    });
  }
  const updated = (
    await client.query<MediaRow>(
      `update app.media_assets set status = 'deleted', deleted_at = coalesce(deleted_at, now())
         where id = $1
         returning id, purpose, bucket, object_path, declared_mime, status, verified_mime, byte_size, created_at`,
      [media.id],
    )
  ).rows[0]!;
  return toMediaAsset(updated);
}
