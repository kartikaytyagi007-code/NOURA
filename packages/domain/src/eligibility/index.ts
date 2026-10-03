/**
 * Eligibility screening (blueprint §1, §5). V1 serves adults seeking general wellness. Automated
 * nutrition/training plans are out of scope for minors, pregnancy/breastfeeding, active
 * eating-disorder concerns, and conditions that need an individualised medical diet. Those users get
 * neutral tracking features with an explanation; no treatment plan is generated.
 *
 * Only the minimum screening data is stored: which questions were answered "yes" or declined.
 * This module is pure and deterministic. Its parameters are product-scope definitions pending
 * legal/clinical confirmation (docs/decisions.md D-019); they are not clinical thresholds.
 */

export const SCREENING_QUESTIONS = [
  'pregnancy_or_breastfeeding',
  'eating_disorder_concern',
  'medical_diet_condition',
] as const;
export type ScreeningQuestion = (typeof SCREENING_QUESTIONS)[number];

export const SCREENING_ANSWERS = ['yes', 'no', 'prefer_not_to_say'] as const;
export type ScreeningAnswer = (typeof SCREENING_ANSWERS)[number];

export type ScreeningAnswers = Record<ScreeningQuestion, ScreeningAnswer>;

export type EligibilityStatus = 'eligible' | 'tracking_only' | 'needs_review';

export interface EligibilityRules {
  version: string;
  /** Provisional: the adult age used to scope V1. Jurisdiction-specific; needs legal confirmation. */
  minimum_adult_age: number;
}

export const ELIGIBILITY_RULES: EligibilityRules = {
  version: 'eligibility-v1',
  minimum_adult_age: 18,
};

export type EligibilityReason =
  'under_minimum_age' | `screening_${ScreeningQuestion}` | 'screening_declined';

export interface EligibilityResult {
  status: EligibilityStatus;
  reasons: EligibilityReason[];
  rules_version: string;
}

/**
 * - under the minimum age, or any "yes" answer  -> tracking_only
 * - otherwise, any declined answer              -> needs_review (eligibility cannot be confirmed)
 * - otherwise                                   -> eligible
 */
export function evaluateEligibility(
  input: { age_years: number; answers: ScreeningAnswers },
  rules: EligibilityRules = ELIGIBILITY_RULES,
): EligibilityResult {
  const trackingReasons: EligibilityReason[] = [];
  if (input.age_years < rules.minimum_adult_age) trackingReasons.push('under_minimum_age');
  for (const question of SCREENING_QUESTIONS) {
    if (input.answers[question] === 'yes') trackingReasons.push(`screening_${question}`);
  }
  if (trackingReasons.length > 0) {
    return { status: 'tracking_only', reasons: trackingReasons, rules_version: rules.version };
  }
  if (SCREENING_QUESTIONS.some((q) => input.answers[q] === 'prefer_not_to_say')) {
    return {
      status: 'needs_review',
      reasons: ['screening_declined'],
      rules_version: rules.version,
    };
  }
  return { status: 'eligible', reasons: [], rules_version: rules.version };
}

/**
 * Persisted form (profiles.screening_flags): one entry per question that was not answered "no".
 * "yes" is stored as the question key, a declined answer as "<question>:declined". Whether the
 * screening was answered at all is tracked by profiles.screening_answered_at.
 */
export function flagsFromAnswers(answers: ScreeningAnswers): string[] {
  const flags: string[] = [];
  for (const question of SCREENING_QUESTIONS) {
    if (answers[question] === 'yes') flags.push(question);
    else if (answers[question] === 'prefer_not_to_say') flags.push(`${question}:declined`);
  }
  return flags;
}

export function answersFromFlags(flags: readonly string[]): ScreeningAnswers {
  const answers = {} as ScreeningAnswers;
  for (const question of SCREENING_QUESTIONS) {
    answers[question] = flags.includes(question)
      ? 'yes'
      : flags.includes(`${question}:declined`)
        ? 'prefer_not_to_say'
        : 'no';
  }
  return answers;
}
