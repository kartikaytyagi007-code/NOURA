import { filterEligibleFoods, type DietConstraints } from '../catalog/eligibility.js';
import { computeNutrition, sumNutrientTotals, type NutrientTotals } from '../catalog/nutrition.js';
import type { CatalogFood } from '../catalog/types.js';
import { computeMealBalance, isVegetableOrFruit, type MealBalanceOut } from './balance.js';
import type { AnalyzedItemOut } from './review.js';

/**
 * "Fix My Plate" keep/reduce/add recommendations (blueprint §8 step 7, §16 M5; docs/decisions.md
 * D-027). Deterministic, backend-only, catalog-grounded: no AI model is involved anywhere in this
 * file, and every suggested catalog food is filtered through the same diet/allergy/exclusion/dislike
 * eligibility rules M3 already uses for recipes (`catalog/eligibility.ts`), applied here to bare
 * foods via `filterEligibleFoods` — never a looser check just because it's a single suggested item.
 *
 * A suggestion is only ever drawn from foods with complete macro data (energy/protein/carb/fat/fibre
 * all non-null), so the "projected" scenario attached to every action is always a real calculation
 * from catalog numbers, never an estimate dressed up as one.
 */

export type PlateActionType = 'keep' | 'reduce' | 'add' | 'replace';

export interface PlateActionOut {
  type: PlateActionType;
  item_id: string | null;
  catalog_food_id: string | null;
  proposed_grams: number | null;
  reason: string;
  projected: {
    totals: NutrientTotals;
    meal_balance: MealBalanceOut;
  };
}

export interface PlateFixesResult {
  fixes: PlateActionOut[];
  after_changes: {
    totals: NutrientTotals;
    meal_balance: MealBalanceOut;
    assumptions: string[];
  };
}

/** A food can only ground a projection when every macro it contributes is actually known. */
function hasCompleteMacros(food: CatalogFood): boolean {
  return (
    food.energy_kcal_per_100g !== null &&
    food.protein_g_per_100g !== null &&
    food.carbohydrate_g_per_100g !== null &&
    food.fat_g_per_100g !== null &&
    food.fibre_g_per_100g !== null
  );
}

/** Recomputes totals + Meal Balance for a hypothetical item list, without mutating the input. */
function projectFor(items: readonly AnalyzedItemOut[]): {
  totals: NutrientTotals;
  meal_balance: MealBalanceOut;
} {
  const totals =
    items.length === 0
      ? {
          nutrients: emptyNutrients(),
          coverage: { items_total: 0, items_with_nutrition: 0, complete: false },
        }
      : sumNutrientTotals(
          items.map((item) => ({
            nutrients: item.nutrients ?? emptyNutrients(),
            coverage: {
              items_total: 1,
              items_with_nutrition: item.nutrients ? 1 : 0,
              complete: item.nutrients !== null,
            },
          })),
        );
  return { totals, meal_balance: computeMealBalance(items, totals) };
}

function emptyNutrients() {
  return {
    energy_kcal: null,
    protein_g: null,
    carbohydrate_g: null,
    fat_g: null,
    fibre_g: null,
  };
}

function itemWithGrams(item: AnalyzedItemOut, food: CatalogFood, grams: number): AnalyzedItemOut {
  const totals = computeNutrition([{ food, grams }]);
  return {
    ...item,
    grams,
    nutrients: totals.nutrients,
    uncertainty: totals.coverage.complete ? 'low' : 'high',
  };
}

function newItemFromFood(food: CatalogFood, grams: number, idFor: () => string): AnalyzedItemOut {
  const totals = computeNutrition([{ food, grams }]);
  return {
    item_id: idFor(),
    label: food.name,
    food_id: food.id,
    recipe_id: null,
    grams,
    grams_range: null,
    nutrients: totals.nutrients,
    uncertainty: totals.coverage.complete ? 'low' : 'high',
  };
}

/** The default suggested gram amount for an "add" suggestion, by what it's addressing. */
const ADD_GRAMS = {
  vegetable_fruit: 80,
  fibre: 40,
  protein: 100,
  variety: 60,
} as const;

/** An item "has nutrient density" roughly like a refined-carb staple: low protein, low fibre. */
function isLowNutrientDensity(food: CatalogFood): boolean {
  return (
    (food.protein_g_per_100g ?? 0) < 5 &&
    (food.fibre_g_per_100g ?? 0) < 2 &&
    (food.energy_kcal_per_100g ?? 0) > 0
  );
}

function roundGrams(grams: number): number {
  return Math.max(10, Math.round(grams / 5) * 5);
}

/**
 * Builds up to three deterministic keep/reduce/add actions for a confirmed, calculated meal, plus a
 * combined "after changes" scenario applying all of them together. Each piece is independently
 * explainable: `reason` names the evidence, and `projected`/`after_changes.assumptions` state exactly
 * what was assumed (which item was reduced to what, which food was added at what weight).
 *
 * Returns fewer than three fixes when there is no safe, catalog-grounded candidate for a given type
 * (e.g. nothing to "reduce" in an already well-balanced meal) rather than inventing a weak one.
 */
