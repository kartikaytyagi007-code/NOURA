import { randomUUID } from 'node:crypto';
import { listOperations, loadOpenApiDocument, toFastifyPath } from '@noura/contracts';
import { ERROR_CODES } from '@noura/domain';
import { SignJWT } from 'jose';
import pg from 'pg';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { createTestApp } from './support/app.js';
import { createTestKeys, signToken, startJwksServer, type TestKeys } from './support/auth.js';
import { expectMatchesContract } from './support/contract.js';

const admin = new pg.Pool({ connectionString: process.env.DATABASE_URL, max: 2 });
let keys: TestKeys;
let jwks: Awaited<ReturnType<typeof startJwksServer>>;
let ctx: Awaited<ReturnType<typeof createTestApp>>;

async function createAuthUser(): Promise<string> {
  const id = randomUUID();
  await admin.query('insert into auth.users (id, email) values ($1, $2)', [
    id,
    `${id}@test.invalid`,
  ]);
  return id;
}

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

describe('health and readiness', () => {
  it('serves liveness without touching dependencies', async () => {
    const res = await ctx.app.inject({ method: 'GET', url: '/health/live' });
    expect(res.statusCode).toBe(200);
    expectMatchesContract('getLiveness', 200, res.json());
    expect(res.json()).toMatchObject({ status: 'ok', service: 'api' });
  });

  it('reports ready when database, server role and queue schema are available', async () => {
    const res = await ctx.app.inject({ method: 'GET', url: '/health/ready' });
    expect(res.statusCode).toBe(200);
    expectMatchesContract('getReadiness', 200, res.json());
    expect(res.json().checks).toEqual([
      { name: 'database', ok: true },
      { name: 'server_role', ok: true },
      { name: 'queue_schema', ok: true },
    ]);
  });

  it('reports unavailable (503) when the database cannot be reached, while liveness stays up', async () => {
    const broken = await createTestApp(jwks.url, {
      DATABASE_URL: 'postgresql://nobody:wrong@127.0.0.1:1/none',
    });
    try {
      const ready = await broken.app.inject({ method: 'GET', url: '/health/ready' });
      expect(ready.statusCode).toBe(503);
      expectMatchesContract('getReadiness', 503, ready.json());
      expect(ready.json().status).toBe('unavailable');
      const live = await broken.app.inject({ method: 'GET', url: '/health/live' });
      expect(live.statusCode).toBe(200);
    } finally {
      await broken.close();
    }
  });
});

describe('request ids', () => {
  it('generates a request id and returns it in the header', async () => {
    const res = await ctx.app.inject({ method: 'GET', url: '/v1/me' });
    const id = res.headers['x-request-id'];
    expect(typeof id).toBe('string');
    expect(res.json().meta.request_id).toBe(id);
  });

  it('keeps a well-formed incoming request id and replaces a malformed one', async () => {
    const good = await ctx.app.inject({
      method: 'GET',
      url: '/health/live',
      headers: { 'x-request-id': 'edge-req-12345678' },
    });
    expect(good.headers['x-request-id']).toBe('edge-req-12345678');
    const bad = await ctx.app.inject({
      method: 'GET',
      url: '/health/live',
      headers: { 'x-request-id': 'bad id <script>' },
    });
    expect(bad.headers['x-request-id']).not.toBe('bad id <script>');
  });
});

