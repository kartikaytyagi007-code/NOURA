# Milestones

Status of each milestone from blueprint §16. A milestone counts as complete only when its
acceptance gate passes. A schema that exists without the feature does not count.

| Milestone     | Status                                                         |
| ------------- | -------------------------------------------------------------- |
| M1 Foundation | Approved by the owner. PR #1 open with CI green                |
| M2 Profile    | Implemented, awaiting review. PR #2 (draft) open with CI green |
| M3 Diet plan  | **Implemented, awaiting review**                               |
| M4 to M10     | Not started. Contract drafts only (`x-noura-status: planned`)  |

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
| Contract drift                                     | `pnpm contracts:check`                                                                             | Passed (after committing the regenerated TS types and Dart client)                            |
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

## M3 Diet plan

**Ticket.** Deliver the diet-plan generation pipeline end to end: a provenance-backed catalog,
deterministic nutrition targets, generation through the job queue, 7-day/daily plan views with
portions and nutrition totals that reconcile exactly, meal swaps, user-requested regeneration, and
enforcement of diet type, allergies, dislikes and other profile constraints — honestly, with no
invented nutrition data (see the catalog-data blocker and D-025 below).

### Delivered

- **Catalog (data blocker, mitigated — D-025):** `data/foods`, `data/recipes`, `data/exercises` and
  `data/provenance` are still empty; no licensed dataset exists in this environment. Migration
  `20261001001000_catalog_test_fixture.sql` seeds ~30 foods and 16 recipes, all explicitly
  `quality_flag = 'test_fixture'` under a `food_sources` row whose `license_notes` disclaims
  production use. A new catalog planning gate (`packages/domain/src/catalog/gate.ts`) refuses
  automated generation in a deployed environment unless at least one `verified`/`reviewed` recipe
  per slot exists; development and test may use the fixture.
