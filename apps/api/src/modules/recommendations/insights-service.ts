import {
  computeDailyPattern,
  computeWeeklyPattern,
  dateRange,
  loadDietPlanningInputs,
  sumNutrientTotals,
  subtractDays,
  todayInTimezone,
  type DailyPatternOut,
  type NutrientTotals,
  type Queryable,
} from '@noura/domain';
import type { components } from '@noura/contracts';

type Schemas = components['schemas'];

interface ProfileRow {
  timezone: string;
}

interface LogRow {
  local_date: Date;
  totals_snapshot: NutrientTotals;
}

function isoDate(d: Date): string {
  return d.toISOString().slice(0, 10);
}

/**
 * Seven-day nutrition-pattern summary (blueprint §10, §16 M6; D-028). Each day's own coverage is
 * computed first (`computeDailyPattern`), then rolled into the week (`computeWeeklyPattern`), so the
 * gap-detection honesty rule is enforced once, in `packages/domain/src/meals/nutrition-patterns.ts`,
 * and this service only shapes the result for the contract.
 */
export async function getInsights(client: Queryable, userId: string): Promise<Schemas['Insights']> {
  const profile = (
    await client.query<ProfileRow>('select timezone from app.profiles where user_id = $1', [userId])
  ).rows[0];
  const timezone = profile?.timezone ?? 'UTC';
  const today = todayInTimezone(timezone);
  const start = subtractDays(today, 6);
  const window = dateRange(start, today);

  const { rows } = await client.query<LogRow>(
    `select local_date, totals_snapshot from app.meal_logs
       where user_id = $1 and local_date between $2 and $3`,
    [userId, start, today],
  );
  const byDate = new Map<string, NutrientTotals[]>();
  for (const row of rows) {
    const key = isoDate(row.local_date);
    const list = byDate.get(key) ?? [];
    list.push(row.totals_snapshot);
    byDate.set(key, list);
  }

  const { dailyTargets } = await loadDietPlanningInputs(client, userId);

  const dailyPatterns: DailyPatternOut[] = window.map((date) => {
    const mealTotals = byDate.get(date) ?? [];
    const totals =
      mealTotals.length === 0
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
        : sumNutrientTotals(mealTotals);
    return computeDailyPattern({ date, totals, logged_meals: mealTotals.length }, dailyTargets);
  });

  const weekly = computeWeeklyPattern(dailyPatterns, dailyTargets);

  const insights: Schemas['Insight'][] = [];
  if (weekly.gaps.includes('protein')) {
    insights.push({
      key: 'protein_gap',
      evidence: {
        average_protein_g: weekly.average?.protein_g ?? null,
        target_protein_g: dailyTargets?.protein_g ?? null,
        usable_days: weekly.usable_days,
      },
      explanation: `Average protein across ${weekly.usable_days} day(s) with complete data is ${weekly.average?.protein_g ?? '—'}g, below your daily target. This reflects logged intake only, not a proven deficit.`,
    });
  }
  if (weekly.gaps.includes('fibre')) {
    insights.push({
      key: 'fibre_gap',
      evidence: {
        average_fibre_g: weekly.average?.fibre_g ?? null,
        target_fibre_g: dailyTargets?.fibre_g ?? null,
        usable_days: weekly.usable_days,
      },
      explanation: `Average fibre across ${weekly.usable_days} day(s) with complete data is ${weekly.average?.fibre_g ?? '—'}g, below your daily target. This reflects logged intake only, not a proven deficit.`,
    });
  }
  if (weekly.uncertain) {
    insights.push({
      key: 'coverage',
      evidence: {
        usable_days: weekly.usable_days,
        days_with_logs: weekly.days_with_logs,
        excluded_days: weekly.excluded_days,
      },
      explanation:
        weekly.usable_days === 0
          ? "Based on 0 days with complete data this week, so a pattern can't be shown yet."
          : `Based on ${weekly.usable_days} of 7 days with complete data; ${weekly.excluded_days.length} day(s) were excluded (missing logs or unmatched items).`,
    });
  }

  const focus =
    insights.find((i) => i.key === 'protein_gap' || i.key === 'fibre_gap') ?? insights[0] ?? null;

  return {
    period_start: weekly.period_start,
    period_end: weekly.period_end,
    logged_meals: weekly.logged_meals,
    days_with_logs: weekly.days_with_logs,
    usable_days: weekly.usable_days,
    excluded_days: weekly.excluded_days,
    coverage_uncertain: weekly.uncertain,
    insights: insights.slice(0, 3),
    focus,
  };
}
