import {
  loadCatalogFoods,
  sniffImage,
  stripImageMetadataForAi,
  toValidatedRecognition,
  validateProviderRecognition,
  withUserTransaction,
  type MediaStorage,
  type PoolLike,
  type QueuePayloads,
  type Queryable,
} from '@noura/domain';
import type { AiProvider } from '@noura/ai';
import type { Job } from 'pg-boss';
import type { Logger } from 'pino';

interface ScanRow {
  id: string;
  user_id: string;
  media_asset_id: string;
  generation_request_id: string | null;
  status: string;
}

interface MediaRow {
  id: string;
  bucket: string;
  object_path: string;
  verified_mime: string | null;
  status: string;
}

interface RequestRow {
  id: string;
  status: 'queued' | 'running' | 'completed' | 'failed' | 'cancelled';
}

const SAFE_MESSAGES: Record<string, string> = {
  not_food: "That doesn't look like a food photo. Please retake it and try again.",
  image_unusable: 'The photo could not be analyzed. Please retake it with better lighting.',
  image_missing: 'The uploaded image could not be found. Please upload it again.',
  invalid_provider_response: 'Recognition failed unexpectedly. Please try again.',
  provider_unavailable: 'Recognition is temporarily unavailable. Please try again shortly.',
};

async function markRequestTerminal(
  client: Queryable,
  requestId: string,
  scanId: string,
  status: 'completed' | 'failed',
  failureCode?: string,
): Promise<void> {
  await client.query(
    `update app.generation_requests
       set status = $2, safe_error_code = $3, safe_error_message = $4, result_ids = $5::jsonb,
           completed_at = now()
       where id = $1 and status in ('queued', 'running')`,
    [
      requestId,
      status,
      failureCode ?? null,
      failureCode ? (SAFE_MESSAGES[failureCode] ?? 'Recognition could not be completed.') : null,
      JSON.stringify(status === 'completed' ? { meal_scan_id: scanId } : {}),
    ],
  );
}

async function markScanTerminal(
  client: Queryable,
  scanId: string,
  requestId: string | null,
  patch: { status: 'needs_confirmation' | 'failed'; failureCode?: string; recognition?: unknown },
): Promise<void> {
  await client.query(
    `update app.meal_scans
       set status = $2, failure_code = $3, recognition = $4::jsonb
       where id = $1`,
    [
      scanId,
      patch.status,
      patch.failureCode ?? null,
      patch.recognition ? JSON.stringify(patch.recognition) : null,
    ],
  );
  if (requestId) {
    await markRequestTerminal(
      client,
      requestId,
      scanId,
      patch.status === 'failed' ? 'failed' : 'completed',
      patch.status === 'failed' ? (patch.failureCode ?? 'unknown') : undefined,
    );
  }
}

/**
 * Handles `meal-scan.analyze` (blueprint §8; docs/decisions.md D-026). Idempotent on
 * `generation_request_id`/the scan id, following the exact crash-recovery shape as
 * `diet-plan-generate.ts`: everything is reloaded fresh under the user's own transaction context, and
 * a scan that is already past `queued`/`recognizing` is a no-op so at-least-once delivery can never
 * recognize the same photo twice or overwrite a user's already-reviewed result.
 */
