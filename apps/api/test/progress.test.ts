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
  dir = mkdtempSync(join(tmpdir(), 'noura-api-progress-test-'));
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
      if (options.key !== null && method !== 'GET')
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

async function newUser(
  overrides: { weightKg?: number | null; timezone?: string } = {},
): Promise<Caller> {
  const id = randomUUID();
  await admin.query('insert into auth.users (id, email) values ($1, $2)', [
    id,
    `${id}@test.invalid`,
  ]);
  await admin.query(
    `insert into app.profiles (user_id, display_name, weight_kg, timezone, onboarding_status, revision)
     values ($1, 'Test User', $2, $3, 'in_progress', 1)`,
    [id, overrides.weightKg ?? null, overrides.timezone ?? 'UTC'],
  );
  const token = await signToken(keys, { sub: id });
  return callerFor(id, token);
}

/** A minimal, genuinely parseable PNG (signature + IHDR only). */
function png(filler = 0): Buffer {
  const bytes = Buffer.alloc(40, filler);
  const sig = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];
  sig.forEach((b, i) => (bytes[i] = b));
  bytes.writeUInt32BE(13, 8);
  bytes.write('IHDR', 12, 'ascii');
  bytes.writeUInt32BE(100, 16);
  bytes.writeUInt32BE(100, 20);
  bytes[24] = 8;
  bytes[25] = 2;
  return bytes;
}

async function rawPutToUploadUrl(uploadUrl: string, bytes: Buffer) {
  const url = new URL(uploadUrl);
  return ctx.app.inject({
    method: 'PUT',
    url: `${url.pathname}${url.search}`,
    headers: { 'content-type': 'image/png' },
    payload: bytes,
  });
}

/** Uploads and verifies a progress-photo media asset, returning its id. */
async function uploadVerifiedProgressPhotoMedia(caller: Caller, bytes = png()): Promise<string> {
  const slot = await caller.call('POST', '/v1/media/upload-slots', {
    purpose: 'progress_photo',
    mime: 'image/png',
    size_bytes: bytes.length,
  });
  expect(slot.status).toBe(201);
  const putRes = await rawPutToUploadUrl(slot.body.data.upload_url, bytes);
  expect(putRes.statusCode).toBe(200);
  const complete = await caller.call('POST', `/v1/media/${slot.body.data.media_id}/complete`);
  expect(complete.status).toBe(200);
  return slot.body.data.media_id as string;
}

describe('weight history', () => {
  it('records a weight entry, is idempotent by client_id, and lists it newest first', async () => {
    const u = await newUser();
    const clientId = randomUUID();
    const first = await u.call('POST', '/v1/weight-logs', {
      client_id: clientId,
      measured_at: '2026-09-28T07:00:00Z',
      weight_kg: 74.2,
    });
    expect(first.status).toBe(201);
    expectMatchesContract('createWeightLog', 201, first.body);

    const second = await u.call('POST', '/v1/weight-logs', {
      client_id: clientId,
      measured_at: '2026-09-28T07:00:00Z',
      weight_kg: 74.2,
    });
    expect(second.body.data.id).toBe(first.body.data.id);
    const count = await admin.query(
      'select count(*)::int as n from app.weight_logs where user_id = $1',
      [u.id],
    );
    expect(count.rows[0]!.n).toBe(1);

    await u.call('POST', '/v1/weight-logs', {
      client_id: randomUUID(),
      measured_at: '2026-10-01T07:00:00Z',
      weight_kg: 73.5,
    });
    const list = await u.call('GET', '/v1/weight-logs');
    expect(list.status).toBe(200);
    expectMatchesContract('listWeightLogs', 200, list.body);
    expect(list.body.data.items[0].weight_kg).toBe(73.5); // newest first
    expect(list.body.data.items).toHaveLength(2);
  });

  it('rejects an unrealistic weight and a future-dated entry', async () => {
    const u = await newUser();
    const tooHigh = await u.call('POST', '/v1/weight-logs', {
      client_id: randomUUID(),
      measured_at: '2026-09-28T07:00:00Z',
      weight_kg: 450,
    });
    expect(tooHigh.status).toBe(422);

    const future = await u.call('POST', '/v1/weight-logs', {
      client_id: randomUUID(),
      measured_at: '2099-01-01T00:00:00Z',
      weight_kg: 70,
    });
    expect(future.status).toBe(422);
  });

  it('deletes a weight entry, and ownership is enforced', async () => {
    const owner = await newUser();
    const created = await owner.call('POST', '/v1/weight-logs', {
      client_id: randomUUID(),
      measured_at: '2026-09-28T07:00:00Z',
      weight_kg: 70,
    });
    const id = created.body.data.id;

    const stranger = await newUser();
    expect((await stranger.call('DELETE', `/v1/weight-logs/${id}`)).status).toBe(404);

    const res = await owner.call('DELETE', `/v1/weight-logs/${id}`);
    expect(res.status).toBe(200);
    expectMatchesContract('deleteWeightLog', 200, res.body);
    expect((await owner.call('DELETE', `/v1/weight-logs/${id}`)).status).toBe(404);
  });

  it('requires authentication', async () => {
    const res = await ctx.app.inject({ method: 'GET', url: '/v1/weight-logs' });
    expect(res.statusCode).toBe(401);
  });
});

