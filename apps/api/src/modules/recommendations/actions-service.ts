import {
  AppError,
  buildPortionsSnapshot,
  computeRecipeNutrition,
  filterEligibleRecipes,
  loadCatalogRecipes,
  loadDietPlanningInputs,
  portionsOf,
  type Queryable,
} from '@noura/domain';
import type { components } from '@noura/contracts';
import { replacePlanMeal } from '../diet/service.js';

type Schemas = components['schemas'];

interface ActivePlanRow {
  id: string;
}

interface PlanMealOrdinalRow {
  slot_ordinal: number;
}

function requireField<T>(value: T | null | undefined, field: string): T {
  if (value === null || value === undefined) {
    throw new AppError('VALIDATION_ERROR', `${field} is required for this action.`, {
      fieldErrors: [
        { field: `body.${field}`, code: 'required', message: 'required for this action' },
      ],
    });
  }
  return value;
}

/**
 * Inserts the recommended recipe as a new plan slot for `date`/`slot` (blueprint §9 "add to plan").
 * Only valid when an active plan exists and a free slot ordinal (1-4) is available; this never
 * overwrites an existing planned meal — that is a `swap`, which reuses `replacePlanMeal` directly.
 */
async function addRecommendationToPlan(
  client: Queryable,
  userId: string,
  date: string,
  slot: Schemas['MealSlot'],
  candidateId: string,
): Promise<Schemas['PlanMeal']> {
  const plan = (
    await client.query<ActivePlanRow>(
      `select id from app.diet_plans
         where user_id = $1 and status = 'active' and starts_on <= $2 and starts_on + 6 >= $2
         order by version desc limit 1`,
      [userId, date],
    )
  ).rows[0];
  if (!plan) {
    throw new AppError('CONSTRAINT_CONFLICT', 'You have no active diet plan to add this to.');
  }

  const inputs = await loadDietPlanningInputs(client, userId);
  const catalog = await loadCatalogRecipes(client);
  const eligible = filterEligibleRecipes(catalog, inputs.constraints);
  const candidate = eligible.find((r) => r.id === candidateId && r.tags.includes(slot));
  if (!candidate) {
    throw new AppError('VALIDATION_ERROR', 'That candidate is not available for this slot.', {
      fieldErrors: [
        { field: 'body.candidate_id', code: 'invalid', message: 'not an eligible candidate' },
      ],
    });
  }

  const { rows: existing } = await client.query<PlanMealOrdinalRow>(
    `select slot_ordinal from app.diet_plan_meals
       where user_id = $1 and plan_id = $2 and meal_date = $3 and slot = $4`,
    [userId, plan.id, date, slot],
  );
  const used = new Set(existing.map((r) => r.slot_ordinal));
  let ordinal = 1;
  while (used.has(ordinal) && ordinal <= 4) ordinal++;
  if (ordinal > 4) {
    throw new AppError('CONSTRAINT_CONFLICT', 'No free slot is available for that meal today.');
  }

  const nutrition = computeRecipeNutrition(candidate, 1);
  const portionsSnapshot = buildPortionsSnapshot(candidate, 1);
  const inserted = (
    await client.query<{ id: string; revision: number }>(
      `insert into app.diet_plan_meals
         (user_id, plan_id, meal_date, slot, slot_ordinal, recipe_id, portions_snapshot, nutrition_snapshot)
       values ($1, $2, $3, $4, $5, $6, $7::jsonb, $8::jsonb)
       returning id, revision`,
      [
        userId,
        plan.id,
        date,
        slot,
        ordinal,
        candidate.id,
        JSON.stringify(portionsSnapshot),
        JSON.stringify(nutrition),
      ],
    )
  ).rows[0]!;

  return {
    id: inserted.id,
    date,
    slot,
    slot_ordinal: ordinal,
    recipe: { id: candidate.id, name: candidate.name },
    portions: portionsOf(portionsSnapshot),
    nutrition,
    revision: inserted.revision,
  };
}

/** Sticky dismissal for one date/slot (D-028). Idempotent: a repeat dismiss is a no-op. */
async function dismissRecommendation(
  client: Queryable,
  userId: string,
  date: string,
  slot: Schemas['MealSlot'],
): Promise<void> {
  await client.query(
    `insert into app.dismissed_recommendations (user_id, local_date, slot)
       values ($1, $2, $3)
     on conflict (user_id, local_date, slot) do nothing`,
    [userId, date, slot],
  );
}

export async function performNextMealAction(
  client: Queryable,
  userId: string,
  body: Schemas['NextMealActionRequest'],
): Promise<Schemas['NextMealActionResult']> {
  switch (body.action) {
    case 'add': {
      const candidateId = requireField(body.candidate_id, 'candidate_id');
      const planMeal = await addRecommendationToPlan(
        client,
        userId,
        body.date,
        body.slot,
        candidateId,
      );
      return { action: 'add', plan_meal: planMeal, dismissed: false };
    }
    case 'swap': {
      const candidateId = requireField(body.candidate_id, 'candidate_id');
      const targetPlanMealId = requireField(body.target_plan_meal_id, 'target_plan_meal_id');
      const expectedRevision = requireField(body.expected_revision, 'expected_revision');
      // Delegates to the exact same domain logic the diet-plan swap screen uses (blueprint §9):
      // never a second, duplicated implementation of "replace a plan slot".
      const planMeal = await replacePlanMeal(client, userId, targetPlanMealId, {
        expected_revision: expectedRevision,
        candidate_id: candidateId,
      });
      return { action: 'swap', plan_meal: planMeal, dismissed: false };
    }
    case 'dismiss': {
      await dismissRecommendation(client, userId, body.date, body.slot);
      return { action: 'dismiss', plan_meal: null, dismissed: true };
    }
    default: {
      throw new AppError('VALIDATION_ERROR', 'Unknown action.', {
        fieldErrors: [
          { field: 'body.action', code: 'invalid', message: 'must be add, swap or dismiss' },
        ],
      });
    }
  }
}