export async function handleMealScanAnalyze(
  [job]: Job<QueuePayloads['meal-scan.analyze']>[],
  pool: PoolLike,
  ai: AiProvider,
  storage: MediaStorage,
  log: Logger,
): Promise<{ status: string }> {
  if (!job) throw new Error('meal-scan.analyze handler received an empty batch');
  const { generation_request_id: requestId, user_id: userId } = job.data;

  return withUserTransaction(pool, 'noura_worker', userId, async (client) => {
    const request = (
      await client.query<RequestRow>(
        'select id, status from app.generation_requests where id = $1 and user_id = $2',
        [requestId, userId],
      )
    ).rows[0];
    if (!request) {
      log.warn({ requestId }, 'meal-scan.analyze: request not found for this user, skipping');
      return { status: 'skipped_missing' };
    }
    if (
      request.status === 'completed' ||
      request.status === 'failed' ||
      request.status === 'cancelled'
    ) {
      return { status: 'already_terminal' };
    }

    const scan = (
      await client.query<ScanRow>(
        `select id, user_id, media_asset_id, generation_request_id, status
           from app.meal_scans where generation_request_id = $1 and user_id = $2`,
        [requestId, userId],
      )
    ).rows[0];
    if (!scan) {
      log.warn({ requestId }, 'meal-scan.analyze: no scan references this request, skipping');
      return { status: 'skipped_missing' };
    }
    if (scan.status !== 'queued' && scan.status !== 'recognizing') {
      // Already resolved by a previous delivery: never reprocess or overwrite the stored result.
      // Only repair the generation_request row in case a crash happened right after the scan update.
      await markRequestTerminal(
        client,
        requestId,
        scan.id,
        scan.status === 'failed' ? 'failed' : 'completed',
        scan.status === 'failed' ? 'already_processed' : undefined,
      );
      return { status: 'already_processed' };
    }

    await client.query("update app.meal_scans set status = 'recognizing' where id = $1", [scan.id]);
    await client.query(
      `update app.generation_requests
         set status = 'running', attempts = attempts + 1, started_at = coalesce(started_at, now())
         where id = $1`,
      [requestId],
    );

    const media = (
      await client.query<MediaRow>(
        `select id, bucket, object_path, verified_mime, status
           from app.media_assets where id = $1 and user_id = $2`,
        [scan.media_asset_id, userId],
      )
    ).rows[0];
    if (!media || media.status !== 'verified') {
      await markScanTerminal(client, scan.id, requestId, {
        status: 'failed',
        failureCode: 'image_missing',
      });
      return { status: 'failed_image_missing' };
    }

    const bytes = await storage.readObject(media.bucket, media.object_path);
    const sniffed = bytes ? sniffImage(bytes) : null;
    if (!bytes || !sniffed) {
      await markScanTerminal(client, scan.id, requestId, {
        status: 'failed',
        failureCode: 'image_missing',
      });
      return { status: 'failed_image_missing' };
    }

    const sanitized = stripImageMetadataForAi(bytes, sniffed.mime);

    let rawOutput: unknown;
    let modelId: string;
    let promptVersion: string;
    try {
      const result = await ai.recognizeMeal(
        { bytes: sanitized, mime: sniffed.mime },
        { purpose: 'meal_scan' },
      );
      rawOutput = result.output;
      modelId = result.meta.model_id;
      promptVersion = result.meta.prompt_version;
    } catch (error) {
      log.warn(
        { requestId, scanId: scan.id, err: error },
        'meal-scan.analyze: provider call failed',
      );
      await markScanTerminal(client, scan.id, requestId, {
        status: 'failed',
        failureCode: 'provider_unavailable',
      });
      return { status: 'failed_provider' };
    }

    let validated;
    try {
      validated = validateProviderRecognition(rawOutput);
    } catch (error) {
      // A malformed/adversarial provider response must never crash the job or corrupt data.
      log.error(
        { requestId, scanId: scan.id, err: error },
        'meal-scan.analyze: invalid provider response',
      );
      await markScanTerminal(client, scan.id, requestId, {
        status: 'failed',
        failureCode: 'invalid_provider_response',
      });
      return { status: 'failed_invalid_response' };
    }

    await client.query(
      `update app.meal_scans set model_id = $2, prompt_version = $3 where id = $1`,
      [scan.id, modelId, promptVersion],
    );

    if (!validated.image_is_food) {
      await markScanTerminal(client, scan.id, requestId, {
        status: 'failed',
        failureCode: 'not_food',
        recognition: toValidatedRecognition(validated, []),
      });
      return { status: 'failed_not_food' };
    }

    const catalogFoods = await loadCatalogFoods(client);
    const recognition = toValidatedRecognition(validated, catalogFoods);

    await markScanTerminal(client, scan.id, requestId, {
      status: 'needs_confirmation',
      recognition,
    });
    log.info({ requestId, userId, scanId: scan.id }, 'meal-scan.analyze completed');
    return { status: 'completed' };
  });
}
