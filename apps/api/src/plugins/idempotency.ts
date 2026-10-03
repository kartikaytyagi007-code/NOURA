import { createHash } from 'node:crypto';
import { AppError, type Queryable } from '@noura/domain';
import type { FastifyRequest } from 'fastify';
import type { Database } from './db.js';

/** Records are kept long enough to cover client retries after a flaky connection. */
const RETENTION_HOURS = 24;

/** JSON with sorted keys, so the same logical body always hashes the same. */
function canonicalJson(value: unknown): string {
  if (Array.isArray(value)) return `[${value.map(canonicalJson).join(',')}]`;
  if (value !== null && typeof value === 'object') {
    const entries = Object.entries(value as Record<string, unknown>)
      .filter(([, v]) => v !== undefined)
      .sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0));
    return `{${entries.map(([k, v]) => `${JSON.stringify(k)}:${canonicalJson(v)}`).join(',')}}`;
  }
  return JSON.stringify(value) ?? 'null';
}

export function hashRequestBody(body: unknown): string {
  return createHash('sha256').update(canonicalJson(body)).digest('hex');
}

export function idempotencyKeyFrom(request: FastifyRequest): string {
  const key = request.headers['idempotency-key'];
  if (typeof key !== 'string' || key.length < 8 || key.length > 255) {
    throw new AppError('VALIDATION_ERROR', 'A valid Idempotency-Key header is required.', {
      fieldErrors: [
        {
          field: 'headers.idempotency-key',
          code: 'required',
          message: 'must be 8 to 255 characters',
        },
      ],
    });
  }
  return key;
}

interface IdempotencyRow {
  request_hash: string;
  response_body: unknown;
}

/**
 * Runs `work` and the idempotency record in ONE user transaction. The first request with a key
 * performs the work and stores its response in the same commit. A replay (same user, route, key and
 * body) returns the stored response and performs no work. The same key with a different body is
 * rejected. A concurrent duplicate waits on the unique index until the first commits, then replays.
 * Failed requests roll back with the record, so they are never cached and can be retried.
 */
export async function withIdempotency<T>(
  db: Database,
  options: { userId: string; route: string; key: string; body: unknown },
  work: (client: Queryable) => Promise<T>,
): Promise<T> {
  const hash = hashRequestBody(options.body);
  return db.forUser(options.userId, async (client) => {
    const inserted = await client.query<{ id: string }>(
      `insert into app.idempotency_records
         (user_id, route, idempotency_key, request_hash, expires_at)
       values ($1, $2, $3, $4, now() + make_interval(hours => $5))
       on conflict (user_id, route, idempotency_key) do nothing
       returning id`,
      [options.userId, options.route, options.key, hash, RETENTION_HOURS],
    );
    const recordId = inserted.rows[0]?.id;
    if (!recordId) {
      const existing = (
        await client.query<IdempotencyRow>(
          `select request_hash, response_body from app.idempotency_records
            where user_id = $1 and route = $2 and idempotency_key = $3`,
          [options.userId, options.route, options.key],
        )
      ).rows[0];
      if (!existing || existing.request_hash !== hash) {
        throw new AppError(
          'VALIDATION_ERROR',
          'This Idempotency-Key was already used with a different request.',
          {
            fieldErrors: [
              {
                field: 'headers.idempotency-key',
                code: 'key_reused',
                message: 'use a new key for a different request',
              },
            ],
          },
        );
      }
      if (existing.response_body === null || existing.response_body === undefined) {
        throw new AppError('INTERNAL_ERROR', 'The original request has no stored response.');
      }
      return existing.response_body as T;
    }
    const result = await work(client);
    await client.query(
      `update app.idempotency_records set response_status = 200, response_body = $3::jsonb
        where id = $1 and user_id = $2`,
      [recordId, options.userId, JSON.stringify(result)],
    );
    return result;
  });
}
