import {
  AppError,
  buildPortionsSnapshot,
  computeRecipeNutrition,
  filterEligibleRecipes,
  gramsScaleOf,
  loadCatalogRecipes,
  loadDietPlanningInputs,
  portionsOf,
  sumNutrientTotals,
  swapCandidatesFor,
  type CatalogRecipe,
  type NutrientTotals,
  type Queryable,
} from '@noura/domain';
import type { components } from '@noura/contracts';

type Schemas = components['schemas'];

const conflict = (what: string) =>
  new AppError(
    'REVISION_CONFLICT',
    `Your ${what} changed since you loaded it. Reload and try again.`,
  );

const UNAVAILABLE = new AppError(
  'CONSTRAINT_CONFLICT',
  'Automated plans are not available for this account.',
);

function recipeRef(recipe: CatalogRecipe | null): Schemas['RecipeRef'] | null {
  return recipe ? { id: recipe.id, name: recipe.name } : null;
}

// ---------------------------------------------------------------- generateDietPlan

interface ActivePlanRow {
  id: string;
}

export async function requestDietPlanGeneration(
  client: Queryable,
  userId: string,
  body: Schemas['GeneratePlanRequest'],
): Promise<Schemas['JobAccepted']> {
  const inputs = await loadDietPlanningInputs(client, userId);
  if (inputs.profileRevision !== body.profile_revision) throw conflict('profile');
  if (inputs.eligibilityStatus !== 'eligible' || !inputs.targetSnapshotId) throw UNAVAILABLE;

  const activePlan = (
    await client.query<ActivePlanRow>(
      "select id from app.diet_plans where user_id = $1 and status = 'active' order by version desc limit 1",
      [userId],
    )
  ).rows[0];
  const requestType = activePlan ? 'plan_regeneration' : 'diet_plan';

  const inserted = await client.query<{ id: string }>(
    `insert into app.generation_requests (user_id, request_type, input_revision)
     values ($1, $2, $3)
     on conflict do nothing
     returning id`,
    [userId, requestType, body.profile_revision],
  );
  const id =
    inserted.rows[0]?.id ??
    (
      await client.query<{ id: string }>(
        `select id from app.generation_requests
           where user_id = $1 and request_type = $2 and status in ('queued', 'running')
           order by created_at desc limit 1`,
        [userId, requestType],
      )
    ).rows[0]?.id;
  if (!id) throw new AppError('INTERNAL_ERROR', 'The plan request could not be recorded.');
  return { job_id: id };
}

// ---------------------------------------------------------------- getCurrentDietPlan

interface DietPlanRow {
  id: string;
  version: number;
  starts_on: Date;
  status: 'draft' | 'active' | 'superseded' | 'cancelled';
  target_snapshot_id: string;
}

interface PlanMealRow {
  id: string;
  meal_date: Date;
  slot: Schemas['MealSlot'];
  slot_ordinal: number;
  recipe_id: string | null;
  portions_snapshot: unknown;
  nutrition_snapshot: NutrientTotals;
  revision: number;
}

function isoDate(d: Date): string {
  return d.toISOString().slice(0, 10);
}

function toPlanMeal(row: PlanMealRow, recipes: Map<string, CatalogRecipe>): Schemas['PlanMeal'] {
  return {
    id: row.id,
    date: isoDate(row.meal_date),
    slot: row.slot,
    slot_ordinal: row.slot_ordinal,
    recipe: recipeRef(row.recipe_id ? (recipes.get(row.recipe_id) ?? null) : null),
    portions: portionsOf(row.portions_snapshot),
    nutrition: row.nutrition_snapshot,
    revision: row.revision,
  };
}

export async function getCurrentDietPlan(
  client: Queryable,
  userId: string,
  date?: string,
): Promise<Schemas['DietPlan']> {
  const plan = (
    await client.query<DietPlanRow>(
      `select id, version, starts_on, status, target_snapshot_id from app.diet_plans
         where user_id = $1 and status = 'active' order by version desc limit 1`,
      [userId],
    )
  ).rows[0];
  if (!plan) throw new AppError('NOT_FOUND', 'No active diet plan.');

  const meals = (
    await client.query<PlanMealRow>(
      `select id, meal_date, slot, slot_ordinal, recipe_id, portions_snapshot, nutrition_snapshot, revision
         from app.diet_plan_meals where user_id = $1 and plan_id = $2
         order by meal_date, slot_ordinal`,
      [userId, plan.id],
    )
  ).rows;
  if (date) {
    const starts = isoDate(plan.starts_on);
    const ends = isoDate(new Date(plan.starts_on.getTime() + 6 * 86_400_000));
    if (date < starts || date > ends)
      throw new AppError('NOT_FOUND', 'No active diet plan for that date.');
  }

  const recipeIds = [
    ...new Set(meals.map((m) => m.recipe_id).filter((id): id is string => id !== null)),
  ];
  const recipes = await (async () => {
    if (recipeIds.length === 0) return new Map<string, CatalogRecipe>();
    const all = await loadCatalogRecipes(client);
    const set = new Set(recipeIds);
    return new Map(all.filter((r) => set.has(r.id)).map((r) => [r.id, r]));
  })();

  const byDate = new Map<string, PlanMealRow[]>();
  for (const meal of meals) {
    const key = isoDate(meal.meal_date);
    const list = byDate.get(key) ?? [];
    list.push(meal);
    byDate.set(key, list);
  }
  const days: Schemas['PlanDay'][] = [...byDate.entries()].map(([d, dayMeals]) => {
    const planMeals = dayMeals.map((m) => toPlanMeal(m, recipes));
    return {
      date: d,
      meals: planMeals,
      totals: sumNutrientTotals(dayMeals.map((m) => m.nutrition_snapshot)),
    };
  });

  return {
    id: plan.id,
    version: plan.version,
    starts_on: isoDate(plan.starts_on),
    status: plan.status as 'active' | 'superseded',
    target_snapshot_id: plan.target_snapshot_id,
    days,
  };
}

