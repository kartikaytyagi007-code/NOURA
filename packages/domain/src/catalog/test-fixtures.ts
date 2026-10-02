import type { CatalogFood, CatalogRecipe } from './types.js';

/** Small in-memory catalog mirroring the shape of the M3 test-fixture seed, for pure unit tests. */

function food(partial: Partial<CatalogFood> & Pick<CatalogFood, 'id' | 'name'>): CatalogFood {
  return {
    energy_kcal_per_100g: 100,
    protein_g_per_100g: 5,
    carbohydrate_g_per_100g: 10,
    fat_g_per_100g: 2,
    fibre_g_per_100g: 1,
    diet_tags: ['vegan', 'vegetarian', 'eggatarian', 'non_vegetarian'],
    allergen_tags: [],
    allergen_coverage: 'complete',
    food_group_tags: [],
    quality_flag: 'test_fixture',
    ...partial,
  };
}

export const RICE = food({
  id: 'food-rice',
  name: 'Rice',
  energy_kcal_per_100g: 130,
  protein_g_per_100g: 2.7,
  carbohydrate_g_per_100g: 28,
  fat_g_per_100g: 0.3,
  fibre_g_per_100g: 0.4,
});
export const VEGETABLES = food({
  id: 'food-veg',
  name: 'Mixed vegetables',
  energy_kcal_per_100g: 50,
  protein_g_per_100g: 2,
  carbohydrate_g_per_100g: 10,
  fat_g_per_100g: 0.3,
  fibre_g_per_100g: 3,
});
export const PANEER = food({
  id: 'food-paneer',
  name: 'Paneer',
  energy_kcal_per_100g: 265,
  protein_g_per_100g: 18,
  carbohydrate_g_per_100g: 1.2,
  fat_g_per_100g: 21,
  fibre_g_per_100g: 0,
  diet_tags: ['vegetarian', 'eggatarian', 'non_vegetarian'],
  allergen_tags: ['milk'],
});
export const EGG = food({
  id: 'food-egg',
  name: 'Egg',
  energy_kcal_per_100g: 143,
  protein_g_per_100g: 13,
  carbohydrate_g_per_100g: 1.1,
  fat_g_per_100g: 9.5,
  fibre_g_per_100g: 0,
  diet_tags: ['eggatarian', 'non_vegetarian'],
  allergen_tags: ['egg'],
});
export const CHICKEN = food({
  id: 'food-chicken',
  name: 'Chicken breast',
  energy_kcal_per_100g: 165,
  protein_g_per_100g: 31,
  carbohydrate_g_per_100g: 0,
  fat_g_per_100g: 3.6,
  fibre_g_per_100g: 0,
  diet_tags: ['non_vegetarian'],
  food_group_tags: ['chicken'],
});
export const PEANUTS = food({
  id: 'food-peanut',
  name: 'Peanuts',
  energy_kcal_per_100g: 567,
  protein_g_per_100g: 25,
  carbohydrate_g_per_100g: 16,
  fat_g_per_100g: 49,
  fibre_g_per_100g: 8.5,
  allergen_tags: ['peanut'],
});
export const MYSTERY_SPICE = food({
  id: 'food-mystery',
  name: 'Mystery spice blend',
  allergen_coverage: 'unknown',
});

export const VEG_RICE_BOWL: CatalogRecipe = {
  id: 'recipe-veg-rice-bowl',
  slug: 'veg-rice-bowl',
  name: 'Vegetable rice bowl',
  tags: ['lunch', 'dinner'],
  cuisine: 'north_indian',
  cooking_minutes: 25,
  budget_band: 'low',
  quality_flag: 'test_fixture',
  ingredients: [
    { food: RICE, edible_grams: 150 },
    { food: VEGETABLES, edible_grams: 150 },
  ],
};

export const PANEER_BOWL: CatalogRecipe = {
  id: 'recipe-paneer-bowl',
  slug: 'paneer-bowl',
  name: 'Paneer bowl',
  tags: ['lunch', 'dinner'],
  cuisine: 'north_indian',
  cooking_minutes: 25,
  budget_band: 'medium',
  quality_flag: 'test_fixture',
  ingredients: [
    { food: PANEER, edible_grams: 120 },
    { food: RICE, edible_grams: 120 },
  ],
};

export const EGG_BREAKFAST: CatalogRecipe = {
  id: 'recipe-egg-breakfast',
  slug: 'egg-breakfast',
  name: 'Egg bhurji',
  tags: ['breakfast'],
  cuisine: 'north_indian',
  cooking_minutes: 15,
  budget_band: 'low',
  quality_flag: 'test_fixture',
  ingredients: [{ food: EGG, edible_grams: 120 }],
};

export const CHICKEN_BOWL: CatalogRecipe = {
  id: 'recipe-chicken-bowl',
  slug: 'chicken-bowl',
  name: 'Chicken rice bowl',
  tags: ['lunch', 'dinner'],
  cuisine: 'continental',
  cooking_minutes: 30,
  budget_band: 'medium',
  quality_flag: 'test_fixture',
  ingredients: [
    { food: CHICKEN, edible_grams: 150 },
    { food: RICE, edible_grams: 120 },
  ],
};

export const PEANUT_SNACK: CatalogRecipe = {
  id: 'recipe-peanut-snack',
  slug: 'peanut-snack',
  name: 'Peanut rice snack',
  tags: ['snack'],
  cuisine: 'indo_chinese',
  cooking_minutes: 10,
  budget_band: 'low',
  quality_flag: 'test_fixture',
  ingredients: [
    { food: PEANUTS, edible_grams: 30 },
    { food: RICE, edible_grams: 100 },
  ],
};

export const VEGAN_BREAKFAST: CatalogRecipe = {
  id: 'recipe-vegan-breakfast',
  slug: 'vegan-breakfast',
  name: 'Vegetable rice porridge',
  tags: ['breakfast'],
  cuisine: 'continental',
  cooking_minutes: 10,
  budget_band: 'low',
  quality_flag: 'test_fixture',
  ingredients: [
    { food: RICE, edible_grams: 100 },
    { food: VEGETABLES, edible_grams: 80 },
  ],
};

export const MYSTERY_RECIPE: CatalogRecipe = {
  id: 'recipe-mystery',
  slug: 'mystery-rice',
  name: 'Mystery spice rice',
  tags: ['lunch', 'dinner'],
  cuisine: 'north_indian',
  cooking_minutes: 10,
  budget_band: 'low',
  quality_flag: 'test_fixture',
  ingredients: [
    { food: RICE, edible_grams: 150 },
    { food: MYSTERY_SPICE, edible_grams: 10 },
  ],
};

export const ALL_RECIPES: CatalogRecipe[] = [
  VEG_RICE_BOWL,
  PANEER_BOWL,
  EGG_BREAKFAST,
  VEGAN_BREAKFAST,
  CHICKEN_BOWL,
  PEANUT_SNACK,
  MYSTERY_RECIPE,
];
