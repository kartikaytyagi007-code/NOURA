import { readFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { randomUUID } from 'node:crypto';
import { TEST_TARGET_POLICY, parseTargetPolicy, type TargetPolicy } from '@noura/domain';
import { z } from 'zod';

/**
 * Validated API configuration. Startup fails on missing or unsafe configuration (blueprint §18).
 * Development mocks are allowed only in development/test; staging/production fail closed.
 */
const appEnv = z.enum(['development', 'test', 'staging', 'production']);

const boolString = z.enum(['true', 'false', '1', '0']).transform((v) => v === 'true' || v === '1');

const schema = z
  .object({
    APP_ENV: appEnv,
    HOST: z.string().default('0.0.0.0'),
    PORT: z.coerce.number().int().min(1).max(65535).default(8080),
    LOG_LEVEL: z
      .enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace', 'silent'])
      .default('info'),
    TRUST_PROXY: boolString.default(false),
    APP_VERSION: z.string().default('0.1.0-dev'),

    DATABASE_URL: z.string().min(1),
    DB_POOL_MAX: z.coerce.number().int().min(1).max(100).default(10),
    DB_STATEMENT_TIMEOUT_MS: z.coerce.number().int().min(100).max(120_000).default(15_000),
    PGBOSS_SCHEMA: z
      .string()
      .regex(/^[a-z_][a-z0-9_]*$/)
      .default('pgboss'),

    SUPABASE_URL: z.url(),
    SUPABASE_JWT_ISSUER: z.url().optional(),
    SUPABASE_JWT_AUDIENCE: z.string().min(1).default('authenticated'),
    SUPABASE_JWKS_URL: z.url().optional(),

    PLANNING_POLICY_FILE: z.string().min(1).optional(),

    AI_PROVIDER: z.enum(['mock', 'gemini']).optional(),
    AI_API_KEY: z.string().min(1).optional(),
    AI_MODEL_ID: z.string().min(1).optional(),

    BILLING_PROVIDER: z.enum(['mock', 'revenuecat']).optional(),
    REVENUECAT_SECRET_API_KEY: z.string().min(1).optional(),
    REVENUECAT_WEBHOOK_AUTH: z.string().min(16).optional(),

    SUPABASE_SERVICE_ROLE_KEY: z.string().min(1).optional(),
    MEDIA_STORAGE_DRIVER: z.enum(['local', 'supabase']).optional(),
    DEV_STORAGE_DIR: z.string().min(1).optional(),
    DEV_STORAGE_SIGNING_SECRET: z.string().min(1).optional(),
    DEV_STORAGE_BASE_URL: z.string().min(1).optional(),

    // Server-controlled free/premium daily quotas (blueprint §13's own proposed figures by default;
    // a release reviewer can override any of them without a code change). See
    // packages/domain/src/billing/limits.ts.
    MEAL_SCAN_FREE_DAILY_QUOTA: z.coerce.number().int().min(0).default(3),
    MEAL_SCAN_PREMIUM_DAILY_QUOTA: z.coerce.number().int().min(0).default(20),
    COACH_REPLY_FREE_DAILY_QUOTA: z.coerce.number().int().min(0).default(5),
    COACH_REPLY_PREMIUM_DAILY_QUOTA: z.coerce.number().int().min(0).default(20),
  })
  .superRefine((env, ctx) => {
    const deployed = env.APP_ENV === 'staging' || env.APP_ENV === 'production';
    const issue = (path: string, message: string) =>
      ctx.addIssue({ code: 'custom', path: [path], message });

    if (!deployed) return;
    if (!env.SUPABASE_URL.startsWith('https://'))
      issue('SUPABASE_URL', 'must use https outside development');
    if (!env.AI_PROVIDER || env.AI_PROVIDER === 'mock') {
      issue(
        'AI_PROVIDER',
        `a real provider is required when APP_ENV=${env.APP_ENV} (mocks are development-only)`,
      );
    } else if (!env.AI_API_KEY || !env.AI_MODEL_ID) {
      issue('AI_API_KEY', 'AI_API_KEY and AI_MODEL_ID are required for a real AI provider');
    }
    if (!env.BILLING_PROVIDER || env.BILLING_PROVIDER === 'mock') {
      issue('BILLING_PROVIDER', `a real billing provider is required when APP_ENV=${env.APP_ENV}`);
    } else if (!env.REVENUECAT_SECRET_API_KEY || !env.REVENUECAT_WEBHOOK_AUTH) {
      issue(
        'REVENUECAT_SECRET_API_KEY',
        'RevenueCat secret API key and webhook authorization are required',
      );
    }
    if (env.MEDIA_STORAGE_DRIVER === 'local') {
      issue(
        'MEDIA_STORAGE_DRIVER',
        `local media storage is not allowed when APP_ENV=${env.APP_ENV}`,
      );
    } else if (!env.SUPABASE_SERVICE_ROLE_KEY) {
      issue(
        'SUPABASE_SERVICE_ROLE_KEY',
        'a Supabase service-role key is required for private media',
      );
    }
  });

export type RawEnv = z.input<typeof schema>;

export interface ApiConfig {
  appEnv: z.infer<typeof appEnv>;
  host: string;
  port: number;
  logLevel: string;
  trustProxy: boolean;
  version: string;
  databaseUrl: string;
  dbPoolMax: number;
  dbStatementTimeoutMs: number;
  pgBossSchema: string;
  auth: { issuer: string; audience: string; jwksUrl: string };
  ai: { provider: 'mock' | 'gemini'; apiKey?: string | undefined; modelId?: string | undefined };
  billing: {
    provider: 'mock' | 'revenuecat';
    secretApiKey?: string | undefined;
    webhookAuthorization?: string | undefined;
  };
  quotas: {
    mealScan: { free: number; premium: number };
    coachReply: { free: number; premium: number };
  };
  media: {
    driver: 'local' | 'supabase' | undefined;
    supabaseUrl: string;
    serviceRoleKey?: string | undefined;
    devStorageDir: string;
    devStorageSigningSecret: string;
    devStorageBaseUrl: string;
  };
  /**
   * The target policy that drives automated planning, or null when none is configured. Development
   * and test default to the clearly labelled TEST policy; staging and production never do (D-018).
   */
  planningPolicy: TargetPolicy | null;
}

export class ConfigError extends Error {
  constructor(readonly issues: string[]) {
    super(`Invalid configuration:\n  - ${issues.join('\n  - ')}`);
    this.name = 'ConfigError';
  }
}

function loadPlanningPolicy(file: string | undefined, deployed: boolean): TargetPolicy | null {
  if (!file) return deployed ? null : TEST_TARGET_POLICY;
  let raw: unknown;
  try {
    raw = JSON.parse(readFileSync(file, 'utf8'));
  } catch {
    throw new ConfigError(['PLANNING_POLICY_FILE: the file could not be read as JSON']);
  }
  let policy: TargetPolicy;
  try {
    policy = parseTargetPolicy(raw);
  } catch (error) {
    // parseTargetPolicy reports field paths only, never values.
    throw new ConfigError([`PLANNING_POLICY_FILE: ${(error as Error).message}`]);
  }
  if (deployed && policy.status !== 'approved') {
    throw new ConfigError([
      'PLANNING_POLICY_FILE: a test policy is not allowed in this environment',
    ]);
  }
  return policy;
}

/** Parses environment variables. Error messages name variables but never echo their values. */
export function loadConfig(env: Record<string, string | undefined> = process.env): ApiConfig {
  const parsed = schema.safeParse(env);
  if (!parsed.success) {
    throw new ConfigError(
      parsed.error.issues.map((i) => `${i.path.join('.') || '(root)'}: ${i.message}`),
    );
  }
  const e = parsed.data;
  const supabase = e.SUPABASE_URL.replace(/\/+$/, '');
  return {
    appEnv: e.APP_ENV,
    host: e.HOST,
    port: e.PORT,
    logLevel: e.LOG_LEVEL,
    trustProxy: e.TRUST_PROXY,
    version: e.APP_VERSION,
    databaseUrl: e.DATABASE_URL,
    dbPoolMax: e.DB_POOL_MAX,
    dbStatementTimeoutMs: e.DB_STATEMENT_TIMEOUT_MS,
    pgBossSchema: e.PGBOSS_SCHEMA,
    auth: {
      issuer: e.SUPABASE_JWT_ISSUER ?? `${supabase}/auth/v1`,
      audience: e.SUPABASE_JWT_AUDIENCE,
      jwksUrl: e.SUPABASE_JWKS_URL ?? `${supabase}/auth/v1/.well-known/jwks.json`,
    },
    // Development defaults to explicit mocks; deployed environments were validated above.
    ai: { provider: e.AI_PROVIDER ?? 'mock', apiKey: e.AI_API_KEY, modelId: e.AI_MODEL_ID },
    billing: {
      provider: e.BILLING_PROVIDER ?? 'mock',
      secretApiKey: e.REVENUECAT_SECRET_API_KEY,
      webhookAuthorization: e.REVENUECAT_WEBHOOK_AUTH,
    },
    quotas: {
      mealScan: { free: e.MEAL_SCAN_FREE_DAILY_QUOTA, premium: e.MEAL_SCAN_PREMIUM_DAILY_QUOTA },
      coachReply: {
        free: e.COACH_REPLY_FREE_DAILY_QUOTA,
        premium: e.COACH_REPLY_PREMIUM_DAILY_QUOTA,
      },
    },
    media: {
      driver: e.MEDIA_STORAGE_DRIVER,
      supabaseUrl: e.SUPABASE_URL,
      serviceRoleKey: e.SUPABASE_SERVICE_ROLE_KEY,
      devStorageDir: e.DEV_STORAGE_DIR ?? join(tmpdir(), `noura-dev-storage-${randomUUID()}`),
      devStorageSigningSecret: e.DEV_STORAGE_SIGNING_SECRET ?? 'dev-only-insecure-signing-secret',
      devStorageBaseUrl:
        e.DEV_STORAGE_BASE_URL ?? `http://${e.HOST === '0.0.0.0' ? '127.0.0.1' : e.HOST}:${e.PORT}`,
    },
    planningPolicy: loadPlanningPolicy(
      e.PLANNING_POLICY_FILE,
      e.APP_ENV === 'staging' || e.APP_ENV === 'production',
    ),
  };
}
