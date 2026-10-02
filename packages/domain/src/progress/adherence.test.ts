import { describe, expect, it } from 'vitest';
import { buildAdherenceSummary, countElapsed } from './adherence.js';

describe('countElapsed', () => {
  it('counts only dates on or before today', () => {
    const dates = ['2026-09-28', '2026-09-29', '2026-09-30', '2026-10-01', '2026-10-02'];
    expect(countElapsed(dates, '2026-09-30')).toBe(3);
  });

  it('excludes every future date, never counting it as a miss', () => {
    const dates = ['2026-10-05', '2026-10-06'];
    expect(countElapsed(dates, '2026-10-01')).toBe(0);
  });

  it('is a non-UTC-timezone-aware string comparison, not a date-object comparison', () => {
    // Local dates near a month boundary still compare correctly as plain strings.
    expect(countElapsed(['2026-09-30', '2026-10-01'], '2026-09-30')).toBe(1);
  });
});

describe('buildAdherenceSummary', () => {
  it('reports null (never 0) when no plan is active, so a client cannot render a fake 0-of-0', () => {
    const summary = buildAdherenceSummary(false, [], '2026-10-02', 3);
    expect(summary).toEqual({ plan_active: false, planned: null, logged: null });
  });

  it('counts only elapsed planned items against the caller-provided logged count', () => {
    const planned = ['2026-09-30', '2026-10-01', '2026-10-05']; // one is still in the future
    const summary = buildAdherenceSummary(true, planned, '2026-10-02', 1);
    expect(summary).toEqual({ plan_active: true, planned: 2, logged: 1 });
  });

  it('a real zero (an active plan with nothing logged yet) is distinct from "no plan"', () => {
    const summary = buildAdherenceSummary(true, ['2026-10-01'], '2026-10-02', 0);
    expect(summary).toEqual({ plan_active: true, planned: 1, logged: 0 });
  });
});
