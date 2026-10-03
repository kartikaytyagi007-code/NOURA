import { describe, expect, it } from 'vitest';
import { createAuthAdminProvider, createBillingProvider } from './factory.js';

describe('createBillingProvider', () => {
  it('allows the mock in development and test', () => {
    for (const appEnv of ['development', 'test'] as const) {
      const provider = createBillingProvider({ appEnv, provider: 'mock' });
      expect(provider.name).toBe('mock');
    }
  });

  it('refuses the mock in staging and production (fails closed)', () => {
    for (const appEnv of ['staging', 'production'] as const) {
      expect(() => createBillingProvider({ appEnv, provider: 'mock' })).toThrow(/not allowed/);
    }
  });

  it('refuses a missing provider and a real provider without credentials', () => {
    expect(() => createBillingProvider({ appEnv: 'production', provider: undefined })).toThrow(
      /not configured/,
    );
    expect(() => createBillingProvider({ appEnv: 'production', provider: 'revenuecat' })).toThrow(
      /requires/,
    );
  });

  it('constructs the real adapter once both secrets are present', () => {
    const provider = createBillingProvider({
      appEnv: 'production',
      provider: 'revenuecat',
      secretApiKey: 'sk',
      webhookAuthorization: 'Bearer wh',
    });
    expect(provider.name).toBe('revenuecat');
  });
});

describe('createAuthAdminProvider', () => {
  it('allows the mock in development and test', () => {
    for (const appEnv of ['development', 'test'] as const) {
      expect(createAuthAdminProvider({ appEnv, provider: 'mock' }).name).toBe('mock');
    }
  });

  it('refuses the mock in staging and production', () => {
    for (const appEnv of ['staging', 'production'] as const) {
      expect(() => createAuthAdminProvider({ appEnv, provider: 'mock' })).toThrow(/not allowed/);
    }
  });

  it('refuses supabase without a service-role key', () => {
    expect(() =>
      createAuthAdminProvider({
        appEnv: 'production',
        provider: 'supabase',
        supabaseUrl: 'https://x',
      }),
    ).toThrow(/requires/);
  });

  it('constructs the real adapter once configured', () => {
    const provider = createAuthAdminProvider({
      appEnv: 'production',
      provider: 'supabase',
      supabaseUrl: 'https://x.supabase.co',
      serviceRoleKey: 'sr',
    });
    expect(provider.name).toBe('supabase');
  });
});
