import { randomUUID } from 'node:crypto';
import Fastify, { LogController, type FastifyInstance, type FastifyServerOptions } from 'fastify';
import type { ApiConfig } from './config.js';
import { registerHealthRoutes } from './modules/health/routes.js';
import { registerJobRoutes } from './modules/jobs/routes.js';
import { registerMeRoutes } from './modules/me/routes.js';
import { registerProfileRoutes } from './modules/profile/routes.js';
import type { TokenVerifier } from './plugins/auth.js';
import type { Database } from './plugins/db.js';
import { registerErrorHandling } from './plugins/errors.js';

export interface AppDeps {
  config: ApiConfig;
  db: Database;
  verifyToken: TokenVerifier;
}

const REQUEST_ID_RE = /^[A-Za-z0-9._-]{8,128}$/;

export function buildApp(
  deps: AppDeps,
  options: { logger?: FastifyServerOptions['logger'] } = {},
): FastifyInstance {
  const app = Fastify({
    logger: options.logger ?? {
      level: deps.config.logLevel,
      // Never log credentials or tokens.
      redact: {
        paths: ['req.headers.authorization', 'req.headers.cookie', 'req.headers["x-api-key"]'],
        censor: '[redacted]',
      },
    },
    trustProxy: deps.config.trustProxy,
    bodyLimit: 256 * 1024,
    requestIdHeader: false,
    logController: new LogController({ requestIdLogLabel: 'request_id' }),
    // Accept a well-formed client/edge request id for correlation; otherwise mint one.
    genReqId: (req) => {
      const incoming = req.headers['x-request-id'];
      return typeof incoming === 'string' && REQUEST_ID_RE.test(incoming) ? incoming : randomUUID();
    },
    ajv: {
      customOptions: {
        // Reject (not silently drop) unrecognized fields where schemas forbid them.
        removeAdditional: false,
        coerceTypes: 'array',
        useDefaults: true,
        allErrors: true,
      },
    },
  });

  app.decorateRequest('auth', null);
  app.addHook('onSend', async (request, reply) => {
    reply.header('x-request-id', request.id);
    reply.header('cache-control', 'no-store');
  });

  registerErrorHandling(app);
  registerHealthRoutes(app, deps);
  registerMeRoutes(app, deps);
  registerProfileRoutes(app, deps);
  registerJobRoutes(app, deps);
  return app;
}
