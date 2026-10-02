/**
 * Timezone-aware local-date bucketing (blueprint §10, §6; docs/decisions.md D-028). "Today" and
 * "this week" for next-meal recommendations and nutrition summaries are always computed in the
 * user's own profile timezone, never server UTC — the same convention M4's meal-log `local_date`
 * capture already uses (`apps/api/src/modules/meals/log-service.ts`'s `localDateOf`), pulled out
 * here so M6's services can share it instead of re-deriving their own.
 */
import { AppError } from '../errors.js';
import { isValidTimezone } from '../profile/validation.js';

/** The local calendar date (YYYY-MM-DD) for an instant, in the given IANA timezone. */
export function localDateInTimezone(instant: Date, timezone: string): string {
  if (!isValidTimezone(timezone)) {
    throw new AppError('VALIDATION_ERROR', 'Unknown timezone.', {
      fieldErrors: [
        { field: 'timezone', code: 'invalid', message: 'not a recognized IANA timezone' },
      ],
    });
  }
  return new Intl.DateTimeFormat('en-CA', { timeZone: timezone }).format(instant);
}

/** The caller's "today" in their own timezone, as a YYYY-MM-DD string. */
export function todayInTimezone(timezone: string, now: Date = new Date()): string {
  return localDateInTimezone(now, timezone);
}

/** `date` minus `days` calendar days, as a YYYY-MM-DD string (pure date arithmetic, no timezone). */
export function subtractDays(date: string, days: number): string {
  const [y, m, d] = date.split('-').map(Number);
  const dt = new Date(Date.UTC(y!, (m ?? 1) - 1, d));
  dt.setUTCDate(dt.getUTCDate() - days);
  return dt.toISOString().slice(0, 10);
}

/** Inclusive list of YYYY-MM-DD strings from `start` to `end` (`start` <= `end`). */
export function dateRange(start: string, end: string): string[] {
  const dates: string[] = [];
  let cursor = start;
  // Bounded by construction (seven-day windows only, blueprint §10); guard against a bad input.
  for (let i = 0; i < 400 && cursor <= end; i++) {
    dates.push(cursor);
    cursor = subtractDays(cursor, -1);
  }
  return dates;
}
