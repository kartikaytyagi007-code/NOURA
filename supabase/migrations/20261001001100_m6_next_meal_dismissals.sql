-- NOURA M6 · Dismissed next-meal recommendations (blueprint §9, §16 M6; docs/decisions.md D-028).
--
-- "Dismiss" must be sticky and safe under retries (the ticket's duplicate-request requirement for
-- every next-meal action), so unlike M5's plate fixes (D-027, which persist nothing because they are
-- a pure read-time computation) this needs one small piece of genuine user-owned state: one row per
-- (date, slot) the user dismissed a next-meal suggestion for. It records no recommendation content,
-- only that the slot was dismissed, so a later GET for the same date/slot can honestly report "you
-- dismissed this" instead of silently recomputing and re-showing the same suggestion.

-- Bugfix, carried forward rather than editing the applied M1 migration: the M1 grants migration's
-- `alter default privileges in schema app revoke all on tables/functions from public;` named only
-- `public`, not `anon`/`authenticated`. Those two roles separately received a blanket
-- `alter default privileges grant all on tables to anon, authenticated` from the Supabase test shim
-- (`supabase/tests/support/supabase_shim.sql`, loaded once per test run with no `IN SCHEMA` clause),
-- which is namespace-independent and therefore still applies to any schema without its own
-- schema-specific default-privilege entry overriding it for those two roles specifically. No table in
-- schema `app` was created after the M1 grants migration until this one, so the gap was latent and
-- never exercised; this table is the first to need it. Fixed here for every future migration, and
-- this table is additionally granted/revoked explicitly below as defence in depth.
alter default privileges in schema app revoke all on tables from public, anon, authenticated;
alter default privileges in schema app revoke all on functions from public, anon, authenticated;

create table app.dismissed_recommendations (
  user_id uuid not null references auth.users (id) on delete cascade,
  local_date date not null,
  slot text not null check (slot in ('breakfast', 'lunch', 'dinner', 'snack')),
  dismissed_at timestamptz not null default now(),
  primary key (user_id, local_date, slot)
);
comment on table app.dismissed_recommendations is
  'Sticky dismissal of a next-meal recommendation for one date/slot (M6). No recommendation content is stored.';
select app.enable_owner_rls('app.dismissed_recommendations');

-- Explicit, in case any default-privilege ordering is ever revisited (defence in depth, not reliance).
revoke all on app.dismissed_recommendations from public, anon, authenticated;

-- No update (a dismissal is never edited); delete is granted so a future "undo dismissal" action or
-- account-deletion cleanup can use it, though M6 itself only reads and inserts.
grant select, insert, delete on app.dismissed_recommendations to noura_api;
