import type { AnalyzedItemOut } from './review.js';
import type { NutrientTotals } from '../catalog/nutrition.js';

/**
 * Meal Balance v1 (blueprint §8 step 7, provisional — see docs/decisions.md). This is an explainable
 * product heuristic over the same deterministic, catalog-derived numbers already computed for the
 * meal; it is not a clinical or medical score and the contract's own schema description says so. It
 * is null, with `missing_data_message` set, whenever the totals are not fully known (an unmatched
 * item, or a matched item missing some nutrient) rather than scored against an incomplete picture.
 */
export const MEAL_BALANCE_POLICY_VERSION = 'meal-balance-v1-provisional';

const VEGETABLE_FRUIT_KEYWORDS = [
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

function isVegetableOrFruit(label: string): boolean {
  const lower = label.toLowerCase();
  return VEGETABLE_FRUIT_KEYWORDS.some((k) => lower.includes(k));
}

export interface MealBalanceComponentOut {
  key: 'protein' | 'fibre' | 'vegetable_fruit' | 'variety';
  score: number | null;
  max_score: 25;
  evidence: Record<string, unknown>;
}

export interface MealBalanceOut {
  score: number | null;
  policy_version: string;
  components: MealBalanceComponentOut[];
  missing_data_message: string | null;
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

  const proteinScore = Math.min(25, Math.max(0, Math.round(protein / 5)));
  const fibreScore = Math.min(25, Math.round(fibre * 2.5));
  const vegFruitScore = hasVegFruit ? 25 : 0;
  const varietyScore = Math.min(25, Math.round((matchedFoodCount / 4) * 25));

  const components: MealBalanceComponentOut[] = [
    { key: 'protein', score: proteinScore, max_score: 25, evidence: { protein_g: protein } },
    { key: 'fibre', score: fibreScore, max_score: 25, evidence: { fibre_g: fibre } },
    {
      key: 'vegetable_fruit',
      score: vegFruitScore,
      max_score: 25,
      evidence: { matched_vegetable_or_fruit: hasVegFruit },
    },
    {
      key: 'variety',
      score: varietyScore,
      max_score: 25,
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
