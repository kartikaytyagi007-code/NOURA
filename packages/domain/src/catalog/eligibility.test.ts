import { describe, expect, it } from 'vitest';
import { filterEligibleRecipes, isRecipeEligible } from './eligibility.js';
import {
  CHICKEN_BOWL,
  EGG_BREAKFAST,
  MYSTERY_RECIPE,
  PANEER_BOWL,
  PEANUT_SNACK,
  VEG_RICE_BOWL,
  ALL_RECIPES,
} from './test-fixtures.js';

const NO_CONSTRAINTS = { diet_type: null, allergy_ids: [], exclusion_ids: [], dislikes: [] };

describe('diet type filtering (blueprint §7)', () => {
  it('vegan excludes dairy, egg and meat', () => {
    const eligible = filterEligibleRecipes(ALL_RECIPES, { ...NO_CONSTRAINTS, diet_type: 'vegan' });
    expect(eligible.map((r) => r.id)).not.toContain(PANEER_BOWL.id);
    expect(eligible.map((r) => r.id)).not.toContain(EGG_BREAKFAST.id);
    expect(eligible.map((r) => r.id)).not.toContain(CHICKEN_BOWL.id);
    expect(eligible.map((r) => r.id)).toContain(VEG_RICE_BOWL.id);
  });

  it('vegetarian permits dairy but excludes egg and meat', () => {
    const eligible = filterEligibleRecipes(ALL_RECIPES, {
      ...NO_CONSTRAINTS,
      diet_type: 'vegetarian',
    });
    expect(eligible.map((r) => r.id)).toContain(PANEER_BOWL.id);
    expect(eligible.map((r) => r.id)).not.toContain(EGG_BREAKFAST.id);
    expect(eligible.map((r) => r.id)).not.toContain(CHICKEN_BOWL.id);
  });

  it('eggatarian permits eggs and dairy but excludes meat and fish', () => {
    const eligible = filterEligibleRecipes(ALL_RECIPES, {
      ...NO_CONSTRAINTS,
      diet_type: 'eggatarian',
    });
    expect(eligible.map((r) => r.id)).toContain(PANEER_BOWL.id);
    expect(eligible.map((r) => r.id)).toContain(EGG_BREAKFAST.id);
    expect(eligible.map((r) => r.id)).not.toContain(CHICKEN_BOWL.id);
  });

  it('non_vegetarian permits everything diet-wise', () => {
    const eligible = filterEligibleRecipes(ALL_RECIPES, {
      ...NO_CONSTRAINTS,
      diet_type: 'non_vegetarian',
    });
    expect(eligible.map((r) => r.id)).toContain(CHICKEN_BOWL.id);
  });

  it('no diet_type applies no diet filter', () => {
    const eligible = filterEligibleRecipes(ALL_RECIPES, NO_CONSTRAINTS);
    expect(eligible.map((r) => r.id)).toContain(CHICKEN_BOWL.id);
  });
});

describe('allergen safety', () => {
  it('excludes a recipe containing a declared allergen', () => {
    expect(isRecipeEligible(PEANUT_SNACK, { ...NO_CONSTRAINTS, allergy_ids: ['peanut'] })).toBe(
      false,
    );
  });

  it('keeps a recipe with no overlapping allergens', () => {
    expect(isRecipeEligible(VEG_RICE_BOWL, { ...NO_CONSTRAINTS, allergy_ids: ['peanut'] })).toBe(
      true,
    );
  });

  it('treats unknown allergen coverage as unsafe whenever any allergy constraint exists', () => {
    expect(isRecipeEligible(MYSTERY_RECIPE, { ...NO_CONSTRAINTS, allergy_ids: ['peanut'] })).toBe(
      false,
    );
    // Unrelated allergen, but coverage is still unknown, so it is still unsafe.
    expect(isRecipeEligible(MYSTERY_RECIPE, { ...NO_CONSTRAINTS, allergy_ids: ['milk'] })).toBe(
      false,
    );
  });

  it('allows unknown-coverage recipes when there are no allergy constraints at all', () => {
    expect(isRecipeEligible(MYSTERY_RECIPE, NO_CONSTRAINTS)).toBe(true);
  });
});

describe('exclusions and dislikes', () => {
  it('excludes a recipe whose ingredient carries an excluded food group', () => {
    expect(isRecipeEligible(CHICKEN_BOWL, { ...NO_CONSTRAINTS, exclusion_ids: ['chicken'] })).toBe(
      false,
    );
  });

  it('excludes a recipe matching a free-text dislike, case-insensitively', () => {
    expect(isRecipeEligible(PANEER_BOWL, { ...NO_CONSTRAINTS, dislikes: ['Paneer'] })).toBe(false);
    expect(isRecipeEligible(PANEER_BOWL, { ...NO_CONSTRAINTS, dislikes: ['mushroom'] })).toBe(true);
  });
});
