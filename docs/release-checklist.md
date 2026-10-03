# V1 release checklist

This consolidates every open release gate recorded across M1-M10 (`docs/decisions.md` D-010 through
D-032, and the "Known limitations and release gates" section of each milestone in `docs/milestones.md`).
M10 is the final V1 milestone — there is no later milestone to defer these into. Every item below needs a
real external account, credential, physical device, licensed dataset or human review that this sandboxed
development container does not have; none of it is further engineering work inside this repository
beyond wiring in the real configuration once it exists.

## Accounts, projects and credentials

- [ ] Real Supabase production project (separate from staging), with migrations applied as a release
      step (blueprint §18) — not run ad hoc. `SUPABASE_URL`/`SUPABASE_SERVICE_ROLE_KEY` set per
      environment, never committed (D-001-era rule, still enforced by `pnpm secrets:check`).
- [ ] Real RevenueCat project: sandbox and production API keys, a real webhook secret
      (`BILLING_PROVIDER=revenuecat`), and `app_user_id` mapped to the Supabase user UUID (blueprint §13).
      `RevenueCatBillingProvider`/`SupabaseAuthAdminProvider` (`packages/billing`) have not been exercised
      against a live project in this environment — only unit-tested against fixed fixtures (D-032).
- [ ] Real AI provider account/key/model for meal recognition (M4, D-010) and coach replies (M9, D-031).
      `AI_PROVIDER=mock` is the only path exercised anywhere in this repository's test suites.
- [ ] Apple and Google developer accounts, app store listings, and screenshots/metadata.
- [ ] SMS gateway for phone sign-in (D-033): provider account configured in Supabase (Phone provider on,
      Email and OAuth providers off), TRAI DLT entity/sender/template registration for Indian numbers,
      SMS rate limits and spend alerts, and an end-to-end sign-in on a real phone. Optionally CAPTCHA
      against SMS pumping, and a decision on a maximum session length (`[auth.sessions]`, paid plan).
- [ ] A real analytics/crash-reporting provider if the product wants more than the opt-in telemetry
      interface shipped in M10 (`TelemetryProvider`, `MockTelemetryProvider` only — D-032).
- [ ] A real `flutter_local_notifications` (or equivalent) integration for reminders — M10 ships only
      `NoOpReminderScheduler`; this needs native Android/iOS project changes and a physical-device test
      this environment cannot perform (D-032).

## Data and content review

- [ ] Licensed, reviewed nutrition/recipe catalog replacing the synthetic fixture data used throughout
      M3-M6's tests (D-018, D-025, D-026).
- [ ] Licensed, reviewed exercise catalog replacing the synthetic fixture data used in M7 (D-029).
- [ ] Clinical/safety review of M9's `checkSafety` keyword screen — it is a deliberately over-flagging
      heuristic, not a reviewed clinical-scope policy (D-031).
- [ ] AI evaluation fixture per blueprint §17: at least 60 annotated Indian meal images (recognition
      accuracy/correction/unknown-rate/latency/cost) and at least 40 diet/coach scenarios (vegan,
      eggatarian, budget, allergy, missing-log cases). Not run in this environment — no real provider.
- [ ] Final legal documents (privacy policy, terms) and their version identifiers recorded in the
      consent-versioning columns already built in M2 (D-019-era note).

## Infrastructure and operations

- [ ] Container image build and deploy pipeline — no Docker daemon is available in this development
      container; every backend test suite ran against a local plain-Postgres instance instead
      (D-012's shim), never a built image.
- [ ] Physical Android and iOS builds and camera/permission tests (blueprint §17) — `flutter analyze`/
      `flutter test`/`dart format` were run in this environment; `flutter build apk`/`flutter build ios`
      against a real device/signing identity were not.
- [ ] Production backup/restore drill that respects deletion tombstones (blueprint §14) — M10's account
      deletion removes owned rows and Storage objects immediately; no backup-retention/restore procedure
      has been exercised here.
- [ ] Monitoring and alerting wired per `docs/runbooks/operations.md` (queue age, provider failures, p95
      latency, quota-reservation leaks, webhook lag, DB errors, per-feature spend) — the runbook
      describes what to monitor and the operational response; no monitoring backend is deployed here.
- [ ] Rate limiting and account-deletion review at the infrastructure layer (blueprint §17's "API rate
      limits and account deletion review" is a pre-production review item, distinct from the
      already-implemented per-user-per-feature daily quotas).
- [ ] Cost/load test against a declared target cohort (blueprint §17) — no load test has been run here.

## Scheduled jobs not yet built (documented gaps, not silent omissions)

None of these have scheduled/cron automation in this codebase; every one of them already has an
immediate, user-initiated or request-time equivalent, so no data is retained indefinitely by omission —
only the _automatic, time-based_ cleanup is missing:

- [ ] 24-hour purge of uncompleted uploads and exports (blueprint §14). Exports currently rely on each
      export object's own `expires_at`; nothing yet deletes the Storage object once expired.
- [ ] 7-day purge of failed/unlogged meal scans (blueprint §14).
- [ ] 90-day purge of logged meal images not deleted sooner (M4, D-025) and of coach history not deleted
      sooner (M9, D-031) — both already support immediate user-initiated deletion.

## Configuration review before first production deploy

- [ ] Confirm every `*_PROVIDER` environment variable (`AI_PROVIDER`, `BILLING_PROVIDER`,
      `AUTH_ADMIN_PROVIDER`, `MEDIA_STORAGE_DRIVER`) is set to its real value, not `mock`/`local` — the
      fail-closed config validation (D-010 pattern, extended by D-032) refuses to start otherwise in
      `staging`/`production`, but this is still worth an explicit pre-flight check.
- [ ] Confirm staging and production use distinct Supabase/RevenueCat/AI-provider projects and keys
      (blueprint §18 — "different accounts/projects/keys for staging and production").
- [ ] Re-run this repository's full check suite (`pnpm secrets:check && pnpm lint && pnpm typecheck`,
      every `vitest` suite, `pnpm contracts:check`, `flutter analyze && flutter test`) against the release
      commit immediately before deploying, exactly as CI does.
