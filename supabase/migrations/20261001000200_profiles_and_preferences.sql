-- NOURA M1 · Profile, preferences, goals, consent and target snapshots.
-- Value sets marked "provisional" are M1 engineering defaults; M2 may revise them with an
-- additive migration recorded in docs/decisions.md. Range checks here are storage sanity bounds,
-- not medical thresholds; the API owns user-facing validation (blueprint §5).

create table app.profiles (
  user_id uuid primary key references auth.users (id) on delete cascade,
  display_name text check (char_length(display_name) between 1 and 80),
  age_years smallint check (age_years between 1 and 120),
  calculation_sex text check (calculation_sex in ('female', 'male')),
  height_cm numeric(5, 1) check (height_cm between 50 and 272),
  activity_band text check (activity_band in ('sedentary', 'light', 'moderate', 'active', 'very_active')),
  timezone text not null default 'UTC' check (char_length(timezone) between 1 and 64),
  unit_system text not null default 'metric' check (unit_system in ('metric', 'imperial')),
  onboarding_status text not null default 'not_started'
    check (onboarding_status in ('not_started', 'in_progress', 'completed')),
  onboarding_step text
    check (onboarding_step in ('basics', 'goals', 'diet', 'training', 'eligibility', 'review')),
  eligibility_status text check (eligibility_status in ('eligible', 'tracking_only', 'needs_review')),
  screening_flags text[] not null default '{}',
  revision integer not null default 1 check (revision >= 1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint profiles_completed_requires_core check (
    onboarding_status <> 'completed'
    or (display_name is not null and age_years is not null and height_cm is not null
        and activity_band is not null and eligibility_status is not null)
  )
);
comment on column app.profiles.calculation_sex is
  'Optional parameter for energy equations only. Never inferred from photos. Not gender identity.';
comment on column app.profiles.revision is 'Profile revision; target snapshots and plans record the revision they were built from.';
select app.enable_owner_rls('app.profiles');
select app.add_touch_trigger('app.profiles');

create table app.user_preferences (
  user_id uuid primary key references app.profiles (user_id) on delete cascade,
  diet_type text check (diet_type in ('vegetarian', 'eggatarian', 'vegan', 'non_vegetarian')),
  allergy_ids text[] not null default '{}',
  exclusion_ids text[] not null default '{}',
  dislikes text[] not null default '{}',
  cuisines text[] not null default '{}',
  budget_band text check (budget_band in ('low', 'medium', 'high')),
  cooking_time text check (cooking_time in ('minimal', 'moderate', 'flexible')),
  meals_per_day smallint check (meals_per_day between 1 and 8),
  reminder_settings jsonb not null default '{}'::jsonb check (jsonb_typeof(reminder_settings) = 'object'),
  revision integer not null default 1 check (revision >= 1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
select app.enable_owner_rls('app.user_preferences');
select app.add_touch_trigger('app.user_preferences');

create table app.training_preferences (
  user_id uuid primary key references app.profiles (user_id) on delete cascade,
  experience text check (experience in ('beginner', 'intermediate', 'advanced')),
  location text check (location in ('home', 'gym', 'both')),
  equipment_ids text[] not null default '{}',
  weekdays smallint[] not null default '{}' check (weekdays <@ array[1, 2, 3, 4, 5, 6, 7]::smallint[]),
  days_per_week smallint check (days_per_week between 1 and 7),
  duration_minutes smallint check (duration_minutes between 10 and 180),
  limitation_tags text[] not null default '{}',
  revision integer not null default 1 check (revision >= 1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on column app.training_preferences.weekdays is 'ISO weekdays, 1 = Monday ... 7 = Sunday.';
select app.enable_owner_rls('app.training_preferences');
select app.add_touch_trigger('app.training_preferences');

create table app.goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  goal_type text not null check (goal_type in ('lose_fat', 'maintain', 'gain_muscle', 'general_health')),
  target_weight_kg numeric(5, 2) check (target_weight_kg between 20 and 400),
  active_from timestamptz not null default now(),
  active_to timestamptz,
  created_at timestamptz not null default now(),
  constraint goals_id_user_unique unique (id, user_id),
  constraint goals_active_range check (active_to is null or active_to >= active_from)
);
create unique index goals_one_active_per_user on app.goals (user_id) where active_to is null;
select app.enable_owner_rls('app.goals');

create table app.consent_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  consent_type text not null check (consent_type in (
    'terms', 'privacy', 'health_data_processing', 'ai_meal_processing', 'progress_photo_storage'
  )),
  version text not null check (char_length(version) between 1 and 32),
  granted_at timestamptz not null default now(),
  revoked_at timestamptz,
  constraint consent_revoked_after_granted check (revoked_at is null or revoked_at >= granted_at)
);
create index consent_records_user_type on app.consent_records (user_id, consent_type, granted_at desc);
select app.enable_owner_rls('app.consent_records');

create table app.target_snapshots (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  profile_revision integer not null check (profile_revision >= 1),
  policy_version text not null check (char_length(policy_version) between 1 and 64),
  estimated_energy_kcal_min integer check (estimated_energy_kcal_min > 0),
  estimated_energy_kcal_max integer check (estimated_energy_kcal_max > 0),
  selected_targets jsonb not null check (jsonb_typeof(selected_targets) = 'object'),
  method text not null check (method in ('policy', 'user_override')),
  method_reference text,
  eligibility text not null check (eligibility in ('eligible', 'tracking_only', 'needs_review')),
  valid_from timestamptz not null default now(),
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  constraint target_snapshots_id_user_unique unique (id, user_id),
  constraint target_snapshots_energy_range check (
    estimated_energy_kcal_min is null or estimated_energy_kcal_max is null
    or estimated_energy_kcal_min <= estimated_energy_kcal_max
  ),
  constraint target_snapshots_valid_range check (valid_to is null or valid_to >= valid_from)
);
create unique index target_snapshots_one_current on app.target_snapshots (user_id) where valid_to is null;
select app.enable_owner_rls('app.target_snapshots');
