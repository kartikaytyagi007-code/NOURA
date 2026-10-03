import type { FastifyInstance } from 'fastify';
import type { components } from '@noura/contracts';
import type { AppDeps } from '../../app.js';
import { requireAuth } from '../../plugins/auth.js';
import { idempotencyKeyFrom, withIdempotency } from '../../plugins/idempotency.js';
import { registerOperation } from '../../plugins/openapi-routes.js';
import {
  getAccountExport,
  requestAccountDeletion,
  requestAccountExport,
  requireRecentAuth,
} from './service.js';

type Schemas = components['schemas'];

export function registerAccountRoutes(app: FastifyInstance, deps: Required<AppDeps>): void {
  registerOperation(app, deps.verifyToken, 'requestAccountExport', async (request, reply) => {
    const { userId } = requireAuth(request);
    const data = await withIdempotency(
      deps.db,
      { userId, route: 'requestAccountExport', key: idempotencyKeyFrom(request), body: {} },
      (client) => requestAccountExport(client, userId),
    );
    reply.code(202);
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'getAccountExport', async (request) => {
    const { userId } = requireAuth(request);
    const { id } = request.params as { id: string };
    const data = await deps.db.forUser(userId, (client) =>
      getAccountExport(client, deps.media, userId, id),
    );
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'deleteAccount', async (request, reply) => {
    const { userId, issuedAt } = requireAuth(request);
    requireRecentAuth(issuedAt);
    const body = request.body as Schemas['DeleteAccountRequest'];
    void body; // schema already restricts this to the literal confirmation string
    const data = await withIdempotency(
      deps.db,
      { userId, route: 'deleteAccount', key: idempotencyKeyFrom(request), body: {} },
      (client) => requestAccountDeletion(client, userId),
    );
    reply.code(202);
    return { data, meta: { request_id: request.id } };
  });
}
