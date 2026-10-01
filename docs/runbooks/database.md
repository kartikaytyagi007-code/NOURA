# Database runbook

## Migrations

- SQL in `supabase/migrations` is the schema authority. Migrations are additive where possible and
  reviewed before release.
- **Local (Supabase CLI, needs Docker):** `pnpm exec supabase start`, then `pnpm exec supabase db reset`.
- **Local or CI (plain PostgreSQL 16, no Docker):** `DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:5432/noura_dev pnpm db:reset:local`.
  This applies a test-only Supabase shim, then every migration. It refuses non-local hosts and
  `APP_ENV=production`.
- **Staging and production:** apply reviewed migrations as a release step
  (`supabase db push --linked`), after a backup for anything destructive. Never run the plain reset
  script against them. The API and worker must stay compatible with the old and new schema during
  rollout.

## Server login roles (deployed environments)

The migrations create `NOLOGIN` roles `noura_api` and `noura_worker` (no `BYPASSRLS`). Create one
dedicated login role per process and grant it the matching restricted role. Do this once per
environment, as a reviewed manual step, with a generated password stored in the host's secret
manager:

```sql
create role noura_api_login login password '<generated>' noinherit;
grant noura_api to noura_api_login;
create role noura_worker_login login password '<generated>' noinherit;
grant noura_worker to noura_worker_login;
grant usage, create on schema pgboss to noura_worker_login;   -- after queue:migrate
```

The API's readiness check reports `role: false` if the connection user cannot assume its role.

## Queue (pg-boss)

- The worker needs a direct or session-mode connection (port 5432 on the Supabase pooler), not the
  transaction pooler.
- Install or upgrade the queue schema as a release step:
  `pnpm --filter @noura/worker run queue:migrate` (or `node apps/worker/dist/queue-migrate.js` in the
  image). Keep `PGBOSS_MIGRATE=false` in deployed workers.
- Failed jobs that exhaust their retries go to `system.dead-letter`.

## Generation request relay (M2)

- Onboarding completion records a durable `generation_requests` row; the worker relays it to the
  queue (D-017). The worker's login role must be granted `noura_worker` (above), because the relay
  assumes that role without a user context.
- Requests waiting to be relayed: `select count(*) from app.generation_requests where status = 'queued' and queue_job_id is null;`
  A count that keeps growing means the worker is down or cannot reach the queue. Nothing is lost:
  the requests are relayed when it recovers.
- M3 adds the consumer. Until then relayed jobs wait in `diet-plan.generate`.

## Planning policy (M2)

- Automated planning needs an approved policy file (`PLANNING_POLICY_FILE`, D-018). Staging and
  production refuse a policy whose status is `test`. Without a file the API starts and reports
  `unavailable_policy` to eligible users, who keep every tracking feature.
- The file holds clinical parameters and their approval record. Treat it as reviewed configuration:
  keep it in the secret or configuration store, change it only with sign-off, and bump its `version`
  (snapshots record the version they used).
