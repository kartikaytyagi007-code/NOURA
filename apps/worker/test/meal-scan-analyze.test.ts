import { randomUUID } from 'node:crypto';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { LocalMediaStorage } from '@noura/domain';
import { MockAiProvider, MockProviderSimulatedError, registerMockScenarioFixture } from '@noura/ai';
import pg from 'pg';
import { pino } from 'pino';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { handleMealScanAnalyze } from '../src/handlers/meal-scan-analyze.js';

const log = pino({ level: 'silent' });
const admin = new pg.Pool({ connectionString: process.env.DATABASE_URL, max: 4 });
const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL, max: 4 });
const ai = new MockAiProvider();

let dir: string;
let storage: LocalMediaStorage;

beforeAll(() => {
  dir = mkdtempSync(join(tmpdir(), 'noura-meal-scan-test-'));
  storage = new LocalMediaStorage({
    baseDir: dir,
    publicBaseUrl: 'http://127.0.0.1',
    signingSecret: 's',
  });
});
afterAll(async () => {
  rmSync(dir, { recursive: true, force: true });
  await admin.end();
  await pool.end();
});

/** A minimal, hand-built but genuinely parseable PNG (signature + IHDR only). */
function png(width = 100, height = 100, filler = 0): Uint8Array {
  const bytes = new Uint8Array(40);
  bytes.fill(filler, 33);
  const sig = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];
  sig.forEach((b, i) => (bytes[i] = b));
  const view = new DataView(bytes.buffer);
  view.setUint32(8, 13);
  'IHDR'.split('').forEach((c, i) => (bytes[12 + i] = c.charCodeAt(0)));
  view.setUint32(16, width);
  view.setUint32(20, height);
  bytes[24] = 8;
  bytes[25] = 2;
  return bytes;
}

async function newUser(): Promise<string> {
  const id = randomUUID();
  await admin.query('insert into auth.users (id, email) values ($1, $2)', [
    id,
    `${id}@test.invalid`,
  ]);
  return id;
}

async function seedVerifiedMedia(userId: string, bytes: Uint8Array): Promise<string> {
  const mediaId = randomUUID();
  const objectPath = `${userId}/${mediaId}.png`;
  await admin.query(
    `insert into app.media_assets
       (id, user_id, purpose, bucket, object_path, declared_mime, status, verified_mime, byte_size, width_px, height_px)
     values ($1, $2, 'meal', 'meal-images', $3, 'image/png', 'verified', 'image/png', $4, 100, 100)`,
    [mediaId, userId, objectPath, bytes.length],
  );
  await storage.writeObject('meal-images', objectPath, bytes);
  return mediaId;
}

async function seedScan(
  userId: string,
  mediaId: string,
): Promise<{ requestId: string; scanId: string }> {
  const request = await admin.query<{ id: string }>(
    `insert into app.generation_requests (user_id, request_type) values ($1, 'meal_scan') returning id`,
    [userId],
  );
  const requestId = request.rows[0]!.id;
  const scan = await admin.query<{ id: string }>(
    `insert into app.meal_scans (user_id, media_asset_id, generation_request_id, status)
       values ($1, $2, $3, 'queued') returning id`,
    [userId, mediaId, requestId],
  );
  return { requestId, scanId: scan.rows[0]!.id };
}

function job(requestId: string, userId: string) {
  return [{ id: requestId, data: { generation_request_id: requestId, user_id: userId } } as never];
}

