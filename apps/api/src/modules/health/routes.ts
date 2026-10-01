import type { FastifyInstance } from 'fastify';
import type { AppDeps } from '../../app.js';
import { registerOperation } from '../../plugins/openapi-routes.js';

export function registerHealthRoutes(app: FastifyInstance, deps: AppDeps): void {
  // Liveness never touches dependencies, so a database outage does not restart healthy processes.
  registerOperation(app, deps.verifyToken, 'getLiveness', async () => ({
    status: 'ok',
    service: 'api',
    version: deps.config.version,
    checks: [],
  }));

  registerOperation(app, deps.verifyToken, 'getReadiness', async (_request, reply) => {
    const result = await deps.db.readiness(deps.config.pgBossSchema);
    const checks = [
      { name: 'database', ok: result.database },
      { name: 'server_role', ok: result.role },
      { name: 'queue_schema', ok: result.queue },
    ];
    const ok = checks.every((c) => c.ok);
    return reply.status(ok ? 200 : 503).send({
      status: ok ? 'ok' : 'unavailable',
      service: 'api',
      version: deps.config.version,
      checks,
    });
  });
}
