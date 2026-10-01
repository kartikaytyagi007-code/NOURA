import { randomUUID } from 'node:crypto';
import { QUEUES } from '@noura/domain';
import pg from 'pg';
import { PgBoss } from 'pg-boss';
import { pino } from 'pino';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { loadConfig } from '../src/config.js';
import { relayGenerationRequests, startRelayLoop } from '../src/relay.js';
import { startWorker, type WorkerRuntime } from '../src/runtime.js';

const log = pino({ level: 'silent' });
let runtime: WorkerRuntime;
let producer: PgBoss;
const admin = new pg.Pool({ connectionString: process.env.DATABASE_URL, max: 2 });
let wiredRequestId: string;

async function newRequest(type = 'diet_plan'): Promise<{ userId: string; requestId: string }> {
  const userId = randomUUID();
  await admin.query('insert into auth.users (id, email) values ($1, $2)', [
    userId,
    `${userId}@test.invalid`,
  ]);
  const { rows } = await admin.query<{ id: string }>(
    'insert into app.generation_requests (user_id, request_type) values ($1, $2) returning id',
    [userId, type],
  );
  return { userId, requestId: rows[0]!.id };
}

beforeAll(async () => {
  // A request that exists before the worker starts must be relayed by the worker's own loop.
  wiredRequestId = (await newRequest()).requestId;
  const config = loadConfig({
    APP_ENV: 'test',
    WORKER_DATABASE_URL: process.env.DATABASE_URL,
    WORKER_HEALTH_HOST: '127.0.0.1',
    WORKER_HEALTH_PORT: '0',
    LOG_LEVEL: 'silent',
    // Tests drive later relays explicitly; the startup tick covers the wiring test.
    WORKER_RELAY_INTERVAL_MS: '60000',
  });
  runtime = await startWorker(config, log);
  // A separate producer connection, as the API will use in later milestones (send only).
  producer = new PgBoss({
    connectionString: process.env.DATABASE_URL,
    supervise: false,
    schedule: false,
    migrate: false,
  });
  await producer.start();
});

afterAll(async () => {
  await producer.stop({ graceful: false });
  await runtime.stop();
  await admin.end();
});

async function waitForState(id: string, state: string, timeoutMs = 15_000) {
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    const job = await producer.getJobById(QUEUES.systemPing, id);
    if (job?.state === state) return job;
    await new Promise((r) => setTimeout(r, 200));
  }
  throw new Error(`job ${id} did not reach ${state}`);
}

describe('worker runtime', () => {
  it('installs the queue schema and registers the M1 queues with policies', async () => {
    expect(await runtime.boss.isInstalled()).toBe(true);
    const queue = await runtime.boss.getQueue(QUEUES.systemPing);
    expect(queue).toMatchObject({
      name: 'system.ping',
      retryLimit: 2,
      deadLetter: 'system.dead-letter',
    });
  });

  it('processes a job sent by a separate producer through PostgreSQL (queue connectivity)', async () => {
    const correlationId = randomUUID();
    const id = await producer.send(QUEUES.systemPing, {
      requested_at: new Date().toISOString(),
      correlation_id: correlationId,
    });
    expect(id).toBeTruthy();
    const job = await waitForState(id!, 'completed');
    expect(job.output).toMatchObject({ pong: true, correlation_id: correlationId });
  });

  it('serves liveness and readiness on the health port', async () => {
    const base = `http://127.0.0.1:${runtime.healthPort()}`;
    const live = await fetch(`${base}/health/live`);
    expect(live.status).toBe(200);
    const ready = await fetch(`${base}/health/ready`);
    expect(ready.status).toBe(200);
    expect(await ready.json()).toMatchObject({ status: 'ok', service: 'worker' });
  });

  it('uses the development mock AI provider only because APP_ENV=test', () => {
    expect(runtime.ai.name).toBe('mock');
  });
});

describe('worker configuration', () => {
  it('fails closed in production without a real AI provider', () => {
    expect(() =>
      loadConfig({ APP_ENV: 'production', WORKER_DATABASE_URL: 'postgresql://x@localhost/db' }),
    ).toThrow(/AI_PROVIDER/);
  });

  it('disables automatic queue-schema migration in deployed environments by default', () => {
    const config = loadConfig({
      APP_ENV: 'production',
      WORKER_DATABASE_URL: 'postgresql://x@localhost/db',
      AI_PROVIDER: 'gemini',
      AI_API_KEY: 'placeholder',
      AI_MODEL_ID: 'placeholder',
    });
    expect(config.migrate).toBe(false);
    expect(
      loadConfig({ APP_ENV: 'development', WORKER_DATABASE_URL: 'postgresql://x@localhost/db' })
        .migrate,
    ).toBe(true);
  });
});