describe('progress photos', () => {
  it('registers a verified upload as a progress photo, idempotently, and lists it', async () => {
    const u = await newUser();
    const mediaId = await uploadVerifiedProgressPhotoMedia(u);
    const first = await u.call('POST', '/v1/progress-photos', {
      media_id: mediaId,
      captured_at: '2026-09-15T08:00:00Z',
      angle: 'front',
    });
    expect(first.status).toBe(201);
    expectMatchesContract('createProgressPhoto', 201, first.body);

    const second = await u.call('POST', '/v1/progress-photos', {
      media_id: mediaId,
      captured_at: '2026-09-15T08:00:00Z',
      angle: 'front',
    });
    expect(second.body.data.id).toBe(first.body.data.id);

    const list = await u.call('GET', '/v1/progress-photos');
    expect(list.status).toBe(200);
    expectMatchesContract('listProgressPhotos', 200, list.body);
    expect(list.body.data.items).toHaveLength(1);
  });

  it('refuses to register media that is not the caller’s own verified progress-photo upload', async () => {
    const owner = await newUser();
    const mediaId = await uploadVerifiedProgressPhotoMedia(owner);

    const stranger = await newUser();
    const res = await stranger.call('POST', '/v1/progress-photos', {
      media_id: mediaId,
      captured_at: '2026-09-15T08:00:00Z',
      angle: 'front',
    });
    expect(res.status).toBe(404);

    // A meal-purpose upload cannot be registered as a progress photo either.
    const mealSlot = await owner.call('POST', '/v1/media/upload-slots', {
      purpose: 'meal',
      mime: 'image/png',
      size_bytes: 40,
    });
    await rawPutToUploadUrl(mealSlot.body.data.upload_url, png(5));
    await owner.call('POST', `/v1/media/${mealSlot.body.data.media_id}/complete`);
    const wrongPurpose = await owner.call('POST', '/v1/progress-photos', {
      media_id: mealSlot.body.data.media_id,
      captured_at: '2026-09-15T08:00:00Z',
      angle: 'front',
    });
    expect(wrongPurpose.status).toBe(404);
  });

  it('deletes a progress photo, which also revokes access to the underlying image (ownership-gated)', async () => {
    const owner = await newUser();
    const mediaId = await uploadVerifiedProgressPhotoMedia(owner);
    const created = await owner.call('POST', '/v1/progress-photos', {
      media_id: mediaId,
      captured_at: '2026-09-15T08:00:00Z',
      angle: 'side',
    });
    const id = created.body.data.id;

    const stranger = await newUser();
    expect((await stranger.call('DELETE', `/v1/progress-photos/${id}`)).status).toBe(404);

    const res = await owner.call('DELETE', `/v1/progress-photos/${id}`);
    expect(res.status).toBe(200);
    expectMatchesContract('deleteProgressPhoto', 200, res.body);

    // Listing no longer shows it, and the backing media is no longer downloadable.
    const list = await owner.call('GET', '/v1/progress-photos');
    expect(list.body.data.items).toHaveLength(0);
    expect((await owner.call('GET', `/v1/media/${mediaId}/download`)).status).toBe(404);
  });

  it('a progress-photo upload slot is granted no auto-expiry (blueprint retention, D-030)', async () => {
    const u = await newUser();
    const slot = await u.call('POST', '/v1/media/upload-slots', {
      purpose: 'progress_photo',
      mime: 'image/png',
      size_bytes: 40,
    });
    const row = await admin.query('select expires_at from app.media_assets where id = $1', [
      slot.body.data.media_id,
    ]);
    expect(row.rows[0]!.expires_at).toBeNull();
  });
});

