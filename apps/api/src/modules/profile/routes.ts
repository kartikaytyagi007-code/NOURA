import type { FastifyInstance } from 'fastify';
import { AppError } from '@noura/domain';
import type { components } from '@noura/contracts';
import type { AppDeps } from '../../app.js';
import { requireAuth } from '../../plugins/auth.js';
import { idempotencyKeyFrom, withIdempotency } from '../../plugins/idempotency.js';
import { registerOperation } from '../../plugins/openapi-routes.js';
import {
  completeOnboarding,
  getNotificationPreferences,
  patchProfile,
  putNotificationPreferences,
  putPreferences,
  putTrainingPreferences,
} from './service.js';
import { loadCurrentSnapshot, type PlanningContext } from './targets.js';

type Schemas = components['schemas'];

export function registerProfileRoutes(app: FastifyInstance, deps: AppDeps): void {
  const context: PlanningContext = {
    appEnv: deps.config.appEnv,
    policy: deps.config.planningPolicy,
  };
  const idempotent = <T>(
    request: Parameters<typeof idempotencyKeyFrom>[0],
    userId: string,
    route: string,
    work: Parameters<typeof withIdempotency<T>>[2],
  ) =>
    withIdempotency<T>(
      deps.db,
      { userId, route, key: idempotencyKeyFrom(request), body: request.body },
      work,
    );

  registerOperation(app, deps.verifyToken, 'patchMe', async (request) => {
    const { userId } = requireAuth(request);
    const body = request.body as Schemas['ProfilePatch'];
    const data = await idempotent(request, userId, 'patchMe', (client) =>
      patchProfile(client, userId, body, context),
    );
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'putPreferences', async (request) => {
    const { userId } = requireAuth(request);
    const body = request.body as Schemas['PreferencesInput'];
    const data = await idempotent(request, userId, 'putPreferences', (client) =>
      putPreferences(client, userId, body),
    );
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'putTrainingPreferences', async (request) => {
    const { userId } = requireAuth(request);
    const body = request.body as Schemas['TrainingPreferencesInput'];
    const data = await idempotent(request, userId, 'putTrainingPreferences', (client) =>
      putTrainingPreferences(client, userId, body),
    );
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'getNotificationPreferences', async (request) => {
    const { userId } = requireAuth(request);
    const data = await deps.db.forUser(userId, (client) =>
      getNotificationPreferences(client, userId),
    );
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'putNotificationPreferences', async (request) => {
    const { userId } = requireAuth(request);
    const body = request.body as Schemas['NotificationPreferencesInput'];
    const data = await idempotent(request, userId, 'putNotificationPreferences', (client) =>
      putNotificationPreferences(client, userId, body),
    );
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'completeOnboarding', async (request) => {
    const { userId } = requireAuth(request);
    const body = request.body as Schemas['OnboardingCompleteRequest'];
    const data = await idempotent(request, userId, 'completeOnboarding', (client) =>
      completeOnboarding(client, userId, body, context),
    );
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'getTargets', async (request) => {
    const { userId } = requireAuth(request);
    const data = await deps.db.forUser(userId, (client) => loadCurrentSnapshot(client, userId));
    if (!data) throw new AppError('NOT_FOUND', 'No targets have been set yet.');
    return { data, meta: { request_id: request.id } };
  });
}
