import {
  filterEligibleRecipes,
  loadCatalogRecipes,
  loadDietPlanningInputs,
  sumNutrientTotals,
  todayInTimezone,
  type CatalogRecipe,
  type DietPlanningInputs,
  type NutrientTotals,
  type PlannedSlotInfo,
  type Queryable,
} from '@noura/domain';
import { AppError } from '@noura/domain';
import type { components } from '@noura/contracts';

type Schemas = components['schemas'];
type MealSlot = Schemas['MealSlot'];

/**
 * Shared "today" loader for M6's recommendation flows (next-meal, actions, home): everything is
 * reloaded fresh under the caller's own transaction context, exactly like M3/M4/M5's precedent
 * (`loadDietPlanningInputs`), so the API never trusts anything beyond the verified user id and the
 * requested date.
 */
export interface TodayContext {
  timezone: string;
  date: string;
  planningInputs: DietPlanningInputs;
  eligibleRecipes: CatalogRecipe[];
  /** Today's active-plan slots (any status), one per slot/ordinal, joined to the catalog recipe. */
  plannedSlots: PlannedSlotInfo[];
  activePlanId: string | null;
  /** Slots with at least one meal log today. */
  loggedSlots: Set<MealSlot>;
  loggedMealsCount: number;
  /** Today's confirmed intake so far, honestly summed (incomplete/empty propagate, never zero). */
  todayTotals: NutrientTotals;
}

interface ProfileRow {
  timezone: string;
}

interface PlanRow {
  id: string;
  starts_on: Date;
}

interface PlanMealRow {
  id: string;
  slot: MealSlot;
  recipe_id: string | null;
  portions_snapshot: unknown;
  nutrition_snapshot: NutrientTotals;
  revision: number;
}

interface LogRow {
  slot: MealSlot;
  totals_snapshot: NutrientTotals;
}

function isoDate(d: Date): string {
  return d.toISOString().slice(0, 10);
}

function gramsScaleOf(snapshot: unknown): number {
  const scale = (snapshot as { grams_scale?: unknown } | null)?.grams_scale;
  return typeof scale === 'number' && scale > 0 ? scale : 1;
}

/** Resolves `date` to the caller's own local "today" when omitted, and loads everything M6 needs. */
export async function loadTodayContext(
  client: Queryable,
  userId: string,
  requestedDate: string | undefined,
): Promise<TodayContext> {
  const profile = (
    await client.query<ProfileRow>('select timezone from app.profiles where user_id = $1', [userId])
  ).rows[0];
  const timezone = profile?.timezone ?? 'UTC';
  const date = requestedDate ?? todayInTimezone(timezone);
  // Validates the date format defensively even though the OpenAPI `format: date` already constrains it.
  if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) {
    throw new AppError('VALIDATION_ERROR', 'Invalid date.', {
      fieldErrors: [{ field: 'query.date', code: 'invalid', message: 'expected YYYY-MM-DD' }],
    });
  }

  const planningInputs = await loadDietPlanningInputs(client, userId);
  const catalog = await loadCatalogRecipes(client);
  const eligibleRecipes = filterEligibleRecipes(catalog, planningInputs.constraints);

  const plan = (
    await client.query<PlanRow>(
      `select id, starts_on from app.diet_plans
         where user_id = $1 and status = 'active' and starts_on <= $2 and starts_on + 6 >= $2
         order by version desc limit 1`,
      [userId, date],
    )
  ).rows[0];

  const plannedSlots: PlannedSlotInfo[] = [];
  if (plan) {
    const { rows } = await client.query<PlanMealRow>(
      `select id, slot, recipe_id, portions_snapshot, nutrition_snapshot, revision
         from app.diet_plan_meals
         where user_id = $1 and plan_id = $2 and meal_date = $3
         order by slot_ordinal`,
      [userId, plan.id, date],
    );
    const recipesById = new Map(catalog.map((r) => [r.id, r]));
    for (const row of rows) {
      const recipe = row.recipe_id ? recipesById.get(row.recipe_id) : undefined;
      if (!recipe) continue; // No slot preview without a resolvable recipe; never guess one.
      plannedSlots.push({
        slot: row.slot,
        plan_meal_id: row.id,
        plan_meal_revision: row.revision,
        recipe,
        grams_scale: gramsScaleOf(row.portions_snapshot),
        nutrition: row.nutrition_snapshot,
      });
    }
  }

  const { rows: logRows } = await client.query<LogRow>(
    `select slot, totals_snapshot from app.meal_logs where user_id = $1 and local_date = $2`,
    [userId, date],
  );
  const loggedSlots = new Set(logRows.map((r) => r.slot));
  const todayTotals =
    logRows.length === 0
      ? {
          nutrients: {
            energy_kcal: null,
            protein_g: null,
            carbohydrate_g: null,
            fat_g: null,
            fibre_g: null,
          },
          coverage: { items_total: 0, items_with_nutrition: 0, complete: false },
        }
      : sumNutrientTotals(logRows.map((r) => r.totals_snapshot));

  return {
    timezone,
    date,
    planningInputs,
    eligibleRecipes,
    plannedSlots,
    activePlanId: plan?.id ?? null,
    loggedSlots,
    loggedMealsCount: logRows.length,
    todayTotals,
  };
}

export { isoDate };
