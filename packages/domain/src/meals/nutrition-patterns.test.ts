import { describe, expect, it } from 'vitest';
import {
  computeDailyPattern,
  computeWeeklyPattern,
  MIN_USABLE_DAYS_FOR_WEEKLY_GAPS,
  type DailyPatternOut,
  type DayLog,
} from './nutrition-patterns.js';
import type { NutrientTotals } from '../catalog/nutrition.js';

const complete = (protein: number, fibre: number, energy = 1800): NutrientTotals => ({
  nutrients: {
    energy_kcal: energy,
    protein_g: protein,
    carbohydrate_g: 200,
    fat_g: 60,
    fibre_g: fibre,
  },
  coverage: { items_total: 3, items_with_nutrition: 3, complete: true },
});

const incomplete: NutrientTotals = {
  nutrients: {
    energy_kcal: null,
    protein_g: null,
    carbohydrate_g: null,
    fat_g: null,
    fibre_g: null,
  },
  coverage: { items_total: 2, items_with_nutrition: 1, complete: false },
};

describe('computeDailyPattern', () => {
  it('flags a day with no logged meals, never a fabricated zero', () => {
    const day: DayLog = { date: '2026-10-01', totals: incomplete, logged_meals: 0 };
    const result = computeDailyPattern(day, { protein_g: 100, fibre_g: 30 });
    expect(result.coverage_complete).toBe(false);
    expect(result.gaps).toEqual([]);
    expect(result.note).toMatch(/No meals logged/);
  });

  it('flags incomplete coverage distinctly from no logs, and claims no gap', () => {
    const day: DayLog = { date: '2026-10-01', totals: incomplete, logged_meals: 2 };
    const result = computeDailyPattern(day, { protein_g: 100, fibre_g: 30 });
    expect(result.coverage_complete).toBe(false);
    expect(result.gaps).toEqual([]);
    expect(result.note).toMatch(/don't have nutrition information/);
  });

  it('identifies a gap only when coverage is complete and the target is known', () => {
    const day: DayLog = { date: '2026-10-01', totals: complete(20, 25), logged_meals: 3 };
    const result = computeDailyPattern(day, { protein_g: 100, fibre_g: 30 });
    expect(result.coverage_complete).toBe(true);
    expect(result.gaps).toEqual(['protein']);
    expect(result.note).toBeNull();
  });

  it('reports no gap once intake meets 80% of target', () => {
    const day: DayLog = { date: '2026-10-01', totals: complete(85, 25), logged_meals: 3 };
    const result = computeDailyPattern(day, { protein_g: 100, fibre_g: 30 });
    expect(result.gaps).toEqual([]);
  });
});

function pattern(date: string, p: DailyPatternOut): DailyPatternOut {
  return { ...p, date };
}

describe('computeWeeklyPattern', () => {
  const completeDay = (date: string, protein: number, fibre: number): DailyPatternOut =>
    pattern(date, {
      date,
      totals: complete(protein, fibre),
      logged_meals: 2,
      coverage_complete: true,
      gaps: [],
      note: null,
    });
  const emptyDay = (date: string): DailyPatternOut =>
    pattern(date, {
      date,
      totals: incomplete,
      logged_meals: 0,
      coverage_complete: false,
      gaps: [],
      note: 'No meals logged for this day.',
    });
  const uncertainDay = (date: string): DailyPatternOut =>
    pattern(date, {
      date,
      totals: incomplete,
      logged_meals: 2,
      coverage_complete: false,
      gaps: [],
      note: "Some logged items don't have nutrition information yet, so gaps can't be identified for this day.",
    });

  it('averages only over usable (logged and fully covered) days, excluding the rest by name', () => {
    const days = [
      completeDay('2026-09-26', 100, 30),
      completeDay('2026-09-27', 100, 30),
      emptyDay('2026-09-28'),
      uncertainDay('2026-09-29'),
      completeDay('2026-09-30', 100, 30),
      completeDay('2026-10-01', 100, 30),
      completeDay('2026-10-02', 100, 30),
    ];
    const result = computeWeeklyPattern(days, { protein_g: 100, fibre_g: 30 });
    expect(result.usable_days).toBe(5);
    expect(result.days_with_logs).toBe(6);
    expect(result.excluded_days).toEqual(['2026-09-28', '2026-09-29']);
    expect(result.uncertain).toBe(true);
    expect(result.average).toEqual({ energy_kcal: 1800, protein_g: 100, fibre_g: 30 });
  });

  it('never silently counts a missing/incomplete day as zero in the average', () => {
    const days = [
      completeDay('2026-09-26', 200, 40),
      emptyDay('2026-09-27'),
      emptyDay('2026-09-28'),
      emptyDay('2026-09-29'),
      emptyDay('2026-09-30'),
      emptyDay('2026-10-01'),
      emptyDay('2026-10-02'),
    ];
    const result = computeWeeklyPattern(days, { protein_g: 100, fibre_g: 30 });
    // Only one usable day; the average reflects that single day, not six zeros averaged in.
    expect(result.usable_days).toBe(1);
    expect(result.average!.protein_g).toBe(200);
  });

  it('reports a fully uncertain pattern (null average) when there are zero usable days', () => {
    const days = Array.from({ length: 7 }, (_, i) => emptyDay(`2026-09-2${i}`));
    const result = computeWeeklyPattern(days, { protein_g: 100, fibre_g: 30 });
    expect(result.usable_days).toBe(0);
    expect(result.average).toBeNull();
    expect(result.gaps).toEqual([]);
    expect(result.uncertain).toBe(true);
  });

  it('withholds a weekly gap claim until enough usable days exist', () => {
    expect(MIN_USABLE_DAYS_FOR_WEEKLY_GAPS).toBeGreaterThan(1);
    const days = [
      completeDay('2026-09-26', 20, 5),
      emptyDay('2026-09-27'),
      emptyDay('2026-09-28'),
      emptyDay('2026-09-29'),
      emptyDay('2026-09-30'),
      emptyDay('2026-10-01'),
      emptyDay('2026-10-02'),
    ];
    const result = computeWeeklyPattern(days, { protein_g: 100, fibre_g: 30 });
    expect(result.usable_days).toBe(1);
    expect(result.gaps).toEqual([]);
  });

  it('identifies a weekly gap once enough usable days show it', () => {
    const days = [
      completeDay('2026-09-26', 20, 5),
      completeDay('2026-09-27', 20, 5),
      completeDay('2026-09-28', 20, 5),
      completeDay('2026-09-29', 20, 5),
      completeDay('2026-09-30', 20, 5),
      completeDay('2026-10-01', 20, 5),
      completeDay('2026-10-02', 20, 5),
    ];
    const result = computeWeeklyPattern(days, { protein_g: 100, fibre_g: 30 });
    expect(result.usable_days).toBe(7);
    expect(result.gaps.sort()).toEqual(['fibre', 'protein']);
    expect(result.uncertain).toBe(false);
  });
});
