import type { ExperienceLevel, TrainingLocation } from '../catalog/types.js';
import type { Queryable } from '../db/user-transaction.js';
import type { EligibilityStatus } from '../eligibility/index.js';
import type { TrainingConstraints } from './eligibility.js';

export interface WorkoutPlanningInputs {
  /** `app.training_preferences.revision`; null when the user has never saved training preferences. */
  trainingRevision: number | null;
  eligibilityStatus: EligibilityStatus | null;
  weekdays: number[];
  daysPerWeek: number | null;
  durationMinutes: number | null;
  constraints: TrainingConstraints;
  /** True once every field required to generate a plan is present (blueprint §11). */
  hasCompleteTrainingPreferences: boolean;
}

interface ProfileRow {
  eligibility_status: EligibilityStatus | null;
}

interface TrainingRow {
  experience: ExperienceLevel | null;
  location: TrainingLocation | null;
  equipment_ids: string[];
  weekdays: number[];
  days_per_week: number | null;
  duration_minutes: number | null;
  limitation_tags: string[];
  revision: number;
}

/**
 * Everything workout-plan generation and substitution filtering need, reloaded fresh under the
 * caller's own transaction context (API or worker) — the exercise-catalog counterpart to
 * `planning/inputs.ts`'s `loadDietPlanningInputs`, which is what keeps the API's feasibility checks
 * and the worker's generation consistent with each other.
 */
export async function loadWorkoutPlanningInputs(
  client: Queryable,
  userId: string,
): Promise<WorkoutPlanningInputs> {
  const profile = (
    await client.query<ProfileRow>(
      'select eligibility_status from app.profiles where user_id = $1',
      [userId],
    )
  ).rows[0];
  const training = (
    await client.query<TrainingRow>(
      `select experience, location, equipment_ids, weekdays, days_per_week, duration_minutes,
              limitation_tags, revision
         from app.training_preferences where user_id = $1`,
      [userId],
    )
  ).rows[0];

  const hasCompleteTrainingPreferences = Boolean(
    training &&
    training.location &&
    training.experience &&
    training.days_per_week !== null &&
    training.duration_minutes !== null &&
    training.weekdays.length >= training.days_per_week,
  );

  return {
    trainingRevision: training?.revision ?? null,
    eligibilityStatus: profile?.eligibility_status ?? null,
    weekdays: training?.weekdays ?? [],
    daysPerWeek: training?.days_per_week ?? null,
    durationMinutes: training?.duration_minutes ?? null,
    constraints: {
      location: training?.location ?? null,
      equipmentIds: training?.equipment_ids ?? [],
      experience: training?.experience ?? null,
      limitationTags: training?.limitation_tags ?? [],
    },
    hasCompleteTrainingPreferences,
  };
}
