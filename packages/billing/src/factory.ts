import { MockAuthAdminProvider, MockBillingProvider, type MockAuthAdminDeps } from './mock.js';
import { RevenueCatBillingProvider, SupabaseAuthAdminProvider } from './revenuecat.js';
import type { AuthAdminProvider, BillingProvider } from './types.js';

export type AppEnv = 'development' | 'test' | 'staging' | 'production';
export type BillingProviderName = 'mock' | 'revenuecat';

export interface BillingProviderConfig {
  appEnv: AppEnv;
  provider: BillingProviderName | undefined;
  secretApiKey?: string | undefined;
  webhookAuthorization?: string | undefined;
}

/**
 * Fails closed exactly like `createAiProvider` (docs/decisions.md D-010): the mock is only available
 * in development/test, and a real provider requires both its secret API key and webhook
 * authorization value. There is no "unavailable" middle ground here the way there is for AI — billing
 * is on the auth/entitlement path, so a deployed environment that is missing configuration must fail
 * to start, not start and silently deny every purchase.
 */
export function createBillingProvider(config: BillingProviderConfig): BillingProvider {
  if (!config.provider) throw new Error('BILLING_PROVIDER is not configured');
  if (config.provider === 'mock') {
    if (config.appEnv !== 'development' && config.appEnv !== 'test') {
      throw new Error(`BILLING_PROVIDER=mock is not allowed when APP_ENV=${config.appEnv}`);
    }
    return new MockBillingProvider();
  }
  if (!config.secretApiKey || !config.webhookAuthorization) {
    throw new Error(
      'BILLING_PROVIDER=revenuecat requires a secret API key and webhook authorization',
    );
  }
  return new RevenueCatBillingProvider({
    secretApiKey: config.secretApiKey,
    webhookAuthorization: config.webhookAuthorization,
  });
}

export type AuthAdminProviderName = 'mock' | 'supabase';

export interface AuthAdminProviderConfig {
  appEnv: AppEnv;
  provider: AuthAdminProviderName;
  supabaseUrl?: string | undefined;
  serviceRoleKey?: string | undefined;
  /** Mock-only: see MockAuthAdminDeps. */
  mockDeps?: MockAuthAdminDeps | undefined;
}

/**
 * Chooses the auth-identity-deletion adapter. Mock is development/test only; a real deployment needs
 * a Supabase service-role key (the same one media storage already requires when deployed) or account
 * deletion fails closed at startup rather than silently no-opping on the auth identity.
 */
export function createAuthAdminProvider(config: AuthAdminProviderConfig): AuthAdminProvider {
  if (config.provider === 'mock') {
    if (config.appEnv !== 'development' && config.appEnv !== 'test') {
      throw new Error(`Auth-admin mock is not allowed when APP_ENV=${config.appEnv}`);
    }
    return new MockAuthAdminProvider(config.mockDeps);
  }
  if (!config.supabaseUrl || !config.serviceRoleKey) {
    throw new Error('Account deletion requires SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY');
  }
  return new SupabaseAuthAdminProvider({
    supabaseUrl: config.supabaseUrl,
    serviceRoleKey: config.serviceRoleKey,
  });
}
