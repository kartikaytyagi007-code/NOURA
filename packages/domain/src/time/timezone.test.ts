import { describe, expect, it } from 'vitest';
import { dateRange, localDateInTimezone, subtractDays, todayInTimezone } from './timezone.js';
import { isValidTimezone } from '../profile/validation.js';

describe('localDateInTimezone', () => {
  it('buckets a near-midnight UTC instant into the correct local date for a non-UTC zone', () => {
    // 2026-10-02T23:30:00Z is already 2026-10-03 in Asia/Kolkata (+05:30).
    const instant = new Date('2026-10-02T23:30:00Z');
    expect(localDateInTimezone(instant, 'Asia/Kolkata')).toBe('2026-10-03');
    expect(localDateInTimezone(instant, 'UTC')).toBe('2026-10-02');
  });

  it('distinguishes 11:59pm local from 12:01am local across the midnight boundary', () => {
    // Asia/Kolkata is UTC+05:30. 18:29 UTC is 23:59 local the same day; 18:31 UTC is 00:01 the next.
    expect(localDateInTimezone(new Date('2026-10-02T18:29:00Z'), 'Asia/Kolkata')).toBe(
      '2026-10-02',
    );
    expect(localDateInTimezone(new Date('2026-10-02T18:31:00Z'), 'Asia/Kolkata')).toBe(
      '2026-10-03',
    );
  });

  it('rejects an unknown timezone rather than silently falling back to UTC', () => {
    expect(() => localDateInTimezone(new Date(), 'Not/AZone')).toThrow();
  });
});

describe('isValidTimezone', () => {
  it('accepts a real IANA zone and rejects a bogus one', () => {
    expect(isValidTimezone('America/New_York')).toBe(true);
    expect(isValidTimezone('Nowhere/Fake')).toBe(false);
  });
});

describe('todayInTimezone', () => {
  it('computes "today" in the caller timezone, not server UTC', () => {
    const now = new Date('2026-10-02T23:30:00Z');
    expect(todayInTimezone('Asia/Kolkata', now)).toBe('2026-10-03');
    expect(todayInTimezone('America/Los_Angeles', now)).toBe('2026-10-02');
  });
});

describe('subtractDays / dateRange', () => {
  it('computes calendar-day arithmetic across a month boundary', () => {
    expect(subtractDays('2026-10-01', 1)).toBe('2026-09-30');
    expect(subtractDays('2026-10-07', 6)).toBe('2026-10-01');
  });

  it('builds an inclusive seven-day window', () => {
    const start = subtractDays('2026-10-07', 6);
    expect(dateRange(start, '2026-10-07')).toEqual([
      '2026-10-01',
      '2026-10-02',
      '2026-10-03',
      '2026-10-04',
      '2026-10-05',
      '2026-10-06',
      '2026-10-07',
    ]);
  });
});
