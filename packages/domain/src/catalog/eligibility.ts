import type { CatalogRecipe, DietType } from './types.js';

/**
 * Dietary, allergy, exclusion and dislike filtering (blueprint §7, docs/decisions.md D-025).
 * A recipe's diet compatibility and allergen safety are always derived fresh from its ingredients,
 * never trusted from a denormalized column, so a stale cache can never relax a safety constraint.
 */
export interface DietConstraints {
  diet_type: DietType | null;
  allergy_ids: readonly string[];
  exclusion_ids: readonly string[];
  dislikes: readonly string[];
}

/** A recipe is diet-safe only if EVERY ingredient is tagged safe for that diet. */
export function isDietSafe(recipe: CatalogRecipe, dietType: DietType | null): boolean {
  if (!dietType) return true;
  return recipe.ingredients.every((ing) => ing.food.diet_tags.includes(dietType));
}

/**
 * Allergen safety rule (blueprint §7): with any allergy constraint, an ingredient whose coverage is
 * not `complete` cannot be treated as safe, because its full allergen content is not known. This is
 * independent of whether its declared tags happen to overlap the user's allergies.
 */
export function isAllergySafe(recipe: CatalogRecipe, allergyIds: readonly string[]): boolean {
  if (allergyIds.length === 0) return true;
  const allergySet = new Set(allergyIds);
  return recipe.ingredients.every((ing) => {
    const { food } = ing;
    if (food.allergen_coverage !== 'complete') return false;
    return !food.allergen_tags.some((tag) => allergySet.has(tag));
  });
}

/** Food-group exclusions (e.g. "no chicken") apply to any ingredient carrying that tag. */
export function isExclusionSafe(recipe: CatalogRecipe, exclusionIds: readonly string[]): boolean {
  if (exclusionIds.length === 0) return true;
  const exclusionSet = new Set(exclusionIds);
  return recipe.ingredients.every(
    (ing) => !ing.food.food_group_tags.some((tag) => exclusionSet.has(tag)),
  );
}

/** Case-insensitive substring match against the recipe name and each ingredient's food name. */
export function isDislikeSafe(recipe: CatalogRecipe, dislikes: readonly string[]): boolean {
  if (dislikes.length === 0) return true;
  const haystacks = [recipe.name, ...recipe.ingredients.map((ing) => ing.food.name)].map((s) =>
    s.toLowerCase(),
  );
  const needles = dislikes.map((d) => d.toLowerCase().trim()).filter((d) => d.length > 0);
  return !needles.some((needle) => haystacks.some((hay) => hay.includes(needle)));
}

export function isRecipeEligible(recipe: CatalogRecipe, constraints: DietConstraints): boolean {
  return (
    isDietSafe(recipe, constraints.diet_type) &&
    isAllergySafe(recipe, constraints.allergy_ids) &&
    isExclusionSafe(recipe, constraints.exclusion_ids) &&
    isDislikeSafe(recipe, constraints.dislikes)
  );
}

export function filterEligibleRecipes(
  recipes: readonly CatalogRecipe[],
  constraints: DietConstraints,
): CatalogRecipe[] {
  return recipes.filter((r) => isRecipeEligible(r, constraints));
}
