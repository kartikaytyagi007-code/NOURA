import { buildRouteSchemas, getOperation, toFastifyPath } from '@noura/contracts';
import type { FastifyInstance, FastifyReply, FastifyRequest, FastifySchema } from 'fastify';
import { bearerToken, type TokenVerifier } from './auth.js';
import { AppError } from '@noura/domain';

export type OperationHandler = (request: FastifyRequest, reply: FastifyReply) => Promise<unknown>;

/**
 * Registers a route from its OpenAPI operationId. Method, path, request validation and response
 * serialization all come from packages/contracts/openapi.yaml, so the contract stays the authority.
 * Authenticated operations verify the bearer token before the handler runs.
 */
export function registerOperation(
  app: FastifyInstance,
  verifyToken: TokenVerifier,
  operationId: string,
  handler: OperationHandler,
): void {
  const op = getOperation(operationId);
  if (op.status !== 'implemented') {
    throw new Error(
      `Operation ${operationId} is marked x-noura-status: ${op.status}; update the contract first`,
    );
  }
  const schemas = buildRouteSchemas(op);
  app.route({
    method: op.method.toUpperCase() as 'GET',
    url: toFastifyPath(op.path),
    schema: schemas as unknown as FastifySchema,
    config: { operationId },
    // Authenticate before body validation so unauthenticated callers learn nothing about payloads.
    onRequest: op.requiresAuth
      ? async (request) => {
          const token = bearerToken(request);
          if (!token) throw new AppError('UNAUTHENTICATED', 'Authentication required.');
          request.auth = await verifyToken(token);
        }
      : undefined,
    handler,
  });
}
