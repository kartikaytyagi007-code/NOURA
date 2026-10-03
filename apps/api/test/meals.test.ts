import { randomUUID } from 'node:crypto';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import pg from 'pg';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { createTestApp } from './support/app.js';
import { createTestKeys, signToken, startJwksServer, type TestKeys } from './support/auth.js';
import { expectMatchesContract } from './support/contract.js';

const admin = new pg.Pool({ connectionString: process.env.DATABASE_URL, max: 4 });

let keys: TestKeys;
let jwks: Awaited<ReturnType<typeof startJwksServer>>;
let ctx: Awaited<ReturnType<typeof createTestApp>>;
let dir: string;

beforeAll(async () => {
  keys = await createTestKeys();
  jwks = await startJwksServer([keys.jwk]);
  dir = mkdtempSync(join(tmpdir(), 'noura-api-meals-test-'));
  ctx = await createTestApp(jwks.url, {
    MEDIA_STORAGE_DRIVER: 'local',
    DEV_STORAGE_DIR: dir,
    DEV_STORAGE_SIGNING_SECRET: 'test-secret',
    DEV_STORAGE_BASE_URL: 'http://test.local',
  });
});

afterAll(async () => {
  await ctx.close();
  await jwks.close();
  await admin.end();
  rmSync(dir, { recursive: true, force: true });
});

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type ApiBody = any;

interface Caller {
  id: string;
  call: (
    method: 'GET' | 'PATCH' | 'PUT' | 'POST' | 'DELETE',
    url: string,
    body?: unknown,
    options?: { key?: string | null },
  ) => Promise<{ status: number; body: ApiBody }>;
}

function callerFor(id: string, token: string): Caller {
  return {
    id,
    async call(method, url, body, options = {}) {
      const headers: Record<string, string> = { authorization: `Bearer ${token}` };
      if (options.key !== null && method !== 'GET' && method !== 'DELETE')
        headers['idempotency-key'] = options.key ?? randomUUID();
      if (options.key !== null && method === 'DELETE')
        headers['idempotency-key'] = options.key ?? randomUUID();
      const res = await ctx.app.inject({
        method,
        url,
        headers,
        ...(body === undefined ? {} : { payload: body as object }),
      });
      return { status: res.statusCode, body: res.json() };
    },
  };
}

async function newUser(): Promise<Caller> {
  const id = randomUUID();
  await admin.query('insert into auth.users (id, email) values ($1, $2)', [
    id,
    `${id}@test.invalid`,
  ]);
  const token = await signToken(keys, { sub: id });
  return callerFor(id, token);
}

/** A minimal, hand-built but genuinely parseable PNG (signature + IHDR only). */
function png(width = 100, height = 100, filler = 0): Buffer {
  const bytes = Buffer.alloc(40, filler);
  const sig = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];
  sig.forEach((b, i) => (bytes[i] = b));
  bytes.writeUInt32BE(13, 8);
  bytes.write('IHDR', 12, 'ascii');
  bytes.writeUInt32BE(width, 16);
  bytes.writeUInt32BE(height, 20);
  bytes[24] = 8;
  bytes[25] = 2;
  return bytes;
}

async function rawPutToUploadUrl(uploadUrl: string, bytes: Buffer, contentType = 'image/png') {
  const url = new URL(uploadUrl);
  const res = await ctx.app.inject({
    method: 'PUT',
    url: `${url.pathname}${url.search}`,
    headers: { 'content-type': contentType },
    payload: bytes,
  });
  return res;
}

/** Full capture -> upload -> verify flow, returning the verified media id. */
async function uploadVerifiedImage(caller: Caller, bytes: Buffer): Promise<string> {
  const slot = await caller.call('POST', '/v1/media/upload-slots', {
    purpose: 'meal',
    mime: 'image/png',
    size_bytes: bytes.length,
  });
  expect(slot.status).toBe(201);
  const putRes = await rawPutToUploadUrl(slot.body.data.upload_url, bytes);
  expect(putRes.statusCode).toBe(200);
  const complete = await caller.call('POST', `/v1/media/${slot.body.data.media_id}/complete`);
  expect(complete.status).toBe(200);
  expect(complete.body.data.status).toBe('verified');
  return slot.body.data.media_id as string;
}

