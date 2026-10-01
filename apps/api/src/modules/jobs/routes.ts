import { AppError, pollDelayMs, type Queryable } from '@noura/domain';
import type { components } from '@noura/contracts';
import type { FastifyInstance } from 'fastify';
import type { AppDeps } from '../../app.js';
import { requireAuth } from '../../plugins/auth.js';
import { registerOperation } from '../../plugins/openapi-routes.js';

type Job = components['schemas']['Job'];

interface JobRow {
  id: string;
  request_type: Job['type'];
  status: Job['status'];
  result_ids: Record<string, string>;
  safe_error_code: string | null;
  safe_error_message: string | null;
  created_at: Date;
  updated_at: Date;
}

export async function findJob(db: Queryable, userId: string, jobId: string): Promise<Job | null> {
  const row = (
    await db.query<JobRow>(
      `select id, request_type, status, result_ids, safe_error_code, safe_error_message, created_at, updated_at
         from app.generation_requests where id = $1 and user_id = $2`,
      [jobId, userId],
    )
  ).rows[0];
  if (!row) return null;
  return {
    id: row.id,
    type: row.request_type,
    status: row.status,
    result_ids: row.result_ids,
    error: row.safe_error_code
      ? {
          code: row.safe_error_code,
          message: row.safe_error_message ?? 'The request could not be completed.',
        }
      : null,
    poll_after_ms: pollDelayMs(row.status, row.created_at),
    created_at: row.created_at.toISOString(),
    updated_at: row.updated_at.toISOString(),
  };
}

export function registerJobRoutes(app: FastifyInstance, deps: AppDeps): void {
  registerOperation(app, deps.verifyToken, 'getJob', async (request) => {
    const { userId } = requireAuth(request);
    const { id } = request.params as { id: string };
    const job = await deps.db.forUser(userId, (client) => findJob(client, userId, id));
    // Missing and non-owned jobs are indistinguishable (blueprint §11).
    if (!job) throw new AppError('NOT_FOUND', 'Resource not found.');
    return { data: job, meta: { request_id: request.id } };
  });
}
