import type { FastifyInstance } from 'fastify';
import type { components } from '@noura/contracts';
import type { AppDeps } from '../../app.js';
import { requireAuth } from '../../plugins/auth.js';
import { idempotencyKeyFrom, withIdempotency } from '../../plugins/idempotency.js';
import { registerOperation } from '../../plugins/openapi-routes.js';
import {
  getCurrentDietPlan,
  getSwapOptions,
  replacePlanMeal,
  requestDietPlanGeneration,
} from './service.js';

type Schemas = components['schemas'];

export function registerDietRoutes(app: FastifyInstance, deps: AppDeps): void {
  registerOperation(app, deps.verifyToken, 'generateDietPlan', async (request, reply) => {
    const { userId } = requireAuth(request);
    const body = request.body as Schemas['GeneratePlanRequest'];
    const data = await withIdempotency(
      deps.db,
      { userId, route: 'generateDietPlan', key: idempotencyKeyFrom(request), body },
      (client) => requestDietPlanGeneration(client, userId, body),
    );
    reply.code(202);
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'getCurrentDietPlan', async (request) => {
    const { userId } = requireAuth(request);
    const { date } = request.query as { date?: string };
    const data = await deps.db.forUser(userId, (client) =>
      getCurrentDietPlan(client, userId, date),
    );
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'getSwapOptions', async (request) => {
    const { userId } = requireAuth(request);
    const { id } = request.params as { id: string };
    const body = request.body as Schemas['RevisionRequest'];
    const data = await deps.db.forUser(userId, (client) =>
      getSwapOptions(client, userId, id, body.expected_revision),
    );
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'replacePlanMeal', async (request) => {
    const { userId } = requireAuth(request);
    const { id } = request.params as { id: string };
    const body = request.body as Schemas['ReplacePlanMealRequest'];
    const data = await withIdempotency(
      deps.db,
      { userId, route: 'replacePlanMeal', key: idempotencyKeyFrom(request), body },
      (client) => replacePlanMeal(client, userId, id, body),
    );
    return { data, meta: { request_id: request.id } };
  });
}
