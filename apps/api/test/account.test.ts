import { randomUUID } from 'node:crypto';
import pg from 'pg';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { requireRecentAuth } from '../src/modules/account/service.js';
import { createTestApp } from './support/app.js';
import { createTestKeys, startJwksServer, signToken, type TestKeys } from './support/auth.js';

const admin = new pg.Pool({ connectionString: process.env.DATABASE_URL, max: 4 });
let keys: TestKeys;
let jwks: Awaited<ReturnType<typeof startJwksServer>>;
let ctx: Awaited<ReturnType<typeof createTestApp>>;

beforeAll(async () => {
  keys = await createTestKeys();
  jwks = await startJwksServer([keys.jwk]);
  ctx = await createTestApp(jwks.url);
});

afterAll(async () => {
  await ctx.close();
  await jwks.close();
  await admin.end();
});

async function newUser(): Promise<{ id: string; token: string }> {
  const id = randomUUID();
  await admin.query('insert into auth.users (id, email) values ($1, $2)', [
    id,
    `${id}@test.invalid`,
  ]);
  const token = await signToken(keys, { sub: id });
  return { id, token };
}

describe('requireRecentAuth', () => {
  it('accepts a token issued just now and rejects a stale one', () => {
    expect(() => requireRecentAuth(Math.floor(Date.now() / 1000))).not.toThrow();
    expect(() => requireRecentAuth(Math.floor(Date.now() / 1000) - 20 * 60)).toThrow(
      /sign in again/,
    );
    expect(() => requireRecentAuth(null)).toThrow(/sign in again/);
  });
});

describe('POST /v1/account/export and GET /v1/account/export/{id}', () => {
  it('accepts an export request and reports queued, then a second concurrent request is quota-limited', async () => {
    const u = await newUser();
    const accepted = await ctx.app.inject({
      method: 'POST',
      url: '/v1/account/export',
      headers: { authorization: `Bearer ${u.token}`, 'idempotency-key': randomUUID() },
    });
    expect(accepted.statusCode).toBe(202);
    const exportId = accepted.json().data.export_id;

    const status = await ctx.app.inject({
      method: 'GET',
      url: `/v1/account/export/${exportId}`,
      headers: { authorization: `Bearer ${u.token}` },
    });
    expect(status.statusCode).toBe(200);
    expect(status.json().data).toMatchObject({ id: exportId, state: 'queued', download_url: null });

    const second = await ctx.app.inject({
      method: 'POST',
      url: '/v1/account/export',
      headers: { authorization: `Bearer ${u.token}`, 'idempotency-key': randomUUID() },
    });
    expect(second.statusCode).toBe(429);
  });

  it('404s for another user’s export id', async () => {
    const u1 = await newUser();
    const u2 = await newUser();
    const accepted = await ctx.app.inject({
      method: 'POST',
      url: '/v1/account/export',
      headers: { authorization: `Bearer ${u1.token}`, 'idempotency-key': randomUUID() },
    });
    const exportId = accepted.json().data.export_id;
    const asU2 = await ctx.app.inject({
      method: 'GET',
      url: `/v1/account/export/${exportId}`,
      headers: { authorization: `Bearer ${u2.token}` },
    });
    expect(asU2.statusCode).toBe(404);
  });
});

describe('DELETE /v1/account', () => {
  it('accepts a deletion request with a recently issued token and is idempotent', async () => {
    const u = await newUser();
    const first = await ctx.app.inject({
      method: 'DELETE',
      url: '/v1/account',
      headers: { authorization: `Bearer ${u.token}`, 'idempotency-key': randomUUID() },
      payload: { confirm: 'DELETE_MY_ACCOUNT' },
    });
    expect(first.statusCode).toBe(202);
    expect(first.json().data.state).toBe('requested');

    const second = await ctx.app.inject({
      method: 'DELETE',
      url: '/v1/account',
      headers: { authorization: `Bearer ${u.token}`, 'idempotency-key': randomUUID() },
      payload: { confirm: 'DELETE_MY_ACCOUNT' },
    });
    expect(second.statusCode).toBe(202);
    expect(second.json().data.deletion_request_id).toBe(first.json().data.deletion_request_id);

    const count = await admin.query(
      'select count(*) from app.deletion_requests where user_id = $1',
      [u.id],
    );
    expect(Number(count.rows[0].count)).toBe(1);
  });

  it('rejects a confirmation value other than the literal string (422)', async () => {
    const u = await newUser();
    const res = await ctx.app.inject({
      method: 'DELETE',
      url: '/v1/account',
      headers: { authorization: `Bearer ${u.token}`, 'idempotency-key': randomUUID() },
      payload: { confirm: 'please delete' },
    });
    expect(res.statusCode).toBe(422);
  });
});

describe('GET/PUT /v1/me/notification-preferences', () => {
  it('defaults to disabled with no consent timestamp, and saves a whole-object replacement', async () => {
    const u = await newUser();
    const initial = await ctx.app.inject({
      method: 'GET',
      url: '/v1/me/notification-preferences',
      headers: { authorization: `Bearer ${u.token}` },
    });
    expect(initial.statusCode).toBe(200);
    expect(initial.json().data).toMatchObject({
      revision: 0,
      meal_reminders_enabled: false,
      workout_reminders_enabled: false,
      consent_granted_at: null,
    });

    const saved = await ctx.app.inject({
      method: 'PUT',
      url: '/v1/me/notification-preferences',
      headers: { authorization: `Bearer ${u.token}`, 'idempotency-key': randomUUID() },
      payload: {
        expected_revision: 0,
        meal_reminders_enabled: true,
        workout_reminders_enabled: false,
        meal_reminder_time: '08:30',
        consent_granted_at: new Date().toISOString(),
      },
    });
    expect(saved.statusCode).toBe(200);
    expect(saved.json().data).toMatchObject({
      revision: 1,
      meal_reminders_enabled: true,
      meal_reminder_time: '08:30',
    });
    expect(saved.json().data.consent_granted_at).not.toBeNull();

    // Toggling off later does not clear the sticky consent timestamp.
    const toggledOff = await ctx.app.inject({
      method: 'PUT',
      url: '/v1/me/notification-preferences',
      headers: { authorization: `Bearer ${u.token}`, 'idempotency-key': randomUUID() },
      payload: {
        expected_revision: 1,
        meal_reminders_enabled: false,
        workout_reminders_enabled: false,
      },
    });
    expect(toggledOff.statusCode).toBe(200);
    expect(toggledOff.json().data.consent_granted_at).toEqual(saved.json().data.consent_granted_at);
  });

  it('returns 409 for a stale expected_revision', async () => {
    const u = await newUser();
    const res = await ctx.app.inject({
      method: 'PUT',
      url: '/v1/me/notification-preferences',
      headers: { authorization: `Bearer ${u.token}`, 'idempotency-key': randomUUID() },
      payload: {
        expected_revision: 5,
        meal_reminders_enabled: true,
        workout_reminders_enabled: true,
      },
    });
    expect(res.statusCode).toBe(409);
  });
});
