-- TEST-ONLY Supabase compatibility shim for plain PostgreSQL (CI and this repo's DB tests).
--
-- It recreates only the Supabase objects NOURA migrations depend on: the anon/authenticated/
-- service_role roles, auth.users, storage.buckets and storage.objects (RLS enabled, no policies),
-- and Supabase's broad default privileges for the client roles. It is NOT applied to any real
-- Supabase project; there these objects already exist. Local development against the real stack
-- uses `supabase start` + `supabase db reset` (see README).

do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then create role anon nologin; end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then create role authenticated nologin; end if;
  if not exists (select 1 from pg_roles where rolname = 'service_role') then create role service_role nologin bypassrls; end if;
end
$$;

create schema if not exists auth;
create table if not exists auth.users (
  id uuid primary key,
  email text,
  created_at timestamptz not null default now()
);

create schema if not exists storage;
create table if not exists storage.buckets (
  id text primary key,
  name text not null unique,
  owner uuid,
  public boolean default false,
  file_size_limit bigint,
  allowed_mime_types text[],
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
create table if not exists storage.objects (
  id uuid primary key default gen_random_uuid(),
  bucket_id text references storage.buckets (id),
  name text,
  owner uuid,
  created_at timestamptz default now()
);
alter table storage.objects enable row level security;
grant usage on schema storage to anon, authenticated;
grant all on storage.objects to anon, authenticated;

-- Supabase grants the client roles broad default privileges. Emulate the worst case globally so the
-- tests prove NOURA's migrations revoke them explicitly.
alter default privileges grant all on tables to anon, authenticated;
alter default privileges grant all on functions to anon, authenticated;
