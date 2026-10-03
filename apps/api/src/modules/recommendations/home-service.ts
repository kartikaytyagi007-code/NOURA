import {
  sumNutrientTotals,
  todayInTimezone,
  type NutrientTotals,
  type Queryable,
} from '@noura/domain';
import type { components } from '@noura/contracts';
import { findJob } from '../jobs/routes.js';

type Schemas = components['schemas'];

interface ProfileRow {
  timezone: string;
  onboarding_status: string;
}

interface PlanRow {
  slot: Schemas['MealSlot'];
  id: string;
  recipe_name: string | null;
}

interface LogRow {
  totals_snapshot: NutrientTotals;
  slot: Schemas['MealSlot'];
}

interface PendingRequestRow {
  id: string;
}

interface WorkoutSessionRow {
  id: string;
  title: string;
  status: Schemas['WorkoutSessionPreview']['status'];
}

const SLOT_ORDER: readonly Schemas['MealSlot'][] = ['breakfast', 'lunch', 'dinner', 'snack'];

/**
 * Home summary (blueprint §4, §11; D-028). `next_meal` and `nutrition` were pre-wired, null
 * placeholders since M1 (the contract's `Home` schema already existed); this is the milestone that
 * fills them from real data — today's actual logged totals, and the next unlogged plan slot — rather
 * than re-deriving a separate recommendation engine. `getNextMeal` (richer: reasons/alternatives) is
 * the dedicated endpoint for the "What should I eat next?" screen; Home only needs a short preview.
 */
export async function getHome(
  client: Queryable,
  userId: string,
  requestedDate: string | undefined,
): Promise<Schemas['Home']> {
  const profile = (
    await client.query<ProfileRow>(
      'select timezone, onboarding_status from app.profiles where user_id = $1',
      [userId],
    )
  ).rows[0];
  const timezone = profile?.timezone ?? 'UTC';
  const date = requestedDate ?? todayInTimezone(timezone);

  const { rows: logRows } = await client.query<LogRow>(
    'select slot, totals_snapshot from app.meal_logs where user_id = $1 and local_date = $2',
    [userId, date],
  );
  const loggedSlots = new Set(logRows.map((r) => r.slot));
  const nutrition: NutrientTotals =
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

  const { rows: planRows } = await client.query<PlanRow>(
    `select dpm.slot, dpm.id, r.name as recipe_name
       from app.diet_plan_meals dpm
       join app.diet_plans dp on dp.id = dpm.plan_id
       left join app.recipes r on r.id = dpm.recipe_id
       where dpm.user_id = $1 and dp.status = 'active' and dpm.meal_date = $2
       order by dpm.slot_ordinal`,
    [userId, date],
  );
  const nextPlanned = SLOT_ORDER.map((slot) =>
    planRows.find((p) => p.slot === slot && !loggedSlots.has(slot)),
  ).find((p) => p !== undefined);
  const nextMeal: Schemas['Home']['next_meal'] = nextPlanned
    ? {
        plan_meal_id: nextPlanned.id,
        slot: nextPlanned.slot,
        title: nextPlanned.recipe_name ?? 'Planned meal',
      }
    : null;

  const { rows: workoutRows } = await client.query<WorkoutSessionRow>(
    `select wps.id, wps.title,
            case when wl.status in ('completed', 'skipped') then wl.status else wps.status end as status
       from app.workout_plan_sessions wps
       join app.workout_plans wp on wp.id = wps.plan_id
       left join lateral (
         select status from app.workout_logs
           where user_id = $1 and session_id = wps.id
           order by created_at desc limit 1
       ) wl on true
       where wps.user_id = $1 and wp.status = 'active' and wps.session_date = $2
       order by wps.session_order limit 1`,
    [userId, date],
  );
  const todaysWorkout: Schemas['Home']['todays_workout'] = workoutRows[0]
    ? { session_id: workoutRows[0].id, title: workoutRows[0].title, status: workoutRows[0].status }
    : null;

  const pending =
    profile?.onboarding_status === 'completed'
      ? (
          await client.query<PendingRequestRow>(
            `select id from app.generation_requests
               where user_id = $1 and request_type in ('diet_plan', 'plan_regeneration')
                 and status in ('queued', 'running')
               order by created_at desc limit 1`,
            [userId],
          )
        ).rows[0]
      : undefined;
  const planGeneration = pending ? await findJob(client, userId, pending.id) : null;

  return {
    date,
    nutrition,
    next_meal: nextMeal,
    todays_workout: todaysWorkout,
    insight: null, // A single-line Home insight is deferred to the dedicated /v1/insights screen.
    plan_generation: planGeneration,
  };
}
