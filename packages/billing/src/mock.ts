import { timingSafeEqual } from 'node:crypto';
import { normalizeRevenueCatEvent } from './revenuecat-parse.js';
import type {
  AuthAdminProvider,
  BillingProvider,
  NormalizedEntitlement,
  NormalizedWebhookEvent,
} from './types.js';

/** Fixed, clearly-labelled dev/test-only shared secret — never valid outside development/test. */
export const MOCK_WEBHOOK_AUTH = 'Bearer mock-dev-webhook-secret';

function safeEqual(a: string, b: string): boolean {
  const bufA = Buffer.from(a);
  const bufB = Buffer.from(b);
  return bufA.length === bufB.length && timingSafeEqual(bufA, bufB);
}

/**
 * Development/test billing provider (docs/decisions.md D-010 pattern). Webhook parsing reuses the
 * exact same normalizer the real adapter uses, so event-shape handling is exercised identically to
 * production; only auth-secret verification and the restore/sync source are mocked.
 *
 * `fetchSubscriberEntitlements` always returns an empty array: the mock never fabricates a premium
 * unlock. Development exercises premium behavior by inserting a webhook event (the same path a real
 * RevenueCat sandbox purchase would take) or by seeding `app.entitlements` directly in tests.
 */
export class MockBillingProvider implements BillingProvider {
  readonly name = 'mock' as const;

  verifyWebhookAuth(authorizationHeader: string | undefined): boolean {
    return (
      typeof authorizationHeader === 'string' && safeEqual(authorizationHeader, MOCK_WEBHOOK_AUTH)
    );
  }

  parseWebhookEvent(payload: unknown): NormalizedWebhookEvent {
    return normalizeRevenueCatEvent(payload);
  }

  fetchSubscriberEntitlements(_appUserId: string): Promise<NormalizedEntitlement[]> {
    return Promise.resolve([]);
  }
}

export interface MockAuthAdminDeps {
  /**
   * Dev/test-only hook: when provided, actually removes the `auth.users` row (via the plain-Postgres
   * shim's unrestricted base connection — see supabase/tests/support/supabase_shim.sql), so cascading
   * foreign keys exercise the *full* account-deletion flow end to end against a real test database.
   * Never wired outside development/test; a real deployment never has a database role that could do
   * this (D-004: domain roles have no access outside schema `app`) and uses the real Admin API
   * (`SupabaseAuthAdminProvider`) instead.
   */
  deleteAuthUser?: (userId: string) => Promise<void>;
}

/** Development/test auth-admin provider: never calls a real Supabase project. */
export class MockAuthAdminProvider implements AuthAdminProvider {
  readonly name = 'mock' as const;
  private readonly deleted = new Set<string>();

  constructor(private readonly deps: MockAuthAdminDeps = {}) {}

  async deleteUser(userId: string): Promise<{ deleted: boolean }> {
    const wasNew = !this.deleted.has(userId);
    this.deleted.add(userId);
    if (this.deps.deleteAuthUser) await this.deps.deleteAuthUser(userId);
    return { deleted: wasNew };
  }
}
