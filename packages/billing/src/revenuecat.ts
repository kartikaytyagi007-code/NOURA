import { timingSafeEqual } from 'node:crypto';
import { AppError } from '@noura/domain';
import { normalizeRevenueCatEvent } from './revenuecat-parse.js';
import type {
  AuthAdminProvider,
  BillingProvider,
  NormalizedEntitlement,
  NormalizedWebhookEvent,
} from './types.js';

function safeEqual(a: string, b: string): boolean {
  const bufA = Buffer.from(a);
  const bufB = Buffer.from(b);
  return bufA.length === bufB.length && timingSafeEqual(bufA, bufB);
}

export interface RevenueCatConfig {
  secretApiKey: string;
  webhookAuthorization: string;
}

/**
 * Real RevenueCat adapter. `createBillingProvider` (factory.ts) refuses to construct this without
 * both a secret API key and a webhook authorization value, so a deployed environment can never start
 * with billing silently unconfigured (docs/decisions.md D-010's fail-closed pattern, extended to
 * billing). Never exercised in this sandboxed environment — no real RevenueCat project exists here —
 * but it is fully typechecked and its webhook-shape parsing is identical to the mock's.
 */
export class RevenueCatBillingProvider implements BillingProvider {
  readonly name = 'revenuecat' as const;
  constructor(private readonly config: RevenueCatConfig) {}

  verifyWebhookAuth(authorizationHeader: string | undefined): boolean {
    return (
      typeof authorizationHeader === 'string' &&
      safeEqual(authorizationHeader, this.config.webhookAuthorization)
    );
  }

  parseWebhookEvent(payload: unknown): NormalizedWebhookEvent {
    return normalizeRevenueCatEvent(payload);
  }

  async fetchSubscriberEntitlements(appUserId: string): Promise<NormalizedEntitlement[]> {
    let response: Response;
    try {
      response = await fetch(
        `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(appUserId)}`,
        {
          headers: { Authorization: `Bearer ${this.config.secretApiKey}` },
          signal: AbortSignal.timeout(10_000),
        },
      );
    } catch (error) {
      throw new AppError('PROVIDER_UNAVAILABLE', 'Billing provider is temporarily unavailable.', {
        cause: error,
      });
    }
    if (!response.ok) {
      throw new AppError('PROVIDER_UNAVAILABLE', 'Billing provider is temporarily unavailable.');
    }
    const body = (await response.json()) as {
      subscriber?: { entitlements?: Record<string, { expires_date?: string | null }> };
    };
    const entitlements = body.subscriber?.entitlements ?? {};
    const now = Date.now();
    return Object.entries(entitlements).map(([key, value]) => {
      const expiresAt = value.expires_date ?? null;
      const isActive = expiresAt === null || new Date(expiresAt).getTime() > now;
      return {
        entitlementKey: key,
        isActive,
        providerStatus: isActive ? 'active' : 'expired',
        expiresAt,
      };
    });
  }
}

export interface SupabaseAuthAdminConfig {
  supabaseUrl: string;
  serviceRoleKey: string;
}

/**
 * Deletes the Supabase auth identity via the Auth Admin API. Every app-owned row references
 * `auth.users(id) on delete cascade` (D-004/D-006 and this milestone's additions), so removing the
 * identity is what actually removes the user's domain data; Storage objects and queued jobs are
 * cleaned up by the deletion worker handler *before* this call (blueprint §14).
 */
export class SupabaseAuthAdminProvider implements AuthAdminProvider {
  readonly name = 'supabase' as const;
  constructor(private readonly config: SupabaseAuthAdminConfig) {}

  async deleteUser(userId: string): Promise<{ deleted: boolean }> {
    let response: Response;
    try {
      response = await fetch(
        `${this.config.supabaseUrl.replace(/\/+$/, '')}/auth/v1/admin/users/${encodeURIComponent(userId)}`,
        {
          method: 'DELETE',
          headers: {
            apikey: this.config.serviceRoleKey,
            Authorization: `Bearer ${this.config.serviceRoleKey}`,
          },
          signal: AbortSignal.timeout(15_000),
        },
      );
    } catch (error) {
      throw new AppError('PROVIDER_UNAVAILABLE', 'Account deletion is temporarily unavailable.', {
        cause: error,
      });
    }
    if (response.status === 404) return { deleted: false };
    if (!response.ok) {
      throw new AppError('PROVIDER_UNAVAILABLE', 'Account deletion is temporarily unavailable.');
    }
    return { deleted: true };
  }
}
