import { PgBoss } from 'pg-boss';
// @ts-expect-error -- plain ESM script without type declarations
import { resetPlainDatabase } from '../../../../supabase/scripts/reset-plain.mjs';

/** Fresh plain-Postgres database with all migrations plus an installed pg-boss schema. */
export default async function setup(): Promise<void> {
  const url = process.env.DATABASE_URL;
  if (!url) throw new Error('DATABASE_URL must point at a dedicated local test database');
  await resetPlainDatabase(url, { log: () => undefined });
  const boss = new PgBoss({
    connectionString: url,
    schema: 'pgboss',
    supervise: false,
    schedule: false,
  });
  await boss.start();
  await boss.stop({ graceful: false });
}
