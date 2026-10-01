-- NOURA M1 · Entitlements, billing events, usage reservations, idempotency and account requests.
-- Billing truth is server-side: clients never write entitlements (blueprint §13).

create table app.entitlements (
  user_id uuid not null references auth.users (id) on delete cascade,
  entitlement_key text not null check (char_length(entitlement_key) between 1 and 64),
  provider text not null default 'revenuecat' check (provider in ('revenuecat')),
  provider_status text not null,
  is_active boolean not null default false,
  expires_at timestamptz,
  last_verified_at timestamptz not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, entitlement_key)
);
select app.enable_owner_rls('app.entitlements');
select app.add_touch_trigger('app.entitlements');

-- Provider events are not user-scoped requests (webhooks carry no user token). app_user_id has no
-- FK so minimal billing records can outlive account deletion where legitimately required.
create table app.billing_events (
  id uuid primary key default gen_random_uuid(),
  provider text not null default 'revenuecat' check (provider in ('revenuecat')),
  provider_event_id text not null check (char_length(provider_event_id) between 1 and 200),
  event_type text not null,
  environment text not null check (environment in ('sandbox', 'production')),
  app_user_id uuid,
  minimal_payload jsonb not null default '{}'::jsonb check (jsonb_typeof(minimal_payload) = 'object'),
  status text not null default 'received' check (status in ('received', 'processed', 'failed', 'ignored')),
  received_at timestamptz not null default now(),
  processed_at timestamptz,
  constraint billing_events_provider_event_unique unique (provider, provider_event_id)
);
alter table app.billing_events enable row level security;
create policy billing_events_server on app.billing_events as permissive for all
  to noura_api, noura_worker using (true) with check (true);

create table app.usage_reservations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  feature text not null check (feature in ('meal_scan', 'coach_reply', 'diet_plan', 'workout_plan', 'plan_regeneration')),
  quota_period text not null check (char_length(quota_period) between 1 and 32),
  request_id uuid not null,
  state text not null default 'reserved' check (state in ('reserved', 'consumed', 'released', 'expired')),
  expires_at timestamptz not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint usage_reservations_request_unique unique (user_id, request_id)
);
create index usage_reservations_user_period on app.usage_reservations (user_id, feature, quota_period, state);
create index usage_reservations_expiry on app.usage_reservations (expires_at) where state = 'reserved';
select app.enable_owner_rls('app.usage_reservations');
select app.add_touch_trigger('app.usage_reservations');

create table app.idempotency_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  route text not null check (char_length(route) between 1 and 200),
  idempotency_key text not null check (char_length(idempotency_key) between 8 and 255),
  request_hash text not null check (char_length(request_hash) between 16 and 128),
  response_status smallint,
  response_body jsonb,
  job_id uuid,
  expires_at timestamptz not null,
  created_at timestamptz not null default now(),
  constraint idempotency_records_key_unique unique (user_id, route, idempotency_key)
);
create index idempotency_records_expiry on app.idempotency_records (expires_at);
select app.enable_owner_rls('app.idempotency_records');

-- Deletion requests intentionally keep user_id without an FK: they act as the deletion tombstone
-- after the auth identity is removed (blueprint §14).
create table app.deletion_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  state text not null default 'requested' check (state in ('requested', 'in_progress', 'completed', 'failed')),
  last_error_code text,
  requested_at timestamptz not null default now(),
  completed_at timestamptz,
  updated_at timestamptz not null default now(),
  constraint deletion_requests_completed_state check ((state = 'completed') = (completed_at is not null))
);
create unique index deletion_requests_one_open on app.deletion_requests (user_id) where state in ('requested', 'in_progress');
select app.enable_owner_rls('app.deletion_requests');
select app.add_touch_trigger('app.deletion_requests');

create table app.export_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  state text not null default 'queued' check (state in ('queued', 'running', 'completed', 'failed', 'expired')),
  result_media_id uuid,
  requested_at timestamptz not null default now(),
  completed_at timestamptz,
  updated_at timestamptz not null default now(),
  constraint export_requests_result_owner foreign key (result_media_id, user_id)
    references app.media_assets (id, user_id)
);
create index export_requests_user_requested on app.export_requests (user_id, requested_at desc);
select app.enable_owner_rls('app.export_requests');
select app.add_touch_trigger('app.export_requests');
