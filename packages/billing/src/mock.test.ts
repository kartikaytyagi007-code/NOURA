import { describe, expect, it } from 'vitest';
import { MOCK_WEBHOOK_AUTH, MockAuthAdminProvider, MockBillingProvider } from './mock.js';

describe('MockBillingProvider', () => {
  it('only accepts the fixed dev/test webhook secret', () => {
    const provider = new MockBillingProvider();
    expect(provider.verifyWebhookAuth(MOCK_WEBHOOK_AUTH)).toBe(true);
    expect(provider.verifyWebhookAuth('Bearer wrong')).toBe(false);
    expect(provider.verifyWebhookAuth(undefined)).toBe(false);
  });

  it('never fabricates an active entitlement on restore/sync', async () => {
    const provider = new MockBillingProvider();
    await expect(provider.fetchSubscriberEntitlements('any-user')).resolves.toEqual([]);
  });
});

describe('MockAuthAdminProvider', () => {
  it('is idempotent: a second delete of the same user reports deleted:false', async () => {
    const provider = new MockAuthAdminProvider();
    await expect(provider.deleteUser('u1')).resolves.toEqual({ deleted: true });
    await expect(provider.deleteUser('u1')).resolves.toEqual({ deleted: false });
  });
});
