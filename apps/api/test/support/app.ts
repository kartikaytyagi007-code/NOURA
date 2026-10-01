import type { FastifyInstance } from 'fastify';
import { buildApp } from '../../src/app.js';
import { loadConfig } from '../../src/config.js';
import { createTokenVerifier } from '../../src/plugins/auth.js';
import { Database } from '../../src/plugins/db.js';
import { AUDIENCE, ISSUER } from './auth.js';

export function testConfig(overrides: Record<string, string> = {}) {
  return loadConfig({
    APP_ENV: 'test',
    DATABASE_URL: process.env.DATABASE_URL,
    SUPABASE_URL: 'http://127.0.0.1:54321',
    SUPABASE_JWT_ISSUER: ISSUER,
    SUPABASE_JWT_AUDIENCE: AUDIENCE,
    LOG_LEVEL: 'silent',
    ...overrides,
  });
}

export async function createTestApp(jwksUrl: string, overrides: Record<string, string> = {}) {
  const config = testConfig({ SUPABASE_JWKS_URL: jwksUrl, ...overrides });
  const db = Database.fromUrl(config.databaseUrl, { max: 4, statementTimeoutMs: 5000 });
  const app: FastifyInstance = buildApp(
    { config, db, verifyToken: createTokenVerifier(config.auth) },
    { logger: false },
  );
  await app.ready();
  return {
    app,
    db,
    close: async () => {
      await app.close();
      await db.close();
    },
  };
}
