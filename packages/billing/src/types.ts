/**
 * Billing/entitlement provider boundary (blueprint §13). The API and worker never derive premium
 * status from a client-submitted flag or from webhook arrival order: every call here either reads a
 * raw, provider-defined payload (webhook) or asks the provider directly (restore/sync), and the
 * caller reconciles the result into `app.entitlements` with `reconcileEntitlement` (never a blind
 * overwrite — see packages/domain/src/billing/reconcile.ts).
 */

export type BillingEnvironment = 'sandbox' | 'production';

/** One entitlement's state as of a specific provider event/fetch, normalized from provider payloads. */
export interface NormalizedEntitlement {
  entitlementKey: string;
  isActive: boolean;
  providerStatus: string;
  /** ISO timestamp, or null for a subscription with no expiry (e.g. a lifetime/non-renewing grant). */
  expiresAt: string | null;
}

/** A single normalized webhook event, already mapped from the provider's own type vocabulary. */
export interface NormalizedWebhookEvent {
  providerEventId: string;
  environment: BillingEnvironment;
  /** Null when the payload has no resolvable app_user_id (ignored by the caller, never guessed). */
  appUserId: string | null;
  /** The event's own effective time, used to reconcile out-of-order delivery — never "now()". */
  eventAt: string;
  entitlement: NormalizedEntitlement;
  rawType: string;
}

export interface BillingProvider {
  readonly name: 'mock' | 'revenuecat';
  /**
   * Verifies the webhook request's Authorization header against the configured shared secret.
   * Returns false (never throws) on any mismatch or missing header — callers must treat false as
   * UNAUTHENTICATED.
   */
  verifyWebhookAuth(authorizationHeader: string | undefined): boolean;
  /**
   * Parses a provider webhook body into a normalized event. Throws on a payload that does not match
   * the provider's documented shape; callers map that to a 422 VALIDATION_ERROR and never guess a
   * user or entitlement from an unparseable body.
   */
  parseWebhookEvent(payload: unknown): NormalizedWebhookEvent;
  /**
   * Restore-purchases / manual sync: asks the provider directly for the subscriber's current
   * entitlement state (ground truth), rather than trusting anything the device claims. The mock
   * implementation always returns an empty, clearly-labelled "no active entitlements" result — it
   * never fabricates a premium unlock (blueprint: "a forged mobile flag never unlocks paid API
   * features").
   */
  fetchSubscriberEntitlements(appUserId: string): Promise<NormalizedEntitlement[]>;
}

/**
 * The narrow slice of Supabase's Auth Admin API account deletion needs: removing the identity itself
 * after app-owned rows and Storage objects are gone. Mirrors the BillingProvider/AiProvider mock-first
 * pattern — development/test use a deterministic mock; a real deletion requires a service-role key.
 */
export interface AuthAdminProvider {
  readonly name: 'mock' | 'supabase';
  /** Idempotent: deleting an already-deleted user is not an error. */
  deleteUser(userId: string): Promise<{ deleted: boolean }>;
}
