import {
  GENERATION_REQUEST_QUEUES,
  QUEUES,
  withSystemTransaction,
  type PoolLike,
  type QueuePayloads,
} from '@noura/domain';
import type { PgBoss } from 'pg-boss';
import type { Logger } from 'pino';

interface PendingRequest {
  id: string;
  user_id: string;
  request_type: string;
}

export interface RelayResult {
  dispatched: number;
  skipped: number;
}

/**
 * Transactional-outbox relay (docs/decisions.md D-017). The API commits a durable generation request
 * together with the onboarding completion; this hands each undispatched request to pg-boss.
 *
 * - The job id is the request id, so a crash between "send" and "record" is repaired on the next
 *   run: the repeated send is a no-op (pg-boss returns null for an existing id) and the dispatch is
 *   then recorded. Delivery is at-least-once; handlers must be idempotent on the request id.
 * - Payloads carry ids only. The handler reloads everything under the user's own context.
 * - Rows are claimed with FOR UPDATE SKIP LOCKED so overlapping relays never double-send.
 */
export async function relayGenerationRequests(
  pool: PoolLike,
  boss: Pick<PgBoss, 'send'>,
  log: Logger,
  options: { batchSize?: number } = {},
): Promise<RelayResult> {
  const batchSize = options.batchSize ?? 25;
  return withSystemTransaction(pool, 'noura_worker', async (client) => {
    const { rows } = await client.query<PendingRequest>(
      `select id, user_id, request_type from app.generation_requests
        where status = 'queued' and queue_job_id is null
        order by created_at
        limit $1
        for update skip locked`,
      [batchSize],
    );
    const result: RelayResult = { dispatched: 0, skipped: 0 };
    for (const request of rows) {
      const queue =
        GENERATION_REQUEST_QUEUES[request.request_type as keyof typeof GENERATION_REQUEST_QUEUES];
      if (!queue) {
        // A request type whose queue does not exist yet; leave it for the milestone that adds it.
        result.skipped += 1;
        log.warn({ request_type: request.request_type }, 'no queue for generation request type');
        continue;
      }
      const payload: QueuePayloads[typeof queue] = {
        generation_request_id: request.id,
        user_id: request.user_id,
      };
      await boss.send(queue, payload, { id: request.id });
      await client.query(
        `update app.generation_requests set queue_name = $2, queue_job_id = $1
          where id = $1 and queue_job_id is null`,
        [request.id, queue],
      );
      result.dispatched += 1;
    }
    return result;
  });
}

/**
 * Same transactional-outbox shape as `relayGenerationRequests`, for `app.export_requests` and
 * `app.deletion_requests` — tables with their own dedicated state machines (not `generation_requests`
 * rows) but the same "dispatch to pg-boss exactly once" columns added in
 * 20261001001400_m10_billing_notifications_account.sql.
 */
export async function relayAccountRequests(
  pool: PoolLike,
  boss: Pick<PgBoss, 'send'>,
  log: Logger,
  options: { batchSize?: number } = {},
): Promise<RelayResult> {
  const batchSize = options.batchSize ?? 25;
  return withSystemTransaction(pool, 'noura_worker', async (client) => {
    const result: RelayResult = { dispatched: 0, skipped: 0 };

    const { rows: exportRows } = await client.query<{ id: string; user_id: string }>(
      `select id, user_id from app.export_requests
         where state = 'queued' and queue_job_id is null
         order by requested_at limit $1 for update skip locked`,
      [batchSize],
    );
    for (const row of exportRows) {
      const payload: QueuePayloads['account.export'] = {
        export_request_id: row.id,
        user_id: row.user_id,
      };
      await boss.send(QUEUES.accountExport, payload, { id: row.id });
      await client.query(
        `update app.export_requests set queue_name = $2, queue_job_id = $1 where id = $1 and queue_job_id is null`,
        [row.id, QUEUES.accountExport],
      );
      result.dispatched += 1;
    }

    const { rows: deletionRows } = await client.query<{ id: string; user_id: string }>(
      `select id, user_id from app.deletion_requests
         where state = 'requested' and queue_job_id is null
         order by requested_at limit $1 for update skip locked`,
      [batchSize],
    );
    for (const row of deletionRows) {
      const payload: QueuePayloads['account.delete'] = {
        deletion_request_id: row.id,
        user_id: row.user_id,
      };
      await boss.send(QUEUES.accountDelete, payload, { id: row.id });
      await client.query(
        `update app.deletion_requests set queue_name = $2, queue_job_id = $1 where id = $1 and queue_job_id is null`,
        [row.id, QUEUES.accountDelete],
      );
      result.dispatched += 1;
    }

    if (result.dispatched > 0) log.info(result, 'relayed account export/deletion requests');
    return result;
  });
}

export interface RelayLoop {
  /** Stops scheduling and waits for a run in progress. */
  stop: () => Promise<void>;
}

/** Runs the relay now and then every intervalMs, never overlapping itself. Errors are logged. */
export function startRelayLoop(
  run: () => Promise<RelayResult>,
  intervalMs: number,
  log: Logger,
): RelayLoop {
  let stopped = false;
  let inFlight: Promise<void> = Promise.resolve();
  let timer: NodeJS.Timeout | undefined;

  const tick = (): void => {
    inFlight = run()
      .then((result) => {
        if (result.dispatched > 0) log.info(result, 'relayed generation requests');
      })
      .catch((error: unknown) => log.error({ err: error }, 'generation relay failed'))
      .finally(() => {
        if (!stopped) timer = setTimeout(tick, intervalMs);
      });
  };
  tick();

  return {
    stop: async () => {
      stopped = true;
      if (timer) clearTimeout(timer);
      await inFlight;
    },
  };
}
