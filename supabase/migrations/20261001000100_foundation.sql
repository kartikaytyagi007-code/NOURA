-- NOURA M1 · Foundation: application schema, server roles and shared helpers.
--
-- Security model (see docs/decisions.md D-004..D-006):
--   * Domain tables live in schema "app", which is NOT exposed through the Supabase Data API.
--   * Mobile clients (anon / authenticated roles) receive no grants on any domain table.
--   * The API and worker run their domain queries under the restricted roles noura_api /
--     noura_worker (via SET LOCAL ROLE inside a transaction). Neither role bypasses RLS.
--   * Each transaction sets the GUC "noura.user_id" to the verified token subject; RLS policies
--     compare user_id against it, so a missing user context returns no rows (fail closed).
--   * Application code still filters by user_id explicitly; RLS is defence in depth.

create schema if not exists app;
comment on schema app is 'NOURA domain schema. Not exposed via the Supabase Data API. SQL is the schema authority.';

do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'noura_api') then
    create role noura_api nologin;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'noura_worker') then
    create role noura_worker nologin;
  end if;
end
$$;

comment on role noura_api is 'Restricted role for API domain queries. NOLOGIN; assumed with SET LOCAL ROLE. Never BYPASSRLS.';
comment on role noura_worker is 'Restricted role for worker domain queries. NOLOGIN; assumed with SET LOCAL ROLE. Never BYPASSRLS.';

-- The migration/connection user must be able to SET ROLE into the restricted roles.
-- Production should use a dedicated login role that is granted these roles instead (runbook).
grant noura_api to current_user;
grant noura_worker to current_user;

revoke all on schema app from public;
grant usage on schema app to noura_api, noura_worker;

-- Verified request owner. NULL when no user context is set, which makes every owner policy deny.
create or replace function app.request_user_id()
returns uuid
language sql
stable
set search_path = ''
as $$
  select nullif(current_setting('noura.user_id', true), '')::uuid
$$;

comment on function app.request_user_id() is
  'Returns the verified user id for the current transaction (GUC noura.user_id, set by API/worker after token verification). NULL means no access.';

create or replace function app.touch_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end
$$;

-- Enables RLS and the standard owner-isolation policy on a user-owned table.
create or replace function app.enable_owner_rls(target regclass)
returns void
language plpgsql
set search_path = ''
as $$
begin
  execute format('alter table %s enable row level security', target);
  execute format(
    'create policy owner_isolation on %s as permissive for all to noura_api, noura_worker '
    'using (user_id = app.request_user_id()) with check (user_id = app.request_user_id())',
    target
  );
end
$$;

-- Attaches the updated_at trigger.
create or replace function app.add_touch_trigger(target regclass)
returns void
language plpgsql
set search_path = ''
as $$
begin
  execute format(
    'create trigger touch_updated_at before update on %s for each row execute function app.touch_updated_at()',
    target
  );
end
$$;

revoke all on function app.enable_owner_rls(regclass) from public;
revoke all on function app.add_touch_trigger(regclass) from public;
revoke all on function app.touch_updated_at() from public;
revoke all on function app.request_user_id() from public;
grant execute on function app.request_user_id() to noura_api, noura_worker;
