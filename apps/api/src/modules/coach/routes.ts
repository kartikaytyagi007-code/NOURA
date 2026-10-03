import type { FastifyInstance } from 'fastify';
import type { components } from '@noura/contracts';
import type { AppDeps } from '../../app.js';
import { requireAuth } from '../../plugins/auth.js';
import { idempotencyKeyFrom, withIdempotency } from '../../plugins/idempotency.js';
import { registerOperation } from '../../plugins/openapi-routes.js';
import {
  applyActionProposal,
  cancelActionProposal,
  createCoachThread,
  deleteCoachThread,
  listCoachMessages,
  sendCoachMessage,
} from './service.js';

type Schemas = components['schemas'];

export function registerCoachRoutes(app: FastifyInstance, deps: AppDeps): void {
  registerOperation(app, deps.verifyToken, 'createCoachThread', async (request, reply) => {
    const { userId } = requireAuth(request);
    const data = await withIdempotency(
      deps.db,
      { userId, route: 'createCoachThread', key: idempotencyKeyFrom(request), body: {} },
      (client) => createCoachThread(client, userId),
    );
    reply.code(201);
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'deleteCoachThread', async (request) => {
    const { userId } = requireAuth(request);
    const { id } = request.params as { id: string };
    const data = await withIdempotency(
      deps.db,
      { userId, route: 'deleteCoachThread', key: idempotencyKeyFrom(request), body: { id } },
      (client) => deleteCoachThread(client, userId, id),
    );
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'listCoachMessages', async (request) => {
    const { userId } = requireAuth(request);
    const { id } = request.params as { id: string };
    const { cursor, limit } = request.query as { cursor?: string; limit?: number };
    const data = await deps.db.forUser(userId, (client) =>
      listCoachMessages(client, userId, id, cursor, limit),
    );
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'sendCoachMessage', async (request, reply) => {
    const { userId } = requireAuth(request);
    const { id } = request.params as { id: string };
    const body = request.body as Schemas['SendCoachMessageRequest'];
    const data = await withIdempotency(
      deps.db,
      {
        userId,
        route: 'sendCoachMessage',
        key: idempotencyKeyFrom(request),
        body: { id, ...body },
      },
      (client) => sendCoachMessage(client, userId, id, body, deps.config.quotas.coachReply),
    );
    reply.code(202);
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'applyActionProposal', async (request) => {
    const { userId } = requireAuth(request);
    const { id } = request.params as { id: string };
    const body = request.body as Schemas['RevisionRequest'];
    const data = await withIdempotency(
      deps.db,
      {
        userId,
        route: 'applyActionProposal',
        key: idempotencyKeyFrom(request),
        body: { id, ...body },
      },
      (client) => applyActionProposal(client, userId, id, body),
    );
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'cancelActionProposal', async (request) => {
    const { userId } = requireAuth(request);
    const { id } = request.params as { id: string };
    const data = await withIdempotency(
      deps.db,
      { userId, route: 'cancelActionProposal', key: idempotencyKeyFrom(request), body: { id } },
      (client) => cancelActionProposal(client, userId, id),
    );
    return { data, meta: { request_id: request.id } };
  });
}
