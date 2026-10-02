import { randomUUID } from 'node:crypto';
import {
  AppError,
  computeMealBalance,
  isUuid,
  loadCatalogFoods,
  resolveConfirmedItems,
  sumAnalyzedNutrition,
  type AnalyzedItemOut,
  type Queryable,
} from '@noura/domain';
import type { components } from '@noura/contracts';

type Schemas = components['schemas'];

/** Provisional daily cap (release-gate item alongside the target/catalog policies): see docs/decisions.md. */
const MEAL_SCAN_DAILY_QUOTA = 20;

const conflict = (what: string) =>
  new AppError(
    'REVISION_CONFLICT',
    `Your ${what} changed since you loaded it. Reload and try again.`,
  );

const SAFE_ERROR_MESSAGES: Record<string, string> = {
  not_food: "That doesn't look like a food photo. Please retake it and try again.",
  image_missing: 'The uploaded image could not be found. Please upload it again.',
  invalid_provider_response: 'Recognition failed unexpectedly. Please try again.',
  provider_unavailable: 'Recognition is temporarily unavailable. Please try again shortly.',
};

interface MediaRow {
  id: string;
  status: string;
}

interface ScanRow {
  id: string;
  status: Schemas['MealScanStatus'];
  recognition: unknown;
  confirmed_analysis: unknown;
  failure_code: string | null;
  generation_request_id: string | null;
  revision: number;
  created_at: Date;
}

interface RequestErrorRow {
  safe_error_code: string | null;
  safe_error_message: string | null;
}

function toMealScan(row: ScanRow, requestError: RequestErrorRow | null): Schemas['MealScan'] {
  const code = row.failure_code ?? requestError?.safe_error_code ?? null;
  return {
    id: row.id,
    status: row.status,
    recognition: (row.recognition as Schemas['Recognition'] | null) ?? null,
    revision: row.revision,
    error: code
      ? {
          code,
          message:
            requestError?.safe_error_message ??
            SAFE_ERROR_MESSAGES[code] ??
            'Recognition could not be completed.',
        }
      : null,
    created_at: row.created_at.toISOString(),
  };
}

export async function createMealScan(
  client: Queryable,
  userId: string,
  body: Schemas['CreateMealScanRequest'],
): Promise<Schemas['MealScanAccepted']> {
  if (!isUuid(body.media_id)) {
    throw new AppError('NOT_FOUND', 'Resource not found.');
  }
  const media = (
    await client.query<MediaRow>(
      'select id, status from app.media_assets where id = $1 and user_id = $2',
      [body.media_id, userId],
    )
  ).rows[0];
  if (!media) throw new AppError('NOT_FOUND', 'Resource not found.');
  if (media.status !== 'verified') {
    throw new AppError('VALIDATION_ERROR', 'This image has not finished upload verification yet.', {
      fieldErrors: [
        { field: 'body.media_id', code: 'not_verified', message: 'media is not verified' },
      ],
    });
  }

  // Duplicate-request handling: re-submitting the same (not-failed) scan returns the same job rather
  // than starting a second analysis of the same photo.
  const existing = (
    await client.query<{ id: string; generation_request_id: string | null; status: string }>(
      `select id, generation_request_id, status from app.meal_scans
         where user_id = $1 and media_asset_id = $2
         order by created_at desc limit 1`,
      [userId, body.media_id],
    )
  ).rows[0];
  if (
    existing &&
    existing.status !== 'failed' &&
    existing.status !== 'cancelled' &&
    existing.status !== 'expired'
  ) {
    return { job_id: existing.generation_request_id ?? existing.id, scan_id: existing.id };
  }

  const today = new Date().toISOString().slice(0, 10);
  const used = (
    await client.query<{ count: string }>(
      `select count(*) from app.usage_reservations
         where user_id = $1 and feature = 'meal_scan' and quota_period = $2 and state in ('reserved', 'consumed')`,
      [userId, today],
    )
  ).rows[0]!;
  if (Number(used.count) >= MEAL_SCAN_DAILY_QUOTA) {
    throw new AppError(
      'QUOTA_EXCEEDED',
      'You have reached today’s meal-scan limit. Try again tomorrow.',
      {
        retryable: false,
      },
    );
  }

  const request = (
    await client.query<{ id: string }>(
      `insert into app.generation_requests (user_id, request_type) values ($1, 'meal_scan') returning id`,
      [userId],
    )
  ).rows[0]!;
  const scan = (
    await client.query<{ id: string }>(
      `insert into app.meal_scans (user_id, media_asset_id, generation_request_id, status)
         values ($1, $2, $3, 'queued') returning id`,
      [userId, body.media_id, request.id],
    )
  ).rows[0]!;
  await client.query(
    `insert into app.usage_reservations (user_id, feature, quota_period, request_id, state, expires_at)
       values ($1, 'meal_scan', $2, $3, 'reserved', now() + interval '1 day')`,
    [userId, today, request.id],
  );

  return { job_id: request.id, scan_id: scan.id };
}

