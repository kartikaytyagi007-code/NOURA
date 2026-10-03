/**
 * Consent catalogue (blueprint §5, §14). Consent text itself is owned by legal review: every version
 * published here is a DRAFT PLACEHOLDER until counsel supplies final documents (docs/decisions.md
 * D-021, release gate in docs/milestones.md). The server accepts only versions it currently publishes,
 * so a client can never record consent to text that does not exist.
 */
export const CONSENT_TYPES = [
  'terms',
  'privacy',
  'health_data_processing',
  'ai_meal_processing',
  'progress_photo_storage',
] as const;
export type ConsentType = (typeof CONSENT_TYPES)[number];

/** Required to complete onboarding. The optional consents are requested where they are used (M4, M8). */
export const REQUIRED_ONBOARDING_CONSENTS = [
  'terms',
  'privacy',
  'health_data_processing',
] as const satisfies readonly ConsentType[];

export const DRAFT_CONSENT_VERSION = 'v0-draft';

export const PUBLISHED_CONSENT_VERSIONS: Record<ConsentType, readonly string[]> = {
  terms: [DRAFT_CONSENT_VERSION],
  privacy: [DRAFT_CONSENT_VERSION],
  health_data_processing: [DRAFT_CONSENT_VERSION],
  ai_meal_processing: [DRAFT_CONSENT_VERSION],
  progress_photo_storage: [DRAFT_CONSENT_VERSION],
};

export function isPublishedConsent(type: ConsentType, version: string): boolean {
  return PUBLISHED_CONSENT_VERSIONS[type].includes(version);
}
