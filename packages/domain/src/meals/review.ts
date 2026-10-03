import { AppError } from '../errors.js';
import { computeNutrition, sumNutrientTotals, type NutrientTotals } from '../catalog/nutrition.js';
import { matchFoodExact } from '../catalog/matching.js';
import type { CatalogFood } from '../catalog/types.js';

/**
 * Turns the user's confirmed/corrected plate (blueprint §8 steps 6-7) into calculated nutrition.
 * Every number here comes from `computeNutrition` against the approved catalog (D-025's rounding
 * rules); nothing from an AI provider ever reaches this function. An item whose food/recipe cannot be
 * resolved in the catalog is kept with `nutrients: null` and `uncertainty: 'high'` rather than guessed
 * at — this is the "unmatched, surfaced honestly" behaviour the ticket requires.
 */
export interface ServingInput {
  unit: string;
  quantity: number;
}

export interface ConfirmedItemInput {
  temporary_id?: string | null;
  food_id?: string | null;
  recipe_id?: string | null;
  label: string;
  grams?: number | null;
  serving?: ServingInput | null;
}

export interface SourceRef {
  source_id: string;
  source_name: string;
  source_version: string;
}

export interface AnalyzedItemOut {
  item_id: string;
  label: string;
  food_id: string | null;
  recipe_id: string | null;
  grams: number | null;
  grams_range: { min: number; max: number } | null;
  nutrients: NutrientTotals['nutrients'] | null;
  uncertainty: 'low' | 'medium' | 'high' | null;
}

function gramsFromServing(food: CatalogFood | null, serving: ServingInput): number | null {
  if (!food) return null;
  const conversion = food.serving_conversions.find(
    (c) => c.unit.toLowerCase() === serving.unit.toLowerCase(),
  );
  if (!conversion) return null;
  const midpoint = (conversion.grams_min + conversion.grams_max) / 2;
  return Math.round(midpoint * serving.quantity * 10) / 10;
}

function fieldError(index: number, field: string, code: string, message: string) {
  return { field: `body.items[${index}].${field}`, code, message };
}

/**
 * Resolves a batch of confirmed items against the catalog. Throws a single `VALIDATION_ERROR` with
 * one field error per offending item when grams cannot be determined (neither grams nor a convertible
 * serving was given) — the same shape M2/M3 use for batched field errors.
 */
export function resolveConfirmedItems(
  items: readonly ConfirmedItemInput[],
  catalogFoods: readonly CatalogFood[],
  idFor: (index: number) => string,
): AnalyzedItemOut[] {
  const fieldErrors: { field: string; code: string; message: string }[] = [];
  const resolved = items.map((item, index) => {
    const food = item.food_id
      ? (catalogFoods.find((f) => f.id === item.food_id) ?? null)
      : matchFoodExact(catalogFoods, item.label);

    let grams: number | null = item.grams ?? null;
    if (grams == null && item.serving) {
      grams = gramsFromServing(food, item.serving);
      if (grams == null) {
        fieldErrors.push(
          fieldError(
            index,
            'serving',
            'unconvertible',
            'This food has no known conversion for that unit; provide grams instead.',
          ),
        );
      }
    }
    if (grams == null && !item.serving) {
      fieldErrors.push(fieldError(index, 'grams', 'required', 'Provide grams or a serving.'));
    }

    const recipeId = item.recipe_id ?? null;
    const matched = !!food && !recipeId;
    const totals = matched && grams != null ? computeNutrition([{ food: food!, grams }]) : null;

    return {
      item_id: idFor(index),
      label: item.label,
      food_id: food?.id ?? null,
      recipe_id: recipeId,
      grams: grams,
      grams_range: null,
      nutrients: totals?.nutrients ?? null,
      // Unmatched items are explicitly high-uncertainty; the user typed/accepted a label the
      // approved catalog has no entry for, so no nutrition claim can be made for it.
      uncertainty: matched
        ? totals?.coverage.complete
          ? 'low'
          : 'high'
        : food || recipeId
          ? null
          : 'high',
    } satisfies AnalyzedItemOut;
  });

  if (fieldErrors.length > 0) {
    throw new AppError('VALIDATION_ERROR', 'Some items could not be resolved.', { fieldErrors });
  }
  return resolved;
}

/** Sums already-rounded per-item totals (D-025: never re-derive from raw grams or re-sum floats). */
export function sumAnalyzedNutrition(items: readonly AnalyzedItemOut[]): NutrientTotals {
  if (items.length === 0) {
    return {
      nutrients: {
        energy_kcal: null,
        protein_g: null,
        carbohydrate_g: null,
        fat_g: null,
        fibre_g: null,
      },
      coverage: { items_total: 0, items_with_nutrition: 0, complete: false },
    };
  }
  return sumNutrientTotals(
    items.map((item) => ({
      nutrients: item.nutrients ?? {
        energy_kcal: null,
        protein_g: null,
        carbohydrate_g: null,
        fat_g: null,
        fibre_g: null,
      },
      coverage: {
        items_total: 1,
        items_with_nutrition: item.nutrients ? 1 : 0,
        complete: item.nutrients !== null,
      },
    })),
  );
}
