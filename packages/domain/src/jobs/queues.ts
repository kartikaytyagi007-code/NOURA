/**
 * Queue registry shared by the API (producer) and worker (consumer). Payloads carry IDs only, never
 * images, chat histories or profile details (blueprint §2).
 *
 * M1 registers only the system ping queue used to prove queue connectivity. Feature queues are added
 * by their milestones.
 */
export const QUEUES = {
  systemPing: 'system.ping',
} as const;

export type QueueName = (typeof QUEUES)[keyof typeof QUEUES];

export interface QueuePayloads {
  'system.ping': { requested_at: string; correlation_id: string };
}

export interface QueuePolicy {
  /** pg-boss retry count for transient failures. Handlers must be idempotent (at-least-once). */
  retryLimit: number;
  retryDelaySeconds: number;
  retryBackoff: boolean;
  /** Seconds before an active job is considered expired and retried. */
  expireInSeconds: number;
  /** Days completed/failed jobs are retained in the queue tables. */
  retentionDays: number;
  deadLetter?: QueueName | string;
}

export const DEAD_LETTER_QUEUE = 'system.dead-letter';

export const QUEUE_POLICIES: Record<QueueName, QueuePolicy> = {
  'system.ping': {
    retryLimit: 2,
    retryDelaySeconds: 2,
    retryBackoff: true,
    expireInSeconds: 60,
    retentionDays: 1,
    deadLetter: DEAD_LETTER_QUEUE,
  },
};

export function isQueueName(value: string): value is QueueName {
  return Object.values(QUEUES).includes(value as QueueName);
}
