import type { FastifyInstance } from 'fastify';
import type { components } from '@noura/contracts';
import type { AppDeps } from '../../app.js';
import { requireAuth } from '../../plugins/auth.js';
import { idempotencyKeyFrom, withIdempotency } from '../../plugins/idempotency.js';
import { registerOperation } from '../../plugins/openapi-routes.js';
import { completeUpload, createUploadSlot, deleteMedia, getMediaDownload } from './service.js';

type Schemas = components['schemas'];

export function registerMediaRoutes(app: FastifyInstance, deps: Required<AppDeps>): void {
  registerOperation(app, deps.verifyToken, 'createUploadSlot', async (request, reply) => {
    const { userId } = requireAuth(request);
    const body = request.body as Schemas['UploadSlotRequest'];
    const data = await withIdempotency(
      deps.db,
      { userId, route: 'createUploadSlot', key: idempotencyKeyFrom(request), body },
      (client) => createUploadSlot(client, deps.media, userId, body),
    );
    reply.code(201);
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'completeUpload', async (request) => {
    const { userId } = requireAuth(request);
    const { id } = request.params as { id: string };
    const data = await withIdempotency(
      deps.db,
      { userId, route: 'completeUpload', key: idempotencyKeyFrom(request), body: { id } },
      (client) => completeUpload(client, deps.media, userId, id),
    );
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'getMediaDownload', async (request) => {
    const { userId } = requireAuth(request);
    const { id } = request.params as { id: string };
    const data = await deps.db.forUser(userId, (client) =>
      getMediaDownload(client, deps.media, userId, id),
    );
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'deleteMedia', async (request) => {
    const { userId } = requireAuth(request);
    const { id } = request.params as { id: string };
    const data = await withIdempotency(
      deps.db,
      { userId, route: 'deleteMedia', key: idempotencyKeyFrom(request), body: { id } },
      (client) => deleteMedia(client, deps.media, userId, id),
    );
    return { data, meta: { request_id: request.id } };
  });
}
