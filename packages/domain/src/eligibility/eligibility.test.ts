import { describe, expect, it } from 'vitest';
import {
  answersFromFlags,
  evaluateEligibility,
  flagsFromAnswers,
  type ScreeningAnswers,
} from './index.js';

const none: ScreeningAnswers = {
  pregnancy_or_breastfeeding: 'no',
  eating_disorder_concern: 'no',
  medical_diet_condition: 'no',
};

describe('evaluateEligibility', () => {
  it('is eligible for an adult with no screening concerns', () => {
    expect(evaluateEligibility({ age_years: 30, answers: none })).toMatchObject({
      status: 'eligible',
      reasons: [],
      rules_version: 'eligibility-v1',
    });
  });

  it('treats the minimum adult age as inclusive and anything below as tracking-only', () => {
    expect(evaluateEligibility({ age_years: 18, answers: none }).status).toBe('eligible');
    expect(evaluateEligibility({ age_years: 17, answers: none })).toMatchObject({
      status: 'tracking_only',
      reasons: ['under_minimum_age'],
    });
  });

  it.each([
    ['pregnancy_or_breastfeeding', 'screening_pregnancy_or_breastfeeding'],
    ['eating_disorder_concern', 'screening_eating_disorder_concern'],
    ['medical_diet_condition', 'screening_medical_diet_condition'],
  ] as const)('a "yes" to %s is tracking-only', (question, reason) => {
    expect(
      evaluateEligibility({ age_years: 30, answers: { ...none, [question]: 'yes' } }),
    ).toMatchObject({ status: 'tracking_only', reasons: [reason] });
  });

  it('declining to answer needs review because eligibility cannot be confirmed', () => {
    expect(
      evaluateEligibility({
        age_years: 30,
        answers: { ...none, eating_disorder_concern: 'prefer_not_to_say' },
      }),
    ).toMatchObject({ status: 'needs_review', reasons: ['screening_declined'] });
  });

  it('a "yes" outranks a declined answer, and collects every reason', () => {
    const result = evaluateEligibility({
      age_years: 15,
      answers: {
        pregnancy_or_breastfeeding: 'yes',
        eating_disorder_concern: 'prefer_not_to_say',
        medical_diet_condition: 'yes',
      },
    });
    expect(result.status).toBe('tracking_only');
    expect(result.reasons).toEqual([
      'under_minimum_age',
      'screening_pregnancy_or_breastfeeding',
      'screening_medical_diet_condition',
    ]);
  });

  it('uses configurable rules', () => {
    expect(
      evaluateEligibility({ age_years: 20, answers: none }, { version: 'x', minimum_adult_age: 21 })
        .status,
    ).toBe('tracking_only');
  });
});

describe('screening flags', () => {
  it('stores only non-"no" answers and round-trips', () => {
    const answers: ScreeningAnswers = {
      pregnancy_or_breastfeeding: 'yes',
      eating_disorder_concern: 'prefer_not_to_say',
      medical_diet_condition: 'no',
    };
    const flags = flagsFromAnswers(answers);
    expect(flags).toEqual(['pregnancy_or_breastfeeding', 'eating_disorder_concern:declined']);
    expect(answersFromFlags(flags)).toEqual(answers);
    expect(flagsFromAnswers(none)).toEqual([]);
    expect(answersFromFlags([])).toEqual(none);
  });
});
