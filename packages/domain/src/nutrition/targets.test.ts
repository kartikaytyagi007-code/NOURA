import { describe, expect, it } from 'vitest';
import {
  parseTargetPolicy,
  planningGate,
  TEST_TARGET_POLICY,
  type TargetPolicy,
} from './policy.js';
import { computeTargets, type TargetInput } from './targets.js';

const male: TargetInput = {
  age_years: 30,
  calculation_sex: 'male',
  height_cm: 175,
  weight_kg: 75,
  activity_band: 'moderate',
  goal_type: 'maintain',
};

describe('computeTargets (test policy)', () => {
  it('matches the hand-computed Mifflin-St Jeor result', () => {
    // resting = 10*75 + 6.25*175 - 5*30 + 5 = 1698.75; x1.55 = 2633.06 -> 2633 kcal
    // protein 75*1.2 = 90 g; fat 2633*0.30/9 = 87.8 g; carbs (2633 - 360 - 790.2)/4 = 370.7 g
    // fibre 2.633 * 14 = 36.9 g
    const result = computeTargets(male, TEST_TARGET_POLICY);
    expect(result.basis).toBe('point');
    expect(result.estimated_energy_kcal).toEqual({ min: 2633, max: 2633 });
    expect(result.targets).toEqual({
      energy_kcal: 2633,
      protein_g: 90,
      fibre_g: 36.9,
      carbohydrate_g: 370.7,
      fat_g: 87.8,
    });
    expect(result.warnings).toEqual([]);
  });

  it('applies the goal adjustment from policy', () => {
    const female: TargetInput = {
      age_years: 28,
      calculation_sex: 'female',
      height_cm: 160,
      weight_kg: 60,
      activity_band: 'light',
      goal_type: 'lose_fat',
    };
    // resting 1299; x1.375 = 1786.1; x0.9 = 1607.5 -> 1608
    expect(computeTargets(female, TEST_TARGET_POLICY).targets.energy_kcal).toBe(1608);
    expect(
      computeTargets({ ...female, goal_type: 'maintain' }, TEST_TARGET_POLICY).targets.energy_kcal,
    ).toBe(1786);
  });

  it('is deterministic and records the policy that produced it', () => {
    const a = computeTargets(male, TEST_TARGET_POLICY);
    const b = computeTargets({ ...male }, structuredClone(TEST_TARGET_POLICY));
    expect(a).toEqual(b);
    expect(a).toMatchObject({
      policy_id: 'noura-targets',
      policy_version: 'test-v0',
      policy_status: 'test',
    });
    expect(a.method_reference).toMatch(/TEST POLICY/);
  });

  it('offers only a range, never an inferred point, when the calculation sex is declined', () => {
    const result = computeTargets({ ...male, calculation_sex: null }, TEST_TARGET_POLICY);
    // female: (1532.75 x 1.55) = 2375.8 -> 2376; male: 2633
    expect(result.basis).toBe('range');
    expect(result.estimated_energy_kcal).toEqual({ min: 2376, max: 2633 });
    expect(result.targets).toEqual({
      energy_kcal: null,
      protein_g: 90,
      fibre_g: null,
      carbohydrate_g: null,
      fat_g: null,
    });
  });

  it('all values come from policy configuration, so changing the policy changes the result', () => {
    const tweaked: TargetPolicy = structuredClone(TEST_TARGET_POLICY);
    tweaked.version = 'test-v0-tweaked';
    tweaked.energy.activity_factors.moderate = 1.5;
    tweaked.macros.protein_g_per_kg = 2;
    const result = computeTargets(male, tweaked);
    expect(result.policy_version).toBe('test-v0-tweaked');
    expect(result.targets.energy_kcal).toBe(Math.round(1698.75 * 1.5));
    expect(result.targets.protein_g).toBe(150);
  });

  it('honours a reviewer-supplied energy floor and says so', () => {
    const floored: TargetPolicy = structuredClone(TEST_TARGET_POLICY);
    floored.energy.minimum_energy_kcal = 2800;
    const result = computeTargets(male, floored);
    expect(result.targets.energy_kcal).toBe(2800);
    expect(result.warnings).toContain('energy_floor_applied');
  });

  it('reports a macro conflict instead of inventing a negative carbohydrate target', () => {
    const heavyProtein: TargetPolicy = structuredClone(TEST_TARGET_POLICY);
    heavyProtein.macros.protein_g_per_kg = 10;
    const result = computeTargets(male, heavyProtein);
    expect(result.targets.carbohydrate_g).toBeNull();
    expect(result.warnings).toContain('macro_budget_conflict');
  });
});

describe('target policy configuration', () => {
  it('accepts the test policy and rejects invalid or unreviewed "approved" policies', () => {
    expect(parseTargetPolicy(structuredClone(TEST_TARGET_POLICY)).status).toBe('test');
    const approvedWithoutSignOff = { ...structuredClone(TEST_TARGET_POLICY), status: 'approved' };
    expect(() => parseTargetPolicy(approvedWithoutSignOff)).toThrow(/approval/);
    const approved = {
      ...structuredClone(TEST_TARGET_POLICY),
      status: 'approved',
      approval: { reviewer: 'Dr Example', approved_on: '2026-10-01', reference: 'REV-1' },
    };
    expect(parseTargetPolicy(approved).status).toBe('approved');
    expect(() => parseTargetPolicy({ ...approved, extra_field: 1 })).toThrow();
    expect(() => parseTargetPolicy({ policy_id: 'x' })).toThrow(/Invalid target policy/);
  });

  it('gates automated planning on an approved policy outside development', () => {
    const approved: TargetPolicy = {
      ...TEST_TARGET_POLICY,
      status: 'approved',
      approval: { reviewer: 'Dr Example', approved_on: '2026-10-01', reference: 'REV-1' },
    };
    expect(planningGate('development', TEST_TARGET_POLICY)).toEqual({ allowed: true });
    expect(planningGate('test', TEST_TARGET_POLICY)).toEqual({ allowed: true });
    for (const env of ['staging', 'production'] as const) {
      expect(planningGate(env, TEST_TARGET_POLICY)).toEqual({
        allowed: false,
        reason: 'test_policy_not_allowed',
      });
      expect(planningGate(env, null)).toEqual({ allowed: false, reason: 'no_policy' });
      expect(planningGate(env, approved)).toEqual({ allowed: true });
    }
  });
});
