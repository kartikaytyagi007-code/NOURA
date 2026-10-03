import { describe, expect, it } from 'vitest';
import { computeRecipeNutrition } from '../catalog/nutrition.js';
import { PANEER_BOWL, VEG_RICE_BOWL } from '../catalog/test-fixtures.js';
import { swapCandidatesFor } from './swap.js';

describe('swapCandidatesFor', () => {
  it('offers other eligible recipes for the same slot, excluding the current one', () => {
    const candidates = swapCandidatesFor({
      slot: 'lunch',
      eligibleRecipes: [VEG_RICE_BOWL, PANEER_BOWL],
      currentRecipeId: VEG_RICE_BOWL.id,
      gramsScale: 1,
      otherMealsNutrition: [],
    });
    expect(candidates).toHaveLength(1);
    expect(candidates[0]!.recipe.id).toBe(PANEER_BOWL.id);
  });

  it('previews the day total as if the candidate replaced the current meal', () => {
    const otherMeal = computeRecipeNutrition(PANEER_BOWL, 1);
    const candidates = swapCandidatesFor({
      slot: 'lunch',
      eligibleRecipes: [VEG_RICE_BOWL, PANEER_BOWL],
      currentRecipeId: PANEER_BOWL.id,
      gramsScale: 1,
      otherMealsNutrition: [otherMeal],
    });
    const candidate = candidates[0]!;
    const expectedEnergy =
      (otherMeal.nutrients.energy_kcal ?? 0) + (candidate.nutrition.nutrients.energy_kcal ?? 0);
    expect(candidate.daily_totals_preview.nutrients.energy_kcal).toBe(expectedEnergy);
  });

  it('caps candidates at 5', () => {
    const many = Array.from({ length: 8 }, (_, i) => ({ ...VEG_RICE_BOWL, id: `r-${i}` }));
    const candidates = swapCandidatesFor({
      slot: 'lunch',
      eligibleRecipes: many,
      currentRecipeId: 'r-0',
      gramsScale: 1,
      otherMealsNutrition: [],
    });
    expect(candidates).toHaveLength(5);
  });
});
