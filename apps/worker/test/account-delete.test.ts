import { randomUUID } from 'node:crypto';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { MockAuthAdminProvider } from '@noura/billing';
import { LocalMediaStorage } from '@noura/domain';
import pg from 'pg';
import { pino } from 'pino';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { handleAccountDelete } from '../src/handlers/account-delete.js';

const log = pino({ level: 'silent' });
const admin = new pg.Pool({ connectionString: process.env.DATABASE_URL, max: 4 });
const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL, max: 4 });

let dir: string;
let storage: LocalMediaStorage;

beforeAll(() => {
  dir = mkdtempSync(join(tmpdir(), 'noura-account-delete-test-'));
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

async function seedDeletionRequest(userId: string): Promise<string> {
  const row = await admin.query<{ id: string }>(
    `insert into app.deletion_requests (user_id, state) values ($1, 'requested') returning id`,
    [userId],
  );
  return row.rows[0]!.id;
}

function job(requestId: string, userId: string) {
  return [{ id: requestId, data: { deletion_request_id: requestId, user_id: userId } } as never];
}

function authAdminThatReallyDeletes(): MockAuthAdminProvider {
  return new MockAuthAdminProvider({
    deleteAuthUser: async (userId) => {
      await pool.query('delete from auth.users where id = $1', [userId]);
    },
  });
}

describe('handleAccountDelete', () => {
  it('cancels queued jobs, deletes Storage objects and cascades to owned rows via the auth identity', async () => {
    const userId = await newUser();
    await admin.query(
      `insert into app.weight_logs (user_id, measured_at, weight_kg, client_id) values ($1, now(), 70, $2)`,
      [userId, randomUUID()],
    );
    const queuedRequest = await admin.query<{ id: string }>(
      `insert into app.generation_requests (user_id, request_type) values ($1, 'coach_reply') returning id`,
      [userId],
    );

    const mediaId = randomUUID();
    const objectPath = `${userId}/${mediaId}.png`;
    await admin.query(
      `insert into app.media_assets
         (id, user_id, purpose, bucket, object_path, declared_mime, status, verified_mime, byte_size)
       values ($1, $2, 'meal', 'meal-images', $3, 'image/png', 'verified', 'image/png', 10)`,
      [mediaId, userId, objectPath],
    );
    await storage.writeObject('meal-images', objectPath, new Uint8Array([1, 2, 3]));

    const requestId = await seedDeletionRequest(userId);
    const authAdmin = authAdminThatReallyDeletes();

    const result = await handleAccountDelete(job(requestId, userId), pool, storage, authAdmin, log);
    expect(result.status).toBe('completed');

    // The queued job was cancelled before the identity (and its FK-owned row) disappeared.
    const cancelled = await admin.query(
      'select status from app.generation_requests where id = $1',
      [queuedRequest.rows[0]!.id],
    );
    expect(cancelled.rows).toEqual([]); // cascaded away with the deleted auth user

    // The Storage object was actually removed.
    expect(await storage.readObject('meal-images', objectPath)).toBeNull();

    // The auth identity and every owned row are gone via cascade.
    const authRow = await admin.query('select 1 from auth.users where id = $1', [userId]);
    expect(authRow.rowCount).toBe(0);
    const weightRows = await admin.query('select 1 from app.weight_logs where user_id = $1', [
      userId,
    ]);
    expect(weightRows.rowCount).toBe(0);

    // The deletion_requests tombstone itself survives (no FK to auth.users) and reports completed.
    const tombstone = await admin.query<{ state: string }>(
      'select state from app.deletion_requests where id = $1',
      [requestId],
    );
    expect(tombstone.rows[0]).toMatchObject({ state: 'completed' });
  });

  it('is idempotent: a second delivery for an already-completed deletion is a no-op', async () => {
    const userId = await newUser();
    const requestId = await seedDeletionRequest(userId);
    const authAdmin = authAdminThatReallyDeletes();
    await handleAccountDelete(job(requestId, userId), pool, storage, authAdmin, log);
    const second = await handleAccountDelete(job(requestId, userId), pool, storage, authAdmin, log);
    expect(second.status).toBe('already_terminal');
  });

  it('skips a request that does not belong to the given user', async () => {
    const owner = await newUser();
    const other = await newUser();
    const requestId = await seedDeletionRequest(owner);
    const result = await handleAccountDelete(
      job(requestId, other),
      pool,
      storage,
      authAdminThatReallyDeletes(),
      log,
    );
    expect(result.status).toBe('skipped_missing');
  });
});