/**
 * Simulates what `handleMealScanAnalyze` (apps/worker, fully tested on its own in
 * apps/worker/test/meal-scan-analyze.test.ts) would have written for a scan: this file tests the API
 * layer's review/confirm/ownership behaviour, not recognition itself.
 */
async function markRecognized(scanId: string, requestId: string, items: object[]): Promise<void> {
  await admin.query(
    `update app.meal_scans set status = 'needs_confirmation', recognition = $2::jsonb where id = $1`,
    [
      scanId,
      JSON.stringify({
        schema_version: '1',
        image_is_food: true,
        quality: 'usable',
        items,
        clarification: null,
      }),
    ],
  );
  await admin.query(
    `update app.generation_requests set status = 'completed', completed_at = now(), result_ids = $2::jsonb where id = $1`,
    [requestId, JSON.stringify({ meal_scan_id: scanId })],
  );
}

describe('media upload and ownership', () => {
  it('reserves an owner-scoped upload slot and verifies real bytes on completion', async () => {
    const user = await newUser();
    const mediaId = await uploadVerifiedImage(user, png());
    expect(mediaId).toBeTruthy();
  });

  it('rejects a non-image upload instead of trusting the declared mime type', async () => {
    const user = await newUser();
    const garbage = Buffer.from('<html>not an image</html>');
    const slot = await user.call('POST', '/v1/media/upload-slots', {
      purpose: 'meal',
      mime: 'image/png',
      size_bytes: garbage.length,
    });
    await rawPutToUploadUrl(slot.body.data.upload_url, garbage);
    const complete = await user.call('POST', `/v1/media/${slot.body.data.media_id}/complete`);
    expect(complete.status).toBe(422);
  });

  it('rejects an oversized declared size', async () => {
    const user = await newUser();
    const slot = await user.call('POST', '/v1/media/upload-slots', {
      purpose: 'meal',
      mime: 'image/png',
      size_bytes: 20 * 1024 * 1024,
    });
    expect(slot.status).toBe(422);
  });

  it('never lets another user download, complete or delete someone else’s media', async () => {
    const owner = await newUser();
    const other = await newUser();
    const mediaId = await uploadVerifiedImage(owner, png());

    expect((await other.call('GET', `/v1/media/${mediaId}/download`)).status).toBe(404);
    expect((await other.call('POST', `/v1/media/${mediaId}/complete`)).status).toBe(404);
    expect((await other.call('DELETE', `/v1/media/${mediaId}`)).status).toBe(404);

    // The owner can still do all of these.
    expect((await owner.call('GET', `/v1/media/${mediaId}/download`)).status).toBe(200);
  });

  it('deletes media on request (retention/deletion policy, docs/decisions.md)', async () => {
    const user = await newUser();
    const mediaId = await uploadVerifiedImage(user, png());
    const res = await user.call('DELETE', `/v1/media/${mediaId}`);
    expect(res.status).toBe(200);
    expect(res.body.data).toMatchObject({ id: mediaId, status: 'deleted' });
    // Deleted media can no longer be downloaded.
    expect((await user.call('GET', `/v1/media/${mediaId}/download`)).status).toBe(404);
  });
});

