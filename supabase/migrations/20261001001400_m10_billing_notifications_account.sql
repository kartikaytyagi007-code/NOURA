-- NOURA M10 · Release hardening: account-export/deletion job tracking columns.
--
-- app.entitlements, app.billing_events, app.usage_reservations, app.idempotency_records,
-- app.deletion_requests and app.export_requests already exist from M1
-- (20261001000700_billing_ops_account.sql) and are already RLS-enabled with explicit
-- noura_api/noura_worker grants. This milestone turns them into real features rather than unused
-- schema; the only additive change needed is giving deletion/export requests the same durable
-- "dispatched to the queue exactly once" columns `app.generation_requests` already has, so the
-- worker relay can hand them to pg-boss with the same transactional-outbox crash-safety as every
-- other generation request (D-017), while keeping their own dedicated state machines
-- (deletion/export have different states than generation_requests' queued/running/completed/failed).

alter table app.deletion_requests
  add column queue_name text,
  add column queue_job_id uuid,
  add column attempts integer not null default 0;

alter table app.export_requests
  add column queue_name text,
  add column queue_job_id uuid,
  add column attempts integer not null default 0,
  add column last_error_code text;

-- Supports the worker relay's "undispatched rows" scan, same shape as
-- generation_requests(status, queue_job_id).
create index deletion_requests_undispatched on app.deletion_requests (requested_at)
  where state = 'requested' and queue_job_id is null;
create index export_requests_undispatched on app.export_requests (requested_at)
  where state = 'queued' and queue_job_id is null;

-- Cross-user relay visibility, narrow and column-guarded, exactly mirroring
-- generation_requests' worker_relay_select/update + guard trigger
-- (20261001000900_m2_profile_onboarding.sql): the relay (no user context) may see and dispatch only
-- still-undispatched rows, and a trigger enforces it can change only the dispatch columns.

create policy worker_relay_select on app.export_requests
  as permissive for select to noura_worker
  using (state = 'queued');
create policy worker_relay_update on app.export_requests
  as permissive for update to noura_worker
  using (state = 'queued' and queue_job_id is null)
  with check (state = 'queued' and queue_job_id is not null);

create function app.guard_export_request_relay()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if current_user = 'noura_worker' and app.request_user_id() is null then
    if (new.id, new.user_id, new.state, new.result_media_id, new.attempts, new.last_error_code,
        new.requested_at, new.completed_at)
       is distinct from
       (old.id, old.user_id, old.state, old.result_media_id, old.attempts, old.last_error_code,
        old.requested_at, old.completed_at) then
      raise exception 'relay may only record queue dispatch' using errcode = '42501';
    end if;
  end if;
  return new;
end
$$;
create trigger export_requests_relay_guard
  before update on app.export_requests
  for each row execute function app.guard_export_request_relay();

create policy worker_relay_select on app.deletion_requests
  as permissive for select to noura_worker
  using (state = 'requested');
create policy worker_relay_update on app.deletion_requests
  as permissive for update to noura_worker
  using (state = 'requested' and queue_job_id is null)
  with check (state = 'requested' and queue_job_id is not null);

create function app.guard_deletion_request_relay()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if current_user = 'noura_worker' and app.request_user_id() is null then
    if (new.id, new.user_id, new.state, new.last_error_code, new.attempts, new.requested_at,
        new.completed_at)
       is distinct from
       (old.id, old.user_id, old.state, old.last_error_code, old.attempts, old.requested_at,
        old.completed_at) then
      raise exception 'relay may only record queue dispatch' using errcode = '42501';
    end if;
  end if;
  return new;
end
$$;
create trigger deletion_requests_relay_guard
  before update on app.deletion_requests
  for each row execute function app.guard_deletion_request_relay();
