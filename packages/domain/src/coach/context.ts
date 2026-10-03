import { filterEligibleRecipes } from '../catalog/eligibility.js';
import { loadCatalogRecipes } from '../catalog/repository.js';
import type { Queryable } from '../db/user-transaction.js';
import { loadDietPlanningInputs } from '../planning/inputs.js';
import { todayInTimezone } from '../time/timezone.js';

/**
 * Coach context assembly (blueprint §12 "coachReply(context, allowedActions)"; §16 "M9 Coach: context
 * retrieval"; docs/decisions.md D-031). Everything here is read-only, reloaded fresh under the
 * caller's own transaction context — never any cross-user data — reusing the exact same domain
 * loaders M3/M6 already built (`loadDietPlanningInputs`, `loadCatalogRecipes`,
 * `filterEligibleRecipes`) rather than inventing a parallel read path. It lives in `packages/domain`
 * (not an `apps/api` module like M6's `loadTodayContext`) because the worker, not the API, is what
 * calls the AI provider (blueprint §2 "one backend codebase... API and worker"; the reply itself is
 * generated asynchronously, like M4's meal-scan job) and needs this loader directly.
 *
 * `diet.today` is deliberately only the single first-planned slot for the day (if any): this
 * milestone's coach can only ever propose a swap for one slot per message (see
 * `CoachProposedActionSchema` in packages/ai), so that is the only slot it needs real ids for.
 */
export interface CoachTodayMeal {
  slot: string;
  plan_meal_id: string;
  plan_meal_revision: number;
  recipe_name: string;
  alternate_candidate_id: string | null;
  alternate_candidate_name: string | null;
}

export interface CoachContext {
  timezone: string;
  date: string;
  profile: { has_goals: boolean; diet_preference: string | null };
  diet: {
    has_active_plan: boolean;
    today: CoachTodayMeal | null;
    today_logged_meal_count: number;
  };
  workout: {
    has_active_plan: boolean;
    today_session_id: string | null;
    today_session_title: string | null;
    today_session_status: string | null;
  };
}

interface ProfileRow {
  timezone: string;
}

interface GoalsRow {
  id: string;
}

interface PlanRow {
  id: string;
}

interface PlanMealRow {
  id: string;
  slot: string;
  recipe_id: string | null;
  revision: number;
}

interface WorkoutPlanRow {
  id: string;
}

interface WorkoutSessionRow {
  id: string;
  title: string;
  status: string;
}

export async function loadCoachContext(client: Queryable, userId: string): Promise<CoachContext> {
  const profile = (
    await client.query<ProfileRow>('select timezone from app.profiles where user_id = $1', [userId])
  ).rows[0];
  const timezone = profile?.timezone ?? 'UTC';
  const date = todayInTimezone(timezone);

  const planningInputs = await loadDietPlanningInputs(client, userId);
  const catalog = await loadCatalogRecipes(client);
  const eligible = filterEligibleRecipes(catalog, planningInputs.constraints);
  const recipesById = new Map(catalog.map((r) => [r.id, r]));

  const goals = (
    await client.query<GoalsRow>(
      `select id from app.goals where user_id = $1 and active_to is null limit 1`,
      [userId],
    )
  ).rows[0];

  const dietPlan = (
    await client.query<PlanRow>(
      `select id from app.diet_plans
         where user_id = $1 and status = 'active' and starts_on <= $2 and starts_on + 6 >= $2
         order by version desc limit 1`,
      [userId, date],
    )
  ).rows[0];

  let today: CoachTodayMeal | null = null;
  let loggedMealsCount = 0;
  if (dietPlan) {
    const { rows: planMeals } = await client.query<PlanMealRow>(
      `select id, slot, recipe_id, revision from app.diet_plan_meals
         where user_id = $1 and plan_id = $2 and meal_date = $3
         order by slot_ordinal limit 1`,
      [userId, dietPlan.id, date],
    );
    const first = planMeals[0];
    const recipe = first?.recipe_id ? recipesById.get(first.recipe_id) : undefined;
    if (first && recipe) {
      const alternate = eligible.find((r) => r.id !== recipe.id && r.tags.includes(first.slot));
      today = {
        slot: first.slot,
        plan_meal_id: first.id,
        plan_meal_revision: first.revision,
        recipe_name: recipe.name,
        alternate_candidate_id: alternate?.id ?? null,
        alternate_candidate_name: alternate?.name ?? null,
      };
    }
    const loggedCount = (
      await client.query<{ count: string }>(
        `select count(*) from app.meal_logs where user_id = $1 and local_date = $2`,
        [userId, date],
      )
    ).rows[0]!;
    loggedMealsCount = Number(loggedCount.count);
  }

  const workoutPlan = (
    await client.query<WorkoutPlanRow>(
      `select id from app.workout_plans where user_id = $1 and status = 'active'
         order by version desc limit 1`,
      [userId],
    )
  ).rows[0];
  let workoutSession: WorkoutSessionRow | undefined;
  if (workoutPlan) {
    workoutSession = (
      await client.query<WorkoutSessionRow>(
        `select id, title, status from app.workout_plan_sessions
           where user_id = $1 and plan_id = $2 and session_date = $3`,
        [userId, workoutPlan.id, date],
      )
    ).rows[0];
  }

  return {
    timezone,
    date,
    profile: { has_goals: !!goals, diet_preference: planningInputs.constraints.diet_type ?? null },
    diet: {
      has_active_plan: !!dietPlan,
      today,
      today_logged_meal_count: loggedMealsCount,
    },
    workout: {
      has_active_plan: !!workoutPlan,
      today_session_id: workoutSession?.id ?? null,
      today_session_title: workoutSession?.title ?? null,
      today_session_status: workoutSession?.status ?? null,
    },
  };
}
