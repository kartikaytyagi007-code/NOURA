/**
 * Minimal pg-compatible interfaces so domain code does not depend on a driver.
 */
export interface Queryable {
  query<R = Record<string, unknown>>(
    text: string,
    params?: unknown[],
  ): Promise<{ rows: R[]; rowCount: number | null }>;
}
export interface PoolClientLike extends Queryable {
  release(error?: Error | boolean): void;
}
export interface PoolLike {
  connect(): Promise<PoolClientLike>;
}

export type ServerRole = 'noura_api' | 'noura_worker';
const SERVER_ROLES: readonly ServerRole[] = ['noura_api', 'noura_worker'];

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

export function isUuid(value: unknown): value is string {
  return typeof value === 'string' && UUID_RE.test(value);
}

/**
 * Runs fn in a transaction that has assumed the restricted server role and carries the verified
 * user id, so RLS owner policies apply in addition to the explicit user_id filters in queries.
 * The user id must come from a verified token (API) or a job row the worker already validated;
 * never from a client-submitted field.
 */
export async function withUserTransaction<T>(
  pool: PoolLike,
  role: ServerRole,
  userId: string,
  fn: (client: Queryable) => Promise<T>,
): Promise<T> {
  if (!SERVER_ROLES.includes(role)) throw new Error(`Unsupported server role: ${String(role)}`);
  if (!isUuid(userId)) throw new Error('withUserTransaction requires a UUID user id');
  const client = await pool.connect();
  let broken = false;
  try {
    await client.query('begin');
    // Role names are from a fixed allow-list above, so interpolation is safe.
    await client.query(`set local role ${role}`);
    await client.query("select set_config('noura.user_id', $1, true)", [userId]);
    const result = await fn(client);
    await client.query('commit');
    return result;
  } catch (error) {
    await client.query('rollback').catch(() => {
      broken = true;
    });
    throw error;
  } finally {
    client.release(broken);
  }
}
