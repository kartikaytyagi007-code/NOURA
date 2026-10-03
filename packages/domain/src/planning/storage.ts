import { roundGrams } from '../nutrition/rounding.js';
import type { CatalogRecipe } from '../catalog/types.js';

/**
 * How a plan meal's `portions_snapshot` jsonb column is shaped (an object, per the M1 check
 * constraint `jsonb_typeof(portions_snapshot) in ('object', 'array')`). `grams_scale` is kept
 * alongside the portion so a later swap or regeneration recomputes nutrition at the same serving
 * size rather than silently resetting it; `portions` is exactly the `PortionRef[]` the API returns.
 */
export interface PortionRefLike {
  food_id: string | null;
  recipe_id: string | null;
  label: string;
  grams_min: number;
  grams_max: number;
}

export interface PortionsSnapshotStorage {
  grams_scale: number;
  portions: PortionRefLike[];
}

export function buildPortionsSnapshot(
  recipe: CatalogRecipe,
  gramsScale: number,
): PortionsSnapshotStorage {
  const totalGrams = roundGrams(
    recipe.ingredients.reduce((sum, ing) => sum + ing.edible_grams * gramsScale, 0),
  );
  return {
    grams_scale: gramsScale,
    portions: [
      {
        food_id: null,
        recipe_id: recipe.id,
        label: recipe.name,
        grams_min: totalGrams,
        grams_max: totalGrams,
      },
    ],
  };
}

export function gramsScaleOf(snapshot: unknown): number {
  const scale = (snapshot as Partial<PortionsSnapshotStorage> | null)?.grams_scale;
  return typeof scale === 'number' && scale > 0 ? scale : 1;
}

export function portionsOf(snapshot: unknown): PortionRefLike[] {
  const portions = (snapshot as Partial<PortionsSnapshotStorage> | null)?.portions;
  return Array.isArray(portions) ? portions : [];
}
