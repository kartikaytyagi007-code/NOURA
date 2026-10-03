import { describe, expect, it } from 'vitest';
import {
  CONSENT_TYPES,
  isPublishedConsent,
  PUBLISHED_CONSENT_VERSIONS,
  REQUIRED_ONBOARDING_CONSENTS,
} from './index.js';

describe('consent catalogue', () => {
  it('publishes at least one version of every consent type, and the required set is a subset', () => {
    for (const type of CONSENT_TYPES)
      expect(PUBLISHED_CONSENT_VERSIONS[type].length).toBeGreaterThan(0);
    for (const type of REQUIRED_ONBOARDING_CONSENTS) expect(CONSENT_TYPES).toContain(type);
  });
  it('accepts only published versions', () => {
    expect(isPublishedConsent('terms', 'v0-draft')).toBe(true);
    expect(isPublishedConsent('terms', 'v99')).toBe(false);
  });
});