export function createPlateFixes(
  items: readonly AnalyzedItemOut[],
  totals: NutrientTotals,
  catalogFoods: readonly CatalogFood[],
  constraints: DietConstraints,
  idFor: () => string,
): PlateFixesResult {
  const baseline = computeMealBalance(items, totals);
  const fixes: PlateActionOut[] = [];
  const assumptions: string[] = [];
  let working = items;

  // Eligible suggestion pool: same diet/allergy/exclusion/dislike rules as M3 recipes, restricted to
  // foods with complete macro data and not already present in the meal (by food_id).
  const presentFoodIds = new Set(items.map((i) => i.food_id).filter((id): id is string => !!id));
  const pool = filterEligibleFoods(catalogFoods, constraints).filter(
    (f) => hasCompleteMacros(f) && !presentFoodIds.has(f.id),
  );

  // --- keep: the matched item contributing most to the meal's strongest component -----------------
  const matchedItems = items.filter((i) => i.food_id && i.nutrients && i.uncertainty !== 'high');
  if (matchedItems.length > 0) {
    const strongest = [...matchedItems].sort(
      (a, b) => (b.nutrients?.protein_g ?? 0) - (a.nutrients?.protein_g ?? 0),
    )[0]!;
    fixes.push({
      type: 'keep',
      item_id: strongest.item_id,
      catalog_food_id: strongest.food_id,
      proposed_grams: strongest.grams,
      reason: `${strongest.label} is a solid contributor to this meal (${strongest.nutrients?.protein_g ?? 0} g protein) — keep this portion.`,
      projected: projectFor(working),
    });
  }

  // --- reduce: the largest, lowest-nutrient-density matched item ----------------------------------
  const reduceCandidates = items.filter(
    (i) =>
      i.food_id &&
      i.grams != null &&
      i.grams > 0 &&
      catalogFoods.find((f) => f.id === i.food_id && isLowNutrientDensity(f)),
  );
  if (reduceCandidates.length > 0) {
    const toReduce = [...reduceCandidates].sort((a, b) => (b.grams ?? 0) - (a.grams ?? 0))[0]!;
    const food = catalogFoods.find((f) => f.id === toReduce.food_id)!;
    const newGrams = roundGrams((toReduce.grams ?? 0) * 0.6);
    const reducedItem = itemWithGrams(toReduce, food, newGrams);
    const scenario = working.map((i) => (i.item_id === toReduce.item_id ? reducedItem : i));
    fixes.push({
      type: 'reduce',
      item_id: toReduce.item_id,
      catalog_food_id: toReduce.food_id,
      proposed_grams: newGrams,
      reason: `${toReduce.label} is low in protein and fibre for its portion; reducing from ${toReduce.grams}g to ${newGrams}g makes room for more balanced foods.`,
      projected: projectFor(scenario),
    });
    assumptions.push(
      `Assumes ${toReduce.label} is reduced from ${toReduce.grams}g to ${newGrams}g; all other items unchanged.`,
    );
    working = scenario;
  }

  // --- add: addresses the weakest scored component, from the eligible, complete-data pool --------
  if (baseline.components.length > 0 && pool.length > 0) {
    const weakest = [...baseline.components].sort((a, b) => (a.score ?? 0) - (b.score ?? 0))[0]!;
    let candidate: CatalogFood | undefined;
    let grams: number;
    let reason: string;
    if (weakest.key === 'vegetable_fruit') {
      candidate = pool.find((f) => isVegetableOrFruit(f.name));
      grams = ADD_GRAMS.vegetable_fruit;
      reason = `This meal has no clear vegetable or fruit; adding ${candidate?.name ?? 'one'} improves variety and fibre.`;
    } else if (weakest.key === 'fibre') {
      candidate = [...pool].sort(
        (a, b) => (b.fibre_g_per_100g ?? 0) - (a.fibre_g_per_100g ?? 0),
      )[0];
      grams = ADD_GRAMS.fibre;
      reason = `Fibre is low for this meal; ${candidate?.name ?? 'this food'} is a strong fibre source.`;
    } else if (weakest.key === 'protein') {
      candidate = [...pool].sort(
        (a, b) => (b.protein_g_per_100g ?? 0) - (a.protein_g_per_100g ?? 0),
      )[0];
      grams = ADD_GRAMS.protein;
      reason = `Protein is low for this meal; ${candidate?.name ?? 'this food'} would help close the gap.`;
    } else {
      candidate =
        pool.find((f) => isVegetableOrFruit(f.name)) ??
        [...pool].sort((a, b) => (b.fibre_g_per_100g ?? 0) - (a.fibre_g_per_100g ?? 0))[0];
      grams = ADD_GRAMS.variety;
      reason = `Adding ${candidate?.name ?? 'a different food group'} brings more variety to this meal.`;
    }
    if (candidate) {
      const newItem = newItemFromFood(candidate, grams, idFor);
      const scenario = [...working, newItem];
      fixes.push({
        type: 'add',
        item_id: null,
        catalog_food_id: candidate.id,
        proposed_grams: grams,
        reason,
        projected: projectFor(scenario),
      });
      assumptions.push(
        `Assumes adding ${grams}g of ${candidate.name} to this meal, unchanged otherwise.`,
      );
      working = scenario;
    }
  }

  return {
    fixes: fixes.slice(0, 3),
    after_changes: { ...projectFor(working), assumptions },
  };
}
