import { describe, expect, it } from 'vitest';
import {
  filterEligibleExercises,
  isEquipmentEligible,
  isExperienceEligible,
  isLimitationSafe,
} from './eligibility.js';
import { BARBELL_SQUAT, BODYWEIGHT_SQUAT, GLUTE_BRIDGE, PLANK } from './test-fixtures.js';

describe('isEquipmentEligible', () => {
  it('always allows a bodyweight exercise', () => {
    expect(isEquipmentEligible(BODYWEIGHT_SQUAT, 'home', [])).toBe(true);
  });

  it('excludes a barbell exercise for home-only equipment that lacks a barbell', () => {
    expect(isEquipmentEligible(BARBELL_SQUAT, 'home', ['dumbbell'])).toBe(false);
  });

  it('allows a barbell exercise once the user declares a barbell at home', () => {
    expect(isEquipmentEligible(BARBELL_SQUAT, 'home', ['barbell'])).toBe(true);
  });

  it('assumes full equipment access for gym and both locations', () => {
    expect(isEquipmentEligible(BARBELL_SQUAT, 'gym', [])).toBe(true);
    expect(isEquipmentEligible(BARBELL_SQUAT, 'both', [])).toBe(true);
  });
});

describe('isLimitationSafe', () => {
  it('excludes an exercise whose contraindication matches a recorded limitation', () => {
    expect(isLimitationSafe(BODYWEIGHT_SQUAT, ['knee'])).toBe(false);
  });

  it('allows an exercise with no overlapping contraindication', () => {
    expect(isLimitationSafe(GLUTE_BRIDGE, ['knee'])).toBe(true);
  });
});

describe('isExperienceEligible', () => {
  it('excludes an advanced-level exercise for a beginner', () => {
    expect(isExperienceEligible(BARBELL_SQUAT, 'beginner')).toBe(false);
  });

  it('includes a beginner-level exercise for an advanced user', () => {
    expect(isExperienceEligible(BODYWEIGHT_SQUAT, 'advanced')).toBe(true);
  });

  it('defaults to beginner-only when experience is unknown', () => {
    expect(isExperienceEligible(BARBELL_SQUAT, null)).toBe(false);
    expect(isExperienceEligible(BODYWEIGHT_SQUAT, null)).toBe(true);
  });
});

describe('filterEligibleExercises', () => {
  it('combines equipment, limitation and experience rules (home, no gym access, knee limitation)', () => {
    const pool = [BODYWEIGHT_SQUAT, BARBELL_SQUAT, GLUTE_BRIDGE, PLANK];
    const eligible = filterEligibleExercises(pool, {
      location: 'home',
      equipmentIds: ['dumbbell'],
      experience: 'intermediate',
      limitationTags: ['knee'],
    });
    // Bodyweight/barbell squat both excluded by the knee limitation; barbell squat is also
    // excluded by missing equipment and by exceeding the user's experience level.
    expect(eligible.map((e) => e.id)).toEqual([GLUTE_BRIDGE.id, PLANK.id]);
  });
});
