import {
  AppError,
  REQUIRED_ONBOARDING_CONSENTS,
  answersFromFlags,
  evaluateEligibility,
  flagsFromAnswers,
  isPublishedConsent,
  isValidTimezone,
  normalizeDisplayName,
  validateGoal,
  validateTraining,
  type ConsentType,
  type FieldError,
  type GoalType,
  type Queryable,
  type ScreeningAnswers,
  type TargetInput,
} from '@noura/domain';
import type { components } from '@noura/contracts';
import {
  PREFERENCES_COLUMNS,
  PROFILE_COLUMNS,
  TRAINING_COLUMNS,
  ensureProfile,
  loadMe,
  type GoalRow,
  type PreferencesRow,
  type ProfileRow,
  type TrainingRow,
} from '../me/repository.js';
import { writeTargetSnapshot, type PlanningContext } from './targets.js';

type Schemas = components['schemas'];
type Me = Schemas['Me'];

const conflict = (what: string) =>
  new AppError(
    'REVISION_CONFLICT',
    `Your ${what} changed since you loaded it. Reload and try again.`,
  );

const fieldError = (field: string, code: string, message: string): FieldError => ({
  field,
  code,
  message,
});

const validation = (errors: FieldError[]) =>
  new AppError('VALIDATION_ERROR', 'Request validation failed.', { fieldErrors: errors });

async function lockProfile(client: Queryable, userId: string): Promise<ProfileRow> {
  await ensureProfile(client, userId);
  const row = (
    await client.query<ProfileRow>(
      `select ${PROFILE_COLUMNS} from app.profiles where user_id = $1 for update`,
      [userId],
    )
  ).rows[0];
  if (!row) throw new AppError('INTERNAL_ERROR', 'Profile could not be loaded.');
  return row;
}

const num = (value: string | null): number | null => (value === null ? null : Number(value));

async function activeGoal(client: Queryable, userId: string): Promise<GoalRow | undefined> {
  return (
    await client.query<GoalRow>(
      `select goal_type, target_weight_kg::text as target_weight_kg
         from app.goals where user_id = $1 and active_to is null`,
      [userId],
    )
  ).rows[0];
}

/** Everything a target calculation needs, or null while any input is still missing. */
function targetInputFrom(p: {
  age_years: number | null;
  calculation_sex: 'female' | 'male' | null;
  height_cm: number | null;
  weight_kg: number | null;
  activity_band: TargetInput['activity_band'] | null;
  goal_type: GoalType | null;
}): TargetInput | null {
  if (
    p.age_years === null ||
    p.height_cm === null ||
    p.weight_kg === null ||
    p.activity_band === null ||
    p.goal_type === null
  ) {
    return null;
  }
  return {
    age_years: p.age_years,
    calculation_sex: p.calculation_sex,
    height_cm: p.height_cm,
    weight_kg: p.weight_kg,
    activity_band: p.activity_band,
    goal_type: p.goal_type,
  };
}

