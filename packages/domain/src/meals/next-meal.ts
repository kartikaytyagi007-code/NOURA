import { computeRecipeNutrition, type NutrientTotals } from '../catalog/nutrition.js';
import type { CatalogRecipe, MealSlot } from '../catalog/types.js';
import { buildPortionsSnapshot, type PortionRefLike } from '../planning/storage.js';

/**
 * "What Should I Eat Next?" (blueprint §9 "next meal", §16 M6; docs/decisions.md D-028). A pure,
 * deterministic function over already-loaded data: today's active-plan slots, which slots are
 * already logged, and the eligible catalog pool (the same diet/allergy/exclusion/dislike filtering
 * M3/M5 already apply — callers pass an already-filtered `eligibleRecipes`, never do their own
 * laxer check). No AI model is involved: picking and ranking is plain, explainable logic over real
 * numbers.
 */

/** Time-of-day order used both to pick "the next" slot and to order options for a requested one. */
export const SLOT_ORDER: readonly MealSlot[] = ['breakfast', 'lunch', 'dinner', 'snack'];

export interface PlannedSlotInfo {
  slot: MealSlot;
  plan_meal_id: string;
  plan_meal_revision: number;
  recipe: CatalogRecipe;
  grams_scale: number;
  nutrition: NutrientTotals;
}

/**
 * 'plan' marks the option that is already the active plan's recipe for this slot; 'catalog' marks a
 * suggestion. Whether an option can be swapped into a plan slot is `plan_meal_id !== null`, not the
 * source — an alternative to an already-planned slot carries that same `plan_meal_id` so it can be
 * swapped in directly.
 */
export type NextMealSource = 'plan' | 'catalog';

export interface NextMealOptionOut {
  source: NextMealSource;
  /** The plan slot this option would fill via a `swap` action; null for a catalog-only option. */
  plan_meal_id: string | null;
  /** The plan slot's current revision, required as `target_plan_meal_id`'s `expected_revision` for a swap. */
  plan_meal_revision: number | null;
  /** The recipe id a `next-meal` action (add/swap) should send back as `candidate_id`. */
  candidate_id: string;
  recipe: { id: string; name: string };
  portions: PortionRefLike[];
  nutrition: NutrientTotals;
  reason: string;
}

export interface NextMealResult {
  slot: MealSlot;
  logged_meals: number;
  limited_context: boolean;
  explanation: string | null;
  options: NextMealOptionOut[];
}

type DailyNutrientKey = 'protein_g' | 'fibre_g';

function nutrientLabel(key: DailyNutrientKey): string {
  return key === 'protein_g' ? 'protein' : 'fibre';
}

/**
 * Which of today's two tracked macros is furthest below its daily target, as a fraction of target.
 * Returns null whenever either input is unusable — today's coverage is incomplete, there is no
 * target to compare against, or neither macro is actually behind — so a recommendation never claims
 * a gap it cannot support (the ticket's "only state a gap claim the data supports" constraint,
 * mirrored here for next-meal reasons and in `nutrition-patterns.ts` for weekly patterns).
 */
export function weakestDailyGap(
  todayTotals: NutrientTotals,
  dailyTargets: { protein_g: number | null; fibre_g: number | null } | null,
): DailyNutrientKey | null {
  if (!todayTotals.coverage.complete || !dailyTargets) return null;
  const ratios: Partial<Record<DailyNutrientKey, number>> = {};
  if (dailyTargets.protein_g && todayTotals.nutrients.protein_g != null) {
    ratios.protein_g = todayTotals.nutrients.protein_g / dailyTargets.protein_g;
  }
  if (dailyTargets.fibre_g && todayTotals.nutrients.fibre_g != null) {
    ratios.fibre_g = todayTotals.nutrients.fibre_g / dailyTargets.fibre_g;
  }
  const entries = Object.entries(ratios) as [DailyNutrientKey, number][];
  const behind = entries.filter(([, ratio]) => ratio < 1);
  if (behind.length === 0) return null;
  return behind.sort((a, b) => a[1] - b[1])[0]![0];
}

function toOption(
  recipe: CatalogRecipe,
  source: NextMealSource,
  planMealId: string | null,
  planMealRevision: number | null,
  nutrition: NutrientTotals,
  gramsScale: number,
  reason: string,
): NextMealOptionOut {
  return {
    source,
    plan_meal_id: planMealId,
    plan_meal_revision: planMealRevision,
    candidate_id: recipe.id,
    recipe: { id: recipe.id, name: recipe.name },
    portions: buildPortionsSnapshot(recipe, gramsScale).portions,
    nutrition,
    reason,
  };
}

/** Deterministic tie-break so repeated calls with identical inputs return identical ordering. */
function byIdAsc(a: CatalogRecipe, b: CatalogRecipe): number {
  return a.id < b.id ? -1 : a.id > b.id ? 1 : 0;
}

