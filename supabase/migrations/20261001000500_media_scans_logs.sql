-- NOURA M1 · Private media, meal scans, meal/workout/weight logs and progress photos.

create table app.media_assets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  purpose text not null check (purpose in ('meal', 'progress_photo', 'export')),
  bucket text not null check (bucket in ('meal-images', 'progress-photos', 'exports')),
  object_path text not null unique check (char_length(object_path) between 1 and 512),
  declared_mime text not null,
  verified_mime text,
  byte_size bigint check (byte_size > 0),
  width_px integer check (width_px > 0),
  height_px integer check (height_px > 0),
  status text not null default 'awaiting_upload'
    check (status in ('awaiting_upload', 'uploaded', 'verified', 'rejected', 'deleted')),
  expires_at timestamptz,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint media_assets_id_user_unique unique (id, user_id),
  constraint media_assets_purpose_bucket check (
    (purpose = 'meal' and bucket = 'meal-images')
    or (purpose = 'progress_photo' and bucket = 'progress-photos')
    or (purpose = 'export' and bucket = 'exports')
  ),
  -- Server-generated paths are always <owner uuid>/<media uuid>[.<ext>] (blueprint §14).
  constraint media_assets_owner_path check (object_path like user_id::text || '/' || id::text || '%'),
  constraint media_assets_deleted_state check ((status = 'deleted') = (deleted_at is not null))
);
create index media_assets_user_created on app.media_assets (user_id, created_at desc);
create index media_assets_expiry on app.media_assets (expires_at) where deleted_at is null;
select app.enable_owner_rls('app.media_assets');
select app.add_touch_trigger('app.media_assets');

create table app.meal_scans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  media_asset_id uuid not null,
  generation_request_id uuid,
  status text not null default 'awaiting_upload' check (status in (
    'awaiting_upload', 'queued', 'recognizing', 'needs_confirmation', 'ready', 'failed', 'cancelled', 'expired'
  )),
  recognition jsonb check (recognition is null or jsonb_typeof(recognition) = 'object'),
  confirmed_analysis jsonb check (confirmed_analysis is null or jsonb_typeof(confirmed_analysis) = 'object'),
  model_id text,
  prompt_version text,
  failure_code text,
  revision integer not null default 1 check (revision >= 1),
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint meal_scans_id_user_unique unique (id, user_id),
  constraint meal_scans_media_owner foreign key (media_asset_id, user_id)
    references app.media_assets (id, user_id),
  constraint meal_scans_generation_owner foreign key (generation_request_id, user_id)
    references app.generation_requests (id, user_id)
);
create index meal_scans_user_created on app.meal_scans (user_id, created_at desc);
select app.enable_owner_rls('app.meal_scans');
select app.add_touch_trigger('app.meal_scans');

create table app.meal_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  client_id uuid not null,
  consumed_at timestamptz not null,
  local_date date not null,
  timezone text not null check (char_length(timezone) between 1 and 64),
  slot text not null check (slot in ('breakfast', 'lunch', 'dinner', 'snack')),
  scan_id uuid,
  plan_meal_id uuid,
  totals_snapshot jsonb not null check (jsonb_typeof(totals_snapshot) = 'object'),
  coverage jsonb not null default '{}'::jsonb check (jsonb_typeof(coverage) = 'object'),
  meal_balance_score smallint check (meal_balance_score between 0 and 100),
  score_policy_version text,
  revision integer not null default 1 check (revision >= 1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint meal_logs_id_user_unique unique (id, user_id),
  constraint meal_logs_client_unique unique (user_id, client_id),
  constraint meal_logs_scan_owner foreign key (scan_id, user_id) references app.meal_scans (id, user_id),
  constraint meal_logs_plan_meal_owner foreign key (plan_meal_id, user_id)
    references app.diet_plan_meals (id, user_id),
  constraint meal_logs_score_has_policy check (meal_balance_score is null or score_policy_version is not null)
);
comment on column app.meal_logs.local_date is 'Meal-local date captured at log time; later timezone changes never move it.';
create index meal_logs_user_date on app.meal_logs (user_id, local_date);
select app.enable_owner_rls('app.meal_logs');
select app.add_touch_trigger('app.meal_logs');