describe('authentication', () => {
  const expectUnauthenticated = (res: { statusCode: number; json: () => unknown }) => {
    expect(res.statusCode).toBe(401);
    const body = res.json() as { error: { code: string; retryable: boolean } };
    expectMatchesContract('getMe', 401, body);
    expect(body.error.code).toBe('UNAUTHENTICATED');
    expect(body.error.retryable).toBe(false);
  };

  it('rejects requests without a bearer token', async () => {
    expectUnauthenticated(await ctx.app.inject({ method: 'GET', url: '/v1/me' }));
    expectUnauthenticated(
      await ctx.app.inject({
        method: 'GET',
        url: '/v1/me',
        headers: { authorization: 'Basic abc' },
      }),
    );
  });

  it('rejects expired, wrong-issuer, wrong-audience, non-authenticated-role and anonymous tokens', async () => {
    const sub = await createAuthUser();
    const cases = [
      await signToken(keys, { sub, expiresIn: Math.floor(Date.now() / 1000) - 60 }),
      await signToken(keys, { sub, issuer: 'https://evil.example/auth/v1' }),
      await signToken(keys, { sub, audience: 'other' }),
      await signToken(keys, { sub, role: 'anon' }),
      await signToken(keys, { sub, role: 'service_role' }),
      await signToken(keys, { sub, isAnonymous: true }),
      await signToken(keys, { sub: 'not-a-uuid' }),
      await signToken(keys, {}),
    ];
    for (const token of cases) {
      expectUnauthenticated(
        await ctx.app.inject({
          method: 'GET',
          url: '/v1/me',
          headers: { authorization: `Bearer ${token}` },
        }),
      );
    }
  });

  it('rejects a token signed by an unknown key', async () => {
    const otherKeys = await createTestKeys('unknown-key');
    const token = await signToken(otherKeys, { sub: await createAuthUser() });
    expectUnauthenticated(
      await ctx.app.inject({
        method: 'GET',
        url: '/v1/me',
        headers: { authorization: `Bearer ${token}` },
      }),
    );
  });

  it('rejects symmetric HS256 tokens even with valid claims', async () => {
    const token = await new SignJWT({ role: 'authenticated' })
      .setProtectedHeader({ alg: 'HS256', kid: keys.kid })
      .setSubject(await createAuthUser())
      .setIssuer('http://127.0.0.1:54321/auth/v1')
      .setAudience('authenticated')
      .setIssuedAt()
      .setExpirationTime('5m')
      .sign(new TextEncoder().encode('a-guessable-shared-secret-value-123'));
    expectUnauthenticated(
      await ctx.app.inject({
        method: 'GET',
        url: '/v1/me',
        headers: { authorization: `Bearer ${token}` },
      }),
    );
  });

  it('rejects a valid token whose auth identity no longer exists', async () => {
    const token = await signToken(keys, { sub: randomUUID() });
    expectUnauthenticated(
      await ctx.app.inject({
        method: 'GET',
        url: '/v1/me',
        headers: { authorization: `Bearer ${token}` },
      }),
    );
  });

  it('returns a retryable 503 when the JWKS endpoint is unreachable', async () => {
    const down = await createTestApp('http://127.0.0.1:1/auth/v1/.well-known/jwks.json');
    try {
      const token = await signToken(keys, { sub: await createAuthUser() });
      const res = await down.app.inject({
        method: 'GET',
        url: '/v1/me',
        headers: { authorization: `Bearer ${token}` },
      });
      expect(res.statusCode).toBe(503);
      expect(res.json().error).toMatchObject({ code: 'PROVIDER_UNAVAILABLE', retryable: true });
    } finally {
      await down.close();
    }
  });
});

describe('GET /v1/me', () => {
  it('creates and returns the caller profile with onboarding status', async () => {
    const sub = await createAuthUser();
    const token = await signToken(keys, { sub });
    const res = await ctx.app.inject({
      method: 'GET',
      url: '/v1/me',
      headers: { authorization: `Bearer ${token}` },
    });
    expect(res.statusCode).toBe(200);
    const body = res.json();
    expectMatchesContract('getMe', 200, body);
    expect(body.data).toMatchObject({
      user_id: sub,
      onboarding: { status: 'not_started', step: null },
      preferences: null,
      training_preferences: null,
      eligibility_status: null,
      goal: null,
      screening: null,
      planning: null,
    });
    expect(body.data.profile.revision).toBe(1);

    const again = await ctx.app.inject({
      method: 'GET',
      url: '/v1/me',
      headers: { authorization: `Bearer ${token}` },
    });
    expect(again.json().data.profile.revision).toBe(1);
    const { rowCount } = await admin.query('select 1 from app.profiles where user_id = $1', [sub]);
    expect(rowCount).toBe(1);
  });

  it('derives identity only from the verified token, ignoring client-supplied user ids', async () => {
    const userA = await createAuthUser();
    const userB = await createAuthUser();
    const token = await signToken(keys, { sub: userA });
    const res = await ctx.app.inject({
      method: 'GET',
      url: `/v1/me?user_id=${userB}`,
      headers: { authorization: `Bearer ${token}`, 'x-user-id': userB },
    });
    expect(res.statusCode).toBe(200);
    expect(res.json().data.user_id).toBe(userA);
  });

  it('returns completed onboarding state written by the server', async () => {
    const sub = await createAuthUser();
    await admin.query(
      `insert into app.profiles (user_id, display_name, age_years, height_cm, weight_kg, activity_band,
                                 onboarding_status, eligibility_status, screening_answered_at, timezone)
       values ($1, 'Asha', 30, 162.5, 58, 'moderate', 'completed', 'eligible', now(), 'Asia/Kolkata')`,
      [sub],
    );
    const token = await signToken(keys, { sub });
    const res = await ctx.app.inject({
      method: 'GET',
      url: '/v1/me',
      headers: { authorization: `Bearer ${token}` },
    });
    const body = res.json();
    expectMatchesContract('getMe', 200, body);
    expect(body.data.profile).toMatchObject({
      display_name: 'Asha',
      height_cm: 162.5,
      timezone: 'Asia/Kolkata',
    });
    expect(body.data.onboarding.status).toBe('completed');
  });
});

