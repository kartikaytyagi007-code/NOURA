import { createServer, type Server } from 'node:http';
import type { AddressInfo } from 'node:net';
import { createAiProvider, type AiProvider } from '@noura/ai';
import {
  DEAD_LETTER_QUEUE,
  QUEUE_POLICIES,
  QUEUES,
  type QueueName,
  type QueuePayloads,
} from '@noura/domain';
import pg from 'pg';
import { PgBoss } from 'pg-boss';
import type { Logger } from 'pino';
import type { WorkerConfig } from './config.js';
import { handleSystemPing } from './handlers/system-ping.js';
import { relayGenerationRequests, startRelayLoop } from './relay.js';

export interface WorkerRuntime {
  boss: PgBoss;
  ai: AiProvider;
  healthServer: Server;
  healthPort: () => number;
  stop: () => Promise<void>;
}

/** Creates every queue in the registry (idempotent) with its retry/expiry/retention policy. */
export async function ensureQueues(boss: PgBoss): Promise<void> {
  if (!(await boss.getQueue(DEAD_LETTER_QUEUE))) {
    await boss.createQueue(DEAD_LETTER_QUEUE, {
      retentionSeconds: 14 * 86_400,
      deleteAfterSeconds: 14 * 86_400,
    });
  }
  for (const name of Object.values(QUEUES) as QueueName[]) {
    const policy = QUEUE_POLICIES[name];
    const options = {
      retryLimit: policy.retryLimit,
      retryDelay: policy.retryDelaySeconds,
      retryBackoff: policy.retryBackoff,
      expireInSeconds: policy.expireInSeconds,
      deleteAfterSeconds: policy.retentionDays * 86_400,
      ...(policy.deadLetter ? { deadLetter: policy.deadLetter } : {}),
    };
    if (await boss.getQueue(name)) await boss.updateQueue(name, options);
    else await boss.createQueue(name, options);
  }
}

export async function startWorker(config: WorkerConfig, log: Logger): Promise<WorkerRuntime> {
  // Fail closed before touching the queue: mocks are refused outside development/test.
  const ai = createAiProvider({
    appEnv: config.appEnv,
    provider: config.ai.provider,
    apiKey: config.ai.apiKey,
    modelId: config.ai.modelId,
  });

  const boss = new PgBoss({
    connectionString: config.databaseUrl,
    schema: config.pgBossSchema,
    max: config.poolMax,
    application_name: 'noura-worker',
    migrate: config.migrate,
    createSchema: config.migrate,
  });
  let ready = false;
  boss.on('error', (error) => log.error({ err: error }, 'pg-boss error'));

  await boss.start();
  await ensureQueues(boss);

  await boss.work<QueuePayloads['system.ping']>(
    QUEUES.systemPing,
    { batchSize: 1, localConcurrency: config.concurrency },
    (jobs) => handleSystemPing(jobs, log),
  );
  ready = true;

  // The relay uses its own small pool so it can assume the restricted noura_worker role.
  const relayPool = new pg.Pool({
    connectionString: config.databaseUrl,
    max: 2,
    application_name: 'noura-worker-relay',
  });
  relayPool.on('error', (error) => log.error({ err: error }, 'relay pool error'));
  const relay = startRelayLoop(
    () => relayGenerationRequests(relayPool, boss, log),
    config.relayIntervalMs,
    log,
  );

  const healthServer = createServer((req, res) => {
    const respond = (status: number, body: object) => {
      res.writeHead(status, { 'content-type': 'application/json', 'cache-control': 'no-store' });
      res.end(JSON.stringify(body));
    };
    if (req.url === '/health/live') {
      respond(200, { status: 'ok', service: 'worker', version: config.version, checks: [] });
      return;
    }
    if (req.url === '/health/ready') {
      void boss
        .isInstalled()
        .then((installed) => installed)
        .catch(() => false)
        .then((installed) => {
          const checks = [
            { name: 'queue_schema', ok: installed },
            { name: 'handlers_registered', ok: ready },
          ];
          const ok = checks.every((c) => c.ok);
          respond(ok ? 200 : 503, {
            status: ok ? 'ok' : 'unavailable',
            service: 'worker',
            version: config.version,
            checks,
          });
        });
      return;
    }
    respond(404, { status: 'not_found' });
  });
  await new Promise<void>((resolve) =>
    healthServer.listen(config.health.port, config.health.host, resolve),
  );

  log.info(
    { app_env: config.appEnv, ai_provider: ai.name, queues: Object.values(QUEUES) },
    ai.name === 'mock' ? 'worker started with DEVELOPMENT MOCK AI provider' : 'worker started',
  );

  return {
    boss,
    ai,
    healthServer,
    healthPort: () => (healthServer.address() as AddressInfo).port,
    stop: async () => {
      ready = false;
      await relay.stop();
      await relayPool.end();
      await new Promise<void>((resolve) => healthServer.close(() => resolve()));
      // Graceful: let in-flight handlers finish; unfinished jobs are retried (at-least-once).
      await boss.stop({ graceful: true, timeout: 20_000 });
    },
  };
}
