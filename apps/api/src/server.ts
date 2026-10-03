import { buildApp } from './app.js';
import { ConfigError, loadConfig } from './config.js';
import { createTokenVerifier } from './plugins/auth.js';
import { Database } from './plugins/db.js';

async function main(): Promise<void> {
  let config;
  try {
    config = loadConfig();
  } catch (error) {
    // Fail closed on missing/unsafe configuration. Messages list variable names, never values.
    console.error(error instanceof ConfigError ? error.message : error);
    process.exit(1);
  }

  const db = Database.fromUrl(config.databaseUrl, {
    max: config.dbPoolMax,
    statementTimeoutMs: config.dbStatementTimeoutMs,
  });
  const app = buildApp({ config, db, verifyToken: createTokenVerifier(config.auth) });

  const shutdown = async (signal: string) => {
    app.log.info({ signal }, 'shutting down');
    await app.close();
    await db.close();
    process.exit(0);
  };
  process.once('SIGTERM', () => void shutdown('SIGTERM'));
  process.once('SIGINT', () => void shutdown('SIGINT'));

  await app.listen({ host: config.host, port: config.port });
  app.log.info(
    {
      app_env: config.appEnv,
      ai_provider: config.ai.provider,
      billing_provider: config.billing.provider,
    },
    config.ai.provider === 'mock' || config.billing.provider === 'mock'
      ? 'API started with DEVELOPMENT MOCK providers'
      : 'API started',
  );
}

void main();