describe('GET /v1/jobs/{id} owner isolation', () => {
  let userA: string;
  let userB: string;
  let jobB: string;

  beforeAll(async () => {
    userA = await createAuthUser();
    userB = await createAuthUser();
    const { rows } = await admin.query<{ id: string }>(
      "insert into app.generation_requests (user_id, request_type) values ($1, 'diet_plan') returning id",
      [userB],
    );
    jobB = rows[0]!.id;
  });

  it('returns the owner job with a polling hint', async () => {
    const token = await signToken(keys, { sub: userB });
    const res = await ctx.app.inject({
      method: 'GET',
      url: `/v1/jobs/${jobB}`,
      headers: { authorization: `Bearer ${token}` },
    });
    expect(res.statusCode).toBe(200);
    expectMatchesContract('getJob', 200, res.json());
    expect(res.json().data).toMatchObject({
      id: jobB,
      type: 'diet_plan',
      status: 'queued',
      poll_after_ms: 2000,
    });
  });

  it('returns 404 for another user job, indistinguishable from a missing job', async () => {
    const token = await signToken(keys, { sub: userA });
    const foreign = await ctx.app.inject({
      method: 'GET',
      url: `/v1/jobs/${jobB}`,
      headers: { authorization: `Bearer ${token}` },
    });
    const missing = await ctx.app.inject({
      method: 'GET',
      url: `/v1/jobs/${randomUUID()}`,
      headers: { authorization: `Bearer ${token}` },
    });
    for (const res of [foreign, missing]) {
      expect(res.statusCode).toBe(404);
      expectMatchesContract('getJob', 404, res.json());
    }
    expect(foreign.json().error).toEqual(missing.json().error);
  });

  it('validates the path id and reports field errors', async () => {
    const token = await signToken(keys, { sub: userA });
    const res = await ctx.app.inject({
      method: 'GET',
      url: '/v1/jobs/not-a-uuid',
      headers: { authorization: `Bearer ${token}` },
    });
    expect(res.statusCode).toBe(422);
    expectMatchesContract('getJob', 422, res.json());
    expect(res.json().error.code).toBe('VALIDATION_ERROR');
    expect(res.json().error.field_errors[0].field).toBe('params.id');
  });

  it('requires authentication before validating input', async () => {
    const res = await ctx.app.inject({ method: 'GET', url: '/v1/jobs/not-a-uuid' });
    expect(res.statusCode).toBe(401);
  });
});

describe('contract parity', () => {
  it('registers every implemented operation and none of the planned ones', () => {
    for (const op of listOperations()) {
      const registered = ctx.app.hasRoute({
        method: op.method.toUpperCase() as 'GET',
        url: toFastifyPath(op.path),
      });
      expect(registered, `${op.operationId} (${op.status})`).toBe(op.status === 'implemented');
    }
  });

  it('answers unregistered (planned) routes with the standard 404 envelope', async () => {
    const token = await signToken(keys, { sub: await createAuthUser() });
    const res = await ctx.app.inject({
      method: 'POST',
      // Still x-noura-status: planned (M5): plate fixes are explicitly out of M4 scope.
      url: '/v1/meal-scans/00000000-0000-0000-0000-000000000000/plate-fixes',
      headers: { authorization: `Bearer ${token}` },
      payload: {},
    });
    expect(res.statusCode).toBe(404);
    expect(res.json().error.code).toBe('NOT_FOUND');
  });

  it('keeps the contract error codes in sync with the domain error codes', () => {
    const doc = loadOpenApiDocument() as {
      components: { schemas: { ErrorCode: { enum: string[] } } };
    };
    expect([...doc.components.schemas.ErrorCode.enum].sort()).toEqual([...ERROR_CODES].sort());
  });
});
