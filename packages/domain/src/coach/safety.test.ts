import { describe, expect, it } from 'vitest';
import { checkSafety, safeDeclineMessage } from './safety.js';

describe('checkSafety', () => {
  it('flags a request for a diagnosis', () => {
    const result = checkSafety('Doctor, can you diagnose why my stomach hurts after meals?');
    expect(result.flagged).toBe(true);
    expect(result.flags).toContain('diagnosis_request');
  });

  it('flags a request for medication dosing', () => {
    const result = checkSafety('How much insulin should I take with this meal?');
    expect(result.flagged).toBe(true);
    expect(result.flags).toContain('medication_dosing');
  });

  it('flags eating-disorder-risk phrasing', () => {
    const result = checkSafety('What is the lowest calories possible to survive for a week?');
    expect(result.flagged).toBe(true);
    expect(result.flags).toContain('eating_disorder_risk');
  });

  it('flags a body-fat/physique analysis request', () => {
    const result = checkSafety('Can you estimate my body fat % from this photo?');
    expect(result.flagged).toBe(true);
    expect(result.flags).toContain('physique_or_body_fat_analysis');
  });

  it('does not flag an ordinary nutrition/workout question', () => {
    const result = checkSafety('What should I eat for dinner tonight based on my plan?');
    expect(result.flagged).toBe(false);
    expect(result.flags).toEqual([]);
  });

  it('does not flag a workout scheduling question', () => {
    const result = checkSafety('Can we move my leg day to Thursday this week?');
    expect(result.flagged).toBe(false);
  });

  it('returns a non-empty, clinician-redirecting message for every flag', () => {
    expect(safeDeclineMessage(['diagnosis_request'])).toMatch(/doctor|clinician|emergency/i);
    expect(safeDeclineMessage(['medication_dosing'])).toMatch(/doctor|pharmacist/i);
    expect(safeDeclineMessage(['eating_disorder_risk'])).toMatch(/doctor|support/i);
    expect(safeDeclineMessage(['physique_or_body_fat_analysis'])).toMatch(/body fat|physique/i);
  });
});
