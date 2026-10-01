# Milestones

Status of each milestone from blueprint §16. A milestone counts as complete only when its
acceptance gate passes. A schema that exists without the feature does not count.

| Milestone     | Status                                                        |
| ------------- | ------------------------------------------------------------- |
| M1 Foundation | Approved by the owner. PR #1 open with CI green               |
| M2 Profile    | **Implemented, awaiting review**                              |
| M3 to M10     | Not started. Contract drafts only (`x-noura-status: planned`) |

## M1 Foundation

### Delivered

- **Monorepo:** pinned versions and committed lockfiles (D-001, D-002).
- **Flutter shell:**
  - Five tabs (Home, Meals, Coach, Workout, Progress). Settings opens from the profile icon.
  - Auth: welcome, sign-in, sign-up, email verification, forgotten password, update password after
    the recovery link, Google and Apple through Supabase OAuth, session restore, sign-out, and
    sign-out on an expired session.
  - Route guards: restoring → signed out → profile loading or error → onboarding → shell.
  - Typed API client with one refresh-and-retry on a 401.
  - Explicit mock mode with a banner.
  - Future features appear only as labelled placeholders.
- **API (Fastify):**
  - Validated configuration that fails closed in staging and production.
  - JWKS-only token verification.
  - Standard error envelope and request IDs.
  - `GET /health/live`, `GET /health/ready`, `GET /v1/me` and `GET /v1/jobs/{id}`.
  - Every route is registered from OpenAPI with its request and response schemas.
- **Worker:**
  - pg-boss with queue policies and a dead-letter queue.
  - `system.ping` handler, health server and graceful shutdown.
  - Separate `queue:migrate` release step.
- **Database:** migrations for all V1 tables in schema `app`:
  - RLS with an owner policy on every user table, and composite ownership foreign keys.
  - Restricted server roles; no grants to mobile roles.
  - Private Storage buckets with no client policies.
- **Contracts:** OpenAPI 3.0.3 covering all V1 routes, with generated TypeScript types and Dart
  client, and a drift check.
- **Configuration and CI:** placeholder-only environment templates, a secret scan and a CI workflow.
- **Docs:** README setup, `docs/decisions.md`, `docs/auth-providers.md`, `docs/runbooks/database.md`
  and `AGENTS.md`.

### Acceptance checks (run 2026-10-01 in the development container)

| Check                                                  | Command                                                                                            | Result                                                                        |
| ------------------------------------------------------ | -------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| Fresh install from lockfile                            | `pnpm install --frozen-lockfile` (after deleting all `node_modules`)                               | Passed                                                                        |
| Secret scan                                            | `pnpm secrets:check`                                                                               | Passed (571 files). Planted leaks were all caught                             |
| Lint and format                                        | `pnpm lint`                                                                                        | Passed                                                                        |
| OpenAPI lint                                           | `pnpm contracts:lint`                                                                              | Valid. 11 example warnings (allOf/nullable validator semantics; known)        |
| Typecheck, including tests                             | `pnpm typecheck`                                                                                   | Passed                                                                        |
| Contract and domain unit tests                         | `pnpm -r --filter './packages/*' run test`                                                         | Passed. contracts 13, domain 8, ai 5                                          |
| Fresh migrations, ownership isolation, grants and RLS  | `supabase`: `vitest run` against PostgreSQL 16                                                     | Passed. 22 tests                                                              |
| Auth, errors, contract parity, owner-isolated jobs     | `apps/api`: `vitest run`                                                                           | Passed. 27 tests (ES256 tokens from a local JWKS server)                      |
| Queue connectivity (produce → complete), worker health | `apps/worker`: `vitest run`                                                                        | Passed. 6 tests                                                               |
| Process startup                                        | `node apps/api/dist/server.js` and `node apps/worker/dist/worker.js` against a freshly migrated DB | Both ready (database, server role, queue schema, handlers). Exit 0 on SIGTERM |
| Production fails closed                                | API with `APP_ENV=production` and mock providers                                                   | Refused to start, exit 1. Error named the variables only                      |
| Contract drift                                         | `pnpm contracts:check`                                                                             | Passed after committing regenerated TS types. The first run caught real drift |
| Flutter format, analyze and tests                      | `dart format`, `flutter analyze`, `flutter test`                                                   | Passed. No issues; 33 tests                                                   |
| Flutter web build                                      | `flutter build web --release`                                                                      | Passed                                                                        |
| Flutter Android build                                  | `flutter build apk --debug`                                                                        | Passed in GitHub Actions CI on PR #1 (no Android SDK in the dev container)    |
| Container image                                        | `docker build .`                                                                                   | **Not run here.** No Docker daemon                                            |
| Local Supabase stack                                   | `supabase start && supabase db reset`                                                              | **Not run here.** No Docker. A plain-Postgres shim was used instead (D-012)   |
| Live Supabase Auth, Google and Apple                   | Manual, on a device                                                                                | **Not run.** Needs the owner's Supabase project and provider accounts         |
| iOS build                                              | `flutter build ios`                                                                                | **Not run.** Needs macOS and Apple configuration                              |