describe('generation request relay (transactional outbox)', () => {
  const relayPool = new pg.Pool({ connectionString: process.env.DATABASE_URL, max: 2 });
  afterAll(async () => {
    await relayPool.end();
  });

  const queued = async (id: string) =>
    (
      await admin.query<{ queue_name: string | null; queue_job_id: string | null; status: string }>(
        'select queue_name, queue_job_id, status from app.generation_requests where id = $1',
        [id],
      )
    ).rows[0]!;

  it('is wired into the worker: a request created before startup is relayed by its loop', async () => {
    const deadline = Date.now() + 10_000;
    let row = await queued(wiredRequestId);
    while (!row.queue_job_id && Date.now() < deadline) {
      await new Promise((r) => setTimeout(r, 100));
      row = await queued(wiredRequestId);
    }
    expect(row).toEqual({
      queue_name: 'diet-plan.generate',
      queue_job_id: wiredRequestId,
      status: 'queued',
    });
  });

  it('sends one job per request with ids-only payload, and never twice', async () => {
    const { userId, requestId } = await newRequest();
    const first = await relayGenerationRequests(relayPool, runtime.boss, log);
    expect(first.dispatched).toBeGreaterThanOrEqual(1);
    const job = await producer.getJobById(QUEUES.dietPlanGenerate, requestId);
    expect(job?.id).toBe(requestId);
    expect(job?.data).toEqual({ generation_request_id: requestId, user_id: userId });
    expect(await queued(requestId)).toMatchObject({
      queue_name: 'diet-plan.generate',
      queue_job_id: requestId,
    });

    const second = await relayGenerationRequests(relayPool, runtime.boss, log);
    expect(second.dispatched).toBe(0);
    const { rows } = await admin.query(
      `select count(*)::int as n from pgboss.job where name = $1 and id = $2`,
      [QUEUES.dietPlanGenerate, requestId],
    );
    expect(rows[0].n).toBe(1);
  });

  it('repairs a crash between send and record without creating a duplicate job', async () => {
    const { userId, requestId } = await newRequest();
    // Simulate: the job was sent, then the process died before the dispatch was recorded.
    await runtime.boss.send(
      QUEUES.dietPlanGenerate,
      { generation_request_id: requestId, user_id: userId },
      { id: requestId },
    );
    expect((await queued(requestId)).queue_job_id).toBeNull();
    await relayGenerationRequests(relayPool, runtime.boss, log);
    expect((await queued(requestId)).queue_job_id).toBe(requestId);
    const { rows } = await admin.query('select count(*)::int as n from pgboss.job where id = $1', [
      requestId,
    ]);
    expect(rows[0].n).toBe(1);
  });

  it('leaves request types without a queue untouched', async () => {
    const { requestId } = await newRequest('workout_plan');
    const result = await relayGenerationRequests(relayPool, runtime.boss, log);
    expect(result.skipped).toBeGreaterThanOrEqual(1);
    expect(await queued(requestId)).toEqual({
      queue_name: null,
      queue_job_id: null,
      status: 'queued',
    });
  });

  it('ignores requests that are no longer queued', async () => {
    const { requestId } = await newRequest('weekly_insight');
    await admin.query(
      "update app.generation_requests set status = 'cancelled', completed_at = now() where id = $1",
      [requestId],
    );
    await relayGenerationRequests(relayPool, runtime.boss, log);
    expect((await queued(requestId)).queue_job_id).toBeNull();
  });

  it('the loop keeps running after a failed run and stops cleanly', async () => {
    let runs = 0;
    const loop = startRelayLoop(
      async () => {
        runs += 1;
        if (runs === 1) throw new Error('transient');
        return { dispatched: 0, skipped: 0 };
      },
      20,
      log,
    );
    const deadline = Date.now() + 5_000;
    while (runs < 3 && Date.now() < deadline) await new Promise((r) => setTimeout(r, 20));
    await loop.stop();
    const stoppedAt = runs;
    await new Promise((r) => setTimeout(r, 100));
    expect(stoppedAt).toBeGreaterThanOrEqual(3);
    expect(runs).toBe(stoppedAt);
  });
});
