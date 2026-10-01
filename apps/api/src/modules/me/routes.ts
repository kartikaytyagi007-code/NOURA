import type { FastifyInstance } from 'fastify';
import type { AppDeps } from '../../app.js';
import { requireAuth } from '../../plugins/auth.js';
import { registerOperation } from '../../plugins/openapi-routes.js';
import { getOrCreateMe } from './repository.js';

export function registerMeRoutes(app: FastifyInstance, deps: AppDeps): void {
  registerOperation(app, deps.verifyToken, 'getMe', async (request) => {
    const { userId } = requireAuth(request);
    const data = await deps.db.forUser(userId, (client) => getOrCreateMe(client, userId));
    return { data, meta: { request_id: request.id } };
  });
}