The Flutter auth and session tests run against the mock auth repository and a fake profile API.
They cover:

- sign-in leading to onboarding;
- a restored session leading to the five tabs;
- sign-out and session expiry;
- password reset and recovery;
- a failed profile load with retry;
- the mock-mode banner;
- an unsafe production configuration;
- tap-target and contrast guidelines.

The interceptor tests cover the bearer token, 401 refresh-and-retry, a failed refresh, a second 401,
and concurrent refreshes. None of these tests use a live Supabase project.

### Known limitations

- Google and Apple are integrated but not verified with real providers. Native SDK sign-in is a
  later improvement (D-011).
- The API does not produce jobs in M1 (D-009).
- Plus Jakarta Sans is not bundled yet (D-014).
- Stitch screens are not integrated yet. The UI uses replaceable primitives.

## M2 Profile and onboarding

### Delivered

- **API (all `x-noura-status: implemented`, with tests):**
  - `PATCH /v1/me`, `PUT /v1/me/preferences`, `PUT /v1/me/training-preferences`,
    `POST /v1/onboarding/complete` and `GET /v1/targets`; `GET /v1/me` now returns weight, goal,
    screening and planning state.
  - Server-side validation with field errors: plausible metric ranges, an IANA timezone, adult and
    screening rules, goal direction, training coherence, tag vocabularies and consent versions.
  - Independent profile, preferences and training revisions; stale writes return `REVISION_CONFLICT`.
  - Idempotent writes (`Idempotency-Key`), stored in the same transaction as the work (D-022).
- **Eligibility (D-019):** `eligible`, `tracking_only` and `needs_review` from age and three screening
  answers, as a pure, versioned function. Only minimal flags are stored.
- **Target-policy framework (D-018):** deterministic, versioned, zod-validated and configurable. Only a
  clearly labelled TEST policy ships. Staging and production refuse it, and with no approved policy
  planning is unavailable. A declined sex gives an energy range. No unreviewed value is presented as
  medical advice, and the app shows no targets.
- **Onboarding completion (D-017, D-022):** one transaction records consents, eligibility, the
  completed profile, a target snapshot and, only for eligible users with an allowed policy, one
  generation request. A worker relay hands requests to pg-boss, so a queue or generation failure never
  loses profile data. Duplicate submits create one request.
- **Flutter (D-023):** six resumable steps (About you, Goal, Food preferences, Training, Eligibility,
  Review and consent) with kg/lb and cm/ft+in, loading, offline, conflict and validation states;
  Settings editing for profile, goal, food preferences, training and eligibility; a Home status card for
  the planning state. The Stitch export has no onboarding screens, so the existing components are used.
- **Database:** migration `20261001000900` adds weight, screening state, snapshot policy status, the
  consent uniqueness index and the narrow relay policies and trigger.
- **Docs:** decisions D-017 to D-024, the database runbook (relay and policy), env templates.

### Acceptance checks (run 2026-10-01 in the development container)

