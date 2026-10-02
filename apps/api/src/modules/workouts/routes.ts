import type { FastifyInstance } from 'fastify';
import type { components } from '@noura/contracts';
import type { AppDeps } from '../../app.js';
import { requireAuth } from '../../plugins/auth.js';
import { idempotencyKeyFrom, withIdempotency } from '../../plugins/idempotency.js';
import { registerOperation } from '../../plugins/openapi-routes.js';
import {
  createWorkoutLog,
  getCurrentWorkoutPlan,
  getExerciseSubstitutions,
  patchWorkoutLog,
  putWorkoutSets,
  requestWorkoutPlanGeneration,
} from './service.js';

type Schemas = components['schemas'];

export function registerWorkoutRoutes(app: FastifyInstance, deps: AppDeps): void {
  registerOperation(app, deps.verifyToken, 'generateWorkoutPlan', async (request, reply) => {
    const { userId } = requireAuth(request);
    const body = request.body as Schemas['GeneratePlanRequest'];
    const data = await withIdempotency(
      deps.db,
      { userId, route: 'generateWorkoutPlan', key: idempotencyKeyFrom(request), body },
      (client) => requestWorkoutPlanGeneration(client, userId, body),
    );
    reply.code(202);
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'getCurrentWorkoutPlan', async (request) => {
    const { userId } = requireAuth(request);
    const data = await deps.db.forUser(userId, (client) => getCurrentWorkoutPlan(client, userId));
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'getExerciseSubstitutions', async (request) => {
    const { userId } = requireAuth(request);
    const { id } = request.params as { id: string };
    const data = await deps.db.forUser(userId, (client) =>
      getExerciseSubstitutions(client, userId, id),
    );
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'createWorkoutLog', async (request, reply) => {
    const { userId } = requireAuth(request);
    const body = request.body as Schemas['CreateWorkoutLogRequest'];
    const data = await withIdempotency(
      deps.db,
      { userId, route: 'createWorkoutLog', key: idempotencyKeyFrom(request), body },
      (client) => createWorkoutLog(client, userId, body),
    );
    reply.code(201);
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'putWorkoutSets', async (request) => {
    const { userId } = requireAuth(request);
    const { id } = request.params as { id: string };
    const body = request.body as Schemas['PutWorkoutSetsRequest'];
    const data = await withIdempotency(
      deps.db,
      { userId, route: 'putWorkoutSets', key: idempotencyKeyFrom(request), body: { id, body } },
      (client) => putWorkoutSets(client, userId, id, body),
    );
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'patchWorkoutLog', async (request) => {
    const { userId } = requireAuth(request);
    const { id } = request.params as { id: string };
    const body = request.body as Schemas['PatchWorkoutLogRequest'];
    const data = await withIdempotency(
      deps.db,
      { userId, route: 'patchWorkoutLog', key: idempotencyKeyFrom(request), body: { id, body } },
      (client) => patchWorkoutLog(client, userId, id, body),
    );
    return { data, meta: { request_id: request.id } };
  });
}