async function loadOwnedScan(client: Queryable, userId: string, id: string): Promise<ScanRow> {
  if (!isUuid(id)) throw new AppError('NOT_FOUND', 'Resource not found.');
  const row = (
    await client.query<ScanRow>(
      `select id, status, recognition, confirmed_analysis, failure_code, generation_request_id, revision, created_at
         from app.meal_scans where id = $1 and user_id = $2`,
      [id, userId],
    )
  ).rows[0];
  if (!row) throw new AppError('NOT_FOUND', 'Resource not found.');
  return row;
}

export async function getMealScan(
  client: Queryable,
  userId: string,
  id: string,
): Promise<Schemas['MealScan']> {
  const scan = await loadOwnedScan(client, userId, id);
  const requestError = scan.generation_request_id
    ? ((
        await client.query<RequestErrorRow>(
          'select safe_error_code, safe_error_message from app.generation_requests where id = $1 and user_id = $2',
          [scan.generation_request_id, userId],
        )
      ).rows[0] ?? null)
    : null;
  return toMealScan(scan, requestError);
}

function toAnalyzedItemSchema(item: AnalyzedItemOut): Schemas['AnalyzedItem'] {
  return {
    item_id: item.item_id,
    label: item.label,
    food_id: item.food_id,
    recipe_id: item.recipe_id,
    source: null,
    grams: item.grams,
    grams_range: item.grams_range,
    nutrients: item.nutrients,
    uncertainty: item.uncertainty,
  };
}

export async function confirmMealScanItems(
  client: Queryable,
  userId: string,
  id: string,
  body: Schemas['ConfirmItemsRequest'],
): Promise<Schemas['MealAnalysis']> {
  const scan = await loadOwnedScan(client, userId, id);
  if (scan.status !== 'needs_confirmation' && scan.status !== 'ready') {
    throw new AppError('CONSTRAINT_CONFLICT', 'This scan is not ready for review yet.');
  }
  if (scan.revision !== body.expected_revision) throw conflict('meal scan');

  const catalogFoods = await loadCatalogFoods(client);
  const items = resolveConfirmedItems(
    body.items.map((i) => ({
      temporary_id: i.temporary_id,
      food_id: i.food_id,
      recipe_id: i.recipe_id,
      label: i.label,
      grams: i.grams,
      serving: i.serving,
    })),
    catalogFoods,
    () => randomUUID(),
  );
  const totals = sumAnalyzedNutrition(items);
  const mealBalance = computeMealBalance(items, totals);

  const analysis: Schemas['MealAnalysis'] = {
    scan_id: scan.id,
    revision: scan.revision + 1,
    items: items.map(toAnalyzedItemSchema),
    totals,
    meal_balance: mealBalance,
  };

  const updated = (
    await client.query<{ revision: number }>(
      `update app.meal_scans
         set status = 'ready', confirmed_analysis = $3::jsonb, revision = revision + 1
         where id = $1 and user_id = $2 and revision = $4
         returning revision`,
      [scan.id, userId, JSON.stringify(analysis), body.expected_revision],
    )
  ).rows[0];
  if (!updated) throw conflict('meal scan');

  return { ...analysis, revision: updated.revision };
}

export { loadOwnedScan, conflict, toAnalyzedItemSchema };
