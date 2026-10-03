import {
  computeRecipeNutrition,
  sumNutrientTotals,
  type NutrientTotals,
} from '../catalog/nutrition.js';
import type { CatalogRecipe, MealSlot } from '../catalog/types.js';

/** Up to this many alternative recipes are offered for a swap (matches the contract's maxItems: 5). */
const MAX_CANDIDATES = 5;

export interface SwapCandidate {
  recipe: CatalogRecipe;
  grams_scale: number;
  nutrition: NutrientTotals;
  daily_totals_preview: NutrientTotals;
}

/**
 * Candidate recipes for one plan slot: every other eligible recipe tagged for that slot, each
 * recomputed at the same portion scale as the meal being replaced, with a preview of what the day's
 * totals would become if it were chosen (blueprint §7).
 */
export function swapCandidatesFor(input: {
  slot: MealSlot;
  eligibleRecipes: readonly CatalogRecipe[];
  currentRecipeId: string;
  gramsScale: number;
  otherMealsNutrition: readonly NutrientTotals[];
}): SwapCandidate[] {
  const pool = input.eligibleRecipes.filter(
    (r) => r.tags.includes(input.slot) && r.id !== input.currentRecipeId,
  );
  return pool.slice(0, MAX_CANDIDATES).map((recipe) => {
    const nutrition = computeRecipeNutrition(recipe, input.gramsScale);
    return {
      recipe,
      grams_scale: input.gramsScale,
      nutrition,
      daily_totals_preview: sumNutrientTotals([...input.otherMealsNutrition, nutrition]),
    };
  });
}
