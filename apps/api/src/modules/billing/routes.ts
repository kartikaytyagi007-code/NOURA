import type { FastifyInstance } from 'fastify';
import { AppError } from '@noura/domain';
import type { components } from '@noura/contracts';
import type { AppDeps } from '../../app.js';
import { requireAuth } from '../../plugins/auth.js';
import { idempotencyKeyFrom, withIdempotency } from '../../plugins/idempotency.js';
import { registerOperation } from '../../plugins/openapi-routes.js';
import {
  getEntitlements,
  getUsage,
  receiveWebhook,
  syncBilling,
  usageFeatureList,
} from './service.js';

type Schemas = components['schemas'];

export function registerBillingRoutes(app: FastifyInstance, deps: Required<AppDeps>): void {
  registerOperation(app, deps.verifyToken, 'getEntitlements', async (request) => {
    const { userId } = requireAuth(request);
    const data = await deps.db.forUser(userId, (client) => getEntitlements(client, userId));
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'getUsage', async (request) => {
    const { userId } = requireAuth(request);
    const features = usageFeatureList(deps.config.quotas);
    const data = await deps.db.forUser(userId, (client) => getUsage(client, userId, features));
    return { data, meta: { request_id: request.id } };
  });

  registerOperation(app, deps.verifyToken, 'syncBilling', async (request) => {
    const { userId } = requireAuth(request);
    const data = await withIdempotency(
      deps.db,
      { userId, route: 'syncBilling', key: idempotencyKeyFrom(request), body: {} },
      (client) => syncBilling(client, userId, deps.billing),
    );
    return { data, meta: { request_id: request.id } };
  });

  // `receiveRevenueCatWebhook` uses `revenueCatWebhookAuth` security, not `bearerAuth`, so
  // registerOperation does not verify a user token for it; the provider's shared secret is checked
  // here, before the body is ever trusted (blueprint §13 "verify webhook authorization").
  registerOperation(app, deps.verifyToken, 'receiveRevenueCatWebhook', async (request) => {
    if (!deps.billing.verifyWebhookAuth(request.headers.authorization)) {
      throw new AppError('UNAUTHENTICATED', 'Invalid webhook authorization.');
    }
    const body = request.body as Schemas['RevenueCatWebhookRequest'];
    const data = await receiveWebhook(deps.db, deps.billing, body);
    return { data, meta: { request_id: request.id } };
  });
}
