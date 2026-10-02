import { describe, expect, it } from 'vitest';
import { buildNextMealRecommendation, weakestDailyGap, type PlannedSlotInfo } from './next-meal.js';
import { computeRecipeNutrition } from '../catalog/nutrition.js';
import {
  CHICKEN_BOWL,
  EGG_BREAKFAST,
  PANEER_BOWL,
  VEG_RICE_BOWL,
  VEGAN_BREAKFAST,
} from '../catalog/test-fixtures.js';
import type { NutrientTotals } from '../catalog/nutrition.js';

const EMPTY_TOTALS: NutrientTotals = {
  nutrients: {
    energy_kcal: null,
    protein_g: null,
    carbohydrate_g: null,
    fat_g: null,
    fibre_g: null,
  },
  coverage: { items_total: 0, items_with_nutrition: 0, complete: false },
};

const COMPLETE_TOTALS = (protein: number, fibre: number): NutrientTotals => ({
  nutrients: {
    energy_kcal: 500,
    protein_g: protein,
    carbohydrate_g: 50,
    fat_g: 10,
    fibre_g: fibre,
  },
  coverage: { items_total: 2, items_with_nutrition: 2, complete: true },
});

const ELIGIBLE = [VEG_RICE_BOWL, PANEER_BOWL, EGG_BREAKFAST, VEGAN_BREAKFAST, CHICKEN_BOWL];

describe('weakestDailyGap', () => {
  it('returns null when coverage is incomplete', () => {
    expect(weakestDailyGap(EMPTY_TOTALS, { protein_g: 100, fibre_g: 30 })).toBeNull();
  });

  it('returns null when there is no target to compare against', () => {
    expect(weakestDailyGap(COMPLETE_TOTALS(10, 5), null)).toBeNull();
  });

  it('returns null when both macros already meet target', () => {
    expect(weakestDailyGap(COMPLETE_TOTALS(100, 30), { protein_g: 90, fibre_g: 25 })).toBeNull();
  });

  it('picks whichever macro is furthest below its target', () => {
    // protein at 20% of target, fibre at 80% of target => protein is weaker.
    expect(weakestDailyGap(COMPLETE_TOTALS(20, 24), { protein_g: 100, fibre_g: 30 })).toBe(
      'protein_g',
    );
  });
});

describe('buildNextMealRecommendation', () => {
  const baseInput = {
    requestedSlot: null,
    plannedSlots: [] as PlannedSlotInfo[],
    loggedSlots: new Set<'breakfast' | 'lunch' | 'dinner' | 'snack'>(),
    loggedMealsCount: 0,
    todayTotals: EMPTY_TOTALS,
    eligibleRecipes: ELIGIBLE,
    dailyTargets: null,
    dismissed: false,
  };

  it('picks the next unlogged slot by time of day when none is requested', () => {
    const result = buildNextMealRecommendation({
      ...baseInput,
      loggedSlots: new Set(['breakfast']),
    });
    expect(result.slot).toBe('lunch');
  });

  it('prefers the active plan slot with a clear plan-grounded reason', () => {
    const planned: PlannedSlotInfo = {
      slot: 'lunch',
      plan_meal_id: 'plan-meal-1',
      plan_meal_revision: 1,
      recipe: VEG_RICE_BOWL,
      grams_scale: 1,
      nutrition: computeRecipeNutrition(VEG_RICE_BOWL, 1),
    };
    const result = buildNextMealRecommendation({
      ...baseInput,
      requestedSlot: 'lunch',
      plannedSlots: [planned],
    });
    expect(result.options[0]!.source).toBe('plan');
    expect(result.options[0]!.plan_meal_id).toBe('plan-meal-1');
    expect(result.options[0]!.reason).toMatch(/next unlogged slot in your plan/);
    // Alternatives are catalog recipes tagged for the same slot, excluding the planned one.
    expect(result.options.slice(1).every((o) => o.source === 'catalog')).toBe(true);
    expect(
      result.options.some((o) => o.candidate_id === VEG_RICE_BOWL.id && o.source !== 'plan'),
    ).toBe(false);
    // Alternatives target the SAME plan slot, so each is directly swap-able in place.
    expect(result.options.slice(1).every((o) => o.plan_meal_id === 'plan-meal-1')).toBe(true);
    expect(result.options.slice(1).every((o) => o.plan_meal_revision === 1)).toBe(true);
  });

  it('falls back to a deterministic catalog pick with no active plan', () => {
    const result = buildNextMealRecommendation({ ...baseInput, requestedSlot: 'dinner' });
    expect(result.options[0]!.source).toBe('catalog');
    expect(result.options[0]!.reason).toMatch(/No planned meal for dinner/);
  });

  it('is deterministic for identical inputs', () => {
    const a = buildNextMealRecommendation({ ...baseInput, requestedSlot: 'lunch' });
    const b = buildNextMealRecommendation({ ...baseInput, requestedSlot: 'lunch' });
    expect(a).toEqual(b);
  });

  it('names the macro gap in the reason only when today is a complete, usable baseline', () => {
    const result = buildNextMealRecommendation({
      ...baseInput,
      requestedSlot: 'lunch',
      todayTotals: COMPLETE_TOTALS(10, 5),
      loggedMealsCount: 1,
      loggedSlots: new Set(['breakfast']),
      dailyTargets: { protein_g: 100, fibre_g: 30 },
    });
    expect(result.limited_context).toBe(false);
    expect(result.options[0]!.reason).toMatch(/high in protein/);
  });

  it('never claims a gap when coverage is incomplete, and flags limited context', () => {
    const result = buildNextMealRecommendation({
      ...baseInput,
      requestedSlot: 'lunch',
      dailyTargets: { protein_g: 100, fibre_g: 30 },
    });
    expect(result.limited_context).toBe(true);
    expect(result.options[0]!.reason).not.toMatch(/low on/);
    expect(result.explanation).toMatch(/limited context/);
  });

  it('reports no options when the requested slot is already logged', () => {
    const result = buildNextMealRecommendation({
      ...baseInput,
      requestedSlot: 'breakfast',
      loggedSlots: new Set(['breakfast']),
      loggedMealsCount: 1,
    });
    expect(result.options).toEqual([]);
    expect(result.explanation).toMatch(/already logged/);
  });

  it('reports no options when every slot is already logged and none was requested', () => {
    const result = buildNextMealRecommendation({
      ...baseInput,
      loggedSlots: new Set(['breakfast', 'lunch', 'dinner', 'snack']),
      loggedMealsCount: 4,
    });
    expect(result.options).toEqual([]);
    expect(result.explanation).toMatch(/every slot/);
  });

  it('never suggests a recipe outside the eligible pool (diet/allergy/exclusion/dislike safe)', () => {
    // Only a vegan-safe pool is passed in; a non-vegan option must never appear.
    const veganOnly = [VEG_RICE_BOWL, VEGAN_BREAKFAST];
    const result = buildNextMealRecommendation({
      ...baseInput,
      requestedSlot: 'dinner',
      eligibleRecipes: veganOnly,
    });
    for (const option of result.options) {
      expect(veganOnly.some((r) => r.id === option.candidate_id)).toBe(true);
    }
    expect(result.options.some((o) => o.candidate_id === CHICKEN_BOWL.id)).toBe(false);
  });

  it('suppresses options and stays sticky once dismissed for a date/slot', () => {
    const result = buildNextMealRecommendation({
      ...baseInput,
      requestedSlot: 'lunch',
      dismissed: true,
    });
    expect(result.options).toEqual([]);
    expect(result.explanation).toMatch(/dismissed/);
  });
});
