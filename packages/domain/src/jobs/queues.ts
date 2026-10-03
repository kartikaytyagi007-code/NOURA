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
  /** Meal-photo recognition (blueprint §8). The handler arrives in M4. */
  mealScanAnalyze: 'meal-scan.analyze',
  /** Weekly workout-plan generation (blueprint §11). The handler arrives in M7. */
  workoutPlanGenerate: 'workout-plan.generate',
  /** Coach chat reply generation (blueprint §12). The handler arrives in M9. */
  coachReply: 'coach.reply',
  /** Account-data export (blueprint §14). The handler arrives in M10. */
  accountExport: 'account.export',
  /** Account deletion: Storage objects, queued jobs, then the auth identity (blueprint §14). The
   * handler arrives in M10. */
  accountDelete: 'account.delete',
} as const;

export type QueueName = (typeof QUEUES)[keyof typeof QUEUES];

export interface QueuePayloads {
  'system.ping': { requested_at: string; correlation_id: string };
  /** IDs only (blueprint §2): the request row holds everything else. */
  'diet-plan.generate': { generation_request_id: string; user_id: string };
  'meal-scan.analyze': { generation_request_id: string; user_id: string };
  'workout-plan.generate': { generation_request_id: string; user_id: string };
  'coach.reply': { generation_request_id: string; user_id: string };
  /** IDs only: the export_requests row holds everything else. */
  'account.export': { export_request_id: string; user_id: string };
  'account.delete': { deletion_request_id: string; user_id: string };
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
  'meal-scan.analyze': {
    // A provider call is a single bounded request; retries cover transient provider/network errors.
    retryLimit: 3,
    retryDelaySeconds: 5,
    retryBackoff: true,
    expireInSeconds: 120,
    retentionDays: 14,
    deadLetter: DEAD_LETTER_QUEUE,
  },
  'workout-plan.generate': {
    retryLimit: 3,
    retryDelaySeconds: 10,
    retryBackoff: true,
    expireInSeconds: 600,
    retentionDays: 14,
    deadLetter: DEAD_LETTER_QUEUE,
  },
  'coach.reply': {
    // A single bounded provider call, same shape as meal-scan.analyze; retries cover transient
    // provider/network errors only (blueprint §12: at most two retries for transient errors).
    retryLimit: 2,
    retryDelaySeconds: 5,
    retryBackoff: true,
    expireInSeconds: 60,
    // Coach history is blueprint-retained for 90 days (§14); the queue job record itself only needs
    // to outlive its own processing window.
    retentionDays: 7,
    deadLetter: DEAD_LETTER_QUEUE,
  },
  'account.export': {
    retryLimit: 3,
    retryDelaySeconds: 10,
    retryBackoff: true,
    expireInSeconds: 300,
    retentionDays: 30,
    deadLetter: DEAD_LETTER_QUEUE,
  },
  'account.delete': {
    // Deletion touches Storage, queued jobs and finally an external auth-admin call; it is retried
    // more patiently than a provider call, and its own idempotent step-by-step design (blueprint §14
    // "retries incomplete steps") makes repeated at-least-once delivery safe.
    retryLimit: 5,
    retryDelaySeconds: 30,
    retryBackoff: true,
    expireInSeconds: 300,
    retentionDays: 90,
    deadLetter: DEAD_LETTER_QUEUE,
  },
};

/** Maps generation_requests.request_type to the queue that serves it (types without a queue yet are omitted). */
export const GENERATION_REQUEST_QUEUES = {
  diet_plan: QUEUES.dietPlanGenerate,
  plan_regeneration: QUEUES.dietPlanGenerate,
  meal_scan: QUEUES.mealScanAnalyze,
  workout_plan: QUEUES.workoutPlanGenerate,
  coach_reply: QUEUES.coachReply,
} as const satisfies Record<string, QueueName>;

export function isQueueName(value: string): value is QueueName {
  return Object.values(QUEUES).includes(value as QueueName);
}
