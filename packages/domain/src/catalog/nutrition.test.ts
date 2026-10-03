import { describe, expect, it } from 'vitest';
import { computeRecipeNutrition, sumNutrientTotals } from './nutrition.js';
import { VEG_RICE_BOWL } from './test-fixtures.js';
import type { CatalogFood } from './types.js';

describe('computeRecipeNutrition', () => {
  it('sums per-ingredient macros at their edible grams', () => {
    // rice 150g: 130*1.5=195 kcal, 2.7*1.5=4.05->4.1g protein, 28*1.5=42g carb, 0.3*1.5=0.45->0.5g fat, 0.4*1.5=0.6g fibre
    // veg 150g: 50*1.5=75 kcal, 2*1.5=3g protein, 10*1.5=15g carb, 0.3*1.5=0.45->0.5g fat, 3*1.5=4.5g fibre
    const result = computeRecipeNutrition(VEG_RICE_BOWL, 1);
    expect(result.nutrients).toEqual({
      energy_kcal: 270,
      protein_g: 7.1,
      carbohydrate_g: 57,
      fat_g: 1,
      fibre_g: 5.1,
    });
    expect(result.coverage).toEqual({ items_total: 2, items_with_nutrition: 2, complete: true });
  });

  it('scales linearly with the portion scale', () => {
    const half = computeRecipeNutrition(VEG_RICE_BOWL, 0.5);
    // rice 130*0.75=97.5 -> 98; vegetables 50*0.75=37.5 -> 38 (rounded per ingredient, then summed)
    expect(half.nutrients.energy_kcal).toBe(136);
  });

  it('reports a nutrient as unknown (null), never zero, when any ingredient lacks it', () => {
    const incomplete: CatalogFood = {
      id: 'food-unknown',
      name: 'Unknown item',
      energy_kcal_per_100g: null,
      protein_g_per_100g: 1,
      carbohydrate_g_per_100g: 1,
      fat_g_per_100g: 1,
      fibre_g_per_100g: 1,
      diet_tags: ['vegan', 'vegetarian', 'eggatarian', 'non_vegetarian'],
      allergen_tags: [],
      allergen_coverage: 'complete',
      food_group_tags: [],
      quality_flag: 'test_fixture',
      serving_conversions: [],
    };
    const result = computeRecipeNutrition(
      { ...VEG_RICE_BOWL, ingredients: [{ food: incomplete, edible_grams: 100 }] },
      1,
    );
    expect(result.nutrients.energy_kcal).toBeNull();
    expect(result.nutrients.protein_g).toBe(1);
    expect(result.coverage).toEqual({ items_total: 1, items_with_nutrition: 0, complete: false });
  });
});

describe('sumNutrientTotals reconciles exactly (blueprint §7)', () => {
  it('a day total equals the sum of its already-rounded meals, with no floating-point drift', () => {
    // Values chosen so naive floating-point summation (0.1 + 0.2 style error) would otherwise drift.
    const meals = [
      computeRecipeNutrition(VEG_RICE_BOWL, 0.37),
      computeRecipeNutrition(VEG_RICE_BOWL, 0.41),
      computeRecipeNutrition(VEG_RICE_BOWL, 1.13),
    ];
    const total = sumNutrientTotals(meals);
    // Each meal's protein_g is already rounded to 1 decimal; the total must equal their exact sum
    // (an integer-tenths sum), not a value that drifted from re-summing floating point decimals.
    const expectedTenths =
      Math.round(meals[0]!.nutrients.protein_g! * 10) +
      Math.round(meals[1]!.nutrients.protein_g! * 10) +
      Math.round(meals[2]!.nutrients.protein_g! * 10);
    expect(total.nutrients.protein_g).toBe(expectedTenths / 10);
  });

  it('coverage.complete is false if any meal is incomplete', () => {
    const complete = computeRecipeNutrition(VEG_RICE_BOWL, 1);
    const incomplete = { ...complete, coverage: { ...complete.coverage, complete: false } };
    expect(sumNutrientTotals([complete, incomplete]).coverage.complete).toBe(false);
  });
});
