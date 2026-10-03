import { roundEnergy, roundGrams, sumEnergy, sumGrams } from '../nutrition/rounding.js';
import type { CatalogIngredient, CatalogRecipe } from './types.js';

export interface Nutrients {
  energy_kcal: number | null;
  protein_g: number | null;
  carbohydrate_g: number | null;
  fat_g: number | null;
  fibre_g: number | null;
}

export interface Coverage {
  items_total: number;
  items_with_nutrition: number;
  complete: boolean;
}

export interface NutrientTotals {
  nutrients: Nutrients;
  coverage: Coverage;
}

const EMPTY_NUTRIENTS: Nutrients = {
  energy_kcal: null,
  protein_g: null,
  carbohydrate_g: null,
  fat_g: null,
  fibre_g: null,
};

/**
 * Sums one macro across ingredients at their (possibly scaled) grams. Unknown stays unknown: if any
 * ingredient is missing the value, the total for that nutrient is null rather than silently treating
 * the missing amount as zero (M1 catalog comment, blueprint §7).
 */
function sumMacro(
  ingredients: readonly { grams: number; perHundred: number | null }[],
  round: (v: number) => number,
  sum: (values: readonly number[]) => number,
): number | null {
  if (ingredients.some((i) => i.perHundred === null)) return null;
  const contributions = ingredients.map((i) => round((i.perHundred as number) * (i.grams / 100)));
  return sum(contributions);
}

/** Nutrition for a set of ingredients at explicit (already-scaled) gram amounts. */
export function computeNutrition(
  ingredients: readonly { food: CatalogIngredient['food']; grams: number }[],
): NutrientTotals {
  const withNutrition = ingredients.filter((i) => i.food.energy_kcal_per_100g !== null);
  const nutrients: Nutrients =
    ingredients.length === 0
      ? EMPTY_NUTRIENTS
      : {
          energy_kcal: sumMacro(
            ingredients.map((i) => ({ grams: i.grams, perHundred: i.food.energy_kcal_per_100g })),
            roundEnergy,
            sumEnergy,
          ),
          protein_g: sumMacro(
            ingredients.map((i) => ({ grams: i.grams, perHundred: i.food.protein_g_per_100g })),
            roundGrams,
            sumGrams,
          ),
          carbohydrate_g: sumMacro(
            ingredients.map((i) => ({
              grams: i.grams,
              perHundred: i.food.carbohydrate_g_per_100g,
            })),
            roundGrams,
            sumGrams,
          ),
          fat_g: sumMacro(
            ingredients.map((i) => ({ grams: i.grams, perHundred: i.food.fat_g_per_100g })),
            roundGrams,
            sumGrams,
          ),
          fibre_g: sumMacro(
            ingredients.map((i) => ({ grams: i.grams, perHundred: i.food.fibre_g_per_100g })),
            roundGrams,
            sumGrams,
          ),
        };
  return {
    nutrients,
    coverage: {
      items_total: ingredients.length,
      items_with_nutrition: withNutrition.length,
      complete: ingredients.length > 0 && withNutrition.length === ingredients.length,
    },
  };
}

/** Nutrition totals for a whole recipe at a uniform portion scale (1 = the recipe's base quantities). */
export function computeRecipeNutrition(recipe: CatalogRecipe, scale = 1): NutrientTotals {
  return computeNutrition(
    recipe.ingredients.map((ing) => ({ food: ing.food, grams: ing.edible_grams * scale })),
  );
}

/**
 * Sums a day's already-rounded meal totals. Each input must itself be the output of
 * computeNutrition/computeRecipeNutrition so every value summed here is already rounded; this
 * function never re-derives a nutrient from raw ingredients, which is what guarantees the sum
 * reconciles exactly with the meals it is built from.
 */
export function sumNutrientTotals(meals: readonly NutrientTotals[]): NutrientTotals {
  const pick = (key: keyof Nutrients, sum: (v: readonly number[]) => number): number | null => {
    const values = meals.map((m) => m.nutrients[key]);
    if (values.some((v) => v === null)) return null;
    return sum(values as number[]);
  };
  const itemsTotal = meals.reduce((t, m) => t + m.coverage.items_total, 0);
  const itemsWithNutrition = meals.reduce((t, m) => t + m.coverage.items_with_nutrition, 0);
  return {
    nutrients: {
      energy_kcal: pick('energy_kcal', sumEnergy),
      protein_g: pick('protein_g', sumGrams),
      carbohydrate_g: pick('carbohydrate_g', sumGrams),
      fat_g: pick('fat_g', sumGrams),
      fibre_g: pick('fibre_g', sumGrams),
    },
    coverage: {
      items_total: itemsTotal,
      items_with_nutrition: itemsWithNutrition,
      complete: meals.every((m) => m.coverage.complete),
    },
  };
}
