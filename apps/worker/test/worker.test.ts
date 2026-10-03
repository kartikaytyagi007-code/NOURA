import { randomUUID } from 'node:crypto';
import { QUEUES } from '@noura/domain';
import { PgBoss } from 'pg-boss';
import { pino } from 'pino';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { loadConfig } from '../src/config.js';
import { startWorker, type WorkerRuntime } from '../src/runtime.js';

const log = pino({ level: 'silent' });
let runtime: WorkerRuntime;
let producer: PgBoss;

beforeAll(async () => {
  const config = loadConfig({
    APP_ENV: 'test',
    WORKER_DATABASE_URL: process.env.DATABASE_URL,
    WORKER_HEALTH_HOST: '127.0.0.1',
    WORKER_HEALTH_PORT: '0',
    LOG_LEVEL: 'silent',
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
