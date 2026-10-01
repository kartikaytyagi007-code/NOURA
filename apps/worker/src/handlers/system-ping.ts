import type { QueuePayloads } from '@noura/domain';
import type { Job } from 'pg-boss';
import type { Logger } from 'pino';

/**
 * Connectivity probe handler. Idempotent and side-effect free (at-least-once delivery means any
 * handler may run more than once). Registered with batchSize 1; the returned value is stored by
 * pg-boss as the job output.
 */
export async function handleSystemPing(
  [job]: Job<QueuePayloads['system.ping']>[],
  log: Logger,
): Promise<{ pong: true; correlation_id: string }> {
  if (!job) throw new Error('system.ping handler received an empty batch');
  log.info({ job_id: job.id, correlation_id: job.data.correlation_id }, 'system.ping handled');
  return { pong: true, correlation_id: job.data.correlation_id };
}
