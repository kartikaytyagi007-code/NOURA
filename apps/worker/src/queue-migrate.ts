/**
 * Release step: installs or upgrades the pg-boss queue schema, then exits. Deployed workers start
 * with PGBOSS_MIGRATE=false so schema changes happen only through this reviewed step.
 */
import { PgBoss } from 'pg-boss';
import { ConfigError, loadConfig } from './config.js';
import { ensureQueues } from './runtime.js';

async function main(): Promise<void> {
  let config;
  try {
    config = loadConfig();
  } catch (error) {
    console.error(error instanceof ConfigError ? error.message : error);
    process.exit(1);
  }
  const boss = new PgBoss({
    connectionString: config.databaseUrl,
    schema: config.pgBossSchema,
    migrate: true,
    createSchema: true,
    supervise: false,
    schedule: false,
  });
  await boss.start();
  await ensureQueues(boss);
  console.log(
    `pg-boss schema "${config.pgBossSchema}" at version ${String(await boss.schemaVersion())}`,
  );
  await boss.stop({ graceful: false });
}

void main();