describe('GET /v1/progress', () => {
  it('reports a data-unavailable state honestly when nothing has been recorded yet', async () => {
    const u = await newUser();
    const res = await u.call('GET', '/v1/progress?period=30d');
    expect(res.status).toBe(200);
    expectMatchesContract('getProgress', 200, res.body);
    expect(res.body.data.starting_weight_kg).toBeNull();
    expect(res.body.data.current_weight_kg).toBeNull();
    expect(res.body.data.goal_weight_kg).toBeNull();
    expect(res.body.data.weight_points).toEqual([]);
    // No active plan: honestly null, never a fabricated 0-of-0.
    expect(res.body.data.diet_adherence).toEqual({
      plan_active: false,
      planned: null,
      logged: null,
    });
    expect(res.body.data.workout_adherence).toEqual({
      plan_active: false,
      planned: null,
      logged: null,
    });
  });

  it('derives starting/current weight from history, falling back to the profile otherwise', async () => {
    const u = await newUser({ weightKg: 80 });
    // No history yet: both starting and current fall back to the profile's onboarding weight.
    const before = await u.call('GET', '/v1/progress?period=30d');
    expect(before.body.data.starting_weight_kg).toBe(80);
    expect(before.body.data.current_weight_kg).toBe(80);

    await u.call('POST', '/v1/weight-logs', {
      client_id: randomUUID(),
      measured_at: '2026-09-01T07:00:00Z',
      weight_kg: 78,
    });
    await u.call('POST', '/v1/weight-logs', {
      client_id: randomUUID(),
      measured_at: '2026-10-01T07:00:00Z',
      weight_kg: 75,
    });
    const after = await u.call('GET', '/v1/progress?period=30d');
    expect(after.body.data.starting_weight_kg).toBe(78); // first-ever recorded entry
    expect(after.body.data.current_weight_kg).toBe(75); // latest entry
  });

  it('reports the active goal weight', async () => {
    const u = await newUser();
    await admin.query(
      `insert into app.goals (user_id, goal_type, target_weight_kg) values ($1, 'lose_fat', 68)`,
      [u.id],
    );
    const res = await u.call('GET', '/v1/progress?period=30d');
    expect(res.body.data.goal_weight_kg).toBe(68);
  });

  it('reports honest meal-plan adherence: real zero is distinct from "no plan"', async () => {
    const u = await newUser({ timezone: 'UTC' });
    const snapshot = await admin.query<{ id: string }>(
      `insert into app.target_snapshots
         (user_id, profile_revision, policy_version, selected_targets, method, eligibility)
       values ($1, 1, 'test', '{}'::jsonb, 'policy', 'eligible') returning id`,
      [u.id],
    );
    const inserted = await admin.query<{ id: string }>(
      `insert into app.diet_plans (user_id, version, profile_revision, target_snapshot_id, starts_on, status)
       values ($1, 1, 1, $2, current_date - 2, 'active') returning id`,
      [u.id, snapshot.rows[0]!.id],
    );
    const planId = inserted.rows[0]!.id;
    const meal1 = await admin.query<{ id: string }>(
      `insert into app.diet_plan_meals
         (user_id, plan_id, meal_date, slot, recipe_id, portions_snapshot, nutrition_snapshot)
       values ($1, $2, current_date - 1, 'breakfast', null, '[]'::jsonb, '{}'::jsonb) returning id`,
      [u.id, planId],
    );
    await admin.query(
      `insert into app.diet_plan_meals
         (user_id, plan_id, meal_date, slot, recipe_id, portions_snapshot, nutrition_snapshot)
       values ($1, $2, current_date, 'lunch', null, '[]'::jsonb, '{}'::jsonb)`,
      [u.id, planId],
    );

    const noneLogged = await u.call('GET', '/v1/progress?period=30d');
    expect(noneLogged.body.data.diet_adherence).toEqual({
      plan_active: true,
      planned: 2,
      logged: 0,
    });

    await admin.query(
      `insert into app.meal_logs
         (user_id, client_id, consumed_at, local_date, timezone, slot, plan_meal_id, totals_snapshot)
       values ($1, gen_random_uuid(), now(), current_date - 1, 'UTC', 'breakfast', $2, '{}'::jsonb)`,
      [u.id, meal1.rows[0]!.id],
    );
    const oneLogged = await u.call('GET', '/v1/progress?period=30d');
    expect(oneLogged.body.data.diet_adherence).toEqual({
      plan_active: true,
      planned: 2,
      logged: 1,
    });
  });

  it('requires authentication', async () => {
    const res = await ctx.app.inject({ method: 'GET', url: '/v1/progress?period=30d' });
    expect(res.statusCode).toBe(401);
  });
});
