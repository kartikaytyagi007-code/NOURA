import { randomUUID } from 'node:crypto';
import pg from 'pg';

export const adminPool = new pg.Pool({ connectionString: process.env.DATABASE_URL, max: 4 });

export async function createAuthUser(): Promise<string> {
  const id = randomUUID();
  await adminPool.query('insert into auth.users (id, email) values ($1, $2)', [
    id,
    `${id}@test.invalid`,
  ]);
  return id;
}

/**
 * Runs fn inside a transaction as a restricted role with an optional verified user context, then
 * always rolls back so tests never leak state into each other.
 */
export async function asRole<T>(
  role: 'noura_api' | 'noura_worker' | 'anon' | 'authenticated',
  userId: string | null,
  fn: (client: pg.PoolClient) => Promise<T>,
): Promise<T> {
  const client = await adminPool.connect();
  try {
    await client.query('begin');
    await client.query(`set local role ${role}`);
    if (userId) await client.query("select set_config('noura.user_id', $1, true)", [userId]);
    return await fn(client);
  } finally {
    await client.query('rollback').catch(() => undefined);
    client.release();
  }
}

/** Runs fn as the migration owner (bypasses RLS) and commits. For fixtures only. */
export async function asOwner<T>(fn: (client: pg.PoolClient) => Promise<T>): Promise<T> {
  const client = await adminPool.connect();
  try {
    return await fn(client);
  } finally {
    client.release();
  }
}
