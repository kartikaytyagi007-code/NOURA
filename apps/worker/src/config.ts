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
    WORKER_CONCURRENCY: z.coerce.number().int().min(1).max(32).default(2),
    AI_PROVIDER: z.enum(['mock', 'gemini']).optional(),
    AI_API_KEY: z.string().min(1).optional(),
    AI_MODEL_ID: z.string().min(1).optional(),
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
  ai: { provider: 'mock' | 'gemini'; apiKey?: string | undefined; modelId?: string | undefined };
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
    ai: { provider: e.AI_PROVIDER ?? 'mock', apiKey: e.AI_API_KEY, modelId: e.AI_MODEL_ID },
  };
}
