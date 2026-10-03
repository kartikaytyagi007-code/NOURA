/**
 * Catalog shapes used by diet-plan generation (blueprint §7, docs/decisions.md D-025). These mirror
 * the M1 `app.foods` / `app.recipes` / `app.recipe_ingredients` columns closely enough to be built
 * directly from a SQL row, so the planning algorithm stays a pure function of plain data and needs
 * no database in its tests.
 */

export type QualityFlag = 'verified' | 'reviewed' | 'provisional' | 'test_fixture';
export type AllergenCoverage = 'complete' | 'partial' | 'unknown';
export type DietType = 'vegetarian' | 'eggatarian' | 'vegan' | 'non_vegetarian';
export type MealSlot = 'breakfast' | 'lunch' | 'dinner' | 'snack';

export interface ServingConversion {
  unit: string;
  grams_min: number;
  grams_max: number;
}

export interface CatalogFood {
  id: string;
  name: string;
  energy_kcal_per_100g: number | null;
  protein_g_per_100g: number | null;
  carbohydrate_g_per_100g: number | null;
  fat_g_per_100g: number | null;
  fibre_g_per_100g: number | null;
  diet_tags: DietType[];
  allergen_tags: string[];
  allergen_coverage: AllergenCoverage;
  food_group_tags: string[];
  quality_flag: QualityFlag;
  serving_conversions: ServingConversion[];
}

export interface CatalogIngredient {
  food: CatalogFood;
  edible_grams: number;
}

export interface CatalogRecipe {
  id: string;
  slug: string;
  name: string;
  tags: string[];
  cuisine: string | null;
  cooking_minutes: number | null;
  budget_band: 'low' | 'medium' | 'high' | null;
  quality_flag: QualityFlag;
  ingredients: CatalogIngredient[];
}

export type ExperienceLevel = 'beginner' | 'intermediate' | 'advanced';
export type TrainingLocation = 'home' | 'gym' | 'both';

/**
 * Mirrors `app.exercises` (blueprint §11, M1 schema, M7 generation, docs/decisions.md D-029).
 * `equipment_tags` empty means a bodyweight-only movement, always available regardless of location.
 */
export interface CatalogExercise {
  id: string;
  slug: string;
  name: string;
  movement_pattern: string;
  muscle_tags: string[];
  equipment_tags: string[];
  level: ExperienceLevel;
  contraindication_tags: string[];
  instructions: string[];
  quality_flag: QualityFlag;
}

export interface CatalogExerciseSubstitution {
  exercise_id: string;
  substitute_id: string;
}
