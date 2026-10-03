import type { CatalogExercise, ExperienceLevel } from '../catalog/types.js';

/**
 * Deterministic workout-plan generation (blueprint §11, docs/decisions.md D-029), the exercise-catalog
 * counterpart to M3's diet-plan generation (`planning/generate.ts`). Pure and seed-free: the same
 * eligible-exercise pool, weekday selection and duration always produce the same week, which keeps
 * generation debuggable and testable without a model or randomness.
 *
 * Sets/reps/rest by experience level are engineering placeholders, not reviewed exercise-science
 * guidance (same honesty note as D-025's diet-plan thresholds) — see D-029.
 */

const CANONICAL_PATTERN_ORDER = [
  'squat',
  'hinge',
  'horizontal_push',
  'horizontal_pull',
  'vertical_push',
  'vertical_pull',
  'core',
  'carry',
  'conditioning',
] as const;

const MIN_EXERCISES_PER_SESSION = 3;
const MAX_EXERCISES_PER_SESSION = 6;

function clamp(value: number, min: number, max: number): number {
  return Math.min(max, Math.max(min, value));
}

interface Prescription {
  sets: number;
  reps_min: number;
  reps_max: number;
  rest_sec: number;
  effort_cue: string;
}

/** Placeholder set/rep/rest norms by level (not reviewed exercise science — D-029). */
const PRESCRIPTION_BY_LEVEL: Record<ExperienceLevel, Prescription> = {
  beginner: {
    sets: 3,
    reps_min: 10,
    reps_max: 12,
    rest_sec: 60,
    effort_cue: 'Controlled tempo. Stop a couple of reps before it gets hard.',
  },
  intermediate: {
    sets: 4,
    reps_min: 8,
    reps_max: 12,
    rest_sec: 75,
    effort_cue: 'Controlled tempo. Stop one or two reps before failure.',
  },
  advanced: {
    sets: 4,
    reps_min: 6,
    reps_max: 10,
    rest_sec: 90,
    effort_cue: 'Controlled tempo. The last rep of each set should feel hard but completable.',
  },
};

export function prescriptionForLevel(level: ExperienceLevel): Prescription {
  return PRESCRIPTION_BY_LEVEL[level];
}

export interface GeneratedExercise {
  ordinal: number;
  exercise: CatalogExercise;
  sets: number;
  reps_min: number;
  reps_max: number;
  rest_sec: number;
  effort_cue: string;
}

export interface GeneratedSession {
  date: string;
  session_order: number;
  title: string;
  exercises: GeneratedExercise[];
}

export interface GeneratedWorkoutPlan {
  sessions: GeneratedSession[];
}

export type WorkoutPlanGenerationResult =
  | { ok: true; plan: GeneratedWorkoutPlan }
  | { ok: false; reason: 'no_eligible_exercises' }
  | { ok: false; reason: 'insufficient_weekdays'; have: number; need: number };

export interface GenerateWorkoutPlanInput {
  /** ISO date (UTC) of the first day of the generated week. */
  startsOn: string;
  /** ISO weekdays (1 = Monday ... 7 = Sunday) the user is available to train. */
  weekdays: readonly number[];
  daysPerWeek: number;
  durationMinutes: number;
  eligibleExercises: readonly CatalogExercise[];
}

function addDays(isoDate: string, days: number): string {
  const d = new Date(`${isoDate}T00:00:00.000Z`);
  d.setUTCDate(d.getUTCDate() + days);
  return d.toISOString().slice(0, 10);
}

/** ISO weekday (1 = Monday ... 7 = Sunday) of a UTC date string. */
function isoWeekdayOf(isoDate: string): number {
  const jsDay = new Date(`${isoDate}T00:00:00.000Z`).getUTCDay(); // 0 = Sunday
  return jsDay === 0 ? 7 : jsDay;
}

function titleFor(patterns: readonly string[]): string {
  const unique = [...new Set(patterns)];
  const label = (p: string) => p.replace(/_/g, ' ');
  if (unique.length <= 2) return unique.map(label).join(' and ') + ' session';
  return 'Full-body session';
}

export function generateWorkoutPlan(input: GenerateWorkoutPlanInput): WorkoutPlanGenerationResult {
  if (input.eligibleExercises.length === 0) return { ok: false, reason: 'no_eligible_exercises' };

  const selectedWeekdays = [...new Set(input.weekdays)].sort((a, b) => a - b);
  if (selectedWeekdays.length < input.daysPerWeek) {
    return {
      ok: false,
      reason: 'insufficient_weekdays',
      have: selectedWeekdays.length,
      need: input.daysPerWeek,
    };
  }
  const weekdaySet = new Set(selectedWeekdays.slice(0, input.daysPerWeek));

  const poolByPattern = new Map<string, CatalogExercise[]>();
  for (const exercise of input.eligibleExercises) {
    const pool = poolByPattern.get(exercise.movement_pattern) ?? [];
    pool.push(exercise);
    poolByPattern.set(exercise.movement_pattern, pool);
  }
  const patternsAvailable = CANONICAL_PATTERN_ORDER.filter((p) => poolByPattern.has(p));
  // Any pattern tags outside the canonical list are still honoured, appended in catalog order.
  for (const pattern of poolByPattern.keys()) {
    if (!(patternsAvailable as readonly string[]).includes(pattern)) {
      (patternsAvailable as string[]).push(pattern);
    }
  }
  if (patternsAvailable.length === 0) return { ok: false, reason: 'no_eligible_exercises' };

  const exercisesPerSession = clamp(
    Math.round(input.durationMinutes / 8),
    MIN_EXERCISES_PER_SESSION,
    MAX_EXERCISES_PER_SESSION,
  );

  const sessions: GeneratedSession[] = [];
  let sessionIndex = 0;
  for (let dayOffset = 0; dayOffset < 7; dayOffset += 1) {
    const date = addDays(input.startsOn, dayOffset);
    if (!weekdaySet.has(isoWeekdayOf(date))) continue;

    const patternCounts = new Map<string, number>();
    const exercises: GeneratedExercise[] = [];
    const usedIds = new Set<string>();
    const patterns: string[] = [];
    let ordinal = 1;
    let attempts = 0;
    while (
      exercises.length < exercisesPerSession &&
      attempts < exercisesPerSession * patternsAvailable.length + patternsAvailable.length
    ) {
      const pattern = patternsAvailable[
        (ordinal - 1 + exercises.length) % patternsAvailable.length
      ] as string;
      const pool = poolByPattern.get(pattern) as CatalogExercise[];
      const count = patternCounts.get(pattern) ?? 0;
      const candidate = pool[(sessionIndex + count) % pool.length] as CatalogExercise;
      patternCounts.set(pattern, count + 1);
      attempts += 1;
      // Avoid repeating the same exercise twice in one session when alternatives exist.
      if (usedIds.has(candidate.id) && pool.length > count) continue;
      if (usedIds.has(candidate.id) && exercises.length >= patternsAvailable.length) continue;
      usedIds.add(candidate.id);
      patterns.push(pattern);
      const prescription = prescriptionForLevel(candidate.level);
      exercises.push({
        ordinal,
        exercise: candidate,
        sets: prescription.sets,
        reps_min: prescription.reps_min,
        reps_max: prescription.reps_max,
        rest_sec: prescription.rest_sec,
        effort_cue: prescription.effort_cue,
      });
      ordinal += 1;
    }

    sessionIndex += 1;
    sessions.push({
      date,
      session_order: sessionIndex,
      title: titleFor(patterns),
      exercises,
    });
  }

  return { ok: true, plan: { sessions } };
}
