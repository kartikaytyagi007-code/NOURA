import { randomUUID } from 'node:crypto';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { z } from 'zod';

const appEnv = z.enum(['development', 'test', 'staging', 'production']);
const boolString = z.enum(['true', 'false', '1', '0']).transform((v) => v === 'true' || v === '1');

const schema = z
  .object({
    APP_ENV: appEnv,
    LOG_LEVEL: z
      .enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace', 'silent'])
      .default('info'),
    APP_VERSION: z.string().default('0.1.0-dev'),
    // pg-boss needs a session-capable connection: direct connection or Supabase *session* pooler
    // (port 5432). The transaction pooler (port 6543) is not supported (docs/decisions.md D-009).
    WORKER_DATABASE_URL: z.string().min(1),
    WORKER_DB_POOL_MAX: z.coerce.number().int().min(2).max(50).default(5),
    PGBOSS_SCHEMA: z
      .string()
      .regex(/^[a-z_][a-z0-9_]*$/)
      .default('pgboss'),
    // Queue-schema migrations are a release step in deployed environments.
    PGBOSS_MIGRATE: boolString.optional(),
    WORKER_HEALTH_HOST: z.string().default('0.0.0.0'),
    WORKER_HEALTH_PORT: z.coerce.number().int().min(0).max(65535).default(8081),
    // How often undispatched generation requests are handed to the queue (docs/decisions.md D-017).
    WORKER_RELAY_INTERVAL_MS: z.coerce.number().int().min(100).max(60_000).default(2_000),
    WORKER_CONCURRENCY: z.coerce.number().int().min(1).max(32).default(2),
    AI_PROVIDER: z.enum(['mock', 'gemini']).optional(),
    AI_API_KEY: z.string().min(1).optional(),
    AI_MODEL_ID: z.string().min(1).optional(),

    // Account deletion needs to remove the auth identity itself (blueprint §14); mock is dev/test
    // only, same fail-closed pattern as AI_PROVIDER/BILLING_PROVIDER (D-010).
    AUTH_ADMIN_PROVIDER: z.enum(['mock', 'supabase']).optional(),

    SUPABASE_URL: z.url().optional(),
    SUPABASE_SERVICE_ROLE_KEY: z.string().min(1).optional(),
    MEDIA_STORAGE_DRIVER: z.enum(['local', 'supabase']).optional(),
    DEV_STORAGE_DIR: z.string().min(1).optional(),
    DEV_STORAGE_SIGNING_SECRET: z.string().min(1).optional(),
  })
  .superRefine((env, ctx) => {
    if (env.APP_ENV !== 'staging' && env.APP_ENV !== 'production') return;
    if (!env.AI_PROVIDER || env.AI_PROVIDER === 'mock') {
      ctx.addIssue({
        code: 'custom',
        path: ['AI_PROVIDER'],
        message: `a real provider is required when APP_ENV=${env.APP_ENV}`,
      });
    } else if (!env.AI_API_KEY || !env.AI_MODEL_ID) {
      ctx.addIssue({
        code: 'custom',
        path: ['AI_API_KEY'],
        message: 'AI_API_KEY and AI_MODEL_ID are required',
      });
    }
    if (env.MEDIA_STORAGE_DRIVER === 'local') {
      ctx.addIssue({
        code: 'custom',
        path: ['MEDIA_STORAGE_DRIVER'],
        message: `local media storage is not allowed when APP_ENV=${env.APP_ENV}`,
      });
    } else if (!env.SUPABASE_URL || !env.SUPABASE_SERVICE_ROLE_KEY) {
      ctx.addIssue({
        code: 'custom',
        path: ['SUPABASE_SERVICE_ROLE_KEY'],
        message: 'SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are required for meal-scan storage',
      });
    }
    if (!env.AUTH_ADMIN_PROVIDER || env.AUTH_ADMIN_PROVIDER === 'mock') {
      ctx.addIssue({
        code: 'custom',
        path: ['AUTH_ADMIN_PROVIDER'],
        message: `a real auth-admin provider is required when APP_ENV=${env.APP_ENV}`,
      });
    }
  });

export interface WorkerConfig {
  appEnv: z.infer<typeof appEnv>;
  logLevel: string;
  version: string;
  databaseUrl: string;
  poolMax: number;
  pgBossSchema: string;
  migrate: boolean;
  health: { host: string; port: number };
  concurrency: number;
  relayIntervalMs: number;
  ai: { provider: 'mock' | 'gemini'; apiKey?: string | undefined; modelId?: string | undefined };
  authAdmin: { provider: 'mock' | 'supabase' };
  media: {
    driver: 'local' | 'supabase' | undefined;
    supabaseUrl: string;
    serviceRoleKey?: string | undefined;
    devStorageDir: string;
    devStorageSigningSecret: string;
  };
}

export class ConfigError extends Error {
  constructor(readonly issues: string[]) {
    super(`Invalid configuration:\n  - ${issues.join('\n  - ')}`);
    this.name = 'ConfigError';
  }
}

export function loadConfig(env: Record<string, string | undefined> = process.env): WorkerConfig {
  const parsed = schema.safeParse(env);
  if (!parsed.success) {
    throw new ConfigError(
      parsed.error.issues.map((i) => `${i.path.join('.') || '(root)'}: ${i.message}`),
    );
  }
  const e = parsed.data;
  const deployed = e.APP_ENV === 'staging' || e.APP_ENV === 'production';
  return {
    appEnv: e.APP_ENV,
    logLevel: e.LOG_LEVEL,
    version: e.APP_VERSION,
    databaseUrl: e.WORKER_DATABASE_URL,
    poolMax: e.WORKER_DB_POOL_MAX,
    pgBossSchema: e.PGBOSS_SCHEMA,
    migrate: e.PGBOSS_MIGRATE ?? !deployed,
    health: { host: e.WORKER_HEALTH_HOST, port: e.WORKER_HEALTH_PORT },
    concurrency: e.WORKER_CONCURRENCY,
    relayIntervalMs: e.WORKER_RELAY_INTERVAL_MS,
    ai: { provider: e.AI_PROVIDER ?? 'mock', apiKey: e.AI_API_KEY, modelId: e.AI_MODEL_ID },
    authAdmin: { provider: e.AUTH_ADMIN_PROVIDER ?? 'mock' },
    media: {
      driver: e.MEDIA_STORAGE_DRIVER,
      supabaseUrl: e.SUPABASE_URL ?? 'https://invalid.local',
      serviceRoleKey: e.SUPABASE_SERVICE_ROLE_KEY,
      devStorageDir: e.DEV_STORAGE_DIR ?? join(tmpdir(), `noura-dev-storage-${randomUUID()}`),
      devStorageSigningSecret: e.DEV_STORAGE_SIGNING_SECRET ?? 'dev-only-insecure-signing-secret',
    },
  };
}
