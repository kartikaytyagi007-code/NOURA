import { AppError, answersFromFlags, type Queryable } from '@noura/domain';
import type { components } from '@noura/contracts';

type Me = components['schemas']['Me'];

interface ProfileRow {
  user_id: string;
  display_name: string | null;
  age_years: number | null;
  calculation_sex: 'female' | 'male' | null;
  height_cm: string | null;
  weight_kg: string | null;
  activity_band: Me['profile']['activity_band'];
  timezone: string;
  unit_system: 'metric' | 'imperial';
  onboarding_status: Me['onboarding']['status'];
  onboarding_step: Me['onboarding']['step'];
  eligibility_status: Me['eligibility_status'];
  screening_flags: string[];
  screening_answered: boolean;
  revision: number;
}

interface GoalRow {
  goal_type: NonNullable<Me['goal']>['goal_type'];
  target_weight_kg: string | null;
}

interface PreferencesRow {
  diet_type: NonNullable<Me['preferences']>['diet_type'];
  allergy_ids: string[];
  exclusion_ids: string[];
  dislikes: string[];
  cuisines: string[];
  budget_band: NonNullable<Me['preferences']>['budget_band'];
  cooking_time: NonNullable<Me['preferences']>['cooking_time'];
  meals_per_day: number | null;
  revision: number;
}

interface TrainingRow {
  experience: NonNullable<Me['training_preferences']>['experience'];
  location: NonNullable<Me['training_preferences']>['location'];
  equipment_ids: string[];
  weekdays: number[];
  days_per_week: number | null;
  duration_minutes: number | null;
  limitation_tags: string[];
  revision: number;
}

const FOREIGN_KEY_VIOLATION = '23503';

export const PROFILE_COLUMNS = `user_id, display_name, age_years, calculation_sex, height_cm::text as height_cm,
  weight_kg::text as weight_kg, activity_band, timezone, unit_system, onboarding_status,
  onboarding_step, eligibility_status, screening_flags, (screening_answered_at is not null) as screening_answered,
  revision`;

export const PREFERENCES_COLUMNS = `diet_type, allergy_ids, exclusion_ids, dislikes, cuisines, budget_band,
  cooking_time, meals_per_day, revision`;

export const TRAINING_COLUMNS = `experience, location, equipment_ids, weekdays, days_per_week, duration_minutes,
  limitation_tags, revision`;

export type { ProfileRow, GoalRow, PreferencesRow, TrainingRow };

/** Creates the empty profile row on first access. userId must be the verified token subject. */
export async function ensureProfile(db: Queryable, userId: string): Promise<void> {
  try {
    await db.query(
      'insert into app.profiles (user_id) values ($1) on conflict (user_id) do nothing',
      [userId],
    );
  } catch (error) {
    // The token was valid but the auth identity no longer exists (e.g. account deleted).
    if ((error as { code?: string }).code === FOREIGN_KEY_VIOLATION) {
      throw new AppError('UNAUTHENTICATED', 'Authentication required.', { cause: error });
    }
    throw error;
  }
}

const numberOrNull = (value: string | null): number | null =>
  value === null ? null : Number(value);

/**
 * Planning status shown to the client. Eligibility always wins: a user who is not eligible never
 * sees a plan request, even if one was created before their answers changed.
 */
function planningFor(profile: ProfileRow, request: { id: string } | undefined): Me['planning'] {
  if (profile.onboarding_status !== 'completed') return null;
  if (profile.eligibility_status === 'tracking_only') {
    return { status: 'unavailable_tracking_only', job_id: null };
  }
  if (profile.eligibility_status === 'needs_review') {
    return { status: 'unavailable_needs_review', job_id: null };
  }
  if (request) return { status: 'requested', job_id: request.id };
  return { status: 'unavailable_policy', job_id: null };
}

/**
 * Returns the caller's profile, creating the empty row on first access. userId must be the
 * verified token subject; every statement filters on it explicitly (RLS is the second line).
 */
export async function getOrCreateMe(db: Queryable, userId: string): Promise<Me> {
  await ensureProfile(db, userId);
  return loadMe(db, userId);
}

export async function loadMe(db: Queryable, userId: string): Promise<Me> {
  const profile = (
    await db.query<ProfileRow>(`select ${PROFILE_COLUMNS} from app.profiles where user_id = $1`, [
      userId,
    ])
  ).rows[0];
  if (!profile) throw new AppError('INTERNAL_ERROR', 'Profile could not be loaded.');

  const goal = (
    await db.query<GoalRow>(
      `select goal_type, target_weight_kg::text as target_weight_kg
         from app.goals where user_id = $1 and active_to is null`,
      [userId],
    )
  ).rows[0];

  const preferences = (
    await db.query<PreferencesRow>(
      `select ${PREFERENCES_COLUMNS} from app.user_preferences where user_id = $1`,
      [userId],
    )
  ).rows[0];

  const training = (
    await db.query<TrainingRow>(
      `select ${TRAINING_COLUMNS} from app.training_preferences where user_id = $1`,
      [userId],
    )
  ).rows[0];

  const request =
    profile.onboarding_status === 'completed'
      ? (
          await db.query<{ id: string }>(
            `select id from app.generation_requests
              where user_id = $1 and request_type = 'diet_plan'
              order by created_at desc limit 1`,
            [userId],
          )
        ).rows[0]
      : undefined;

  return {
    user_id: profile.user_id,
    profile: {
      display_name: profile.display_name,
      age_years: profile.age_years,
      calculation_sex: profile.calculation_sex,
      height_cm: numberOrNull(profile.height_cm),
      weight_kg: numberOrNull(profile.weight_kg),
      activity_band: profile.activity_band,
      timezone: profile.timezone,
      unit_system: profile.unit_system,
      revision: profile.revision,
    },
    goal: goal
      ? { goal_type: goal.goal_type, target_weight_kg: numberOrNull(goal.target_weight_kg) }
      : null,
    preferences: preferences ?? null,
    training_preferences: training ?? null,
    eligibility_status: profile.eligibility_status,
    screening: profile.screening_answered ? answersFromFlags(profile.screening_flags) : null,
    onboarding: { status: profile.onboarding_status, step: profile.onboarding_step },
    planning: planningFor(profile, request),
  };
}
