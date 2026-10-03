import type { AnalyzedItemOut } from './review.js';
import type { NutrientTotals } from '../catalog/nutrition.js';

/**
 * Meal Balance v1 (blueprint §7 "Meal Balance policy v1", §8 step 7; docs/decisions.md D-026, D-027).
 *
 * This is an explainable product heuristic over the same deterministic, catalog-derived numbers
 * already computed for the meal; it is not a clinical or medical score and the contract's own schema
 * description says so. It is null, with `missing_data_message` set, whenever the totals are not fully
 * known (an unmatched item, or a matched item missing some nutrient) rather than scored against an
 * incomplete picture.
 *
 * M4 shipped this under the name `meal-balance-v1-provisional` as a side effect of building the
 * meal-scan review flow. M5 (D-027) formalizes it as the real, documented `meal-balance-v1`: the
 * component math is unchanged (the M4 rules were already reasonable and match blueprint §7's four
 * equal 0-25 components), but every threshold now lives in the exported `MEAL_BALANCE_POLICY`
 * constant instead of being inlined, and each component also carries a qualitative `band` so the
 * Flutter results screen and the plate-fix recommender (`recommendations.ts`) can read "this
 * component is low/adequate/good" without re-deriving thresholds of their own.
 */
export const MEAL_BALANCE_POLICY_VERSION = 'meal-balance-v1';

/**
 * Documented inputs and rules for `meal-balance-v1` (blueprint §7). These are product/engineering
 * defaults, not clinically reviewed thresholds — the same provisional-until-reviewed status as the
 * target policy (D-018) and the catalog itself (D-025). They are read by both `computeMealBalance`
 * and `recommendations.ts`, so the two stay consistent by construction rather than by convention.
 */
export const MEAL_BALANCE_POLICY = {
  version: MEAL_BALANCE_POLICY_VERSION,
  /** Grams of protein per meal that earns the full 25 protein points (linear below that). */
  protein_g_for_max_score: 125,
  /** Grams of fibre per meal that earns the full 25 fibre points (linear below that). */
  fibre_g_for_max_score: 10,
  /** Distinct matched catalog foods that earns the full 25 variety points (linear below that). */
  distinct_foods_for_max_score: 4,
  /** Component score bands, as a fraction of max_score (25): low < 0.4, adequate < 0.8, else good. */
  band_thresholds: { low: 0.4, adequate: 0.8 },
} as const;

export const VEGETABLE_FRUIT_KEYWORDS = [
  'vegetable',
  'spinach',
  'tomato',
  'onion',
  'garlic',
  'potato',
  'mushroom',
  'banana',
  'apple',
  'fruit',
];

/**
 * Keyword match against a food/item label (blueprint §7's catalog has no dedicated vegetable/fruit
 * tag yet, same provisional-matching caveat as D-025's dislike filter — not NLP, a release-gate item).
 */
export function isVegetableOrFruit(label: string): boolean {
  const lower = label.toLowerCase();
  return VEGETABLE_FRUIT_KEYWORDS.some((k) => lower.includes(k));
}

export type MealBalanceComponentKey = 'protein' | 'fibre' | 'vegetable_fruit' | 'variety';
export type MealBalanceBand = 'low' | 'adequate' | 'good';

export interface MealBalanceComponentOut {
  key: MealBalanceComponentKey;
  score: number | null;
  max_score: 25;
  band: MealBalanceBand | null;
  evidence: Record<string, unknown>;
}

export interface MealBalanceOut {
  score: number | null;
  policy_version: string;
  components: MealBalanceComponentOut[];
  missing_data_message: string | null;
}

function bandFor(score: number, maxScore: number): MealBalanceBand {
  const fraction = maxScore === 0 ? 0 : score / maxScore;
  if (fraction < MEAL_BALANCE_POLICY.band_thresholds.low) return 'low';
  if (fraction < MEAL_BALANCE_POLICY.band_thresholds.adequate) return 'adequate';
  return 'good';
}

export function computeMealBalance(
  items: readonly AnalyzedItemOut[],
  totals: NutrientTotals,
): MealBalanceOut {
  if (items.length === 0 || !totals.coverage.complete) {
    return {
      score: null,
      policy_version: MEAL_BALANCE_POLICY_VERSION,
      components: [],
      missing_data_message:
        items.length === 0
          ? 'Add at least one item to see a balance score.'
          : "Some items don't have nutrition information yet, so a balance score isn't shown.",
    };
  }

  const protein = totals.nutrients.protein_g ?? 0;
  const fibre = totals.nutrients.fibre_g ?? 0;
  const matchedFoodCount = new Set(items.map((i) => i.food_id).filter((id): id is string => !!id))
    .size;
  const hasVegFruit = items.some((i) => isVegetableOrFruit(i.label));

  const proteinScore = Math.min(
    25,
    Math.max(0, Math.round((protein / MEAL_BALANCE_POLICY.protein_g_for_max_score) * 25)),
  );
  const fibreScore = Math.min(
    25,
    Math.max(0, Math.round((fibre / MEAL_BALANCE_POLICY.fibre_g_for_max_score) * 25)),
  );
  const vegFruitScore = hasVegFruit ? 25 : 0;
  const varietyScore = Math.min(
    25,
    Math.round((matchedFoodCount / MEAL_BALANCE_POLICY.distinct_foods_for_max_score) * 25),
  );

  const components: MealBalanceComponentOut[] = [
    {
      key: 'protein',
      score: proteinScore,
      max_score: 25,
      band: bandFor(proteinScore, 25),
      evidence: { protein_g: protein },
    },
    {
      key: 'fibre',
      score: fibreScore,
      max_score: 25,
      band: bandFor(fibreScore, 25),
      evidence: { fibre_g: fibre },
    },
    {
      key: 'vegetable_fruit',
      score: vegFruitScore,
      max_score: 25,
      band: bandFor(vegFruitScore, 25),
      evidence: { matched_vegetable_or_fruit: hasVegFruit },
    },
    {
      key: 'variety',
      score: varietyScore,
      max_score: 25,
      band: bandFor(varietyScore, 25),
      evidence: { distinct_catalog_foods: matchedFoodCount },
    },
  ];

  return {
    score: components.reduce((sum, c) => sum + (c.score ?? 0), 0),
    policy_version: MEAL_BALANCE_POLICY_VERSION,
    components,
    missing_data_message: null,
  };
}
