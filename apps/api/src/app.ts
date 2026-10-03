import { randomUUID } from 'node:crypto';
import { createMediaStorage, type MediaStorage } from '@noura/domain';
import Fastify, { LogController, type FastifyInstance, type FastifyServerOptions } from 'fastify';
import type { ApiConfig } from './config.js';
import { registerDietRoutes } from './modules/diet/routes.js';
import { registerHealthRoutes } from './modules/health/routes.js';
import { registerJobRoutes } from './modules/jobs/routes.js';
import { registerMealRoutes } from './modules/meals/routes.js';
import { registerMediaRoutes } from './modules/media/routes.js';
import { registerDevStorageRoutes } from './modules/media/dev-storage.js';
import { registerMeRoutes } from './modules/me/routes.js';
import { registerProfileRoutes } from './modules/profile/routes.js';
import { registerRecommendationRoutes } from './modules/recommendations/routes.js';
import type { TokenVerifier } from './plugins/auth.js';
import type { Database } from './plugins/db.js';
import { registerErrorHandling } from './plugins/errors.js';

export interface AppDeps {
  config: ApiConfig;
  db: Database;
  verifyToken: TokenVerifier;
  /** Built from config automatically when omitted; tests may inject one (e.g. to pre-seed bytes). */
  media?: MediaStorage;
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

  const media =
    deps.media ??
    createMediaStorage({
      appEnv: deps.config.appEnv,
      driver: deps.config.media.driver,
      supabaseUrl: deps.config.media.supabaseUrl,
      serviceRoleKey: deps.config.media.serviceRoleKey,
      local: {
        baseDir: deps.config.media.devStorageDir,
        publicBaseUrl: deps.config.media.devStorageBaseUrl,
        signingSecret: deps.config.media.devStorageSigningSecret,
      },
    });
  const fullDeps: Required<AppDeps> = { ...deps, media };

  registerErrorHandling(app);
  registerHealthRoutes(app, fullDeps);
  registerMeRoutes(app, fullDeps);
  registerProfileRoutes(app, fullDeps);
  registerJobRoutes(app, fullDeps);
  registerDietRoutes(app, fullDeps);
  registerMediaRoutes(app, fullDeps);
  registerMealRoutes(app, fullDeps);
  registerRecommendationRoutes(app, fullDeps);
  // Development/test only: see modules/media/dev-storage.ts. Never registered when deployed.
  if (
    deps.config.appEnv !== 'staging' &&
    deps.config.appEnv !== 'production' &&
    media.driver === 'local'
  ) {
    registerDevStorageRoutes(app, fullDeps, media);
  }
  return app;
}
