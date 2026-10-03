import { describe, expect, it } from 'vitest';
import { filterEligibleRecipes } from '../catalog/eligibility.js';
import {
  ALL_RECIPES,
  CHICKEN_BOWL,
  EGG_BREAKFAST,
  VEGAN_BREAKFAST,
} from '../catalog/test-fixtures.js';
import { generatePlan } from './generate.js';

const NO_CONSTRAINTS: {
  diet_type: null;
  allergy_ids: string[];
  exclusion_ids: string[];
  dislikes: string[];
} = {
  diet_type: null,
  allergy_ids: [],
  exclusion_ids: [],
  dislikes: [],
};

describe('generatePlan', () => {
  it('produces 7 days with breakfast/lunch/dinner and sums reconcile exactly', () => {
    const eligible = filterEligibleRecipes(ALL_RECIPES, {
      ...NO_CONSTRAINTS,
      diet_type: 'non_vegetarian',
    });
    const result = generatePlan({
      startsOn: '2026-10-05',
      mealsPerDay: 3,
      eligibleRecipes: eligible,
      targetEnergyKcal: 2000,
    });
    expect(result.ok).toBe(true);
    if (!result.ok) return;
    expect(result.plan.days).toHaveLength(7);
    expect(result.plan.days[0]!.date).toBe('2026-10-05');
    expect(result.plan.days[6]!.date).toBe('2026-10-11');
    for (const day of result.plan.days) {
      expect(day.meals.map((m) => m.slot)).toEqual(['breakfast', 'lunch', 'dinner']);
      const tenthsSum = day.meals.reduce(
        (s, m) => s + Math.round(m.nutrition.nutrients.energy_kcal ?? 0),
        0,
      );
      expect(day.totals.nutrients.energy_kcal).toBe(tenthsSum);
    }
  });

  it('is deterministic: the same inputs always produce the same plan', () => {
    const eligible = filterEligibleRecipes(ALL_RECIPES, { ...NO_CONSTRAINTS, diet_type: 'vegan' });
    const input = {
      startsOn: '2026-10-05',
      mealsPerDay: 4,
      eligibleRecipes: eligible,
      targetEnergyKcal: 1800,
    };
    const a = generatePlan(input);
    const b = generatePlan(input);
    expect(a).toEqual(b);
  });

  it('adds a snack slot once meals_per_day is above 3', () => {
    const eligible = filterEligibleRecipes(ALL_RECIPES, { ...NO_CONSTRAINTS, diet_type: 'vegan' });
    const result = generatePlan({
      startsOn: '2026-10-05',
      mealsPerDay: 4,
      eligibleRecipes: eligible,
      targetEnergyKcal: null,
    });
    expect(result.ok).toBe(true);
    if (result.ok) expect(result.plan.days[0]!.meals.map((m) => m.slot)).toContain('snack');
  });

  it('scales portions toward the per-meal energy share, within bounds', () => {
    const eligible = [VEGAN_BREAKFAST];
    const result = generatePlan({
      startsOn: '2026-10-05',
      mealsPerDay: 3,
      eligibleRecipes: [...eligible, CHICKEN_BOWL, CHICKEN_BOWL],
      targetEnergyKcal: 3000,
    });
    expect(result.ok).toBe(true);
    if (!result.ok) return;
    const breakfast = result.plan.days[0]!.meals.find((m) => m.slot === 'breakfast')!;
    expect(breakfast.grams_scale).toBeGreaterThan(1);
    expect(breakfast.grams_scale).toBeLessThanOrEqual(1.75);
  });

  it('never scales portions when no point energy target is available (basis: range, D-024)', () => {
    const eligible = filterEligibleRecipes(ALL_RECIPES, { ...NO_CONSTRAINTS, diet_type: 'vegan' });
    const result = generatePlan({
      startsOn: '2026-10-05',
      mealsPerDay: 3,
      eligibleRecipes: eligible,
      targetEnergyKcal: null,
    });
    expect(result.ok).toBe(true);
    if (result.ok) {
      for (const meal of result.plan.days[0]!.meals) expect(meal.grams_scale).toBe(1);
    }
  });

  it('reports infeasibility honestly when a required slot has no eligible recipe', () => {
    // Only an eggatarian breakfast recipe is eligible; vegan has none eligible for breakfast.
    const eligible = [EGG_BREAKFAST];
    const result = generatePlan({
      startsOn: '2026-10-05',
      mealsPerDay: 3,
      eligibleRecipes: eligible,
      targetEnergyKcal: 2000,
    });
    expect(result).toEqual({ ok: false, reason: 'infeasible_slot', slot: 'lunch' });
  });
});