describe('meal scan recognition and review', () => {
  it('runs end to end: submit -> analyze -> review -> correct -> confirm', async () => {
    const user = await newUser();
    const bytes = png(100, 100, 11);
    const mediaId = await uploadVerifiedImage(user, bytes);

    const created = await user.call('POST', '/v1/meal-scans', { media_id: mediaId });
    expect(created.status).toBe(202);
    expectMatchesContract('createMealScan', 202, created.body);
    const { scan_id: scanId, job_id: jobId } = created.body.data;

    await markRecognized(scanId, jobId, [
      {
        temporary_id: 'item-1',
        label: 'White rice',
        alternative_labels: [],
        confidence_band: 'high',
        estimated_grams: { min: 150, max: 200 },
        preparation_questions: [],
        needs_confirmation: false,
        catalog_candidates: [],
      },
      {
        temporary_id: 'item-2',
        label: 'Development mock unlisted dish',
        alternative_labels: [],
        confidence_band: 'medium',
        estimated_grams: { min: 50, max: 120 },
        preparation_questions: [],
        needs_confirmation: true,
        catalog_candidates: [],
      },
    ]);

    const scan = await user.call('GET', `/v1/meal-scans/${scanId}`);
    expect(scan.status).toBe(200);
    expectMatchesContract('getMealScan', 200, scan.body);
    expect(scan.body.data.status).toBe('needs_confirmation');
    expect(scan.body.data.recognition.items).toHaveLength(2);
    const revision = scan.body.data.revision;

    // The user corrects the unmatched item's label to one the catalog does recognize, and adjusts
    // portions, before saving anything (blueprint §8 step 6: review/edit is required, not optional).
    const confirm = await user.call('PUT', `/v1/meal-scans/${scanId}/confirmed-items`, {
      expected_revision: revision,
      items: [
        { label: 'White rice', grams: 180 },
        { label: 'Chicken breast', grams: 120 },
      ],
    });
    expect(confirm.status).toBe(200);
    expectMatchesContract('confirmMealScanItems', 200, confirm.body);
    expect(
      confirm.body.data.items.every((i: { uncertainty: string }) => i.uncertainty === 'low'),
    ).toBe(true);
    expect(confirm.body.data.totals.coverage.complete).toBe(true);
    expect(confirm.body.data.meal_balance.score).not.toBeNull();

    // A stale revision is rejected, not silently applied.
    const stale = await user.call('PUT', `/v1/meal-scans/${scanId}/confirmed-items`, {
      expected_revision: revision,
      items: [{ label: 'White rice', grams: 100 }],
    });
    expect(stale.status).toBe(409);
  });

  it('surfaces an unmatched item honestly rather than guessing nutrition', async () => {
    const user = await newUser();
    const bytes = png(100, 100, 12);
    const mediaId = await uploadVerifiedImage(user, bytes);
    const created = await user.call('POST', '/v1/meal-scans', { media_id: mediaId });
    await markRecognized(created.body.data.scan_id, created.body.data.job_id, []);
    const scan = await user.call('GET', `/v1/meal-scans/${created.body.data.scan_id}`);

    const confirm = await user.call(
      'PUT',
      `/v1/meal-scans/${created.body.data.scan_id}/confirmed-items`,
      {
        expected_revision: scan.body.data.revision,
        items: [{ label: 'A dish the catalog has never heard of', grams: 100 }],
      },
    );
    expect(confirm.status).toBe(200);
    expect(confirm.body.data.items[0]).toMatchObject({
      food_id: null,
      nutrients: null,
      uncertainty: 'high',
    });
  });

  it('handles a duplicate submission of the same photo without starting a second analysis', async () => {
    const user = await newUser();
    const mediaId = await uploadVerifiedImage(user, png(100, 100, 13));
    const first = await user.call('POST', '/v1/meal-scans', { media_id: mediaId });
    const second = await user.call(
      'POST',
      '/v1/meal-scans',
      { media_id: mediaId },
      { key: randomUUID() },
    );
    expect(second.body.data.scan_id).toBe(first.body.data.scan_id);
    const count = await admin.query(
      'select count(*)::int as n from app.meal_scans where media_asset_id = $1',
      [mediaId],
    );
    expect(count.rows[0]!.n).toBe(1);
  });

  it('replays an identical createMealScan request under the same Idempotency-Key', async () => {
    const user = await newUser();
    const mediaId = await uploadVerifiedImage(user, png(100, 100, 14));
    const key = randomUUID();
    const first = await user.call('POST', '/v1/meal-scans', { media_id: mediaId }, { key });
    const second = await user.call('POST', '/v1/meal-scans', { media_id: mediaId }, { key });
    expect(second.body.data).toEqual(first.body.data);
  });

  it('never lets another user read or confirm someone else’s scan', async () => {
    const owner = await newUser();
    const other = await newUser();
    const mediaId = await uploadVerifiedImage(owner, png(100, 100, 15));
    const created = await owner.call('POST', '/v1/meal-scans', { media_id: mediaId });
    await markRecognized(created.body.data.scan_id, created.body.data.job_id, []);

    expect((await other.call('GET', `/v1/meal-scans/${created.body.data.scan_id}`)).status).toBe(
      404,
    );
    const confirm = await other.call(
      'PUT',
      `/v1/meal-scans/${created.body.data.scan_id}/confirmed-items`,
      {
        expected_revision: 1,
        items: [{ label: 'x', grams: 10 }],
      },
    );
    expect(confirm.status).toBe(404);
  });
});

