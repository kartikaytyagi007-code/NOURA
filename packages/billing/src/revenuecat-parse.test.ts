import { describe, expect, it } from 'vitest';
import { normalizeRevenueCatEvent } from './revenuecat-parse.js';

function event(overrides: Record<string, unknown> = {}): unknown {
  return {
    api_version: '1.0',
    event: {
      id: 'evt_1',
      type: 'INITIAL_PURCHASE',
      app_user_id: '11111111-1111-4111-8111-111111111111',
      environment: 'SANDBOX',
      entitlement_id: 'premium',
      event_timestamp_ms: 1_700_000_000_000,
      expiration_at_ms: 1_700_000_000_000 + 30 * 86_400_000,
      ...overrides,
    },
  };
}

describe('normalizeRevenueCatEvent', () => {
  it('rejects a non-object payload and a payload missing event.id/type', () => {
    expect(() => normalizeRevenueCatEvent(null)).toThrow(/object/);
    expect(() => normalizeRevenueCatEvent({ event: {} })).toThrow(/id.*type|type.*id/);
  });

  it('marks INITIAL_PURCHASE/RENEWAL active until their expiry', () => {
    const parsed = normalizeRevenueCatEvent(event());
    expect(parsed.entitlement.isActive).toBe(true);
    expect(parsed.entitlement.entitlementKey).toBe('premium');
    expect(parsed.appUserId).toBe('11111111-1111-4111-8111-111111111111');
    expect(parsed.environment).toBe('sandbox');
  });

  it('keeps CANCELLATION active until period end (blueprint: retains access until expiry)', () => {
    const parsed = normalizeRevenueCatEvent(
      event({ type: 'CANCELLATION', expiration_at_ms: 1_700_000_000_000 + 86_400_000 }),
    );
    expect(parsed.entitlement.isActive).toBe(true);
    expect(parsed.entitlement.providerStatus).toBe('cancellation');
  });

  it('treats a CANCELLATION whose expiry has already passed as inactive', () => {
    const parsed = normalizeRevenueCatEvent(
      event({ type: 'CANCELLATION', expiration_at_ms: 1_700_000_000_000 - 1 }),
    );
    expect(parsed.entitlement.isActive).toBe(false);
  });

  it('ends access immediately for EXPIRATION and REFUND', () => {
    expect(normalizeRevenueCatEvent(event({ type: 'EXPIRATION' })).entitlement.isActive).toBe(
      false,
    );
    expect(normalizeRevenueCatEvent(event({ type: 'REFUND' })).entitlement.isActive).toBe(false);
  });

  it('never grants access for an unrecognized event type', () => {
    const parsed = normalizeRevenueCatEvent(event({ type: 'SOMETHING_FUTURE_RC_ADDS' }));
    expect(parsed.entitlement.isActive).toBe(false);
    expect(parsed.entitlement.providerStatus).toMatch(/^unrecognized:/);
  });

  it('defaults entitlement_id to "premium" when absent', () => {
    const parsed = normalizeRevenueCatEvent(event({ entitlement_id: undefined }));
    expect(parsed.entitlement.entitlementKey).toBe('premium');
  });
});