// ---------------------------------------------------------------- getSwapOptions / replacePlanMeal

async function loadPlanMealForUpdate(
  client: Queryable,
  userId: string,
  id: string,
): Promise<PlanMealRow & { plan_id: string }> {
  const row = (
    await client.query<PlanMealRow & { plan_id: string }>(
      `select id, plan_id, meal_date, slot, slot_ordinal, recipe_id, portions_snapshot, nutrition_snapshot, revision
         from app.diet_plan_meals where user_id = $1 and id = $2`,
      [userId, id],
    )
  ).rows[0];
  if (!row) throw new AppError('NOT_FOUND', 'Plan meal not found.');
  return row;
}

async function otherMealsNutrition(
  client: Queryable,
  userId: string,
  planId: string,
  mealDate: Date,
  excludeId: string,
): Promise<NutrientTotals[]> {
  const { rows } = await client.query<{ nutrition_snapshot: NutrientTotals }>(
    `select nutrition_snapshot from app.diet_plan_meals
       where user_id = $1 and plan_id = $2 and meal_date = $3 and id <> $4`,
    [userId, planId, mealDate, excludeId],
  );
  return rows.map((r) => r.nutrition_snapshot);
}

export async function getSwapOptions(
  client: Queryable,
  userId: string,
  id: string,
  expectedRevision: number,
): Promise<Schemas['SwapOptions']> {
  const meal = await loadPlanMealForUpdate(client, userId, id);
  if (meal.revision !== expectedRevision) throw conflict('plan meal');

  const inputs = await loadDietPlanningInputs(client, userId);
  const catalog = await loadCatalogRecipes(client);
  const eligible = filterEligibleRecipes(catalog, inputs.constraints);
  const others = await otherMealsNutrition(client, userId, meal.plan_id, meal.meal_date, meal.id);

  const candidates = swapCandidatesFor({
    slot: meal.slot,
    eligibleRecipes: eligible,
    currentRecipeId: meal.recipe_id ?? '',
    gramsScale: gramsScaleOf(meal.portions_snapshot),
    otherMealsNutrition: others,
  });

  return {
    plan_meal_id: meal.id,
    revision: meal.revision,
    candidates: candidates.map((c) => ({
      candidate_id: c.recipe.id,
      recipe: recipeRef(c.recipe) as Schemas['RecipeRef'],
      portions: buildPortionsSnapshot(c.recipe, c.grams_scale).portions,
      nutrition: c.nutrition,
      daily_totals_preview: c.daily_totals_preview,
    })),
  };
}

export async function replacePlanMeal(
  client: Queryable,
  userId: string,
  id: string,
  body: Schemas['ReplacePlanMealRequest'],
): Promise<Schemas['PlanMeal']> {
  const meal = await loadPlanMealForUpdate(client, userId, id);
  if (meal.revision !== body.expected_revision) throw conflict('plan meal');

  const inputs = await loadDietPlanningInputs(client, userId);
  const catalog = await loadCatalogRecipes(client);
  const eligible = filterEligibleRecipes(catalog, inputs.constraints);
  const candidate = eligible.find((r) => r.id === body.candidate_id && r.tags.includes(meal.slot));
  if (!candidate) {
    throw new AppError('VALIDATION_ERROR', 'That candidate is not available for this slot.', {
      fieldErrors: [
        { field: 'body.candidate_id', code: 'invalid', message: 'not an eligible candidate' },
      ],
    });
  }

  const gramsScale = gramsScaleOf(meal.portions_snapshot);
  const nutrition = computeRecipeNutrition(candidate, gramsScale);
  const portionsSnapshot = buildPortionsSnapshot(candidate, gramsScale);

  const updated = (
    await client.query<{ revision: number }>(
      `update app.diet_plan_meals
         set recipe_id = $3, portions_snapshot = $4::jsonb, nutrition_snapshot = $5::jsonb, revision = revision + 1
         where user_id = $1 and id = $2 and revision = $6
         returning revision`,
      [
        userId,
        id,
        candidate.id,
        JSON.stringify(portionsSnapshot),
        JSON.stringify(nutrition),
        meal.revision,
      ],
    )
  ).rows[0];
  if (!updated) throw conflict('plan meal');

  return {
    id: meal.id,
    date: isoDate(meal.meal_date),
    slot: meal.slot,
    slot_ordinal: meal.slot_ordinal,
    recipe: recipeRef(candidate),
    portions: portionsSnapshot.portions,
    nutrition,
    revision: updated.revision,
  };
}
