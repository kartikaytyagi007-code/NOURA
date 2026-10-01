-- NOURA M1 · Versioned diet and workout plans. Child rows carry user_id and reference their parent
-- through (parent_id, user_id) so a child can never attach to another user's parent.

create table app.generation_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  request_type text not null check (request_type in (
    'diet_plan', 'workout_plan', 'plan_regeneration', 'meal_scan', 'coach_reply', 'weekly_insight'
  )),
  status text not null default 'queued' check (status in ('queued', 'running', 'completed', 'failed', 'cancelled')),
  input_revision integer check (input_revision >= 1),
  result_ids jsonb not null default '{}'::jsonb check (jsonb_typeof(result_ids) = 'object'),
  safe_error_code text,
  safe_error_message text check (char_length(safe_error_message) <= 500),
  queue_name text,
  queue_job_id text,
  attempts integer not null default 0 check (attempts >= 0),
  started_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint generation_requests_id_user_unique unique (id, user_id),
  constraint generation_requests_terminal_completed_at check (
    (status in ('completed', 'failed', 'cancelled')) = (completed_at is not null)
  )
);
comment on column app.generation_requests.safe_error_message is 'User-safe message only. Never provider internals.';
-- Repeated taps must not create parallel plan generations (blueprint §13).
create unique index generation_requests_one_active_plan_job
  on app.generation_requests (user_id, request_type)
  where status in ('queued', 'running') and request_type in ('diet_plan', 'workout_plan', 'plan_regeneration');
create index generation_requests_user_created on app.generation_requests (user_id, created_at desc);
select app.enable_owner_rls('app.generation_requests');
select app.add_touch_trigger('app.generation_requests');

create table app.diet_plans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  version integer not null check (version >= 1),
  profile_revision integer not null check (profile_revision >= 1),
  target_snapshot_id uuid not null,
  starts_on date not null,
  status text not null default 'draft' check (status in ('draft', 'active', 'superseded', 'cancelled')),
  supersedes_id uuid,
  generation_request_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint diet_plans_id_user_unique unique (id, user_id),
  constraint diet_plans_version_unique unique (user_id, version),
  constraint diet_plans_target_owner foreign key (target_snapshot_id, user_id)
    references app.target_snapshots (id, user_id),
  constraint diet_plans_supersedes_owner foreign key (supersedes_id, user_id)
    references app.diet_plans (id, user_id),
  constraint diet_plans_generation_owner foreign key (generation_request_id, user_id)
    references app.generation_requests (id, user_id)
);
create unique index diet_plans_one_active_per_start on app.diet_plans (user_id, starts_on) where status = 'active';
select app.enable_owner_rls('app.diet_plans');
select app.add_touch_trigger('app.diet_plans');

create table app.diet_plan_meals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  plan_id uuid not null,
  meal_date date not null,
  slot text not null check (slot in ('breakfast', 'lunch', 'dinner', 'snack')),
  slot_ordinal smallint not null default 1 check (slot_ordinal between 1 and 4),
  recipe_id uuid references app.recipes (id),
  portions_snapshot jsonb not null check (jsonb_typeof(portions_snapshot) in ('object', 'array')),
  nutrition_snapshot jsonb not null check (jsonb_typeof(nutrition_snapshot) = 'object'),
  status text not null default 'planned' check (status in ('planned', 'replaced')),
  revision integer not null default 1 check (revision >= 1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint diet_plan_meals_id_user_unique unique (id, user_id),
  constraint diet_plan_meals_plan_owner foreign key (plan_id, user_id)
    references app.diet_plans (id, user_id) on delete cascade,
  constraint diet_plan_meals_slot_unique unique (plan_id, meal_date, slot, slot_ordinal)
);
create index diet_plan_meals_user_date on app.diet_plan_meals (user_id, meal_date);
select app.enable_owner_rls('app.diet_plan_meals');
select app.add_touch_trigger('app.diet_plan_meals');

create table app.workout_plans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  version integer not null check (version >= 1),
  profile_revision integer not null check (profile_revision >= 1),
  starts_on date not null,
  status text not null default 'draft' check (status in ('draft', 'active', 'superseded', 'cancelled')),
  supersedes_id uuid,
  generation_request_id uuid,
  revision integer not null default 1 check (revision >= 1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint workout_plans_id_user_unique unique (id, user_id),
  constraint workout_plans_version_unique unique (user_id, version),
  constraint workout_plans_supersedes_owner foreign key (supersedes_id, user_id)
    references app.workout_plans (id, user_id),
  constraint workout_plans_generation_owner foreign key (generation_request_id, user_id)
    references app.generation_requests (id, user_id)
);
create unique index workout_plans_one_active_per_start on app.workout_plans (user_id, starts_on) where status = 'active';
select app.enable_owner_rls('app.workout_plans');
select app.add_touch_trigger('app.workout_plans');

create table app.workout_plan_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  plan_id uuid not null,
  session_date date not null,
  session_order smallint not null default 1 check (session_order between 1 and 10),
  title text not null check (char_length(title) between 1 and 120),
  status text not null default 'scheduled' check (status in ('scheduled', 'rescheduled', 'cancelled')),
  revision integer not null default 1 check (revision >= 1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint workout_plan_sessions_id_user_unique unique (id, user_id),
  constraint workout_plan_sessions_plan_owner foreign key (plan_id, user_id)
    references app.workout_plans (id, user_id) on delete cascade
);
create index workout_plan_sessions_user_date on app.workout_plan_sessions (user_id, session_date);
select app.enable_owner_rls('app.workout_plan_sessions');
select app.add_touch_trigger('app.workout_plan_sessions');

create table app.workout_plan_exercises (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  session_id uuid not null,
  exercise_id uuid not null references app.exercises (id),
  ordinal smallint not null check (ordinal >= 1),
  sets smallint not null check (sets between 1 and 20),
  reps_min smallint not null check (reps_min between 1 and 100),
  reps_max smallint not null check (reps_max between 1 and 100),
  rest_sec smallint not null check (rest_sec between 0 and 900),
  effort_cue text check (char_length(effort_cue) <= 200),
  prescription_snapshot jsonb not null default '{}'::jsonb check (jsonb_typeof(prescription_snapshot) = 'object'),
  constraint workout_plan_exercises_session_owner foreign key (session_id, user_id)
    references app.workout_plan_sessions (id, user_id) on delete cascade,
  constraint workout_plan_exercises_reps_range check (reps_min <= reps_max),
  constraint workout_plan_exercises_ordinal_unique unique (session_id, ordinal)
);
select app.enable_owner_rls('app.workout_plan_exercises');