/** PATCH /v1/me. Partial profile, goal, screening and onboarding-step save. */
export async function patchProfile(
  client: Queryable,
  userId: string,
  body: Schemas['ProfilePatch'],
  context: PlanningContext,
): Promise<Me> {
  const row = await lockProfile(client, userId);
  if (row.revision !== body.expected_revision) throw conflict('profile');

  const errors: FieldError[] = [];
  const has = (key: keyof Schemas['ProfilePatch']) => body[key] !== undefined;

  let displayName = row.display_name;
  if (body.display_name !== undefined) {
    displayName = normalizeDisplayName(body.display_name);
    if (displayName === null) {
      errors.push(fieldError('body.display_name', 'required', 'Enter a name.'));
    }
  }
  const timezone = body.timezone ?? row.timezone;
  if (body.timezone !== undefined && !isValidTimezone(body.timezone)) {
    errors.push(
      fieldError('body.timezone', 'invalid_timezone', 'Use an IANA timezone such as Asia/Kolkata.'),
    );
  }
  if (body.onboarding_step !== undefined && row.onboarding_status === 'completed') {
    errors.push(
      fieldError('body.onboarding_step', 'onboarding_completed', 'Onboarding is already complete.'),
    );
  }

  const age = body.age_years ?? row.age_years;
  const sex =
    body.calculation_sex === undefined
      ? row.calculation_sex
      : body.calculation_sex === 'declined'
        ? null
        : body.calculation_sex;
  const height = body.height_cm ?? num(row.height_cm);
  const weight = body.weight_kg ?? num(row.weight_kg);
  const activity = (body.activity_band ?? row.activity_band) as TargetInput['activity_band'] | null;

  const currentGoal = await activeGoal(client, userId);
  const nextGoal = body.primary_goal
    ? {
        goal_type: body.primary_goal.goal_type,
        target_weight_kg: body.primary_goal.target_weight_kg ?? null,
      }
    : currentGoal
      ? { goal_type: currentGoal.goal_type, target_weight_kg: num(currentGoal.target_weight_kg) }
      : null;
  // Check the goal whenever the goal or the current weight changes.
  if (nextGoal && (has('primary_goal') || has('weight_kg'))) {
    for (const e of validateGoal(nextGoal, weight)) {
      errors.push({ ...e, field: `body.${e.field}` });
    }
  }
  if (errors.length > 0) throw validation(errors);

  const screening: ScreeningAnswers | null =
    body.screening ?? (row.screening_answered ? answersFromFlags(row.screening_flags) : null);
  const eligibility =
    age !== null && screening !== null
      ? evaluateEligibility({ age_years: age, answers: screening }).status
      : null;

  const completed = row.onboarding_status === 'completed';
  const updated = (
    await client.query<{ revision: number }>(
      `update app.profiles set
         display_name = $3, age_years = $4, calculation_sex = $5, height_cm = $6, weight_kg = $7,
         activity_band = $8, timezone = $9, unit_system = $10, onboarding_status = $11,
         onboarding_step = $12, eligibility_status = $13, screening_flags = $14::text[],
         screening_answered_at = case when $15::boolean then now() else screening_answered_at end,
         revision = revision + 1
       where user_id = $1 and revision = $2
       returning revision`,
      [
        userId,
        row.revision,
        displayName,
        age,
        sex,
        height,
        weight,
        activity,
        timezone,
        body.unit_system ?? row.unit_system,
        completed ? 'completed' : 'in_progress',
        completed ? row.onboarding_step : (body.onboarding_step ?? row.onboarding_step),
        eligibility,
        body.screening ? flagsFromAnswers(body.screening) : row.screening_flags,
        body.screening !== undefined,
      ],
    )
  ).rows[0];
  if (!updated) throw conflict('profile');

  if (body.primary_goal) {
    const same =
      currentGoal?.goal_type === nextGoal?.goal_type &&
      num(currentGoal?.target_weight_kg ?? null) === (nextGoal?.target_weight_kg ?? null);
    if (!same) {
      await client.query(
        'update app.goals set active_to = now() where user_id = $1 and active_to is null',
        [userId],
      );
      await client.query(
        'insert into app.goals (user_id, goal_type, target_weight_kg) values ($1, $2, $3)',
        [userId, nextGoal?.goal_type, nextGoal?.target_weight_kg ?? null],
      );
    }
  }

  // Once onboarding is complete, edits that feed the targets produce a fresh snapshot for the new
  // revision. Plans built on older revisions are detected as stale by comparing revisions (M3).
  const targetRelevant =
    has('age_years') ||
    has('calculation_sex') ||
    has('height_cm') ||
    has('weight_kg') ||
    has('activity_band') ||
    has('screening') ||
    (has('primary_goal') && currentGoal?.goal_type !== nextGoal?.goal_type);
  const target = targetInputFrom({
    age_years: age,
    calculation_sex: sex,
    height_cm: height,
    weight_kg: weight,
    activity_band: activity,
    goal_type: nextGoal?.goal_type ?? null,
  });
  if (completed && targetRelevant && eligibility && target) {
    await writeTargetSnapshot(
      client,
      userId,
      { profileRevision: updated.revision, eligibility, target },
      context,
    );
  }

  return loadMe(client, userId);
}

function cleanDislikes(raw: readonly string[] | undefined, errors: FieldError[]): string[] {
  const seen = new Set<string>();
  const out: string[] = [];
  (raw ?? []).forEach((value, index) => {
    const cleaned = normalizeDisplayName(value);
    if (cleaned === null) {
      errors.push(fieldError(`body.dislikes.${index}`, 'required', 'Remove empty entries.'));
      return;
    }
    const key = cleaned.toLowerCase();
    if (!seen.has(key)) {
      seen.add(key);
      out.push(cleaned);
    }
  });
  return out;
}