| Check                                              | Command                                                                                            | Result                                                                                        |
| -------------------------------------------------- | -------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| Secret scan                                        | `pnpm secrets:check`                                                                               | Passed                                                                                        |
| Lint and format                                    | `pnpm lint`                                                                                        | Passed                                                                                        |
| OpenAPI lint                                       | `pnpm contracts:lint`                                                                              | Valid. 14 example warnings (11 in M1; same allOf/nullable validator semantics)                |
| Typecheck, including tests                         | `pnpm typecheck`                                                                                   | Passed                                                                                        |
| Contract, domain and ai unit tests                 | `pnpm -r --filter './packages/*' run test`                                                         | Passed. contracts 13, domain 39, ai 5                                                         |
| Migrations, RLS, grants, relay policies            | `supabase`: `vitest run` against PostgreSQL 16                                                     | Passed. 33 tests (22 from M1, 11 new)                                                         |
| API integration (profile, eligibility, completion) | `apps/api`: `vitest run`                                                                           | Passed. 62 tests (27 from M1, 35 new)                                                         |
| Relay and worker                                   | `apps/worker`: `vitest run`                                                                        | Passed. 12 tests (6 from M1, 6 new)                                                           |
| Flutter format, analyze and tests                  | `dart format --line-length 120`, `flutter analyze`, `flutter test`                                 | Passed. No issues; 62 tests (33 from M1, 29 new)                                              |
| Flutter web build                                  | `flutter build web --release`                                                                      | Passed                                                                                        |
| Process startup                                    | `node apps/api/dist/server.js`, `node apps/worker/dist/worker.js`                                  | Both ready against a freshly migrated database and exit 0 on SIGTERM                          |
| Production fails closed on policy                  | API with `APP_ENV=production` and a test-status `PLANNING_POLICY_FILE`                             | Refused to start, exit 1, error names the variable only. With no file it starts, planning off |
| Test strength (mutations, then restored)           | Removed the relay guard trigger, the already-complete check, and the never-move-the-step-back rule | Each was caught by a test (DB, API and Flutter respectively)                                  |
| Contract drift                                     | `pnpm contracts:check`                                                                             | DRIFT_RESULT                                                                                  |
| Flutter Android build                              | `flutter build apk --debug`                                                                        | **Not run here** (no Android SDK). Runs in CI on the M2 PR                                    |
| Container image                                    | `docker build .`                                                                                   | **Not run here.** No Docker daemon                                                            |
| Local Supabase stack                               | `supabase start && supabase db reset`                                                              | **Not run here.** No Docker. The plain-Postgres shim was used (D-012)                         |
| Live Supabase Auth, Google and Apple, on a device  | Manual                                                                                             | **Not run.** Needs the owner's Supabase project and provider accounts                         |

How the M2 acceptance gate maps to tests:

- **Resume after restart:** the Flutter flow tests rebuild the whole app against the same server state
  and land on the saved step with the saved answers; `getMe` returns the stored step (API tests).
- **Unit and timezone validation:** API tests for ranges and IANA names; Flutter tests for kg/lb and
  cm/ft+in input, validation in the user's units, and the metric values sent.
- **Edits increment revisions, stale writes conflict:** API tests per resource and Flutter conflict and
  "Load latest" flows, in onboarding and in Settings.
- **Unsupported users cannot reach planning:** API tests for a minor, each "yes" answer and a declined
  answer (no generation request, `not_calculated` snapshot) and for a deployed environment with no
  approved policy; Flutter tests for the explanation and Home card.
- **Duplicate submits create one request:** API tests with concurrent same-key requests, a new key and
  a stale revision; a Flutter test that a retry reuses its idempotency key.

### Known limitations and release gates

- **Approved target policy (open).** Only the test policy exists. Staging and production cannot plan
  until a reviewer supplies one (D-018).
- **Consent text (open).** All consent versions are `v0-draft` placeholders (D-021).
- **Eligibility parameters and copy (open).** The adult age and the question and explanation wording
  need legal and clinical review (D-019).
- **Vocabularies (provisional).** Tag sets and the curated timezone list are revised with the catalogs
  (D-020).
- No handler consumes the generation job yet. Relayed jobs wait for M3 (D-017).
- Google and Apple sign-in, the Android and iOS builds and the container image are unchanged from M1
  and still unverified here.

### M3 hand-off

See D-024. Diet plan generation is not started.