- **Domain (`packages/domain/src`):**
  - `catalog/eligibility.ts`: diet-type, allergen-safety (incomplete coverage is unsafe whenever any
    allergy constraint exists), exclusion and dislike filtering.
  - `catalog/nutrition.ts`, `nutrition/rounding.ts`: per-ingredient rounding and totals that sum
    exactly, with unknown nutrients reported as `null`, never zero.
  - `planning/generate.ts`: deterministic 7-day plan generation with per-meal portion scaling toward
    an energy target (or the recipe's base portion when only a range target is available, D-024),
    and explicit infeasibility results.
  - `planning/swap.ts`, `planning/storage.ts`: swap-candidate computation and the plan-meal storage
    shape shared by the API and the worker.
  - `planning/inputs.ts`, `catalog/repository.ts`: the single, shared DB-reading functions used by
    both the API and the worker, so eligibility and targets can never drift between them.
- **Queue:** `GENERATION_REQUEST_QUEUES` now routes both `diet_plan` and `plan_regeneration` to
  `diet-plan.generate`.
- **Worker:** `apps/worker/src/handlers/diet-plan-generate.ts`, registered in `runtime.ts`.
  Idempotent on `generation_request_id`; reloads everything fresh under the user's own
  `noura_worker` context; supersedes the previous active plan on regeneration; records an honest
  `catalog_unavailable` or `plan_infeasible` result instead of ever fabricating a plan. Requests
  relayed before this handler existed (the open question in D-017/D-024) are simply processed now.
- **API (`apps/api/src/modules/diet`):** `POST /v1/diet-plans/generate` (Idempotency-Key,
  `REVISION_CONFLICT` on a stale `profile_revision`, reuses an in-flight request via the existing
  partial unique index), `GET /v1/diet-plans/current`, `POST /v1/diet-plan-meals/{id}/swap-options`
  (read-only, re-filters eligibility fresh), `PUT /v1/diet-plan-meals/{id}` (Idempotency-Key,
  `expected_revision`, re-validates the candidate against fresh eligibility before applying it).
- **Contracts:** `generateDietPlan`, `getCurrentDietPlan`, `getSwapOptions`, `replacePlanMeal`
  flipped to `x-noura-status: implemented`; TS and Dart clients regenerated and committed.
- **Flutter:** `core/diet` (repository + `DietController`) and `features/diet/diet_plan_screen.dart`
  — a day selector, meal cards with portions/recipe name/kcal, a swap bottom sheet, a regenerate
  confirmation, and loading/empty/error states (reusing the M1/M2 component system per D-014/D-023;
  the Stitch export has no diet-plan screens). Reached from Meals → "Diet plan". A development-only
  `MockDietRepository` mirrors `MockProfileRepository`'s convention. Updating Home's
  `plan_generation`/`next_meal` cards to the now-real plan data was left for a follow-up (lower
  priority per the ticket); Home is unchanged from M2.
- **Docs:** decision D-025; this M3 section.

### Acceptance checks (run 2026-10-02 in the development container)

| Check                                                                           | Command                                                                | Result                                                                  |
| ------------------------------------------------------------------------------- | ---------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| Secret scan                                                                     | `pnpm secrets:check`                                                   | Passed (650 files)                                                      |
| Lint and format                                                                 | `pnpm lint`                                                            | Passed                                                                  |
| OpenAPI lint                                                                    | `pnpm contracts:lint`                                                  | Valid. 14 pre-existing example warnings (same as M2)                    |
| Typecheck                                                                       | `pnpm typecheck`                                                       | Passed (6 workspace projects)                                           |
| Contract, domain and ai unit tests                                              | `pnpm -r --filter './packages/*' run test`                             | Passed. contracts 13, domain 68, ai 5                                   |
| Migrations, RLS, grants, catalog seed                                           | `supabase`: `vitest run` against PostgreSQL 16                         | Passed. 39 tests (33 from M1/M2, 6 new)                                 |
| API integration (diet routes)                                                   | `apps/api`: `vitest run`                                               | Passed. 76 tests (62 from M1/M2, 14 new)                                |
| Worker (handler, relay, runtime)                                                | `apps/worker`: `vitest run`                                            | Passed. 20 tests (12 from M1/M2, 8 new)                                 |
| Flutter format, analyze and tests                                               | `dart format --line-length 120`, `flutter analyze`, `flutter test`     | Passed. No issues; 71 tests (62 from M1/M2, 9 new)                      |
| Flutter web build                                                               | `flutter build web --release`                                          | Passed                                                                  |
| Contract drift                                                                  | `pnpm contracts:check`                                                 | Passed (after committing regenerated TS/Dart clients)                   |
| Idempotent generation under concurrency                                         | API test: duplicate `generateDietPlan` with the same key               | Passed (one `generation_requests` row)                                  |
| At-least-once worker processing                                                 | Worker test: redelivery after "crash" between commit and terminal mark | Passed (`already_generated`, no duplicate plan)                         |
| Honest infeasibility / catalog gate                                             | Worker tests: no eligible recipe for a slot; production catalog gate   | Passed (`plan_infeasible` / `catalog_unavailable`, no plan row created) |
| Day totals reconcile exactly                                                    | Domain test: summing already-rounded meals vs. re-deriving from grams  | Passed                                                                  |
| Flutter Android build                                                           | `flutter build apk --debug`                                            | **Not run here** (no Android SDK), same as M1/M2                        |
| Container image                                                                 | `docker build .`                                                       | **Not run here.** No Docker daemon, same as M1/M2                       |
| Local Supabase stack                                                            | `supabase start && supabase db reset`                                  | **Not run here.** Plain-Postgres shim used (D-012)                      |
| Live worker + API processing a real request against a deployed Supabase project | Manual                                                                 | **Not run.** Needs the owner's Supabase project                         |

How the M3 acceptance gate maps to tests:

- **Diet/allergy/exclusion/dislike enforcement:** domain tests for every diet type, the
  allergen-coverage rule, exclusions and dislikes; worker test for an allergy set that makes every
  breakfast recipe ineligible (infeasible, not a crash or a silent violation).
- **7-day/daily views with totals that reconcile:** API test asserts a day's `totals.nutrients`
  equals the sum of its `meals[].nutrition.nutrients`; domain test asserts the same at the
  recipe/day level with values chosen to expose floating-point drift if the rounding were wrong.
- **Swaps and regeneration:** API tests for `getSwapOptions`/`replacePlanMeal` (candidate safety,
  revision conflict, idempotent replay) and for `generateDietPlan` picking `plan_regeneration` once
  an active plan exists; worker test for superseding the previous plan and keeping exactly one
  active version.
- **Idempotency and concurrency:** API tests for duplicate `generateDietPlan`/`replacePlanMeal`
  requests (same key, new key, stale revision); worker tests for redelivery before and after the
  handler existed.
- **No invented nutrition data in production:** worker test for the catalog gate refusing a
  `test_fixture`-only catalog in a `production`-configured run.

### Known limitations and release gates

- **No licensed nutrition/recipe catalog (open, the central M3 blocker).** Only the synthetic
  `test_fixture` catalog exists (D-025). Staging and production cannot plan until a licensed,
  reviewed dataset is imported; the catalog gate enforces this mechanically.
- **Approved target policy (open, carried from M2).** Still only the test policy exists (D-018);
  plan generation inherits this gate via the target snapshot.
- **Portion-scaling tolerance (provisional).** A 50%–175% engineering clamp stands in for a
  reviewer-set energy tolerance (D-025).
- **Diet/allergy/exclusion vocabularies (provisional, carried from M2).** Still D-020's provisional
  tag sets.
- **Home wiring (deferred).** `plan_generation`/`next_meal` on Home still reflect M2's placeholder
  behaviour; only the Meals → Diet plan screen was wired to real (fixture-backed) data this
  milestone, per the ticket's stated priority.
- **Recipe instructions and catalog browsing (`GET /v1/foods`, `GET /v1/recipes/{id}`)** remain
  `x-noura-status: planned`; M3 only needed recipes through the diet-plan response, not standalone
  catalog browsing.
- Google/Apple sign-in, the Android/iOS builds and the container image remain unverified here,
  unchanged from M1/M2.

### M4 hand-off

Meal-photo scanning (blueprint §8, §16): a camera/gallery capture flow, a recognition adapter behind
the existing AI-provider abstraction (`packages/ai`, mock-first per D-010), mapping recognized items
onto the M3 catalog (and handling items the catalog cannot match, honestly, not by guessing
nutrition), and manual meal logs with edit/delete. `app.meal_scans`, `app.meal_logs` and
`app.meal_log_items` already exist from M1; `POST /v1/meal-logs` and friends are drafted in the
contract as `x-noura-status: planned`, `x-noura-milestone: M4`. Not started.
