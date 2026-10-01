import { withUserTransaction, type Queryable } from '@noura/domain';
import pg from 'pg';

/**
 * Database access for the API. Domain queries always run through forUser(), which assumes the
 * restricted noura_api role and sets the verified user context, so RLS backs up the explicit
 * user_id filter every query must still include.
 */
export class Database {
  constructor(readonly pool: pg.Pool) {}

  static fromUrl(url: string, options: { max: number; statementTimeoutMs: number }): Database {
    const pool = new pg.Pool({
      connectionString: url,
      max: options.max,
      statement_timeout: options.statementTimeoutMs,
      application_name: 'noura-api',
    });
    return new Database(pool);
  }

  forUser<T>(userId: string, fn: (client: Queryable) => Promise<T>): Promise<T> {
    return withUserTransaction(this.pool, 'noura_api', userId, fn);
  }

  /** Readiness: connectivity, the connection user's ability to assume noura_api, and queue schema. */
  async readiness(
    pgBossSchema: string,
  ): Promise<{ database: boolean; role: boolean; queue: boolean }> {
    try {
      const { rows } = await this.pool.query<{ role: boolean; queue: boolean }>(
        `select pg_has_role(current_user, 'noura_api', 'MEMBER') as role,
                to_regnamespace($1) is not null as queue`,
        [pgBossSchema],
      );
      return { database: true, role: rows[0]?.role === true, queue: rows[0]?.queue === true };
    } catch {
      return { database: false, role: false, queue: false };
    }
  }

  close(): Promise<void> {
    return this.pool.end();
  }
}
