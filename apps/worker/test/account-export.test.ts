import { randomUUID } from 'node:crypto';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { LocalMediaStorage } from '@noura/domain';
import pg from 'pg';
import { pino } from 'pino';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { handleAccountExport } from '../src/handlers/account-export.js';

const log = pino({ level: 'silent' });
const admin = new pg.Pool({ connectionString: process.env.DATABASE_URL, max: 4 });
const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL, max: 4 });

let dir: string;
let storage: LocalMediaStorage;

beforeAll(() => {
  dir = mkdtempSync(join(tmpdir(), 'noura-account-export-test-'));
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

async function newUser(): Promise<string> {
  const id = randomUUID();
  await admin.query('insert into auth.users (id, email) values ($1, $2)', [
    id,
    `${id}@test.invalid`,
  ]);
  return id;
}

async function seedExportRequest(userId: string): Promise<string> {
  const row = await admin.query<{ id: string }>(
    `insert into app.export_requests (user_id, state) values ($1, 'queued') returning id`,
    [userId],
  );
  return row.rows[0]!.id;
}

function job(requestId: string, userId: string) {
  return [{ id: requestId, data: { export_request_id: requestId, user_id: userId } } as never];
}

describe('handleAccountExport', () => {
  it('writes a manifest including owned diet/meal/weight data and marks the export completed', async () => {
    const userId = await newUser();
    await admin.query(
      `insert into app.profiles (user_id, display_name, timezone, unit_system, onboarding_status, onboarding_step, revision)
       values ($1, 'Export Test', 'UTC', 'metric', 'not_started', 'basics', 1)`,
      [userId],
    );
    await admin.query(
      `insert into app.weight_logs (user_id, measured_at, weight_kg, client_id) values ($1, now(), 70, $2)`,
      [userId, randomUUID()],
    );
    const requestId = await seedExportRequest(userId);

    const result = await handleAccountExport(job(requestId, userId), pool, storage, log);
    expect(result.status).toBe('completed');

    const row = await admin.query<{ state: string; result_media_id: string }>(
      'select state, result_media_id from app.export_requests where id = $1',
      [requestId],
    );
    expect(row.rows[0]).toMatchObject({ state: 'completed' });
    const mediaId = row.rows[0]!.result_media_id;
    expect(mediaId).toBeTruthy();

    const media = await admin.query<{ bucket: string; object_path: string; purpose: string }>(
      'select bucket, object_path, purpose from app.media_assets where id = $1',
      [mediaId],
    );
    expect(media.rows[0]).toMatchObject({ bucket: 'exports', purpose: 'export' });

    const bytes = await storage.readObject(media.rows[0]!.bucket, media.rows[0]!.object_path);
    const manifest = JSON.parse(new TextDecoder().decode(bytes!));
    expect(manifest.profile).toMatchObject({ display_name: 'Export Test' });
    expect(manifest.weight_logs).toHaveLength(1);
    // No secrets/provider internals among the actual exported data (the disclaimer note itself
    // mentions "secrets" by name, so it is excluded from this check).
    const { note: _note, ...dataOnly } = manifest;
    expect(JSON.stringify(dataOnly)).not.toMatch(/service_role|api_key|secret/i);
  });

  it('is idempotent: a second delivery for an already-completed export is a no-op', async () => {
    const userId = await newUser();
    const requestId = await seedExportRequest(userId);
    await handleAccountExport(job(requestId, userId), pool, storage, log);
    const second = await handleAccountExport(job(requestId, userId), pool, storage, log);
    expect(second.status).toBe('already_terminal');
  });

  it('skips a request that does not belong to the given user (never cross-user)', async () => {
    const owner = await newUser();
    const other = await newUser();
    const requestId = await seedExportRequest(owner);
    const result = await handleAccountExport(job(requestId, other), pool, storage, log);
    expect(result.status).toBe('skipped_missing');
  });
});
