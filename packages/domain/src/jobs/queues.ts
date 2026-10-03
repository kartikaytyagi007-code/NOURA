/**
 * Queue registry shared by the API (producer) and worker (consumer). Payloads carry IDs only, never
 * images, chat histories or profile details (blueprint §2).
 *
 * M1 registers only the system ping queue used to prove queue connectivity. Feature queues are added
 * by their milestones.
 */
export const QUEUES = {
  systemPing: 'system.ping',
  /** Initial diet-plan generation, requested when onboarding completes. The handler arrives in M3. */
  dietPlanGenerate: 'diet-plan.generate',
} as const;

export type QueueName = (typeof QUEUES)[keyof typeof QUEUES];

export interface QueuePayloads {
  'system.ping': { requested_at: string; correlation_id: string };
  /** IDs only (blueprint §2): the request row holds everything else. */
  'diet-plan.generate': { generation_request_id: string; user_id: string };
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
  'diet-plan.generate': {
    retryLimit: 3,
    retryDelaySeconds: 10,
    retryBackoff: true,
    expireInSeconds: 600,
    retentionDays: 14,
    deadLetter: DEAD_LETTER_QUEUE,
  },
};

/** Maps generation_requests.request_type to the queue that serves it (types without a queue yet are omitted). */
export const GENERATION_REQUEST_QUEUES = {
  diet_plan: QUEUES.dietPlanGenerate,
} as const satisfies Record<string, QueueName>;

export function isQueueName(value: string): value is QueueName {
  return Object.values(QUEUES).includes(value as QueueName);
}
