import type { LocalMediaStorage, MediaStorage } from '@noura/domain';
import type { FastifyInstance } from 'fastify';
import type { AppDeps } from '../../app.js';

/**
 * DEVELOPMENT/TEST ONLY (docs/decisions.md D-010, D-026). Stands in for Supabase Storage's signed
 * upload/download URLs so the whole upload → verify → recognize → review pipeline can be exercised in
 * an environment with no reachable Supabase project. `app.ts` registers this only when
 * `APP_ENV` is development/test AND the media storage driver is `local`; it is never reachable in a
 * deployed environment. Authorization is a short-lived HMAC token minted by `LocalMediaStorage`
 * itself (an ownership check already happened when that signed URL was minted), not a bearer token —
 * exactly mirroring how a real Supabase signed Storage URL works.
 */
export function registerDevStorageRoutes(
  app: FastifyInstance,
  _deps: AppDeps,
  media: MediaStorage,
): void {
  if (media.driver !== 'local') return;
  const local = media as LocalMediaStorage;

  app.addContentTypeParser(
    ['image/jpeg', 'image/png', 'image/webp', 'application/octet-stream'],
    { parseAs: 'buffer' },
    (_req, body, done) => done(null, body),
  );

  app.route({
    method: 'PUT',
    url: '/dev-storage/:bucket/*',
    bodyLimit: 15 * 1024 * 1024,
    handler: async (request, reply) => {
      const { bucket } = request.params as { bucket: string; '*': string };
      const objectPath = (request.params as { '*': string })['*'];
      const query = request.query as { exp?: string; token?: string };
      const expiresAtMs = Number(query.exp);
      if (!query.token || !local.verifyToken(bucket, objectPath, expiresAtMs, query.token)) {
        reply.code(403);
        return {
          error: {
            code: 'UNAUTHENTICATED',
            message: 'Invalid or expired upload link.',
            field_errors: [],
            retryable: false,
          },
          meta: { request_id: request.id },
        };
      }
      await local.writeObject(bucket, objectPath, request.body as Buffer);
      reply.code(200);
      return { ok: true };
    },
  });

  app.route({
    method: 'GET',
    url: '/dev-storage/:bucket/*',
    handler: async (request, reply) => {
      const { bucket } = request.params as { bucket: string; '*': string };
      const objectPath = (request.params as { '*': string })['*'];
      const query = request.query as { exp?: string; token?: string };
      const expiresAtMs = Number(query.exp);
      if (!query.token || !local.verifyToken(bucket, objectPath, expiresAtMs, query.token)) {
        reply.code(403);
        return {
          error: {
            code: 'UNAUTHENTICATED',
            message: 'Invalid or expired download link.',
            field_errors: [],
            retryable: false,
          },
          meta: { request_id: request.id },
        };
      }
      const bytes = await local.readObject(bucket, objectPath);
      if (!bytes) {
        reply.code(404);
        return {
          error: { code: 'NOT_FOUND', message: 'Not found.', field_errors: [], retryable: false },
          meta: { request_id: request.id },
        };
      }
      reply.header('content-type', 'application/octet-stream');
      reply.send(Buffer.from(bytes));
      return reply;
    },
  });
}