describe('meal logs', () => {
  it('creates, lists, edits and deletes a manual meal log', async () => {
    const user = await newUser();
    const clientId = randomUUID();
    const created = await user.call('POST', '/v1/meal-logs', {
      client_id: clientId,
      consumed_at: new Date().toISOString(),
      timezone: 'Asia/Kolkata',
      slot: 'lunch',
      items: [{ label: 'White rice', grams: 150 }],
    });
    expect(created.status).toBe(201);
    expectMatchesContract('createMealLog', 201, created.body);
    expect(created.body.data.totals.nutrients.energy_kcal).toBeCloseTo(195, 0);

    const date = created.body.data.local_date;
    const diary = await user.call('GET', `/v1/meal-logs?date=${date}`);
    expect(diary.status).toBe(200);
    expectMatchesContract('listMealLogs', 200, diary.body);
    expect(diary.body.data.logs).toHaveLength(1);

    const patch = await user.call('PATCH', `/v1/meal-logs/${created.body.data.id}`, {
      expected_revision: created.body.data.revision,
      items: [{ label: 'White rice', grams: 200 }],
    });
    expect(patch.status).toBe(200);
    expect(patch.body.data.revision).toBe(created.body.data.revision + 1);

    const staleDelete = await user.call(
      'DELETE',
      `/v1/meal-logs/${created.body.data.id}?expected_revision=${created.body.data.revision}`,
    );
    expect(staleDelete.status).toBe(409);

    const del = await user.call(
      'DELETE',
      `/v1/meal-logs/${created.body.data.id}?expected_revision=${patch.body.data.revision}`,
    );
    expect(del.status).toBe(200);
    expect(del.body.data).toEqual({ id: created.body.data.id, deleted: true });

    const afterDelete = await user.call('GET', `/v1/meal-logs?date=${date}`);
    expect(afterDelete.body.data.logs).toHaveLength(0);
  });

  it('replays createMealLog on the same client_id (offline-safe duplicate handling)', async () => {
    const user = await newUser();
    const clientId = randomUUID();
    const body = {
      client_id: clientId,
      consumed_at: new Date().toISOString(),
      timezone: 'UTC',
      slot: 'breakfast',
      items: [{ label: 'Banana', grams: 100 }],
    };
    const first = await user.call('POST', '/v1/meal-logs', body, { key: randomUUID() });
    const second = await user.call('POST', '/v1/meal-logs', body, { key: randomUUID() });
    expect(second.body.data.id).toBe(first.body.data.id);
    const count = await admin.query(
      'select count(*)::int as n from app.meal_logs where client_id = $1',
      [clientId],
    );
    expect(count.rows[0]!.n).toBe(1);
  });

  it('never lets another user edit or delete someone else’s meal log', async () => {
    const owner = await newUser();
    const other = await newUser();
    const created = await owner.call('POST', '/v1/meal-logs', {
      client_id: randomUUID(),
      consumed_at: new Date().toISOString(),
      timezone: 'UTC',
      slot: 'dinner',
      items: [{ label: 'White rice', grams: 100 }],
    });
    expect(
      (
        await other.call('PATCH', `/v1/meal-logs/${created.body.data.id}`, {
          expected_revision: 1,
          slot: 'snack',
        })
      ).status,
    ).toBe(404);
    expect(
      (await other.call('DELETE', `/v1/meal-logs/${created.body.data.id}?expected_revision=1`))
        .status,
    ).toBe(404);
  });
});
