/**
 * Meal-plan adherence and workout-consistency counting (blueprint §6, §16 "M8 Progress";
 * docs/decisions.md D-030). Every function here is a pure, honest count over dates that have already
 * elapsed in the user's own timezone — never a prediction, never an inference from missing data, and
 * never a claim of causation. "Elapsed" means `date <= today`; a planned meal or scheduled session on
 * a future date is excluded entirely rather than counted as a miss (same convention as the blueprint's
 * workout-consistency denominator: "scheduled sessions elapsed, excluding future sessions").
 */

/** How many of `dates` fall on or before `today` (all YYYY-MM-DD strings, compared lexicographically). */
export function countElapsed(dates: readonly string[], today: string): number {
  return dates.filter((d) => d <= today).length;
}

export interface AdherenceSummary {
  /** Whether the user has any plan to measure adherence against at all. */
  plan_active: boolean;
  /** Null, never 0, when there is no active plan — a missing plan is not a real zero (ticket). */
  planned: number | null;
  logged: number | null;
}

/**
 * Builds an honest adherence summary. When no plan is active, `planned`/`logged` are null so a
 * client can never render "0 of 0" as if it were a real adherence number.
 */
export function buildAdherenceSummary(
  planActive: boolean,
  elapsedPlannedDates: readonly string[],
  todayLocalDate: string,
  loggedCount: number,
): AdherenceSummary {
  if (!planActive) return { plan_active: false, planned: null, logged: null };
  const planned = countElapsed(elapsedPlannedDates, todayLocalDate);
  return { plan_active: true, planned, logged: loggedCount };
}
