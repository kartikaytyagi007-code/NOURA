import type { FastifyInstance } from 'fastify';
import type { components } from '@noura/contracts';
import type { AppDeps } from '../../app.js';
import { requireAuth } from '../../plugins/auth.js';
import { idempotencyKeyFrom, withIdempotency } from '../../plugins/idempotency.js';
import { registerOperation } from '../../plugins/openapi-routes.js';
import { performNextMealAction } from './actions-service.js';
import { getHome } from './home-service.js';
import { getInsights } from './insights-service.js';
import { getNextMeal } from './next-meal-service.js';

type Schemas = components['schemas'];

export function registerRecommendationRoutes(app: FastifyInstance, deps: AppDeps): void {
  registerOperation(app, deps.verifyToken, 'getHome', async (request) => {
    const { userId } = requireAuth(request);
    const { date } = request.query as { date?: string };
    const data = await deps.db.forUser(userId, (client) => getHome(client, userId, date));
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'getNextMeal', async (request) => {
    const { userId } = requireAuth(request);
    const { date, slot } = request.query as { date?: string; slot?: Schemas['MealSlot'] };
    const data = await deps.db.forUser(userId, (client) => getNextMeal(client, userId, date, slot));
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'nextMealAction', async (request) => {
    const { userId } = requireAuth(request);
    const body = request.body as Schemas['NextMealActionRequest'];
    const data = await withIdempotency(
      deps.db,
      { userId, route: 'nextMealAction', key: idempotencyKeyFrom(request), body },
      (client) => performNextMealAction(client, userId, body),
    );
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'getInsights', async (request) => {
    const { userId } = requireAuth(request);
    const data = await deps.db.forUser(userId, (client) => getInsights(client, userId));
    return { data, meta: { request_id: request.id } };
  });
}
