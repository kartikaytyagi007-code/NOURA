# Operations runbook

Per blueprint §18: what to monitor, how alerts are shaped, and the response for each named incident
class. No monitoring backend is deployed in this development container; this document describes what a
real deployment must wire up, and is the pre-production checklist item tracked in
`docs/release-checklist.md`.

## What to monitor

- **Queue age** — oldest undispatched row in `app.generation_requests`/`app.export_requests`/
  `app.deletion_requests` (`state`/`status = 'queued'`/`'requested'`) and oldest unprocessed pg-boss job.
  A growing age means the relay loop or a worker handler is stuck.
- **Provider failures** — rate of `provider_unavailable`/`failed_invalid_response` outcomes from the AI
  provider (meal recognition, coach replies) and the billing provider (webhook/sync calls), broken out
  by provider name so a single vendor's outage is visible immediately.
- **p95 request/generation latency** — API route latency and the queued-to-completed duration for each
  async job type (meal scan, diet/workout plan, coach reply, export, deletion).
- **Quota reservation leaks** — rows in `app.usage_reservations` older than a few minutes still in a
  non-terminal state. A real leak means a handler failed without releasing its reservation.
- **Webhook lag** — time between a RevenueCat webhook's own event timestamp and when
  `app.billing_events` recorded it, and the `ignored`/`processed` split (a growing `ignored` rate can
  mean the `app_user_id` mapping is broken).
- **Database errors** — connection pool exhaustion, RLS policy violations surfaced as unexpected 403s,
  deadlocks/lock-wait timeouts (the account-deletion handler's three-transaction split in D-032 exists
  specifically to avoid one class of these).
- **Per-feature spend** — AI provider token/request cost attributed to meal scans vs. coach replies vs.
  plan generation, so a cost regression in one feature is distinguishable from overall growth.

Alerts contain IDs and error codes only (request id, job id, error code) — never request/response bodies,
meal/chat content, or PII, consistent with the structured-logging redaction rules the API and worker
already apply.

## Runbooks

### Provider outage / fallback (AI or billing provider)

1. Confirm via the provider-failure-rate monitor above which provider and which operation is failing.
2. Check the provider's own status page. If it is a known outage, no immediate schema/config change is
   needed — queued jobs retry automatically (pg-boss retry policy; see `packages/domain/src/jobs/queues.ts`
   for each queue's `retryLimit`/`retryDelay`/`retryBackoff`).
3. If the outage is prolonged, consider pausing new job submission at the API layer (reject new
   meal-scan/coach-reply requests with a clear `PROVIDER_UNAVAILABLE` error) rather than letting a large
   retry backlog build, since quota reservations are held until a job reaches a terminal state.
4. For a billing-provider outage specifically: webhooks already queue at the provider's end and will be
   redelivered; entitlement checks continue to serve the last-reconciled state from `app.entitlements`,
   so existing premium users are not locked out mid-outage.

### Worker retry / stuck job

1. Identify the stuck row via the queue-age monitor (table + id).
2. Confirm the corresponding pg-boss job exists and its `retrycount`/`state` in the `pgboss.job` table.
3. If the job is dead-lettered (`system.dead-letter`), inspect its last error, fix the underlying cause,
   and re-queue by resetting the domain row's state back to `queued`/`requested` so the relay loop picks
   it up again on its next poll — never hand-edit the row straight to `completed`.
4. If a job is stuck `running` with no corresponding live worker process (a crashed worker), pg-boss's
   own expiry (`expire_in` per queue) eventually reclaims it; do not manually force a state change until
   that expiry has passed, to avoid two workers processing the same row.

### Purchase reconciliation

1. A user reports their premium access is wrong. First call `POST /v1/billing/sync` for that user
   (the same "restore purchases" path Flutter's `BillingScreen` uses) — this re-fetches the provider's
   current subscriber state and reconciles it, which resolves the large majority of drift without any
   manual database change.
2. If still wrong, inspect `app.billing_events` for that user's recent events (ordered by
   `event_at`) and `app.entitlements.last_verified_at` to see which event actually won the
   reconcile-guard comparison in `reconcileEntitlement` (D-032) — a legitimately newer event always wins,
   so an apparently "stale" state is usually correct given what the provider has reported so far.
3. Only as a last resort, after confirming with the provider's own dashboard what the subscriber's real
   state is, manually correct the `app.entitlements` row — and record why in an incident note, since this
   bypasses the normal reconciliation path.

### Restore (database)

See `docs/runbooks/database.md` for the migration/connection details. For a data-loss incident:

1. Restore from the most recent backup per the hosting provider's documented procedure.
2. Before resuming traffic, re-apply any migrations committed after that backup was taken.
3. Respect deletion tombstones (blueprint §14): a restore must not resurrect a user who deleted their
   account after the backup was taken. `app.deletion_requests` rows marked `completed` are the source of
   truth for who was deleted; cross-check restored user ids against them before resuming writes for that
   user.

### Deletion backlog

1. If `app.deletion_requests` rows are piling up in `requested`/`in_progress` beyond the queue-age
   alert threshold, first check whether the worker's `account.delete` handler is erroring (structured
   logs will show the failing step: cancel-jobs, storage-delete, or `authAdmin.deleteUser`).
2. A failure in the Storage-delete step is retried automatically (the transaction rolls back and the row
   stays `in_progress` for pg-boss to retry) — confirm the underlying Storage API is reachable.
3. A failure in `authAdmin.deleteUser` (the Supabase Admin API call) with no open transaction, per
   D-032's three-transaction design, is safe to retry as-is; do not re-run the earlier steps.

### Rollback

1. Revert to the previous release image/commit.
2. Database migrations in this repository are additive-only (AGENTS.md); a rollback does not need a
   down-migration in the common case. If a migration genuinely must be reverted, write a new additive
   migration that undoes its effect rather than editing or deleting the applied file.
3. Re-run the full check suite (`docs/release-checklist.md`'s final item) against the rolled-back commit
   before resuming traffic.
