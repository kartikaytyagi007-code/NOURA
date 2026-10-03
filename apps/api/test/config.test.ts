import { mkdtempSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { TEST_TARGET_POLICY } from '@noura/domain';
import { describe, expect, it } from 'vitest';
import { ConfigError, loadConfig } from '../src/config.js';

const base = {
  APP_ENV: 'development',
  DATABASE_URL: 'postgresql://user:SuperSecretPassword@127.0.0.1:5432/noura',
  SUPABASE_URL: 'http://127.0.0.1:54321',
};

const production = {
  ...base,
  APP_ENV: 'production',
  SUPABASE_URL: 'https://project.supabase.co',
  AI_PROVIDER: 'gemini',
  AI_API_KEY: 'placeholder-ai-key',
  AI_MODEL_ID: 'placeholder-model',
  BILLING_PROVIDER: 'revenuecat',
  REVENUECAT_SECRET_API_KEY: 'placeholder-rc-key',
  REVENUECAT_WEBHOOK_AUTH: 'placeholder-webhook-authorization',
};

describe('loadConfig', () => {
  it('defaults development to explicit mock providers and derives Supabase auth endpoints', () => {
    const config = loadConfig(base);
    expect(config.ai.provider).toBe('mock');
    expect(config.billing.provider).toBe('mock');
    expect(config.auth).toEqual({
      issuer: 'http://127.0.0.1:54321/auth/v1',
      audience: 'authenticated',
      jwksUrl: 'http://127.0.0.1:54321/auth/v1/.well-known/jwks.json',
    });
  });

  it('accepts a fully configured production environment', () => {
    expect(loadConfig(production).appEnv).toBe('production');
  });

  it('fails closed when production would use mocks or lacks provider secrets', () => {
    expect(() => loadConfig({ ...production, AI_PROVIDER: 'mock' })).toThrow(/AI_PROVIDER/);
    expect(() => loadConfig({ ...production, AI_PROVIDER: undefined })).toThrow(/AI_PROVIDER/);
    expect(() => loadConfig({ ...production, BILLING_PROVIDER: 'mock' })).toThrow(
      /BILLING_PROVIDER/,
    );
    expect(() => loadConfig({ ...production, AI_API_KEY: undefined })).toThrow(/AI_API_KEY/);
    expect(() => loadConfig({ ...production, REVENUECAT_WEBHOOK_AUTH: undefined })).toThrow(
      /RevenueCat/,
    );
    expect(() => loadConfig({ ...production, SUPABASE_URL: 'http://project.supabase.co' })).toThrow(
      /https/,
    );
  });

  it('applies the same fail-closed rules to staging', () => {
    expect(() => loadConfig({ ...production, APP_ENV: 'staging', AI_PROVIDER: 'mock' })).toThrow(
      /AI_PROVIDER/,
    );
  });

  it('fails on missing required configuration without echoing secret values', () => {
    try {
      loadConfig({ ...base, DATABASE_URL: undefined, SUPABASE_URL: 'not a url' });
      expect.unreachable();
    } catch (error) {
      expect(error).toBeInstanceOf(ConfigError);
      const message = (error as Error).message;
      expect(message).toMatch(/DATABASE_URL/);
      expect(message).toMatch(/SUPABASE_URL/);
      expect(message).not.toContain('SuperSecretPassword');
    }
    try {
      loadConfig({ ...production, AI_PROVIDER: 'mock' });
    } catch (error) {
      expect((error as Error).message).not.toContain('placeholder-rc-key');
    }
  });

  it('rejects an unknown APP_ENV', () => {
    expect(() => loadConfig({ ...base, APP_ENV: 'prod' })).toThrow(/APP_ENV/);
  });

  describe('planning policy', () => {
    const write = (policy: unknown): string => {
      const file = join(mkdtempSync(join(tmpdir(), 'noura-policy-')), 'policy.json');
      writeFileSync(file, JSON.stringify(policy));
      return file;
    };
    const approved = {
      ...TEST_TARGET_POLICY,
      status: 'approved',
      approval: {
        reviewer: 'Placeholder Reviewer',
        approved_on: '2026-10-01',
        reference: 'TEST-REF',
      },
    };

    it('defaults to the labelled test policy in development and test only', () => {
      expect(loadConfig(base).planningPolicy?.status).toBe('test');
      expect(loadConfig({ ...base, APP_ENV: 'test' }).planningPolicy?.status).toBe('test');
      expect(loadConfig(production).planningPolicy).toBeNull();
      expect(loadConfig({ ...production, APP_ENV: 'staging' }).planningPolicy).toBeNull();
    });

    it('loads an approved policy file in a deployed environment', () => {
      const config = loadConfig({ ...production, PLANNING_POLICY_FILE: write(approved) });
      expect(config.planningPolicy?.status).toBe('approved');
    });

    it('refuses a test-status policy in staging and production', () => {
      expect(() =>
        loadConfig({ ...production, PLANNING_POLICY_FILE: write(TEST_TARGET_POLICY) }),
      ).toThrow(/test policy is not allowed/);
    });

    it('rejects unreadable or invalid files without echoing their content', () => {
      expect(() =>
        loadConfig({ ...base, PLANNING_POLICY_FILE: '/nonexistent/policy.json' }),
      ).toThrow(/PLANNING_POLICY_FILE/);
      const bad = { ...approved, approval: null, secret_note: 'do-not-echo-me' };
      try {
        loadConfig({ ...base, PLANNING_POLICY_FILE: write(bad) });
        expect.unreachable();
      } catch (error) {
        expect(error).toBeInstanceOf(ConfigError);
        expect((error as Error).message).not.toContain('do-not-echo-me');
      }
    });
  });
});