/** PUT /v1/me/preferences. Whole-object replacement with its own revision. */
export async function putPreferences(
  client: Queryable,
  userId: string,
  body: Schemas['PreferencesInput'],
): Promise<Schemas['Preferences']> {
  await ensureProfile(client, userId);
  const errors: FieldError[] = [];
  const dislikes = cleanDislikes(body.dislikes, errors);
  if (errors.length > 0) throw validation(errors);

  const values = [
    body.diet_type,
    body.allergy_ids,
    body.exclusion_ids,
    dislikes,
    body.cuisines,
    body.budget_band,
    body.cooking_time,
    body.meals_per_day,
  ];
  const result =
    body.expected_revision === 0
      ? await client.query<PreferencesRow>(
          `insert into app.user_preferences
             (user_id, diet_type, allergy_ids, exclusion_ids, dislikes, cuisines, budget_band,
              cooking_time, meals_per_day)
           values ($1, $2, $3::text[], $4::text[], $5::text[], $6::text[], $7, $8, $9)
           on conflict (user_id) do nothing
           returning ${PREFERENCES_COLUMNS}`,
          [userId, ...values],
        )
      : await client.query<PreferencesRow>(
          `update app.user_preferences set
             diet_type = $3, allergy_ids = $4::text[], exclusion_ids = $5::text[],
             dislikes = $6::text[], cuisines = $7::text[], budget_band = $8, cooking_time = $9,
             meals_per_day = $10, revision = revision + 1
           where user_id = $1 and revision = $2
           returning ${PREFERENCES_COLUMNS}`,
          [userId, body.expected_revision, ...values],
        );
  const saved = result.rows[0];
  if (!saved) throw conflict('preferences');
  return saved;
}

/** PUT /v1/me/training-preferences. Whole-object replacement with its own revision. */
export async function putTrainingPreferences(
  client: Queryable,
  userId: string,
  body: Schemas['TrainingPreferencesInput'],
): Promise<Schemas['TrainingPreferences']> {
  await ensureProfile(client, userId);
  const errors = validateTraining({
    location: body.location,
    equipment_ids: body.equipment_ids,
    weekdays: body.weekdays,
    days_per_week: body.days_per_week,
  }).map((e) => ({ ...e, field: `body.${e.field}` }));
  if (errors.length > 0) throw validation(errors);

  const weekdays = [...body.weekdays].sort((a, b) => a - b);
  const values = [
    body.experience,
    body.location,
    body.equipment_ids,
    weekdays,
    body.days_per_week,
    body.duration_minutes,
    body.limitation_tags,
  ];
  const result =
    body.expected_revision === 0
      ? await client.query<TrainingRow>(
          `insert into app.training_preferences
             (user_id, experience, location, equipment_ids, weekdays, days_per_week,
              duration_minutes, limitation_tags)
           values ($1, $2, $3, $4::text[], $5::smallint[], $6, $7, $8::text[])
           on conflict (user_id) do nothing
           returning ${TRAINING_COLUMNS}`,
          [userId, ...values],
        )
      : await client.query<TrainingRow>(
          `update app.training_preferences set
             experience = $3, location = $4, equipment_ids = $5::text[], weekdays = $6::smallint[],
             days_per_week = $7, duration_minutes = $8, limitation_tags = $9::text[],
             revision = revision + 1
           where user_id = $1 and revision = $2
           returning ${TRAINING_COLUMNS}`,
          [userId, body.expected_revision, ...values],
        );
  const saved = result.rows[0];
  if (!saved) throw conflict('training preferences');
  return saved;
}

function missingForCompletion(
  row: ProfileRow,
  goal: GoalRow | undefined,
  preferences: PreferencesRow | undefined,
  training: TrainingRow | undefined,
): FieldError[] {
  const required = (field: string, message: string) => fieldError(field, 'required', message);
  const errors: FieldError[] = [];
  if (row.display_name === null) errors.push(required('profile.display_name', 'Enter your name.'));
  if (row.age_years === null) errors.push(required('profile.age_years', 'Enter your age.'));
  if (row.height_cm === null) errors.push(required('profile.height_cm', 'Enter your height.'));
  if (row.weight_kg === null) errors.push(required('profile.weight_kg', 'Enter your weight.'));
  if (row.activity_band === null) {
    errors.push(required('profile.activity_band', 'Choose your activity level.'));
  }
  if (!goal) errors.push(required('goal', 'Choose a goal.'));
  if (!row.screening_answered)
    errors.push(required('screening', 'Answer the screening questions.'));
  if (
    !preferences ||
    preferences.diet_type === null ||
    preferences.budget_band === null ||
    preferences.cooking_time === null ||
    preferences.meals_per_day === null
  ) {
    errors.push(required('preferences', 'Complete your food preferences.'));
  }
  if (
    !training ||
    training.experience === null ||
    training.location === null ||
    training.days_per_week === null ||
    training.duration_minutes === null
  ) {
    errors.push(required('training_preferences', 'Complete your training preferences.'));
  }
  return errors;
}

