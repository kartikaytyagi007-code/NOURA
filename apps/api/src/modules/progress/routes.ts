import type { FastifyInstance } from 'fastify';
import type { components } from '@noura/contracts';
import type { AppDeps } from '../../app.js';
import { requireAuth } from '../../plugins/auth.js';
import { idempotencyKeyFrom, withIdempotency } from '../../plugins/idempotency.js';
import { registerOperation } from '../../plugins/openapi-routes.js';
import {
  createProgressPhoto,
  createWeightLog,
  deleteProgressPhoto,
  deleteWeightLog,
  getProgress,
  listProgressPhotos,
  listWeightLogs,
} from './service.js';

type Schemas = components['schemas'];

export function registerProgressRoutes(app: FastifyInstance, deps: Required<AppDeps>): void {
  registerOperation(app, deps.verifyToken, 'listWeightLogs', async (request) => {
    const { userId } = requireAuth(request);
    const { cursor, limit } = request.query as { cursor?: string; limit?: number };
    const data = await deps.db.forUser(userId, (client) =>
      listWeightLogs(client, userId, cursor, limit),
    );
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'createWeightLog', async (request, reply) => {
    const { userId } = requireAuth(request);
    const body = request.body as Schemas['CreateWeightLogRequest'];
    const data = await withIdempotency(
      deps.db,
      { userId, route: 'createWeightLog', key: idempotencyKeyFrom(request), body },
      (client) => createWeightLog(client, userId, body),
    );
    reply.code(201);
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'deleteWeightLog', async (request) => {
    const { userId } = requireAuth(request);
    const { id } = request.params as { id: string };
    const data = await withIdempotency(
      deps.db,
      { userId, route: 'deleteWeightLog', key: idempotencyKeyFrom(request), body: { id } },
      (client) => deleteWeightLog(client, userId, id),
    );
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'listProgressPhotos', async (request) => {
    const { userId } = requireAuth(request);
    const { cursor, limit } = request.query as { cursor?: string; limit?: number };
    const data = await deps.db.forUser(userId, (client) =>
      listProgressPhotos(client, userId, cursor, limit),
    );
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'createProgressPhoto', async (request, reply) => {
    const { userId } = requireAuth(request);
    const body = request.body as Schemas['CreateProgressPhotoRequest'];
    const data = await withIdempotency(
      deps.db,
      { userId, route: 'createProgressPhoto', key: idempotencyKeyFrom(request), body },
      (client) => createProgressPhoto(client, userId, body),
    );
    reply.code(201);
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'deleteProgressPhoto', async (request) => {
    const { userId } = requireAuth(request);
    const { id } = request.params as { id: string };
    const data = await withIdempotency(
      deps.db,
      { userId, route: 'deleteProgressPhoto', key: idempotencyKeyFrom(request), body: { id } },
      (client) => deleteProgressPhoto(client, deps.media, userId, id),
    );
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'getProgress', async (request) => {
    const { userId } = requireAuth(request);
    const data = await deps.db.forUser(userId, (client) => getProgress(client, userId));
    return { data, meta: { request_id: request.id } };
  });
}
