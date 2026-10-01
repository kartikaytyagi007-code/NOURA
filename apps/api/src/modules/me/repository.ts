import { AppError, type Queryable } from '@noura/domain';
import type { components } from '@noura/contracts';

type Me = components['schemas']['Me'];

interface ProfileRow {
  user_id: string;
  display_name: string | null;
  age_years: number | null;
  calculation_sex: 'female' | 'male' | null;
  height_cm: string | null;
  activity_band: Me['profile']['activity_band'];
  timezone: string;
  unit_system: 'metric' | 'imperial';
  onboarding_status: Me['onboarding']['status'];
  onboarding_step: Me['onboarding']['step'];
  eligibility_status: Me['eligibility_status'];
  revision: number;
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

/**
 * Returns the caller's profile, creating the empty row on first access. userId must be the
 * verified token subject; every statement filters on it explicitly (RLS is the second line).
 */
export async function getOrCreateMe(db: Queryable, userId: string): Promise<Me> {
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

  const profile = (
    await db.query<ProfileRow>(
      `select user_id, display_name, age_years, calculation_sex, height_cm::text as height_cm, activity_band,
              timezone, unit_system, onboarding_status, onboarding_step, eligibility_status, revision
         from app.profiles where user_id = $1`,
      [userId],
    )
  ).rows[0];
  if (!profile) throw new AppError('INTERNAL_ERROR', 'Profile could not be loaded.');

  const preferences = (
    await db.query<PreferencesRow>(
      `select diet_type, allergy_ids, exclusion_ids, dislikes, cuisines, budget_band, cooking_time,
              meals_per_day, revision
         from app.user_preferences where user_id = $1`,
      [userId],
    )
  ).rows[0];

  const training = (
    await db.query<TrainingRow>(
      `select experience, location, equipment_ids, weekdays, days_per_week, duration_minutes,
              limitation_tags, revision
         from app.training_preferences where user_id = $1`,
      [userId],
    )
  ).rows[0];

  return {
    user_id: profile.user_id,
    profile: {
      display_name: profile.display_name,
      age_years: profile.age_years,
      calculation_sex: profile.calculation_sex,
      height_cm: profile.height_cm === null ? null : Number(profile.height_cm),
      activity_band: profile.activity_band,
      timezone: profile.timezone,
      unit_system: profile.unit_system,
      revision: profile.revision,
    },
    preferences: preferences ?? null,
    training_preferences: training ?? null,
    eligibility_status: profile.eligibility_status,
    onboarding: { status: profile.onboarding_status, step: profile.onboarding_step },
  };
}
