-- NOURA M2 · Profile and onboarding (additive; no M1 object is dropped, one check is widened below).
--
--   * profiles gains weight_kg (the self-reported weight used for targets; M8 weight logs may update
--     it later) and screening_answered_at (whether eligibility screening has been answered).
--   * profiles.screening_flags is constrained to the minimal flag vocabulary.
--   * target_snapshots records whether the policy that produced it was a test or approved policy.
--   * consent_records cannot hold two active records for the same consent type and version.
--   * generation_requests can be relayed to pg-boss by the worker (transactional outbox, D-017).

alter table app.profiles
  add column weight_kg numeric(5, 2) check (weight_kg between 20 and 400),
  add column screening_answered_at timestamptz;

comment on column app.profiles.weight_kg is
  'Self-reported weight in kg used for target calculation. Plausibility bound only, not a medical threshold.';
comment on column app.profiles.screening_answered_at is
  'When the user last answered the eligibility screening. Null until answered.';

alter table app.profiles
  add constraint profiles_screening_flags_vocabulary check (
    screening_flags <@ array[
      'pregnancy_or_breastfeeding', 'pregnancy_or_breastfeeding:declined',
      'eating_disorder_concern', 'eating_disorder_concern:declined',
      'medical_diet_condition', 'medical_diet_condition:declined'
    ]::text[]
  );

-- A completed profile now also requires weight and answered screening.
alter table app.profiles drop constraint profiles_completed_requires_core;
alter table app.profiles
  add constraint profiles_completed_requires_core check (
    onboarding_status <> 'completed'
    or (display_name is not null and age_years is not null and height_cm is not null
        and weight_kg is not null and activity_band is not null
        and eligibility_status is not null and screening_answered_at is not null)
  );

alter table app.target_snapshots
  add column policy_status text not null default 'test'
    check (policy_status in ('test', 'approved'));
comment on column app.target_snapshots.policy_status is
  'test = development placeholder policy (never medical advice); approved = reviewed policy. Defaults to test so an unlabelled snapshot is never presented as reviewed.';

create unique index consent_records_one_active
  on app.consent_records (user_id, consent_type, version)
  where revoked_at is null;

-- ---------------------------------------------------------------------------------------------
-- Generation request relay (transactional outbox).
-- The API only records a durable generation request in the same transaction as the onboarding
-- completion. The worker later relays requests that have not been handed to pg-boss. The API holds
-- no queue privileges at all.
-- ---------------------------------------------------------------------------------------------
create index generation_requests_undispatched
  on app.generation_requests (created_at)
  where status = 'queued' and queue_job_id is null;

-- Cross-user visibility for the relay is deliberately narrow: only requests that are still queued,
-- and the update may only mark an undispatched one as dispatched. (PostgreSQL also checks the SELECT
-- policy against the updated row, so the select policy must keep matching after dispatch.)
create policy worker_relay_select on app.generation_requests
  as permissive for select to noura_worker
  using (status = 'queued');

create policy worker_relay_update on app.generation_requests
  as permissive for update to noura_worker
  using (status = 'queued' and queue_job_id is null)
  with check (status = 'queued' and queue_job_id is not null);

-- Policies cannot restrict columns, so a trigger does: with no user context the worker may change
-- only the dispatch columns. Per-user job handling (with a user context) is unaffected.
create function app.guard_generation_request_relay()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if current_user = 'noura_worker' and app.request_user_id() is null then
    if (new.id, new.user_id, new.request_type, new.status, new.input_revision, new.result_ids,
        new.safe_error_code, new.safe_error_message, new.attempts, new.started_at,
        new.completed_at, new.created_at)
       is distinct from
       (old.id, old.user_id, old.request_type, old.status, old.input_revision, old.result_ids,
        old.safe_error_code, old.safe_error_message, old.attempts, old.started_at,
        old.completed_at, old.created_at) then
      raise exception 'relay may only record queue dispatch' using errcode = '42501';
    end if;
  end if;
  return new;
end
$$;

create trigger generation_requests_relay_guard
  before update on app.generation_requests
  for each row execute function app.guard_generation_request_relay();