describe('handleMealScanAnalyze', () => {
  it('recognizes a usable photo, matching what it can against the catalog honestly', async () => {
    const userId = await newUser();
    const bytes = png(100, 100, 1);
    registerMockScenarioFixture(bytes, 'unmatched_item');
    const mediaId = await seedVerifiedMedia(userId, bytes);
    const { requestId, scanId } = await seedScan(userId, mediaId);

    const result = await handleMealScanAnalyze(job(requestId, userId), pool, ai, storage, log);
    expect(result).toEqual({ status: 'completed' });

    const scan = await admin.query('select status, recognition from app.meal_scans where id = $1', [
      scanId,
    ]);
    expect(scan.rows[0]!.status).toBe('needs_confirmation');
    const recognition = scan.rows[0]!.recognition;
    expect(recognition.items).toHaveLength(2);
    const rice = recognition.items.find((i: { label: string }) => i.label === 'White rice');
    expect(rice.catalog_candidates.length).toBeGreaterThan(0);
    const unmatched = recognition.items.find((i: { label: string }) =>
      i.label.includes('unlisted'),
    );
    expect(unmatched.catalog_candidates).toEqual([]);

    const request = await admin.query('select status from app.generation_requests where id = $1', [
      requestId,
    ]);
    expect(request.rows[0]!.status).toBe('completed');
  });

  it('fails honestly, not a crash, when the photo is not food', async () => {
    const userId = await newUser();
    const bytes = png(100, 100, 2);
    registerMockScenarioFixture(bytes, 'non_food');
    const mediaId = await seedVerifiedMedia(userId, bytes);
    const { requestId, scanId } = await seedScan(userId, mediaId);

    const result = await handleMealScanAnalyze(job(requestId, userId), pool, ai, storage, log);
    expect(result).toEqual({ status: 'failed_not_food' });
    const scan = await admin.query(
      'select status, failure_code from app.meal_scans where id = $1',
      [scanId],
    );
    expect(scan.rows[0]).toMatchObject({ status: 'failed', failure_code: 'not_food' });
  });

  it('surfaces a provider error as a clear job failure, never a crash', async () => {
    const userId = await newUser();
    const bytes = png(100, 100, 3);
    registerMockScenarioFixture(bytes, 'provider_error');
    const mediaId = await seedVerifiedMedia(userId, bytes);
    const { requestId, scanId } = await seedScan(userId, mediaId);

    await expect(ai.recognizeMeal({ bytes, mime: 'image/png' }, {})).rejects.toBeInstanceOf(
      MockProviderSimulatedError,
    );
    const result = await handleMealScanAnalyze(job(requestId, userId), pool, ai, storage, log);
    expect(result).toEqual({ status: 'failed_provider' });
    const scan = await admin.query(
      'select status, failure_code from app.meal_scans where id = $1',
      [scanId],
    );
    expect(scan.rows[0]).toMatchObject({ status: 'failed', failure_code: 'provider_unavailable' });
    const request = await admin.query(
      'select status, safe_error_code from app.generation_requests where id = $1',
      [requestId],
    );
    expect(request.rows[0]).toMatchObject({
      status: 'failed',
      safe_error_code: 'provider_unavailable',
    });
  });

  it('rejects a malformed provider response safely instead of corrupting the scan', async () => {
    const userId = await newUser();
    const bytes = png(100, 100, 4);
    const mediaId = await seedVerifiedMedia(userId, bytes);
    const { requestId, scanId } = await seedScan(userId, mediaId);
    const badAi = {
      name: 'mock',
      recognizeMeal: async () => ({
        output: { not: 'a valid recognition shape' },
        meta: {
          provider: 'mock',
          model_id: 'mock',
          prompt_version: 'x',
          latency_ms: 0,
          input_tokens: null,
          output_tokens: null,
          mock: true,
        },
      }),
      explainMeal: async () => ({ output: {} }) as never,
      rankDietCandidates: async () => ({ output: {} }) as never,
      explainWeeklyInsights: async () => ({ output: {} }) as never,
      coachReply: async () => ({ output: {} }) as never,
    };
    const result = await handleMealScanAnalyze(
      job(requestId, userId),
      pool,
      badAi as never,
      storage,
      log,
    );
    expect(result).toEqual({ status: 'failed_invalid_response' });
    const scan = await admin.query(
      'select status, failure_code from app.meal_scans where id = $1',
      [scanId],
    );
    expect(scan.rows[0]).toMatchObject({
      status: 'failed',
      failure_code: 'invalid_provider_response',
    });
  });

  it('is idempotent on generation_request_id: redelivery never reprocesses a resolved scan', async () => {
    const userId = await newUser();
    const bytes = png(100, 100, 5);
    registerMockScenarioFixture(bytes, 'all_matched');
    const mediaId = await seedVerifiedMedia(userId, bytes);
    const { requestId, scanId } = await seedScan(userId, mediaId);

    await handleMealScanAnalyze(job(requestId, userId), pool, ai, storage, log);
    const first = await admin.query(
      'select recognition, revision from app.meal_scans where id = $1',
      [scanId],
    );

    const second = await handleMealScanAnalyze(job(requestId, userId), pool, ai, storage, log);
    // The request itself is already terminal from the first delivery; the top-level idempotency
    // check short-circuits before even looking at the scan row (same shape as diet-plan-generate).
    expect(second.status).toBe('already_terminal');
    const after = await admin.query(
      'select recognition, revision from app.meal_scans where id = $1',
      [scanId],
    );
    // Redelivery must never overwrite an already-reviewed/resolved recognition result.
    expect(after.rows[0]!.recognition).toEqual(first.rows[0]!.recognition);
  });

  it('recovers from a crash between resolving the scan and marking the request terminal', async () => {
    const userId = await newUser();
    const bytes = png(100, 100, 8);
    registerMockScenarioFixture(bytes, 'all_matched');
    const mediaId = await seedVerifiedMedia(userId, bytes);
    const { requestId, scanId } = await seedScan(userId, mediaId);

    await handleMealScanAnalyze(job(requestId, userId), pool, ai, storage, log);
    const before = await admin.query('select recognition from app.meal_scans where id = $1', [
      scanId,
    ]);
    // Simulate the crash: the scan resolved, but the request row never got marked terminal.
    await admin.query(
      "update app.generation_requests set status = 'running', completed_at = null, safe_error_code = null where id = $1",
      [requestId],
    );
    const result = await handleMealScanAnalyze(job(requestId, userId), pool, ai, storage, log);
    expect(result).toEqual({ status: 'already_processed' });
    const after = await admin.query('select recognition from app.meal_scans where id = $1', [
      scanId,
    ]);
    expect(after.rows[0]!.recognition).toEqual(before.rows[0]!.recognition);
    const request = await admin.query('select status from app.generation_requests where id = $1', [
      requestId,
    ]);
    expect(request.rows[0]!.status).toBe('completed');
  });

  it('is a no-op once the request is already terminal', async () => {
    const userId = await newUser();
    const bytes = png(100, 100, 6);
    const mediaId = await seedVerifiedMedia(userId, bytes);
    const { requestId } = await seedScan(userId, mediaId);
    await admin.query(
      "update app.generation_requests set status = 'cancelled', completed_at = now() where id = $1",
      [requestId],
    );
    const result = await handleMealScanAnalyze(job(requestId, userId), pool, ai, storage, log);
    expect(result).toEqual({ status: 'already_terminal' });
  });

  it('fails honestly when the uploaded image can no longer be found in storage', async () => {
    const userId = await newUser();
    const bytes = png(100, 100, 7);
    const mediaId = await seedVerifiedMedia(userId, bytes);
    const { requestId, scanId } = await seedScan(userId, mediaId);
    await storage.deleteObject('meal-images', `${userId}/${mediaId}.png`);

    const result = await handleMealScanAnalyze(job(requestId, userId), pool, ai, storage, log);
    expect(result).toEqual({ status: 'failed_image_missing' });
    const scan = await admin.query(
      'select status, failure_code from app.meal_scans where id = $1',
      [scanId],
    );
    expect(scan.rows[0]).toMatchObject({ status: 'failed', failure_code: 'image_missing' });
  });
});
