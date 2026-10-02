import { buildNextMealRecommendation, type Queryable } from '@noura/domain';
import type { components } from '@noura/contracts';
import { loadTodayContext } from './context.js';

type Schemas = components['schemas'];
type MealSlot = Schemas['MealSlot'];

interface DismissalRow {
  slot: MealSlot;
}

export async function getNextMeal(
  client: Queryable,
  userId: string,
  date: string | undefined,
  requestedSlot: MealSlot | undefined,
): Promise<Schemas['NextMeal']> {
  const ctx = await loadTodayContext(client, userId, date);

  const dismissals = (
    await client.query<DismissalRow>(
      'select slot from app.dismissed_recommendations where user_id = $1 and local_date = $2',
      [userId, ctx.date],
    )
  ).rows;
  const dismissedSlots = new Set(dismissals.map((d) => d.slot));

  const candidateSlot = requestedSlot ?? null;
  const dismissed = candidateSlot ? dismissedSlots.has(candidateSlot) : false;

  const result = buildNextMealRecommendation({
    requestedSlot: candidateSlot,
    plannedSlots: ctx.plannedSlots,
    loggedSlots: ctx.loggedSlots,
    loggedMealsCount: ctx.loggedMealsCount,
    todayTotals: ctx.todayTotals,
    eligibleRecipes: ctx.eligibleRecipes,
    dailyTargets: ctx.planningInputs.dailyTargets,
    dismissed,
  });

  // When no slot was requested, the engine may resolve to a different slot than any explicitly
  // checked above; re-check dismissal for the slot it actually picked.
  if (!candidateSlot && dismissedSlots.has(result.slot) && result.options.length > 0) {
    const redone = buildNextMealRecommendation({
      requestedSlot: result.slot,
      plannedSlots: ctx.plannedSlots,
      loggedSlots: ctx.loggedSlots,
      loggedMealsCount: ctx.loggedMealsCount,
      todayTotals: ctx.todayTotals,
      eligibleRecipes: ctx.eligibleRecipes,
      dailyTargets: ctx.planningInputs.dailyTargets,
      dismissed: true,
    });
    return { date: ctx.date, ...redone };
  }

  return { date: ctx.date, ...result };
}
