import { describe, expect, it } from 'vitest';
import {
  isValidTimezone,
  normalizeDisplayName,
  validateGoal,
  validateTraining,
} from './validation.js';

describe('isValidTimezone', () => {
  it('accepts IANA names', () => {
    for (const tz of ['Asia/Kolkata', 'UTC', 'America/Argentina/Buenos_Aires', 'Europe/London']) {
      expect(isValidTimezone(tz), tz).toBe(true);
    }
  });
  it('rejects unknown, malformed and offset-style values', () => {
    for (const tz of ['Mars/Olympus', 'IST+5:30', '+05:30', '', 'Asia/', '../etc', 'a b']) {
      expect(isValidTimezone(tz), tz).toBe(false);
    }
  });
});

describe('normalizeDisplayName', () => {
  it('trims, collapses whitespace and strips control characters', () => {
    expect(normalizeDisplayName('  Asha   Rao ')).toBe('Asha Rao');
    expect(normalizeDisplayName('A\u0000sha\n')).toBe('A sha');
  });
  it('returns null when nothing printable remains', () => {
    expect(normalizeDisplayName('   \n\t ')).toBeNull();
  });
});

describe('validateGoal', () => {
  it('requires a fat-loss target below, and a muscle-gain target above, the current weight', () => {
    expect(validateGoal({ goal_type: 'lose_fat', target_weight_kg: 80 }, 70)[0]?.code).toBe(
      'target_not_below_current',
    );
    expect(validateGoal({ goal_type: 'lose_fat', target_weight_kg: 65 }, 70)).toEqual([]);
    expect(validateGoal({ goal_type: 'gain_muscle', target_weight_kg: 70 }, 70)[0]?.code).toBe(
      'target_not_above_current',
    );
    expect(validateGoal({ goal_type: 'gain_muscle', target_weight_kg: 75 }, 70)).toEqual([]);
  });
  it('does not check what it cannot compare', () => {
    expect(validateGoal({ goal_type: 'lose_fat', target_weight_kg: null }, 70)).toEqual([]);
    expect(validateGoal({ goal_type: 'lose_fat', target_weight_kg: 90 }, null)).toEqual([]);
    expect(validateGoal({ goal_type: 'maintain', target_weight_kg: 90 }, 70)).toEqual([]);
  });
});

describe('validateTraining', () => {
  const ok = {
    location: 'gym',
    equipment_ids: [],
    weekdays: [1, 3, 5],
    days_per_week: 3,
  } as const;
  it('accepts consistent input', () => {
    expect(validateTraining(ok)).toEqual([]);
  });
  it('needs at least days_per_week available weekdays', () => {
    expect(validateTraining({ ...ok, weekdays: [1, 3] })[0]?.code).toBe('fewer_than_days_per_week');
  });
  it('needs equipment for home or mixed training', () => {
    expect(validateTraining({ ...ok, location: 'home' })[0]?.code).toBe('equipment_required');
    expect(validateTraining({ ...ok, location: 'both', equipment_ids: ['bodyweight'] })).toEqual(
      [],
    );
  });
});