function checkConsents(consents: Schemas['OnboardingCompleteRequest']['consents']): FieldError[] {
  const errors: FieldError[] = [];
  const seen = new Set<string>();
  consents.forEach((c, index) => {
    if (seen.has(c.consent_type)) {
      errors.push(fieldError(`body.consents.${index}`, 'duplicate', 'Each consent appears once.'));
    }
    seen.add(c.consent_type);
    if (!isPublishedConsent(c.consent_type as ConsentType, c.version)) {
      errors.push(
        fieldError(
          `body.consents.${index}.version`,
          'unknown_version',
          'This consent version is not currently published.',
        ),
      );
    }
  });
  for (const type of REQUIRED_ONBOARDING_CONSENTS) {
    if (!seen.has(type)) {
      errors.push(
        fieldError('body.consents', 'consent_required', `Consent to ${type} is required.`),
      );
    }
  }
  return errors;
}

/**
 * POST /v1/onboarding/complete. One transaction: verify inputs, record consents, fix eligibility,
 * complete onboarding, write the target snapshot and (only for eligible users with an allowed
 * policy) one durable generation request. Profile data is committed whether or not generation later
 * succeeds; the worker relays the request to the queue (D-017).
 */
export async function completeOnboarding(
  client: Queryable,
  userId: string,
  body: Schemas['OnboardingCompleteRequest'],
  context: PlanningContext,
): Promise<Schemas['OnboardingComplete']> {
  const row = await lockProfile(client, userId);
  if (row.onboarding_status === 'completed') {
    throw new AppError('CONSTRAINT_CONFLICT', 'Onboarding is already complete.');
  }
  if (row.revision !== body.expected_revision) throw conflict('profile');

  const goal = await activeGoal(client, userId);
  const preferences = (
    await client.query<PreferencesRow>(
      `select ${PREFERENCES_COLUMNS} from app.user_preferences where user_id = $1`,
      [userId],
    )
  ).rows[0];
  const training = (
    await client.query<TrainingRow>(
      `select ${TRAINING_COLUMNS} from app.training_preferences where user_id = $1`,
      [userId],
    )
  ).rows[0];

  const errors = [
    ...missingForCompletion(row, goal, preferences, training),
    ...checkConsents(body.consents),
  ];
  if (errors.length > 0 || !goal || row.age_years === null) throw validation(errors);

  const eligibility = evaluateEligibility({
    age_years: row.age_years,
    answers: answersFromFlags(row.screening_flags),
  }).status;

  for (const c of body.consents) {
    await client.query(
      `insert into app.consent_records (user_id, consent_type, version)
       values ($1, $2, $3)
       on conflict (user_id, consent_type, version) where revoked_at is null do nothing`,
      [userId, c.consent_type, c.version],
    );
  }

  const done = (
    await client.query<{ revision: number }>(
      `update app.profiles set onboarding_status = 'completed', onboarding_step = 'review',
              eligibility_status = $3, revision = revision + 1
        where user_id = $1 and revision = $2
        returning revision`,
      [userId, row.revision, eligibility],
    )
  ).rows[0];
  if (!done) throw conflict('profile');

  const target = targetInputFrom({
    age_years: row.age_years,
    calculation_sex: row.calculation_sex,
    height_cm: num(row.height_cm),
    weight_kg: num(row.weight_kg),
    activity_band: row.activity_band as TargetInput['activity_band'],
    goal_type: goal.goal_type,
  });
  if (!target) throw new AppError('INTERNAL_ERROR', 'Onboarding inputs were incomplete.');
  const { calculated } = await writeTargetSnapshot(
    client,
    userId,
    { profileRevision: done.revision, eligibility, target },
    context,
  );

  const jobIds: string[] = [];
  if (eligibility === 'eligible' && calculated) {
    const request = (
      await client.query<{ id: string }>(
        `insert into app.generation_requests (user_id, request_type, input_revision)
         values ($1, 'diet_plan', $2)
         returning id`,
        [userId, done.revision],
      )
    ).rows[0];
    if (request) jobIds.push(request.id);
  }

  return { me: await loadMe(client, userId), job_ids: jobIds };
}
