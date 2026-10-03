import { randomUUID } from 'node:crypto';
import { MOCK_WEBHOOK_AUTH } from '@noura/billing';
import pg from 'pg';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
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

function webhookEvent(overrides: Record<string, unknown> = {}) {
  return {
    api_version: '1.0',
    event: {
      id: randomUUID(),
      type: 'INITIAL_PURCHASE',
      app_user_id: overrides.app_user_id,
      environment: 'SANDBOX',
      entitlement_id: 'premium',
      event_timestamp_ms: Date.now(),
      expiration_at_ms: Date.now() + 30 * 86_400_000,
      ...overrides,
    },
  };
}

describe('GET /v1/entitlements and GET /v1/usage', () => {
  it('reports no entitlements and the free quota for a brand-new user', async () => {
    const u = await newUser();
    const ent = await ctx.app.inject({
      method: 'GET',
      url: '/v1/entitlements',
      headers: { authorization: `Bearer ${u.token}` },
    });
    expect(ent.statusCode).toBe(200);
    expect(ent.json().data.entitlements).toEqual([]);

    const usage = await ctx.app.inject({
      method: 'GET',
      url: '/v1/usage',
      headers: { authorization: `Bearer ${u.token}` },
    });
    expect(usage.statusCode).toBe(200);
    const mealScan = usage
      .json()
      .data.features.find((f: { feature: string }) => f.feature === 'meal_scan');
    expect(mealScan).toMatchObject({ limit: 3, used: 0, reserved: 0 });
  });
});

describe('POST /v1/webhooks/revenuecat', () => {
  it('rejects a missing/invalid webhook authorization', async () => {
    const res = await ctx.app.inject({
      method: 'POST',
      url: '/v1/webhooks/revenuecat',
      headers: { authorization: 'Bearer wrong' },
      payload: webhookEvent({ app_user_id: randomUUID() }),
    });
    expect(res.statusCode).toBe(401);
  });

  it('activates premium entitlement for the mapped user and is idempotent on event id', async () => {
    const u = await newUser();
    const event = webhookEvent({ app_user_id: u.id });
    for (let i = 0; i < 2; i++) {
      const res = await ctx.app.inject({
        method: 'POST',
        url: '/v1/webhooks/revenuecat',
        headers: { authorization: MOCK_WEBHOOK_AUTH },
        payload: event,
      });
      expect(res.statusCode).toBe(200);
      expect(res.json().data.received).toBe(true);
    }
    const count = await admin.query(
      'select count(*) from app.billing_events where provider_event_id = $1',
      [(event.event as { id: string }).id],
    );
    expect(Number(count.rows[0].count)).toBe(1);

    const ent = await ctx.app.inject({
      method: 'GET',
      url: '/v1/entitlements',
      headers: { authorization: `Bearer ${u.token}` },
    });
    expect(ent.json().data.entitlements).toEqual([
      expect.objectContaining({ key: 'premium', is_active: true }),
    ]);

    const usage = await ctx.app.inject({
      method: 'GET',
      url: '/v1/usage',
      headers: { authorization: `Bearer ${u.token}` },
    });
    const mealScan = usage
      .json()
      .data.features.find((f: { feature: string }) => f.feature === 'meal_scan');
    expect(mealScan.limit).toBe(20); // premium limit, not the free default
  });

  it('never reconciles backwards: a stale/older event cannot undo a newer one', async () => {
    const u = await newUser();
    const now = Date.now();
    const newer = webhookEvent({
      app_user_id: u.id,
      event_timestamp_ms: now,
      expiration_at_ms: now + 30 * 86_400_000,
    });
    const older = webhookEvent({
      app_user_id: u.id,
      type: 'EXPIRATION',
      event_timestamp_ms: now - 60_000,
    });
    await ctx.app.inject({
      method: 'POST',
      url: '/v1/webhooks/revenuecat',
      headers: { authorization: MOCK_WEBHOOK_AUTH },
      payload: newer,
    });
    await ctx.app.inject({
      method: 'POST',
      url: '/v1/webhooks/revenuecat',
      headers: { authorization: MOCK_WEBHOOK_AUTH },
      payload: older,
    });
    const ent = await ctx.app.inject({
      method: 'GET',
      url: '/v1/entitlements',
      headers: { authorization: `Bearer ${u.token}` },
    });
    // The older EXPIRATION event must not have overwritten the newer active state.
    expect(ent.json().data.entitlements[0]).toMatchObject({ is_active: true });
  });

  it('ignores an event with no resolvable app_user_id rather than guessing a user', async () => {
    const res = await ctx.app.inject({
      method: 'POST',
      url: '/v1/webhooks/revenuecat',
      headers: { authorization: MOCK_WEBHOOK_AUTH },
      payload: webhookEvent({ app_user_id: undefined }),
    });
    expect(res.statusCode).toBe(200);
  });

  it('rejects a malformed payload with 422', async () => {
    const res = await ctx.app.inject({
      method: 'POST',
      url: '/v1/webhooks/revenuecat',
      headers: { authorization: MOCK_WEBHOOK_AUTH },
      payload: { event: {} },
    });
    expect(res.statusCode).toBe(422);
  });
});

describe('POST /v1/billing/sync', () => {
  it('never fabricates an entitlement (mock restore returns no active entitlements)', async () => {
    const u = await newUser();
    const res = await ctx.app.inject({
      method: 'POST',
      url: '/v1/billing/sync',
      headers: { authorization: `Bearer ${u.token}`, 'idempotency-key': randomUUID() },
    });
    expect(res.statusCode).toBe(200);
    expect(res.json().data.entitlements).toEqual([]);
  });
});

describe('entitlement-aware quota: meal-scan and coach-reply', () => {
  it('raises the coach-reply quota to the premium limit once entitled', async () => {
    const u = await newUser();
    await ctx.app.inject({
      method: 'POST',
      url: '/v1/webhooks/revenuecat',
      headers: { authorization: MOCK_WEBHOOK_AUTH },
      payload: webhookEvent({ app_user_id: u.id }),
    });
    const thread = await ctx.app.inject({
      method: 'POST',
      url: '/v1/coach/threads',
      headers: { authorization: `Bearer ${u.token}`, 'idempotency-key': randomUUID() },
    });
    const threadId = thread.json().data.id;
    let last;
    for (let i = 0; i < 6; i++) {
      last = await ctx.app.inject({
        method: 'POST',
        url: `/v1/coach/threads/${threadId}/messages`,
        headers: { authorization: `Bearer ${u.token}`, 'idempotency-key': randomUUID() },
        payload: { client_id: randomUUID(), message: `message ${i}` },
      });
    }
    // A free user would be blocked at message 6 (quota 5); premium allows at least 6.
    expect(last!.statusCode).toBe(202);
  });
});
