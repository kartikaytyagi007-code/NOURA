import { describe, expect, it } from 'vitest';
import { generateWorkoutPlan } from './generate.js';
import { ALL_EXERCISES, BARBELL_SQUAT, BODYWEIGHT_SQUAT } from './test-fixtures.js';

describe('generateWorkoutPlan', () => {
  it('schedules exactly days_per_week sessions on the selected weekdays', () => {
    const result = generateWorkoutPlan({
      startsOn: '2026-10-05', // Monday
      weekdays: [1, 3, 5], // Mon, Wed, Fri
      daysPerWeek: 3,
      durationMinutes: 40,
      eligibleExercises: ALL_EXERCISES,
    });
    expect(result.ok).toBe(true);
    if (!result.ok) return;
    expect(result.plan.sessions).toHaveLength(3);
    expect(result.plan.sessions.map((s) => s.date)).toEqual([
      '2026-10-05',
      '2026-10-07',
      '2026-10-09',
    ]);
    expect(result.plan.sessions.map((s) => s.session_order)).toEqual([1, 2, 3]);
  });

  it('never prescribes an exercise outside the eligible pool (equipment/location/limitations)', () => {
    // Only the bodyweight squat is eligible: a barbell squat must never appear.
    const result = generateWorkoutPlan({
      startsOn: '2026-10-05',
      weekdays: [1],
      daysPerWeek: 1,
      durationMinutes: 30,
      eligibleExercises: [BODYWEIGHT_SQUAT],
    });
    expect(result.ok).toBe(true);
    if (!result.ok) return;
    for (const session of result.plan.sessions) {
      for (const ex of session.exercises) {
        expect(ex.exercise.id).not.toBe(BARBELL_SQUAT.id);
        expect(ex.exercise.id).toBe(BODYWEIGHT_SQUAT.id);
      }
    }
  });

  it('scales the number of exercises per session toward the requested duration, within bounds', () => {
    const short = generateWorkoutPlan({
      startsOn: '2026-10-05',
      weekdays: [1],
      daysPerWeek: 1,
      durationMinutes: 15,
      eligibleExercises: ALL_EXERCISES,
    });
    const long = generateWorkoutPlan({
      startsOn: '2026-10-05',
      weekdays: [1],
      daysPerWeek: 1,
      durationMinutes: 90,
      eligibleExercises: ALL_EXERCISES,
    });
    expect(short.ok && long.ok).toBe(true);
    if (!short.ok || !long.ok) return;
    const shortCount = short.plan.sessions[0]!.exercises.length;
    const longCount = long.plan.sessions[0]!.exercises.length;
    expect(shortCount).toBeGreaterThanOrEqual(3);
    expect(longCount).toBeLessThanOrEqual(6);
    expect(longCount).toBeGreaterThan(shortCount);
  });

  it('is deterministic: the same inputs always produce the same plan', () => {
    const input = {
      startsOn: '2026-10-05',
      weekdays: [1, 2, 4],
      daysPerWeek: 3,
      durationMinutes: 45,
      eligibleExercises: ALL_EXERCISES,
    };
    const a = generateWorkoutPlan(input);
    const b = generateWorkoutPlan(input);
    expect(a).toEqual(b);
  });

  it('reports infeasibility honestly when no exercise is eligible at all', () => {
    const result = generateWorkoutPlan({
      startsOn: '2026-10-05',
      weekdays: [1],
      daysPerWeek: 1,
      durationMinutes: 30,
      eligibleExercises: [],
    });
    expect(result).toEqual({ ok: false, reason: 'no_eligible_exercises' });
  });

  it('reports infeasibility honestly when fewer weekdays are available than days_per_week', () => {
    const result = generateWorkoutPlan({
      startsOn: '2026-10-05',
      weekdays: [1, 3],
      daysPerWeek: 3,
      durationMinutes: 30,
      eligibleExercises: ALL_EXERCISES,
    });
    expect(result).toEqual({ ok: false, reason: 'insufficient_weekdays', have: 2, need: 3 });
  });
});
