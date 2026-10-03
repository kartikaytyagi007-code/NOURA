import { AppError } from '@noura/domain';
import type { BillingEnvironment, NormalizedWebhookEvent } from './types.js';

/**
 * RevenueCat event types that leave (or put) the subscriber in an active state for the named
 * entitlement. `CANCELLATION` means auto-renew was turned off but the blueprint is explicit that
 * access is retained until period end — so it is active until `expiration_at_ms`, not inactive
 * immediately. `BILLING_ISSUE` means a renewal failed and the provider has entered a grace period;
 * access is retained (store/provider decide the grace window) with a visible provider_status so a UI
 * can warn the user. Every other named type ends the entitlement.
 * https://www.revenuecat.com/docs/integrations/webhooks/event-types-and-fields
 */
const RETAINS_ACCESS_UNTIL_EXPIRY = new Set([
  'INITIAL_PURCHASE',
  'RENEWAL',
  'UNCANCELLATION',
  'PRODUCT_CHANGE',
  'TRANSFER',
  'NON_RENEWING_PURCHASE',
  'SUBSCRIPTION_EXTENDED',
  'CANCELLATION',
  'BILLING_ISSUE',
  'SUBSCRIPTION_PAUSED',
]);
const ENDS_ACCESS_IMMEDIATELY = new Set(['EXPIRATION', 'REFUND']);

const DEFAULT_ENTITLEMENT_KEY = 'premium';

function asString(value: unknown): string | null {
  return typeof value === 'string' && value.length > 0 ? value : null;
}

function asMillis(value: unknown): number | null {
  return typeof value === 'number' && Number.isFinite(value) ? value : null;
}

/**
 * Normalizes a RevenueCat webhook body. Shared by both the mock and real providers, since the wire
 * shape is identical in sandbox and production — only webhook-auth verification and
 * fetchSubscriberEntitlements differ between them.
 */
export function normalizeRevenueCatEvent(payload: unknown): NormalizedWebhookEvent {
  if (typeof payload !== 'object' || payload === null) {
    throw new AppError('VALIDATION_ERROR', 'Webhook payload must be a JSON object.');
  }
  const event = (payload as Record<string, unknown>)['event'];
  if (typeof event !== 'object' || event === null) {
    throw new AppError('VALIDATION_ERROR', 'Webhook payload is missing "event".');
  }
  const e = event as Record<string, unknown>;
  const providerEventId = asString(e['id']);
  const rawType = asString(e['type']);
  if (!providerEventId || !rawType) {
    throw new AppError('VALIDATION_ERROR', 'Webhook event is missing "id" or "type".');
  }
  const environment: BillingEnvironment =
    e['environment'] === 'PRODUCTION' ? 'production' : 'sandbox';
  const appUserId = asString(e['app_user_id']);
  const entitlementKey =
    asString(e['entitlement_id']) ??
    (Array.isArray(e['entitlement_ids']) ? asString(e['entitlement_ids'][0]) : null) ??
    DEFAULT_ENTITLEMENT_KEY;

  const eventAtMs = asMillis(e['event_timestamp_ms']) ?? Date.now();
  const expiresAtMs = asMillis(e['expiration_at_ms']);

  let isActive: boolean;
  let providerStatus: string;
  if (RETAINS_ACCESS_UNTIL_EXPIRY.has(rawType)) {
    // Still reconciled against a real expiry when the provider supplies one, so a stale CANCELLATION
    // event can never grant access past the period it already told us about.
    isActive = expiresAtMs === null || expiresAtMs > eventAtMs;
    providerStatus = rawType.toLowerCase();
  } else if (ENDS_ACCESS_IMMEDIATELY.has(rawType)) {
    isActive = false;
    providerStatus = rawType.toLowerCase();
  } else {
    // An unrecognized-but-well-formed event type (provider added a new one): persist and surface it,
    // but never silently grant access on a type this adapter does not understand.
    isActive = false;
    providerStatus = `unrecognized:${rawType.toLowerCase()}`;
  }

  return {
    providerEventId,
    environment,
    appUserId,
    eventAt: new Date(eventAtMs).toISOString(),
    rawType,
    entitlement: {
      entitlementKey,
      isActive,
      providerStatus,
      expiresAt: expiresAtMs !== null ? new Date(expiresAtMs).toISOString() : null,
    },
  };
}
