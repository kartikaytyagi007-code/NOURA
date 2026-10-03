import {
  computeRecipeNutrition,
  sumNutrientTotals,
  type NutrientTotals,
} from '../catalog/nutrition.js';
import type { CatalogRecipe, MealSlot } from '../catalog/types.js';

/**
 * Deterministic diet-plan generation (blueprint §7, docs/decisions.md D-025). Pure and seed-free:
 * the same eligible-recipe pool, start date and target always produce the same plan, which keeps
 * generation debuggable and testable without a model or randomness.
 *
 * Each slot's base portion is scaled toward an even share of the (optional) daily energy target,
 * clamped to a plausible range, so the pipeline genuinely exercises portion-scaling math rather than
 * always emitting the catalog's base serving. With no usable point energy target (for example
 * `basis: range`, D-024), meals are served at their base portion and the plan still generates
 * honestly, never fabricating a number to scale against.
 */

export interface PlanSlotSpec {
  slot: MealSlot;
  slot_ordinal: number;
}

/** The catalog only tags recipes for these four slots (blueprint §7). */
export function slotsForMealsPerDay(mealsPerDay: number | null): PlanSlotSpec[] {
  const base: PlanSlotSpec[] = [
    { slot: 'breakfast', slot_ordinal: 1 },
    { slot: 'lunch', slot_ordinal: 1 },
    { slot: 'dinner', slot_ordinal: 1 },
  ];
  if (mealsPerDay !== null && mealsPerDay <= 3) return base;
  return [...base, { slot: 'snack', slot_ordinal: 1 }];
}

/** Minimum and maximum portion-scale factors: half to one-and-three-quarters of the base recipe. */
const MIN_SCALE = 0.5;
const MAX_SCALE = 1.75;

function clamp(value: number, min: number, max: number): number {
  return Math.min(max, Math.max(min, value));
}

export interface GeneratedMeal {
  date: string;
  slot: MealSlot;
  slot_ordinal: number;
  recipe: CatalogRecipe;
  grams_scale: number;
  nutrition: NutrientTotals;
}

export interface GeneratedDay {
  date: string;
  meals: GeneratedMeal[];
  totals: NutrientTotals;
}

export interface GeneratedPlan {
  days: GeneratedDay[];
}

export type PlanGenerationResult =
  { ok: true; plan: GeneratedPlan } | { ok: false; reason: 'infeasible_slot'; slot: MealSlot };

export interface GeneratePlanInput {
  /** ISO date (UTC) the plan's first day starts on. */
  startsOn: string;
  days?: number;
  mealsPerDay: number | null;
  eligibleRecipes: readonly CatalogRecipe[];
  /** Null when no single point energy target is available (D-024's `basis: range`). */
  targetEnergyKcal: number | null;
}

function addDays(isoDate: string, days: number): string {
  const d = new Date(`${isoDate}T00:00:00.000Z`);
  d.setUTCDate(d.getUTCDate() + days);
  return d.toISOString().slice(0, 10);
}

function poolForSlot(recipes: readonly CatalogRecipe[], slot: MealSlot): CatalogRecipe[] {
  return recipes.filter((r) => r.tags.includes(slot));
}

export function generatePlan(input: GeneratePlanInput): PlanGenerationResult {
  const days = input.days ?? 7;
  const slots = slotsForMealsPerDay(input.mealsPerDay);
  const pools = new Map<MealSlot, CatalogRecipe[]>();
  for (const spec of slots) {
    const pool = poolForSlot(input.eligibleRecipes, spec.slot);
    if (pool.length === 0) return { ok: false, reason: 'infeasible_slot', slot: spec.slot };
    pools.set(spec.slot, pool);
  }

  const perMealTarget =
    input.targetEnergyKcal !== null ? input.targetEnergyKcal / slots.length : null;

  const generatedDays: GeneratedDay[] = [];
  for (let dayIndex = 0; dayIndex < days; dayIndex += 1) {
    const date = addDays(input.startsOn, dayIndex);
    const meals: GeneratedMeal[] = slots.map((spec, slotIndex) => {
      const pool = pools.get(spec.slot) as CatalogRecipe[];
      // Deterministic rotation: varies by day and slot without randomness, and wraps to reuse the
      // pool once every recipe in it has been offered. pool.length > 0 is guaranteed above.
      const recipe = pool[(dayIndex + slotIndex) % pool.length] as CatalogRecipe;
      const base = computeRecipeNutrition(recipe, 1);
      const baseEnergy = base.nutrients.energy_kcal;
      const scale =
        perMealTarget !== null && baseEnergy !== null && baseEnergy > 0
          ? clamp(perMealTarget / baseEnergy, MIN_SCALE, MAX_SCALE)
          : 1;
      const nutrition = scale === 1 ? base : computeRecipeNutrition(recipe, scale);
      return {
        date,
        slot: spec.slot,
        slot_ordinal: spec.slot_ordinal,
        recipe,
        grams_scale: scale,
        nutrition,
      };
    });
    generatedDays.push({
      date,
      meals,
      totals: sumDayTotals(meals),
    });
  }
  return { ok: true, plan: { days: generatedDays } };
}

function sumDayTotals(meals: readonly GeneratedMeal[]): NutrientTotals {
  return sumNutrientTotals(meals.map((m) => m.nutrition));
}
