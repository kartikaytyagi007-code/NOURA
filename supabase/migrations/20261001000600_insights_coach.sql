-- NOURA M1 · Summaries, weekly insights, coach threads/messages and action proposals.

create table app.daily_summaries (
  user_id uuid not null references auth.users (id) on delete cascade,
  local_date date not null,
  nutrient_totals jsonb not null default '{}'::jsonb check (jsonb_typeof(nutrient_totals) = 'object'),
  coverage jsonb not null default '{}'::jsonb check (jsonb_typeof(coverage) = 'object'),
  meal_count smallint not null default 0 check (meal_count >= 0),
  workout_count smallint not null default 0 check (workout_count >= 0),
  revision integer not null default 1 check (revision >= 1),
  computed_at timestamptz not null default now(),
  primary key (user_id, local_date)
);
select app.enable_owner_rls('app.daily_summaries');

create table app.weekly_insights (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  period_start date not null,
  period_end date not null,
  aggregate_revision integer not null check (aggregate_revision >= 1),
  policy_version text not null,
  evidence jsonb not null check (jsonb_typeof(evidence) = 'object'),
  explanation text check (char_length(explanation) <= 4000),
  created_at timestamptz not null default now(),
  -- V1 supports seven-day windows only (blueprint §10).
  constraint weekly_insights_seven_days check (period_end = period_start + 6),
  constraint weekly_insights_unique unique (user_id, period_start, policy_version, aggregate_revision)
);
create index weekly_insights_user_period on app.weekly_insights (user_id, period_start desc);
select app.enable_owner_rls('app.weekly_insights');

create table app.coach_threads (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  title text check (char_length(title) <= 120),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint coach_threads_id_user_unique unique (id, user_id)
);
create index coach_threads_user_updated on app.coach_threads (user_id, updated_at desc);
select app.enable_owner_rls('app.coach_threads');
select app.add_touch_trigger('app.coach_threads');

create table app.coach_messages (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  thread_id uuid not null,
  client_id uuid,
  role text not null check (role in ('user', 'assistant')),
  content text not null check (char_length(content) between 1 and 8000),
  status text not null default 'completed' check (status in ('pending', 'completed', 'failed')),
  failure_code text,
  model_id text,
  prompt_version text,
  created_at timestamptz not null default now(),
  constraint coach_messages_id_user_unique unique (id, user_id),
  constraint coach_messages_thread_owner foreign key (thread_id, user_id)
    references app.coach_threads (id, user_id) on delete cascade,
  constraint coach_messages_client_unique unique (user_id, client_id),
  constraint coach_messages_failed_has_code check (status <> 'failed' or failure_code is not null)
);
create index coach_messages_thread_created on app.coach_messages (thread_id, created_at);
select app.enable_owner_rls('app.coach_messages');

create table app.action_proposals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  thread_id uuid,
  message_id uuid,
  proposal_type text not null check (proposal_type in ('swap_meal', 'regenerate_day', 'reschedule_workout')),
  payload jsonb not null check (jsonb_typeof(payload) = 'object'),
  expected_plan_revision integer not null check (expected_plan_revision >= 1),
  status text not null default 'pending' check (status in ('pending', 'applied', 'cancelled', 'expired', 'failed')),
  expires_at timestamptz not null,
  applied_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint action_proposals_thread_owner foreign key (thread_id, user_id)
    references app.coach_threads (id, user_id) on delete cascade,
  constraint action_proposals_message_owner foreign key (message_id, user_id)
    references app.coach_messages (id, user_id) on delete cascade,
  constraint action_proposals_applied_state check ((status = 'applied') = (applied_at is not null))
);
create index action_proposals_user_status on app.action_proposals (user_id, status, created_at desc);
select app.enable_owner_rls('app.action_proposals');
select app.add_touch_trigger('app.action_proposals');
