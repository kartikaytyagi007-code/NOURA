import type { FastifyInstance } from 'fastify';
import { AppError } from '@noura/domain';
import type { components } from '@noura/contracts';
import type { AppDeps } from '../../app.js';
import { requireAuth } from '../../plugins/auth.js';
import { idempotencyKeyFrom, withIdempotency } from '../../plugins/idempotency.js';
import { registerOperation } from '../../plugins/openapi-routes.js';
import { confirmMealScanItems, createMealScan, getMealScan } from './scan-service.js';
import { createMealLog, deleteMealLog, listMealLogs, patchMealLog } from './log-service.js';
import { createPlateFixesForScan } from './plate-fixes-service.js';

type Schemas = components['schemas'];

export function registerMealRoutes(app: FastifyInstance, deps: Required<AppDeps>): void {
  registerOperation(app, deps.verifyToken, 'createMealScan', async (request, reply) => {
    const { userId } = requireAuth(request);
    const body = request.body as Schemas['CreateMealScanRequest'];
    const data = await withIdempotency(
      deps.db,
      { userId, route: 'createMealScan', key: idempotencyKeyFrom(request), body },
      (client) => createMealScan(client, userId, body),
    );
    reply.code(202);
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'getMealScan', async (request) => {
    const { userId } = requireAuth(request);
    const { id } = request.params as { id: string };
    const data = await deps.db.forUser(userId, (client) => getMealScan(client, userId, id));
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'confirmMealScanItems', async (request) => {
    const { userId } = requireAuth(request);
    const { id } = request.params as { id: string };
    const body = request.body as Schemas['ConfirmItemsRequest'];
    const data = await withIdempotency(
      deps.db,
      {
        userId,
        route: 'confirmMealScanItems',
        key: idempotencyKeyFrom(request),
        body: { id, ...body },
      },
      (client) => confirmMealScanItems(client, userId, id, body),
    );
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'createPlateFixes', async (request) => {
    const { userId } = requireAuth(request);
    const { id } = request.params as { id: string };
    const body = request.body as Schemas['RevisionRequest'];
    const data = await withIdempotency(
      deps.db,
      {
        userId,
        route: 'createPlateFixes',
        key: idempotencyKeyFrom(request),
        body: { id, ...body },
      },
      (client) => createPlateFixesForScan(client, userId, id, body),
    );
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'createMealLog', async (request, reply) => {
    const { userId } = requireAuth(request);
    const body = request.body as Schemas['CreateMealLogRequest'];
    const data = await withIdempotency(
      deps.db,
      { userId, route: 'createMealLog', key: idempotencyKeyFrom(request), body },
      (client) => createMealLog(client, userId, body),
    );
    reply.code(201);
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'listMealLogs', async (request) => {
    const { userId } = requireAuth(request);
    const { date } = request.query as { date: string };
    const data = await deps.db.forUser(userId, (client) => listMealLogs(client, userId, date));
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'patchMealLog', async (request) => {
    const { userId } = requireAuth(request);
    const { id } = request.params as { id: string };
    const body = request.body as Schemas['PatchMealLogRequest'];
    const data = await withIdempotency(
      deps.db,
      { userId, route: 'patchMealLog', key: idempotencyKeyFrom(request), body: { id, ...body } },
      (client) => patchMealLog(client, userId, id, body),
    );
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'deleteMealLog', async (request) => {
    const { userId } = requireAuth(request);
    const { id } = request.params as { id: string };
    const { expected_revision: expectedRevision } = request.query as { expected_revision: number };
    if (typeof expectedRevision !== 'number') {
      throw new AppError('VALIDATION_ERROR', 'expected_revision is required.', {
        fieldErrors: [{ field: 'query.expected_revision', code: 'required', message: 'required' }],
      });
    }
    const data = await withIdempotency(
      deps.db,
      {
        userId,
        route: 'deleteMealLog',
        key: idempotencyKeyFrom(request),
        body: { id, expected_revision: expectedRevision },
      },
      (client) => deleteMealLog(client, userId, id, expectedRevision),
    );
    return { data, meta: { request_id: request.id } };
  });
}
