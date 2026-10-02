import { sumNutrientTotals, type NutrientTotals } from '../catalog/nutrition.js';

/**
 * Daily and seven-day nutrition-pattern summaries (blueprint §10, §16 M6; docs/decisions.md D-028).
 * Gaps (protein, fibre) are identified ONLY when the underlying data actually supports the
 * conclusion — a day whose logged meals have incomplete nutrient coverage is excluded from the
 * seven-day average rather than silently counted as zero, and the exclusion is reported, not hidden
 * (the ticket's gap-detection honesty constraint, repeated twice in the ticket).
 *
 * No 30/90-day analysis (explicitly out of scope, blueprint §15); this module only ever sees a
 * caller-bounded window of up to seven days.
 */

export type GapNutrient = 'protein' | 'fibre';

/** A day's gap/adequacy read counts only when its average is below this fraction of target. */
const GAP_THRESHOLD_FRACTION = 0.8;

/** The seven-day average needs at least this many usable days before a gap is ever reported. */
export const MIN_USABLE_DAYS_FOR_WEEKLY_GAPS = 3;

export interface DayLog {
  date: string;
  totals: NutrientTotals;
  logged_meals: number;
}

export interface DailyPatternOut {
  date: string;
  totals: NutrientTotals;
  logged_meals: number;
  /** False when nothing was logged, or something was logged but its nutrition isn't fully known. */
  coverage_complete: boolean;
  gaps: GapNutrient[];
  note: string | null;
}

export interface DailyTargets {
  protein_g: number | null;
  fibre_g: number | null;
}

/**
 * One day's pattern read. A day with zero logged meals is distinguished from a day with incomplete
 * coverage (blueprint §9 "distinguish unlogged from missed meals", applied here to pattern evidence
 * too) — both are honest, neither claims a gap.
 */
export function computeDailyPattern(day: DayLog, targets: DailyTargets | null): DailyPatternOut {
  if (day.logged_meals === 0) {
    return {
      date: day.date,
      totals: day.totals,
      logged_meals: 0,
      coverage_complete: false,
      gaps: [],
      note: 'No meals logged for this day.',
    };
  }
  if (!day.totals.coverage.complete) {
    return {
      date: day.date,
      totals: day.totals,
      logged_meals: day.logged_meals,
      coverage_complete: false,
      gaps: [],
      note: "Some logged items don't have nutrition information yet, so gaps can't be identified for this day.",
    };
  }
  const gaps: GapNutrient[] = [];
  if (
    targets?.protein_g != null &&
    (day.totals.nutrients.protein_g ?? 0) < targets.protein_g * GAP_THRESHOLD_FRACTION
  ) {
    gaps.push('protein');
  }
  if (
    targets?.fibre_g != null &&
    (day.totals.nutrients.fibre_g ?? 0) < targets.fibre_g * GAP_THRESHOLD_FRACTION
  ) {
    gaps.push('fibre');
  }
  return {
    date: day.date,
    totals: day.totals,
    logged_meals: day.logged_meals,
    coverage_complete: true,
    gaps,
    note: null,
  };
}

export interface WeeklyPatternOut {
  period_start: string;
  period_end: string;
  logged_meals: number;
  days_with_logs: number;
  /** Days with at least one logged meal AND complete nutrient coverage; the average's denominator. */
  usable_days: number;
  /** Null only when there are zero usable days — never a number derived from a partial picture. */
  average: { energy_kcal: number | null; protein_g: number | null; fibre_g: number | null } | null;
  /** Identified only when `usable_days >= MIN_USABLE_DAYS_FOR_WEEKLY_GAPS` and targets are known. */
  gaps: GapNutrient[];
  /** Dates left out of the average because nothing was logged or coverage was incomplete. */
  excluded_days: string[];
  /** True whenever at least one day in the window was excluded from the average. */
  uncertain: boolean;
}

function average(values: readonly (number | null)[]): number | null {
  const usable = values.filter((v): v is number => v !== null);
  if (usable.length === 0) return null;
  return Math.round((usable.reduce((s, v) => s + v, 0) / usable.length) * 10) / 10;
}

/**
 * Seven-day pattern from each day's own already-computed `DailyPatternOut`. The average is taken
 * only over "usable" days (logged and fully covered); every excluded day is named in
 * `excluded_days`, and a gap is only ever reported once there are enough usable days to support the
 * conclusion (`MIN_USABLE_DAYS_FOR_WEEKLY_GAPS`), per the ticket's explicit, twice-stated constraint.
 */
export function computeWeeklyPattern(
  days: readonly DailyPatternOut[],
  targets: DailyTargets | null,
): WeeklyPatternOut {
  if (days.length === 0) {
    throw new Error('computeWeeklyPattern requires at least one day');
  }
  const loggedMeals = days.reduce((s, d) => s + d.logged_meals, 0);
  const daysWithLogs = days.filter((d) => d.logged_meals > 0).length;
  const usable = days.filter((d) => d.logged_meals > 0 && d.coverage_complete);
  const excluded = days
    .filter((d) => !(d.logged_meals > 0 && d.coverage_complete))
    .map((d) => d.date);

  const base = {
    period_start: days[0]!.date,
    period_end: days[days.length - 1]!.date,
    logged_meals: loggedMeals,
    days_with_logs: daysWithLogs,
    excluded_days: excluded,
    uncertain: excluded.length > 0,
  };

  if (usable.length === 0) {
    return { ...base, usable_days: 0, average: null, gaps: [] };
  }

  const avgEnergy = average(usable.map((d) => d.totals.nutrients.energy_kcal));
  const avgProtein = average(usable.map((d) => d.totals.nutrients.protein_g));
  const avgFibre = average(usable.map((d) => d.totals.nutrients.fibre_g));

  const gaps: GapNutrient[] = [];
  if (usable.length >= MIN_USABLE_DAYS_FOR_WEEKLY_GAPS && targets) {
    if (
      targets.protein_g != null &&
      avgProtein != null &&
      avgProtein < targets.protein_g * GAP_THRESHOLD_FRACTION
    ) {
      gaps.push('protein');
    }
    if (
      targets.fibre_g != null &&
      avgFibre != null &&
      avgFibre < targets.fibre_g * GAP_THRESHOLD_FRACTION
    ) {
      gaps.push('fibre');
    }
  }

  return {
    ...base,
    usable_days: usable.length,
    average: { energy_kcal: avgEnergy, protein_g: avgProtein, fibre_g: avgFibre },
    gaps,
  };
}

/** Convenience: sums a day's meal-log totals the same honest way `sumAnalyzedNutrition` does. */
export function sumDayTotals(mealTotals: readonly NutrientTotals[]): NutrientTotals {
  if (mealTotals.length === 0) {
    return {
      nutrients: {
        energy_kcal: null,
        protein_g: null,
        carbohydrate_g: null,
        fat_g: null,
        fibre_g: null,
      },
      coverage: { items_total: 0, items_with_nutrition: 0, complete: false },
    };
  }
  return sumNutrientTotals(mealTotals);
}