create table app.meal_log_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  meal_log_id uuid not null,
  food_id uuid references app.foods (id),
  recipe_id uuid references app.recipes (id),
  label text not null check (char_length(label) between 1 and 200),
  grams numeric(7, 2) check (grams > 0),
  grams_min numeric(7, 2) check (grams_min > 0),
  grams_max numeric(7, 2) check (grams_max > 0),
  preparation text check (char_length(preparation) <= 200),
  nutrients jsonb check (nutrients is null or jsonb_typeof(nutrients) = 'object'),
  provenance jsonb not null check (jsonb_typeof(provenance) = 'object'),
  uncertainty text check (uncertainty in ('low', 'medium', 'high')),
  constraint meal_log_items_log_owner foreign key (meal_log_id, user_id)
    references app.meal_logs (id, user_id) on delete cascade,
  constraint meal_log_items_gram_range check (grams_min is null or grams_max is null or grams_min <= grams_max)
);
comment on column app.meal_log_items.nutrients is 'NULL means unknown nutrition. Never replaced by zero or invented values.';
create index meal_log_items_log on app.meal_log_items (meal_log_id);
select app.enable_owner_rls('app.meal_log_items');

create table app.workout_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  client_id uuid not null,
  session_id uuid not null,
  status text not null default 'in_progress' check (status in ('in_progress', 'completed', 'skipped', 'abandoned')),
  started_at timestamptz,
  completed_at timestamptz,
  revision integer not null default 1 check (revision >= 1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint workout_logs_id_user_unique unique (id, user_id),
  constraint workout_logs_client_unique unique (user_id, client_id),
  constraint workout_logs_session_owner foreign key (session_id, user_id)
    references app.workout_plan_sessions (id, user_id),
  constraint workout_logs_time_order check (completed_at is null or started_at is null or completed_at >= started_at)
);
create index workout_logs_user_created on app.workout_logs (user_id, created_at desc);
select app.enable_owner_rls('app.workout_logs');
select app.add_touch_trigger('app.workout_logs');

create table app.workout_set_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  workout_log_id uuid not null,
  exercise_id uuid not null references app.exercises (id),
  set_ordinal smallint not null check (set_ordinal between 1 and 50),
  reps smallint check (reps between 0 and 500),
  load_kg numeric(6, 2) check (load_kg >= 0),
  skipped boolean not null default false,
  constraint workout_set_logs_log_owner foreign key (workout_log_id, user_id)
    references app.workout_logs (id, user_id) on delete cascade,
  constraint workout_set_logs_unique unique (workout_log_id, exercise_id, set_ordinal)
);
comment on column app.workout_set_logs.load_kg is 'User-entered load; 0 is valid for bodyweight work.';
select app.enable_owner_rls('app.workout_set_logs');

create table app.weight_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  client_id uuid not null,
  measured_at timestamptz not null,
  weight_kg numeric(5, 2) not null check (weight_kg between 20 and 400),
  created_at timestamptz not null default now(),
  constraint weight_logs_client_unique unique (user_id, client_id)
);
create index weight_logs_user_measured on app.weight_logs (user_id, measured_at desc);
select app.enable_owner_rls('app.weight_logs');

-- Progress photos are storage/comparison only: intentionally no AI analysis columns (blueprint §6, §10).
create table app.progress_photos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  media_asset_id uuid not null,
  captured_at timestamptz not null,
  angle text not null check (angle in ('front', 'side', 'back')),
  created_at timestamptz not null default now(),
  constraint progress_photos_media_owner foreign key (media_asset_id, user_id)
    references app.media_assets (id, user_id)
);
create index progress_photos_user_captured on app.progress_photos (user_id, captured_at desc);
select app.enable_owner_rls('app.progress_photos');