export interface BuildNextMealInput {
  /** The user's requested slot, or null to let the engine pick the next unlogged one. */
  requestedSlot: MealSlot | null;
  /** Today's active-plan slots (any status), reloaded fresh under the caller's own transaction. */
  plannedSlots: readonly PlannedSlotInfo[];
  /** Slots that already have at least one meal log today. */
  loggedSlots: ReadonlySet<MealSlot>;
  loggedMealsCount: number;
  /** Today's confirmed intake so far, honestly summed (null/incomplete propagate, never zero). */
  todayTotals: NutrientTotals;
  /** Already filtered by diet/allergy/exclusion/dislike (`filterEligibleRecipes`). */
  eligibleRecipes: readonly CatalogRecipe[];
  /** The caller's daily protein/fibre targets, when a target snapshot with real numbers exists. */
  dailyTargets: { protein_g: number | null; fibre_g: number | null } | null;
  /** True when this date/slot was explicitly dismissed (D-028); suppresses options, not history. */
  dismissed: boolean;
}

/**
 * Builds the next-meal recommendation. `limited_context` is true whenever today's intake isn't a
 * reliable picture (nothing logged yet, or an unmatched/uncertain item makes the totals incomplete)
 * — the explanation says so rather than silently reasoning from a partial or zeroed baseline.
 */
export function buildNextMealRecommendation(input: BuildNextMealInput): NextMealResult {
  const candidateSlots = input.requestedSlot ? [input.requestedSlot] : SLOT_ORDER;
  const targetSlot = candidateSlots.find((s) => !input.loggedSlots.has(s));
  const limitedContext = input.loggedMealsCount === 0 || !input.todayTotals.coverage.complete;

  if (!targetSlot) {
    return {
      slot: input.requestedSlot ?? SLOT_ORDER[SLOT_ORDER.length - 1]!,
      logged_meals: input.loggedMealsCount,
      limited_context: limitedContext,
      explanation: input.requestedSlot
        ? `You've already logged a meal for ${input.requestedSlot} today.`
        : "You've already logged meals for every slot today.",
      options: [],
    };
  }

  if (input.dismissed) {
    return {
      slot: targetSlot,
      logged_meals: input.loggedMealsCount,
      limited_context: limitedContext,
      explanation: 'You dismissed this recommendation for today. Check your plan or diary instead.',
      options: [],
    };
  }

  const weakest = weakestDailyGap(input.todayTotals, input.dailyTargets);
  const pool = input.eligibleRecipes.filter((r) => r.tags.includes(targetSlot));
  const planned = input.plannedSlots.find((p) => p.slot === targetSlot);

  const options: NextMealOptionOut[] = [];
  let explanation: string | null = null;

  if (planned) {
    options.push(
      toOption(
        planned.recipe,
        'plan',
        planned.plan_meal_id,
        planned.plan_meal_revision,
        planned.nutrition,
        planned.grams_scale,
        `This is the next unlogged slot in your plan (${targetSlot}).`,
      ),
    );
    const alternatives = pool
      .filter((r) => r.id !== planned.recipe.id)
      .sort(byIdAsc)
      .slice(0, 2);
    for (const alt of alternatives) {
      // Alternatives target the SAME plan slot, so each one is directly swap-able in place.
      options.push(
        toOption(
          alt,
          'catalog',
          planned.plan_meal_id,
          planned.plan_meal_revision,
          computeRecipeNutrition(alt, 1),
          1,
          `A suitable alternative for ${targetSlot} if you'd rather swap your plan.`,
        ),
      );
    }
  } else {
    let sorted = [...pool].sort(byIdAsc);
    if (weakest) {
      sorted = [...sorted].sort((a, b) => {
        const na = computeRecipeNutrition(a, 1).nutrients[weakest] ?? 0;
        const nb = computeRecipeNutrition(b, 1).nutrients[weakest] ?? 0;
        if (nb !== na) return nb - na;
        return byIdAsc(a, b);
      });
    }
    const primary = sorted[0];
    if (primary) {
      const reason = weakest
        ? `No planned meal for ${targetSlot}; ${primary.name} is high in ${nutrientLabel(weakest)}, which your day is currently low on.`
        : `No planned meal for ${targetSlot}; ${primary.name} fits your diet and preferences.`;
      options.push(
        toOption(primary, 'catalog', null, null, computeRecipeNutrition(primary, 1), 1, reason),
      );
      for (const alt of sorted.slice(1, 3)) {
        options.push(
          toOption(
            alt,
            'catalog',
            null,
            null,
            computeRecipeNutrition(alt, 1),
            1,
            `A suitable alternative for ${targetSlot}.`,
          ),
        );
      }
    } else {
      explanation = `No eligible catalog option is available for ${targetSlot} right now.`;
    }
  }

  if (limitedContext && !explanation) {
    explanation =
      input.loggedMealsCount === 0
        ? "You haven't logged any meals yet today, so this recommendation has limited context."
        : "Some of today's logged items don't have nutrition information yet, so this recommendation has limited context.";
  }

  return {
    slot: targetSlot,
    logged_meals: input.loggedMealsCount,
    limited_context: limitedContext,
    explanation,
    options,
  };
}
