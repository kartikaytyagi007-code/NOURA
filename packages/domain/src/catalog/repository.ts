import type { Queryable } from '../db/user-transaction.js';
import type { CatalogFood, CatalogRecipe, DietType } from './types.js';

interface RecipeIngredientRow {
  recipe_id: string;
  recipe_slug: string;
  recipe_name: string;
  recipe_tags: string[];
  recipe_cuisine: string | null;
  recipe_cooking_minutes: number | null;
  recipe_budget_band: 'low' | 'medium' | 'high' | null;
  recipe_quality_flag: CatalogRecipe['quality_flag'];
  edible_grams: string;
  food_id: string;
  food_name: string;
  energy_kcal_per_100g: string | null;
  protein_g_per_100g: string | null;
  carbohydrate_g_per_100g: string | null;
  fat_g_per_100g: string | null;
  fibre_g_per_100g: string | null;
  diet_tags: DietType[];
  allergen_tags: string[];
  allergen_coverage: CatalogFood['allergen_coverage'];
  food_group_tags: string[];
  food_quality_flag: CatalogFood['quality_flag'];
}

const num = (v: string | null): number | null => (v === null ? null : Number(v));

/**
 * Every recipe with its ingredients joined to their foods. Catalog tables are shared reference data
 * (read-only for server roles, the `catalog_read` RLS policy), so this needs no user context and is
 * used identically by the API (swaps, the current plan) and the worker (generation), which is what
 * keeps filtering and nutrition consistent between them.
 */
export async function loadCatalogRecipes(db: Queryable): Promise<CatalogRecipe[]> {
  const { rows } = await db.query<RecipeIngredientRow>(
    `select
       r.id as recipe_id, r.slug as recipe_slug, r.name as recipe_name, r.tags as recipe_tags,
       r.cuisine as recipe_cuisine, r.cooking_minutes as recipe_cooking_minutes,
       r.budget_band as recipe_budget_band, r.quality_flag as recipe_quality_flag,
       ri.edible_grams::text as edible_grams,
       f.id as food_id, f.name as food_name,
       f.energy_kcal_per_100g::text as energy_kcal_per_100g,
       f.protein_g_per_100g::text as protein_g_per_100g,
       f.carbohydrate_g_per_100g::text as carbohydrate_g_per_100g,
       f.fat_g_per_100g::text as fat_g_per_100g,
       f.fibre_g_per_100g::text as fibre_g_per_100g,
       f.diet_tags, f.allergen_tags, f.allergen_coverage, f.food_group_tags,
       f.quality_flag as food_quality_flag
     from app.recipes r
     join app.recipe_ingredients ri on ri.recipe_id = r.id
     join app.foods f on f.id = ri.food_id
     order by r.id, ri.ordinal`,
  );
  const byRecipe = new Map<string, CatalogRecipe>();
  for (const row of rows) {
    let recipe = byRecipe.get(row.recipe_id);
    if (!recipe) {
      recipe = {
        id: row.recipe_id,
        slug: row.recipe_slug,
        name: row.recipe_name,
        tags: row.recipe_tags,
        cuisine: row.recipe_cuisine,
        cooking_minutes: row.recipe_cooking_minutes,
        budget_band: row.recipe_budget_band,
        quality_flag: row.recipe_quality_flag,
        ingredients: [],
      };
      byRecipe.set(row.recipe_id, recipe);
    }
    recipe.ingredients.push({
      edible_grams: Number(row.edible_grams),
      food: {
        id: row.food_id,
        name: row.food_name,
        energy_kcal_per_100g: num(row.energy_kcal_per_100g),
        protein_g_per_100g: num(row.protein_g_per_100g),
        carbohydrate_g_per_100g: num(row.carbohydrate_g_per_100g),
        fat_g_per_100g: num(row.fat_g_per_100g),
        fibre_g_per_100g: num(row.fibre_g_per_100g),
        diet_tags: row.diet_tags,
        allergen_tags: row.allergen_tags,
        allergen_coverage: row.allergen_coverage,
        food_group_tags: row.food_group_tags,
        quality_flag: row.food_quality_flag,
        serving_conversions: [],
      },
    });
  }
  return [...byRecipe.values()];
}

interface FoodRow {
  id: string;
  name: string;
  energy_kcal_per_100g: string | null;
  protein_g_per_100g: string | null;
  carbohydrate_g_per_100g: string | null;
  fat_g_per_100g: string | null;
  fibre_g_per_100g: string | null;
  diet_tags: DietType[];
  allergen_tags: string[];
  allergen_coverage: CatalogFood['allergen_coverage'];
  food_group_tags: string[];
  quality_flag: CatalogFood['quality_flag'];
  serving_conversions: CatalogFood['serving_conversions'];
}

/**
 * Every standalone catalog food (blueprint §8: meal-scan recognition maps items onto this same
 * catalog, never onto recipes). Read-only reference data, shared by the API and worker exactly like
 * `loadCatalogRecipes`.
 */
export async function loadCatalogFoods(db: Queryable): Promise<CatalogFood[]> {
  const { rows } = await db.query<FoodRow>(
    `select id, name,
            energy_kcal_per_100g::text as energy_kcal_per_100g,
            protein_g_per_100g::text as protein_g_per_100g,
            carbohydrate_g_per_100g::text as carbohydrate_g_per_100g,
            fat_g_per_100g::text as fat_g_per_100g,
            fibre_g_per_100g::text as fibre_g_per_100g,
            diet_tags, allergen_tags, allergen_coverage, food_group_tags, quality_flag,
            coalesce(serving_conversions, '[]'::jsonb) as serving_conversions
       from app.foods`,
  );
  return rows.map((row) => ({
    id: row.id,
    name: row.name,
    energy_kcal_per_100g: num(row.energy_kcal_per_100g),
    protein_g_per_100g: num(row.protein_g_per_100g),
    carbohydrate_g_per_100g: num(row.carbohydrate_g_per_100g),
    fat_g_per_100g: num(row.fat_g_per_100g),
    fibre_g_per_100g: num(row.fibre_g_per_100g),
    diet_tags: row.diet_tags,
    allergen_tags: row.allergen_tags,
    allergen_coverage: row.allergen_coverage,
    food_group_tags: row.food_group_tags,
    quality_flag: row.quality_flag,
    serving_conversions: row.serving_conversions,
  }));
}
