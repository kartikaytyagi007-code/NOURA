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

## M4 Meal photo scanning

**Ticket.** Deliver private photo upload with ownership checks and a retention/deletion policy, an
async recognition job on the existing `generation_requests`/worker pipeline, a replaceable
server-side AI provider adapter (mock-first per D-010, failing closed without a real provider),
schema-validated recognition resolved against the M3 catalog deterministically (never inventing
nutrition), honest "unmatched" surfacing for catalog-missing items, a mandatory user review/edit
step before anything is saved, and the Flutter camera/gallery capture → upload → processing →
review → correction → save flow — end to end, with no invented data (see D-026).

### Delivered

- **No real AI vision provider available in this environment (flagged in the ticket, not a
  blocker).** `MockAiProvider.recognizeMeal` is extended with a deterministic, hash-keyed scenario
  system (D-026) and is what the full pipeline is actually exercised against end to end; it still
  never returns a nutrition value, and `createAiProvider` is unchanged in refusing to start in
  staging/production without a real provider and key (D-010).
- **Media storage (D-026):** `packages/domain/src/media/storage.ts` — a `MediaStorage` interface
  with `LocalMediaStorage` (development/test: local disk behind the API's own signed
  `/dev-storage/*` route) and `SupabaseMediaStorage` (a REST adapter, not exercised against a live
  project here) implementations; `createMediaStorage` fails closed exactly like `createAiProvider`.
  `packages/domain/src/media/image.ts` hand-sniffs real PNG/JPEG/WEBP dimensions/format from bytes
  (no new binary dependency) so a mislabelled or corrupt upload is rejected before it ever reaches
  the AI provider, and strips JPEG metadata before the provider call.
- **Catalog matching and recognition validation:** `packages/domain/src/catalog/matching.ts` (simple
  exact/prefix/substring matching against the real M3 catalog, attached server-side — never trusted
  from the provider); `packages/domain/src/meals/recognition-schema.ts` (a strict, versioned zod
  schema for the provider's raw output; anything malformed becomes a safe job failure, never a
  crash); `packages/domain/src/meals/review.ts` (resolves confirmed items against the catalog by id
  or exact label match; unmatched items get `nutrients: null, uncertainty: 'high'` and are excluded,
  honestly, from the meal's totals); `packages/domain/src/meals/balance.ts` (Meal Balance v1, a
  provisional, explainable, non-medical heuristic score, null when coverage is incomplete).
- **Worker:** `apps/worker/src/handlers/meal-scan-analyze.ts`, registered on the new
  `meal-scan.analyze` queue (`GENERATION_REQUEST_QUEUES.meal_scan`). Mirrors
  `diet-plan-generate.ts`'s idempotency precedent: short-circuits on an already-terminal
  `generation_requests` row, and separately on an already-resolved `meal_scans` row (the
  crash-recovery case), each covered by its own test; records `image_missing`, `provider_unavailable`,
  `invalid_provider_response` or `not_food` as an honest, safe failure rather than ever fabricating a
  recognition.
- **API:** `apps/api/src/modules/media` (`POST /v1/media/upload-slots`, `POST /v1/media/{id}/complete`,
  `GET /v1/media/{id}/download`, `DELETE /v1/media/{id}`) and `apps/api/src/modules/meals`
  (`POST /v1/meal-scans`, `GET /v1/meal-scans/{id}`, `PUT /v1/meal-scans/{id}/confirmed-items`,
  `POST /v1/meal-logs`, `GET /v1/meal-logs`, `PATCH /v1/meal-logs/{id}`, `DELETE /v1/meal-logs/{id}`).
  Duplicate `createMealScan` submissions for the same media dedup onto the same job; a provisional
  daily scan quota (`MEAL_SCAN_DAILY_QUOTA = 20`, D-026) reuses `usage_reservations`; all mutations
  carry `Idempotency-Key`, and revision-bearing writes carry `expected_revision` (409
  `REVISION_CONFLICT` on a stale confirm/patch/delete, D-022's convention).
- **Contracts:** `createUploadSlot`, `completeUpload`, `getMediaDownload`, `deleteMedia`,
  `createMealScan`, `getMealScan`, `confirmMealScanItems`, `createMealLog`, `listMealLogs`,
  `patchMealLog`, `deleteMealLog` flipped to `x-noura-status: implemented`; TS and Dart clients
  regenerated and committed. `createPlateFixes` correctly remains `planned` (M5).
- **Database:** no new migration was needed — M1's `20261001000500_media_scans_logs.sql` already
  defines `app.media_assets`/`app.meal_scans`/`app.meal_logs`/`app.meal_log_items` with RLS and
  owner-path constraints, and `20261001000800_storage_and_grants.sql` already grants
  `noura_api`/`noura_worker`. A negative ownership test for all three tables was added to
  `supabase/tests/security.test.ts` (select/update/delete/insert-as-another-user all denied), per
  AGENTS.md's requirement for every newly-active user-owned table.
- **Flutter:** `apps/mobile/lib/core/meals/` (`MealScanRepository`/`ApiMealScanRepository`/
  `MockMealScanRepository`, `MealScanController` as an explicit multi-step state machine) and
  `apps/mobile/lib/features/meals/meal_scan_screen.dart` — capture (camera/gallery via
  `image_picker`), uploading, processing (polling), review/correction (editable grams, remove,
  add-missed-item, unmatched-item disclosure), save, and labelled error states (non-food, provider
  failure, timeout/offline), reached from Meals → "Scan a meal" (D-023's component system; no Stitch
  screens exist for this feature). Android/iOS camera permissions added.
- **Docs:** decision D-026; this M4 section.

### Acceptance checks (run 2026-10-02 in the development container)

| Check                                               | Command                                                                                                                                                           | Result                                                                           |
| --------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| Secret scan                                         | `pnpm secrets:check`                                                                                                                                              | Passed (678 files)                                                               |
| Lint and format                                     | `pnpm lint`                                                                                                                                                       | Passed                                                                           |
| Typecheck                                           | `pnpm typecheck`                                                                                                                                                  | Passed (6 workspace projects)                                                    |
| Contract, domain and ai unit tests                  | `pnpm -r --filter './packages/*' run test`                                                                                                                        | Passed. contracts 13, domain 112, ai 6                                           |
| Migrations, RLS, grants, M4 owner-isolation         | `supabase`: `vitest run` against PostgreSQL 16                                                                                                                    | Passed. 43 tests (39 from M1-M3, 4 new)                                          |
| API integration (media, meal-scan, meal-log routes) | `apps/api`: `vitest run`                                                                                                                                          | Passed. 89 tests (76 from M1-M3, 13 new)                                         |
| Worker (meal-scan handler, retries, crash recovery) | `apps/worker`: `vitest run`                                                                                                                                       | Passed. 28 tests (20 from M1-M3, 8 new)                                          |
| Flutter format, analyze and tests                   | `dart format --line-length 120`, `flutter analyze`, `flutter test`                                                                                                | Passed. No issues; 82 tests (71 from M1-M3, 11 new)                              |
| Flutter web build                                   | `flutter build web --release`                                                                                                                                     | Not re-run this milestone (unchanged toolchain from M3)                          |
| Contract drift                                      | `pnpm contracts:check`                                                                                                                                            | Passed (after committing regenerated TS/Dart clients)                            |
| Cross-owner media/scan/log access denied            | API tests: download/complete/delete a media asset owned by another user; read/confirm a scan owned by another user; read/patch/delete a log owned by another user | Passed (404 in every case)                                                       |
| Non-food / provider failure / image-missing handled | Worker tests: `non_food` recognition, simulated provider error, deleted storage object before analysis                                                            | Passed (`not_food`, `provider_unavailable`, `image_missing`, never a crash)      |
| No log before confirmation                          | API test: `createMealLog` requires items the caller confirmed; `confirmMealScanItems` is a distinct, required step before the scan reaches `ready`                | Passed                                                                           |
| Honest unmatched-item surfacing                     | API test: an item with no catalog match keeps `nutrients: null`, `uncertainty: 'high'`, and `coverage.complete = false` on the total                              | Passed                                                                           |
| Duplicate scan submission is safe                   | API test: two `createMealScan` calls for the same media id return the same `scan_id`/`job_id`                                                                     | Passed                                                                           |
| At-least-once worker processing / crash recovery    | Worker tests: redelivery after the request is already terminal; redelivery after the scan resolved but the request row had not yet been marked terminal           | Passed (`already_terminal` / `already_processed`, recognition never overwritten) |
| Container image                                     | `docker build .`                                                                                                                                                  | **Not run here.** No Docker daemon, unchanged from M1-M3                         |
| Local Supabase stack                                | `supabase start && supabase db reset`                                                                                                                             | **Not run here.** Plain-Postgres shim used (D-012)                               |
| Live worker + a real AI vision provider             | Manual                                                                                                                                                            | **Not run.** No real provider key is available in this environment (D-026)       |

How the M4 acceptance gate maps to tests:

- **Non-food/unknown/provider failure handled:** worker tests cover a `non_food` recognition result,
  a simulated provider exception, an invalid (schema-failing) provider response, and a deleted
  storage object — each becomes a safe, specific job failure, never a crash or a fabricated result.
- **No log before confirmation:** API tests exercise the full scan → review → `confirmMealScanItems`
  → `createMealLog` sequence and assert a log cannot be created by skipping confirmation; a stale
  `expected_revision` on confirm is rejected (409).
- **Cross-owner media denied:** API tests attempt to download, complete, delete another user's media
  asset and to read/confirm another user's scan and read/patch/delete another user's log, all
  expecting 404; a DB-level negative ownership test additionally proves RLS denies these at the
  database layer even bypassing the API.

### Known limitations and release gates

- **No real AI vision provider (open, the central M4 limitation, flagged in the ticket).** Only the
  extended mock provider exists; recognition quality, prompt design, cost and provider-specific
  error handling cannot be evaluated until a real provider and key are available (D-010, D-026).
- **No licensed nutrition/recipe catalog (open, carried from M3).** Recognized items still resolve
  against the synthetic `test_fixture` catalog (D-025); this was already the production-blocking gap
  and M4 does not change it.
- **Scheduled media purge (open).** `deleteMedia` is user-invokable today; a background job to
  actually enforce the 30-day retention default has not been built (D-026).
- **Provisional daily scan quota (provisional).** `MEAL_SCAN_DAILY_QUOTA = 20` is an engineering
  placeholder, not a reviewed entitlement (D-026); real quotas are M10 billing scope.
- **Catalog matching (provisional, same caveat as D-025's dislike filter).** Exact/prefix/substring
  string matching, not NLP; a release-gate-quality item, not a blocker for this milestone.
- **`SupabaseMediaStorage` unverified (open).** The real adapter has not been exercised against a
  live Supabase Storage project in this environment; only `LocalMediaStorage` (development/test) was
  exercised end to end.
- **No Stitch screens for this feature.** The capture/review/correction UI uses the existing
  component system (D-014/D-023), as with M3's diet-plan screen.
- Android/iOS builds, the container image and Google/Apple sign-in remain unverified here, unchanged
  from M1-M3.

## M5 Meal Balance and Fix My Plate

**Ticket.** Formalize M4's provisional Meal Balance calculation into a versioned, documented,
explainable score; add meal-level nutrient indicators with uncertainty; add backend keep/reduce/add
recommendations respecting diet/allergy/exclusion/dislike constraints; add a suggested "after changes"
score that is only ever presented when fully supported by catalog data; and the Flutter results and
Fix My Plate screens on top of the M4 meal-scan flow (see D-027).

### Delivered

- **Meal Balance formalized (`packages/domain/src/meals/balance.ts`):** `meal-balance-v1-provisional`
  becomes `meal-balance-v1`. The four-component math (protein/fibre adequacy, vegetable-fruit
  presence, variety, 0-25 each, null with a message on incomplete coverage) is unchanged — it already
  matched blueprint §7 — but every threshold is now named and documented in an exported
  `MEAL_BALANCE_POLICY` constant, and each component carries a qualitative `band`
  (`low`/`adequate`/`good`), which is the per-nutrient indicator the ticket asked for.
- **Recommendations (`packages/domain/src/meals/recommendations.ts`, new):** `createPlateFixes`
  deterministically proposes up to one keep/reduce/add action, each from a suggestion pool filtered by
  new `isFoodDietSafe`/`isFoodAllergySafe`/`isFoodExclusionSafe`/`isFoodDislikeSafe`/`isFoodEligible`/
  `filterEligibleFoods` functions added to `packages/domain/src/catalog/eligibility.ts` — the exact
  same rules D-025 already applies to recipe ingredients, reused rather than reimplemented, and
  additionally restricted to foods with complete macro data so every projection is real.
- **After-changes projection:** `createPlateFixes` also returns a combined `after_changes` scenario
  (all proposed fixes applied together) with its gram-level `assumptions` stated as text; its
  `meal_balance.score` is null (via the existing `computeMealBalance` convention) whenever any part of
  the picture is not fully calculable, rather than ever being estimated.
- **API:** `POST /v1/meal-scans/{id}/plate-fixes` (`createPlateFixes`,
  `apps/api/src/modules/meals/plate-fixes-service.ts`) flips to `x-noura-status: implemented`. It is a
  pure computation over the scan's already-confirmed analysis, the live catalog and the caller's live
  diet/allergy/exclusion/dislike preferences (reusing `loadDietPlanningInputs` from M3) — nothing new
  is written, so no new migration or user-owned table was needed. It still requires
  `expected_revision` (409 on stale) and an `Idempotency-Key` (`withIdempotency`, same as every other
  mutating route), 422s (`CONSTRAINT_CONFLICT`) if the scan has not been confirmed yet, and 404s for
  another user's scan.
- **Contracts:** `MealBalanceComponent` gained `band`; `PlateFixes` gained `after_changes` (new
  `AfterChangesScenario` schema); `createPlateFixes` flipped to `implemented`. TS and Dart clients
  regenerated and committed.
- **Flutter:** `MealScanController` gains an explicit `MealScanAnalyzed` step between confirmation and
  logging (confirm → Meal Balance → Fix My Plate → log, blueprint §8), replacing the old single-shot
  `confirmAndLog` with `confirmItems()` and `logConfirmedMeal()`; `backToReview()` is the
  user-correction state, reusing M4's review screen rather than duplicating it. `MealBalanceView`
  (`apps/mobile/lib/features/meals/meal_balance_view.dart`) shows the score, components and bands
  inline in the scan flow; `FixMyPlateScreen` (`fix_my_plate_screen.dart`, pushed separately) has its
  own idle/loading/loaded/empty/error states via a new `PlateFixesController`
  (`core/meals/plate_fixes_controller.dart`), listing up to three suggestion cards and the combined
  after-changes card. `MockMealScanRepository.getPlateFixes` returns one clearly `(mock)`-labelled
  suggestion.
- **Docs:** decision D-027; this M5 section.

### Acceptance checks (run 2026-10-02 in the development container)

| Check                                                           | Command                                                                                                                   | Result                                                   |
| --------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------- |
| Secret scan                                                     | `pnpm secrets:check`                                                                                                      | Passed (696 files)                                       |
| Lint and format                                                 | `pnpm lint`                                                                                                               | Passed                                                   |
| OpenAPI lint                                                    | `pnpm contracts:lint`                                                                                                     | Valid. 14 pre-existing example warnings (same as M1-M4)  |
| Typecheck                                                       | `pnpm typecheck`                                                                                                          | Passed (6 workspace projects)                            |
| Contract, domain and ai unit tests                              | `pnpm -r --filter './packages/*' run test`                                                                                | Passed. contracts 13, domain 121, ai 6                   |
| Migrations, RLS, grants                                         | `supabase`: `vitest run` against PostgreSQL 16                                                                            | Passed. 43 tests, unchanged from M4 (no new migration)   |
| API integration (meal-scan, plate-fixes routes)                 | `apps/api`: `vitest run`                                                                                                  | Passed. 95 tests (89 from M1-M4, 6 new)                  |
| Worker                                                          | `apps/worker`: `vitest run`                                                                                               | Passed. 28 tests, unchanged from M4 (no new handler)     |
| Flutter format, analyze and tests                               | `dart format --line-length 120`, `flutter analyze`, `flutter test`                                                        | Passed. No issues; 86 tests (82 from M1-M4, 4 new)       |
| Contract drift                                                  | `pnpm contracts:check`                                                                                                    | Passed (after committing regenerated TS/Dart clients)    |
| Incomplete coverage yields a null score, never a fabricated one | Domain tests: `computeMealBalance`/`createPlateFixes` with an unmatched item                                              | Passed                                                   |
| Recommendations never suggest an allergen/exclusion/dislike     | Domain tests: allergy, exclusion and dislike constraints each checked against the suggestion pool                         | Passed                                                   |
| Suggestions filtered by diet type and catalog completeness      | Domain test: vegan constraint excludes a non-vegan food from suggestions                                                  | Passed                                                   |
| Deterministic for identical inputs                              | Domain test: same items/catalog/constraints produce identical fixes and after-changes score                               | Passed                                                   |
| Projected changes never modify actual logs                      | API/domain: `createPlateFixes` writes nothing to `meal_scans`/`meal_logs`; only `confirmMealScanItems`/`createMealLog` do | Passed (no new write path exists)                        |
| Authorization: cross-owner plate fixes denied                   | API test: another user's scan returns 404 for `createPlateFixes`                                                          | Passed                                                   |
| Stale confirmation rejected                                     | API test: `expected_revision` behind the scan's confirmed revision returns 409                                            | Passed                                                   |
| Plate fixes require prior confirmation                          | API test: calling before `confirmMealScanItems` returns 422 `CONSTRAINT_CONFLICT`                                         | Passed                                                   |
| Idempotent retry                                                | API test: same `Idempotency-Key` replays the identical response                                                           | Passed                                                   |
| Container image                                                 | `docker build .`                                                                                                          | **Not run here.** No Docker daemon, unchanged from M1-M4 |
| Local Supabase stack                                            | `supabase start && supabase db reset`                                                                                     | **Not run here.** Plain-Postgres shim used (D-012)       |

How the M5 acceptance gate maps to tests:

- **Incomplete data yields null score:** `balance.test.ts` and `recommendations.test.ts` both assert
  `score === null` with a `missing_data_message` whenever coverage is incomplete, for both the base
  Meal Balance and the `after_changes` projection.
- **Projected changes don't modify actual logs:** `createPlateFixesForScan` has no write statement at
  all (reviewable directly), and the API test suite's existing meal-log tests are unaffected/unchanged
  by this milestone — the only way to change a logged meal remains `confirmMealScanItems` →
  `createMealLog`/`patchMealLog`.
- **Recalculation stable:** the `createPlateFixes` determinism test runs the same inputs twice with
  independent id counters and asserts identical suggested foods and identical after-changes score.

### Known limitations and release gates

- **No licensed nutrition/recipe catalog (open, carried from M3/M4, the central blocker).** Plate-fix
  suggestions and the Meal Balance score are computed correctly, but only against the synthetic
  `test_fixture` catalog (D-025); see D-027's catalog-honesty note.
- **Meal Balance thresholds and recommendation defaults are engineering placeholders (provisional,
  D-027).** `MEAL_BALANCE_POLICY`'s grams-for-max-score values and the recommendation module's default
  suggested gram amounts (60%/80g/40g/100g/60g) have not been reviewed; they should be confirmed by a
  reviewer before this is presented as anything beyond an explainable heuristic.
- **Catalog matching for "reduce"/"add" candidates (provisional, same caveat as D-025's dislike
  filter).** Vegetable/fruit detection is keyword matching against food names, not a dedicated catalog
  tag or NLP.
- **No scheduled purge, no real AI vision provider, no licensed catalog (carried, unchanged from
  M4).**
- Android/iOS builds, the container image and Google/Apple sign-in remain unverified here, unchanged
  from M1-M4.

## M6 "What should I eat next?" and nutrition gap tracking

**Ticket.** A synchronous, deterministic next-meal recommendation grounded in today's meal log, the
active diet plan, goals/preferences/allergies/dislikes and the verified catalog, with clear reasons,
suitable alternatives, and add/swap/dismiss actions; explicit uncertainty disclosure whenever today's
logged data is incomplete; basic daily and seven-day nutrition-pattern summaries that name a
protein/fibre gap only when the underlying data actually supports it; and the Flutter screens for both,
with loading/empty/error/incomplete-data states (see D-028). No 30/90-day analysis and no automatic
plan adaptation are in scope.

### Delivered

- **Next-meal engine (`packages/domain/src/meals/next-meal.ts`, new):** `buildNextMealRecommendation`
  picks the first unlogged slot in `breakfast → lunch → dinner → snack` order (or a requested slot),
  grounds the primary option in the active plan's own recipe for that slot when one exists (reason:
  "This is the next unlogged slot in your plan"), and otherwise falls back to a deterministic
  catalog pick — eligible recipes only (`filterEligibleRecipes`, reusing M3/M5's diet/allergy/
  exclusion/dislike filtering), ranked by the day's weakest recorded nutrient
  (`weakestDailyGap`) with a stable id tiebreak. Alternatives to a planned slot carry the same
  `plan_meal_id`/`plan_meal_revision` as the primary option, so they can be swapped in directly.
  `limited_context` is set whenever nothing is logged yet or today's nutrition coverage is incomplete;
  a prior dismissal for that date/slot is sticky and suppresses re-suggestion.
- **Honest gap tracking (`packages/domain/src/meals/nutrition-patterns.ts`, new):**
  `computeDailyPattern` marks a day `coverage_complete: false` (with an explicit note) whenever it has
  no logged meals or incomplete nutrition data, and only computes a gap when coverage is complete and
  targets exist. `computeWeeklyPattern` averages only over usable days
  (`logged_meals > 0 && coverage_complete`), names every excluded day, and only reports a weekly gap
  once at least `MIN_USABLE_DAYS_FOR_WEEKLY_GAPS = 3` days are usable — otherwise it returns
  `coverage_uncertain: true` and no gap claim, never a fabricated pattern from a handful of days.
- **Timezone-aware date bucketing (`packages/domain/src/time/timezone.ts`, new):**
  `todayInTimezone`/`localDateInTimezone`/`subtractDays`/`dateRange`, built on
  `Intl.DateTimeFormat('en-CA', { timeZone })`, factor out the local-date convention M4's
  `localDateOf` already used, now directly tested for a midnight-boundary crossing in a non-UTC
  timezone.
- **API (`apps/api/src/modules/recommendations/`, new):** `GET /v1/recommendations/next-meal`
  (`getNextMeal`), `POST /v1/recommendations/next-meal/actions` (`nextMealAction`, new path and
  schemas), `GET /v1/insights` (`getInsights`) and `GET /v1/home` (`getHome`) all flip to
  `x-noura-status: implemented`. `nextMealAction`'s `swap` case delegates directly to the existing
  `replacePlanMeal` (`apps/api/src/modules/diet/service.ts`, D-022) rather than duplicating it; `add`
  inserts a new `diet_plan_meals` row after the same eligibility/slot checks; `dismiss` is an
  idempotent `INSERT ... ON CONFLICT DO NOTHING` into the new `app.dismissed_recommendations` table.
  All actions run through `withIdempotency` and `withUserTransaction`, deriving the user only from the
  verified token.
- **Migration:** `20261001001100_m6_next_meal_dismissals.sql` adds
  `app.dismissed_recommendations (user_id, local_date, slot)` with `enable_owner_rls` and explicit
  `noura_api` grants, plus a corrective default-privileges statement for a latent M1 grants gap
  (`anon`/`authenticated` were never explicitly excluded in schema-scoped default privileges) —
  documented inline rather than editing the applied M1 migration, per AGENTS.md.
- **Contracts:** new `NextMealSource`, `NextMealActionType`, `NextMealActionRequest`,
  `NextMealActionResult`, `NextMealActionResponse` schemas; `NextMealOption` gained `source`,
  `plan_meal_id`, `plan_meal_revision`, `candidate_id`; `Insights` gained `usable_days`,
  `excluded_days`, `coverage_uncertain`. TS and Dart clients regenerated and committed.
- **Flutter:** `NextMealScreen` and `NutritionInsightsScreen`
  (`apps/mobile/lib/features/meals/`), reached from Meals → "What should I eat next?" / "Seven-day
  patterns"; Home's next-meal and nutrition-summary placeholders are replaced with real data from a
  new `HomeController`. `NextMealController` (a plain `Notifier`) drives load/add/swap/dismiss;
  `InsightsController` and `HomeController` (`AsyncNotifier`) drive the two read-only screens. All
  three follow the existing idle/loading/loaded/error convention (D-023) and surface the API's
  limited-context/coverage-uncertain notices rather than re-deriving them. `MockRecommendationsRepository`
  provides clearly `(mock)`-labelled development data. No Stitch screens exist for this feature (same
  precedent as D-023/D-026/D-027), so the existing `lib/core/ui` component system is used.
- **Docs:** decision D-028; this M6 section.

### Acceptance checks (run 2026-10-02 in the development container)

| Check                                                                  | Command                                                                                                              | Result                                                                  |
| ---------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| Secret scan                                                            | `pnpm secrets:check`                                                                                                 | Passed (724 files)                                                      |
| Lint and format                                                        | `pnpm lint`                                                                                                          | Passed                                                                  |
| OpenAPI lint                                                           | `pnpm contracts:lint`                                                                                                | Valid. 14 pre-existing example warnings (same as M1-M5)                 |
| Typecheck                                                              | `pnpm typecheck`                                                                                                     | Passed (6 workspace projects)                                           |
| Contract, domain and ai unit tests                                     | `pnpm -r --filter './packages/*' run test`                                                                           | Passed. contracts 13, domain 151 (30 new), ai 6                         |
| Migrations, RLS, grants                                                | `supabase`: `vitest run` against PostgreSQL 16                                                                       | Passed. 44 tests (43 from M1-M5, 1 new negative-ownership)              |
| API integration (recommendations routes)                               | `apps/api`: `vitest run`                                                                                             | Passed. 118 tests (95 from M1-M5, 23 new)                               |
| Worker                                                                 | `apps/worker`: `vitest run`                                                                                          | Passed. 28 tests, unchanged from M5 (no new handler; M6 is synchronous) |
| Flutter format, analyze and tests                                      | `dart format --line-length 120`, `flutter analyze`, `flutter test`                                                   | Passed. No issues; 110 tests (86 from M1-M5, 24 new)                    |
| Contract drift                                                         | `pnpm contracts:check`                                                                                               | Passed (after committing regenerated TS/Dart clients)                   |
| Never suggests an allergen/diet-incompatible food                      | API test: vegan constraint excludes a non-vegan plan/catalog option; domain test over the eligibility pool           | Passed                                                                  |
| Ownership: next-meal/actions/insights/home all require a session       | API tests: each route 401s without a token                                                                           | Passed                                                                  |
| Incomplete today's log never silently treated as zero                  | Domain + API tests: `limited_context`/`coverage_complete` false whenever nothing or partial data is logged           | Passed                                                                  |
| Catalog-based calculations use real nutrient totals, never fabricate   | Domain tests: `sumNutrientTotals`/`weakestDailyGap` propagate null coverage rather than zero                         | Passed                                                                  |
| Date/timezone boundaries, including a non-UTC midnight crossing        | `timezone.test.ts` (domain) + API test: a meal logged near local midnight in a non-UTC timezone buckets correctly    | Passed                                                                  |
| Duplicate/retried next-meal action requests                            | API test: identical `Idempotency-Key` + body replays the same result and writes nothing twice                        | Passed                                                                  |
| Dismiss is sticky and idempotent                                       | API test: a later GET honestly reports the dismissal; repeated dismiss is a no-op (`ON CONFLICT DO NOTHING`)         | Passed                                                                  |
| Swap delegates to, not duplicates, M3's replace logic                  | API test: swap action behaves identically to `replacePlanMeal`, including 409 on stale `expected_revision`           | Passed                                                                  |
| Seven-day average excludes incomplete days, never counts them as zero  | Domain + API tests: `computeWeeklyPattern`/`GET /v1/insights` average only over usable days, name every excluded day | Passed                                                                  |
| Weekly gap withheld below the usable-days threshold                    | Domain + API tests: fewer than 3 usable days yields `coverage_uncertain: true` and no gap claim                      | Passed                                                                  |
| Negative ownership: new user-owned table (`dismissed_recommendations`) | `supabase` test: user B cannot read, insert-as, or delete user A's dismissal row                                     | Passed                                                                  |
| Container image                                                        | `docker build .`                                                                                                     | **Not run here.** No Docker daemon, unchanged from M1-M5                |
| Local Supabase stack                                                   | `supabase start && supabase db reset`                                                                                | **Not run here.** Plain-Postgres shim used (D-012)                      |

### Known limitations and release gates

- **No licensed nutrition/recipe catalog (open, carried from M3-M5, the central blocker).**
  Next-meal suggestions and gap calculations are computed correctly, but only against the synthetic
  `test_fixture` catalog (D-025); see D-028's catalog-honesty note.
- **Gap thresholds are engineering placeholders (provisional, D-028).**
  `GAP_THRESHOLD_FRACTION = 0.8` and `MIN_USABLE_DAYS_FOR_WEEKLY_GAPS = 3` have not been reviewed by a
  nutrition professional; they should be confirmed before this is presented as anything beyond an
  explainable heuristic.
- **No automatic plan adaptation, by design.** Every next-meal action is a recommendation the user
  explicitly accepts, swaps in, or dismisses; the engine never writes to a plan on its own.
- **No 30/90-day analysis, by design.** Only daily and seven-day summaries are in scope for M6.
- **No scheduled purge, no real AI vision provider, no licensed catalog (carried, unchanged from M5).**
- Android/iOS builds, the container image and Google/Apple sign-in remain unverified here, unchanged
  from M1-M5.

## M7 · Personalized workout plans and workout logging

**Delivered**

- **Exercise-catalog test-fixture seed (`supabase/migrations/20261001001200_m7_exercise_test_fixture.sql`,
  new), mirroring M3/D-025 exactly:** 29 `quality_flag = 'test_fixture'` exercises across squat, hinge,
  horizontal/vertical push, horizontal/vertical pull, core and carry/conditioning movement patterns,
  beginner/intermediate/advanced levels, and bodyweight/dumbbell/barbell/bench/pull-up-bar/kettlebell/
  resistance-band/gym-machine/bike equipment, plus 19 symmetric `exercise_substitutions` relationships.
  No other migration was needed: M1's `workout_plans`/`workout_plan_sessions`/`workout_plan_exercises`
  (the generated prescription) and `workout_logs`/`workout_set_logs` (what actually happened) already
  existed, unused, as exactly the two-layer schema this milestone's session logging needed.
- **Catalog gate generalized, not duplicated (`packages/domain/src/catalog/gate.ts`):** `catalogGate()`
  now takes any `{ quality_flag }` item, so the same D-025 fail-closed rule governs both diet-plan and
  workout-plan generation from one implementation.
- **Workout-plan generation (`packages/domain/src/workouts/`, new):** `generate.ts`'s
  `generateWorkoutPlan` is the deterministic, seed-free counterpart to M3's `generatePlan` — one
  session per selected weekday, exercise count scaled from `duration_minutes` (clamped 3-6),
  movement-pattern rotation by session index, and level-based set/rep/rest prescriptions
  (`prescriptionForLevel`, explicitly documented as engineering placeholders, not reviewed exercise
  science). `eligibility.ts` filters by equipment (a `home`-only location is restricted to declared
  `equipment_ids`; `gym`/`both` assume full access), recorded limitations
  (`contraindication_tags` overlap excludes outright), and experience (a ceiling, not a floor).
  `substitutions.ts`'s `substitutionsFor` offers only catalog-declared `exercise_substitutions`
  relationships, filtered through the same eligibility rules. `inputs.ts` loads training preferences
  and flags `hasCompleteTrainingPreferences` honestly.
- **Queue registration:** `workout-plan.generate` added to `QUEUES`/`QUEUE_POLICIES`/
  `GENERATION_REQUEST_QUEUES` (`packages/domain/src/jobs/queues.ts`); `request_type` is always
  `'workout_plan'` (never `'plan_regeneration'`, which `diet_plan` already claims) — see D-029.
- **Worker (`apps/worker/src/handlers/workout-plan-generate.ts`, new):** idempotent on
  `generation_request_id`, mirroring `handleDietPlanGenerate` exactly — reloads inputs fresh, applies
  the catalog gate, supersedes the previous active plan, and records an honest
  `safe_error_code`/`safe_error_message` (`planning_unavailable`, `catalog_unavailable`,
  `plan_infeasible`) rather than ever fabricating a plan.
- **API (`apps/api/src/modules/workouts/`, new):** `POST /v1/workout-plans/generate`
  (`generateWorkoutPlan`), `GET /v1/workout-plans/current` (`getCurrentWorkoutPlan`),
  `GET /v1/exercises/{id}/substitutions` (`getExerciseSubstitutions`), `POST /v1/workout-logs`
  (`createWorkoutLog`), `PUT /v1/workout-logs/{id}/sets` (`putWorkoutSets`) and
  `PATCH /v1/workout-logs/{id}` (`patchWorkoutLog`) all flip from `x-noura-status: planned` (set since
  the contract was first drafted) to `implemented`. `createWorkoutLog` dedupes by `client_id` the same
  way M4's meal logs do; `putWorkoutSets` additionally verifies every logged `exercise_id` belongs to
  the log's own session before accepting a write. Home's `todays_workout` placeholder is wired to real
  data (`apps/api/src/modules/recommendations/home-service.ts`), status derived from the latest
  `workout_logs` row for that session when `completed`/`skipped`.
- **Contracts:** no schema changes were needed — the M7 operations, request/response schemas
  (`WorkoutPlan`, `WorkoutSession`, `PrescribedExercise`, `Substitutions`, `WorkoutLog`, etc.) were
  already fully drafted since the contract's initial authoring; this milestone only flips their
  `x-noura-status`. TS and Dart clients regenerated (no content change) and contract drift verified.
- **Flutter (`apps/mobile/lib/features/workouts/`, `core/workouts/`, new):** `WorkoutScreen` (weekly
  schedule), `WorkoutSessionScreen` (one day's prescribed exercises with a "Replace" action),
  `ActiveSessionScreen` (set-by-set logging with a real `Timer.periodic` countdown rest timer, not a
  stub), `ExerciseReplacementScreen` (catalog-approved, currently-eligible substitutes only), and
  `CompletionSummaryScreen` (completed-vs-skipped per exercise), each with loading/empty/error states
  per D-023. `ActiveSessionController` is the session's state machine (exercise/set/rest/finished).
  `MockWorkoutRepository` provides `(mock)`-labelled development data. Home's "Today's workout"
  placeholder is replaced with real data.
- **Docs:** decision D-029; this M7 section.

### Acceptance checks (run 2026-10-02 in the development container)

| Check                                                                       | Command                                                                                                                                                                                                             | Result                                                                                                    |
| --------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| Secret scan                                                                 | `pnpm secrets:check`                                                                                                                                                                                                | Passed (740 files)                                                                                        |
| Lint and format                                                             | `pnpm lint`                                                                                                                                                                                                         | Passed                                                                                                    |
| OpenAPI lint                                                                | `pnpm contracts:lint`                                                                                                                                                                                               | Valid. 14 pre-existing example warnings (same as M1-M6)                                                   |
| Typecheck                                                                   | `pnpm typecheck`                                                                                                                                                                                                    | Passed (6 workspace projects)                                                                             |
| Contract, domain and ai unit tests                                          | `pnpm -r --filter './packages/*' run test`                                                                                                                                                                          | Passed. contracts 13, domain 170 (19 new), ai 6                                                           |
| Migrations, RLS, grants                                                     | `supabase`: `vitest run` against PostgreSQL 16                                                                                                                                                                      | Passed. 53 tests (44 from M1-M6, 9 new: catalog honesty + negative ownership)                             |
| API integration (workouts routes)                                           | `apps/api`: `vitest run`                                                                                                                                                                                            | Passed. 133 tests (118 from M1-M6, 15 new)                                                                |
| Worker                                                                      | `apps/worker`: `vitest run`                                                                                                                                                                                         | Passed. 37 tests (28 from M1-M6, 9 new; 1 pre-existing test updated to a genuinely unmapped request type) |
| Flutter format, analyze and tests                                           | `dart format --line-length 120`, `flutter analyze`, `flutter test`                                                                                                                                                  | Passed. No issues; 125 tests (110 from M1-M6, 15 new)                                                     |
| Contract drift                                                              | `pnpm contracts:check`                                                                                                                                                                                              | Passed (after committing regenerated TS/Dart clients)                                                     |
| Plan never includes an exercise the equipment/location can't support        | Domain test: home-only, no barbell excludes `barbell-back-squat`; declaring a barbell includes it; `gym`/`both` always include it                                                                                   | Passed                                                                                                    |
| Plan never includes a contraindicated exercise for a recorded limitation    | Domain + worker tests: overlapping `contraindication_tags` excludes outright; a fully-excluded catalog is infeasible, never silently relaxed                                                                        | Passed                                                                                                    |
| Schedule respects `days_per_week`/`weekdays`/`duration_minutes`             | Domain test: exactly `days_per_week` sessions land on the selected weekdays; exercise count scales with duration within bounds                                                                                      | Passed                                                                                                    |
| Substitutions are catalog-only and currently eligible                       | Domain + API tests: only `exercise_substitutions` relationships are offered, filtered to what the user can currently do                                                                                             | Passed                                                                                                    |
| Workout logging: start/complete/log-exercise, partial/skipped, weights/reps | API tests: `createWorkoutLog`/`putWorkoutSets`/`patchWorkoutLog` persist correctly, including skipped sets and null load                                                                                            | Passed                                                                                                    |
| Authorization and ownership (new negative-ownership requirement, AGENTS.md) | `supabase` tests: user B cannot read/update/delete/insert-as user A's workout plan, session, exercise, log or set log; API tests: cross-user session/log access 404s                                                | Passed                                                                                                    |
| Idempotent generation requests                                              | API test: identical `Idempotency-Key` + body replays the same job id and writes nothing twice; DB test: the existing one-active-job partial index covers `workout_plan`                                             | Passed                                                                                                    |
| Idempotent session-logging mutations                                        | API tests: `createWorkoutLog` dedupes by `client_id`; `putWorkoutSets`/`patchWorkoutLog` 409 on a stale `expected_revision`                                                                                         | Passed                                                                                                    |
| Infeasibility and catalog-gate honesty                                      | Worker tests: `no_eligible_exercises`, `insufficient_weekdays`, missing training preferences, and a test-fixture-only catalog in a "production" env all record an honest `safe_error_code`, never a fabricated plan | Passed                                                                                                    |
| Container image                                                             | `docker build .`                                                                                                                                                                                                    | **Not run here.** No Docker daemon, unchanged from M1-M6                                                  |
| Local Supabase stack                                                        | `supabase start && supabase db reset`                                                                                                                                                                               | **Not run here.** Plain-Postgres shim used (D-012)                                                        |

### Known limitations and release gates

- **No licensed exercise dataset (open, new to this milestone, mirrors M3-M6's catalog gap).**
  Workout-plan generation and substitutions are computed correctly, but only against the synthetic
  `test_fixture` exercise catalog (D-029); a licensed, reviewed catalog must replace it before staging/
  production use.
- **Set/rep/rest prescriptions and session-sizing are engineering placeholders (provisional, D-029).**
  `PRESCRIPTION_BY_LEVEL` and the one-exercise-per-~8-minutes session-sizing heuristic have not been
  reviewed by a qualified trainer; they should be confirmed before this is presented as anything beyond
  an explainable heuristic.
- **Exercise replacement is informational only, by design.** There is no API operation to permanently
  substitute an exercise within an already-generated plan this milestone; `ExerciseReplacementScreen`
  changes what the user logs for the current session, not the stored plan. A persisted "replace a
  planned exercise" endpoint is a natural later extension.
- **No adaptive training, by design.** Every regeneration is a fresh deterministic run from current
  training preferences, never influenced by prior session logs.
- **No physique analysis, no wearable integrations, by design.**
- **No licensed nutrition/recipe catalog, no scheduled purge, no real AI vision provider (carried,
  unchanged from M3-M6).**
- Android/iOS builds, the container image and Google/Apple sign-in remain unverified here, unchanged
  from M1-M6.

### M8 hand-off

Not scoped by this milestone; see the M8 ticket in a future update to this file.

## M8 Basic Progress Tracking

**Ticket.** Weight history with starting/current/goal weight, read-only meal-plan-adherence and
completed-workout summaries over already-recorded app data (never inferring progress from missing
data or claiming causation), private progress-photo upload/storage with ownership checks and deletion,
a simple two-date side-by-side comparison view with no physique/body-fat/medical analysis, clear
empty/loading/error/data-unavailable states, and tests for ownership, validation, summary honesty,
photo access/deletion and timezone handling (see D-030).

### Delivered

- **No new migration needed.** `app.weight_logs` and `app.progress_photos`
  (`supabase/migrations/20261001000500_media_scans_logs.sql`) already existed from M1, RLS-enabled and
  granted, unused. `app.media_assets` already carried the `progress_photo` purpose/bucket
  discriminator. The OpenAPI operations and schemas for all of `/v1/weight-logs`,
  `/v1/progress-photos` and `/v1/progress` were likewise already drafted as `planned`.
- **Domain (`packages/domain/src/progress/`, new):** `weight.ts`'s `validateWeightEntry` (realistic
  20–400 kg range, no future-dated entries beyond a small clock-skew allowance) and `adherence.ts`'s
  `buildAdherenceSummary`/`countElapsed` — the honesty mechanism that returns `{plan_active: false,
planned: null, logged: null}` whenever no plan is active, so a missing plan is never rendered as a
  real "0 of 0" (D-030). Both are pure and unit-tested directly.
- **API (`apps/api/src/modules/progress/`, new):** `listWeightLogs`/`createWeightLog`
  (idempotent by `client_id`)/`deleteWeightLog`, `listProgressPhotos`/`createProgressPhoto`
  (idempotent by `media_id`, requires the media to be the caller's own verified `progress_photo`
  upload)/`deleteProgressPhoto` (deletes the reference and the backing media object via M4's
  `deleteMedia`, actually revoking download access), and `getProgress` — starting/current/goal weight,
  30-day weight points, and `diet_adherence`/`workout_adherence` computed only over already-elapsed
  plan days/sessions in the user's own timezone (`packages/domain/src/time/timezone.ts`, reused from
  M6). All mutations run through `withIdempotency`/`withUserTransaction`, deriving the user only from
  the verified token.
- **Progress-photo retention fixed to match the blueprint (`apps/api/src/modules/media/service.ts`).**
  The blueprint specifies progress photos are retained "until user deletion," distinct from meal
  images' 90-day figure. `createUploadSlot` previously applied a flat 30-day `expires_at` to every
  purpose; it now omits `expires_at` entirely for `progress_photo` uploads (`PURPOSES_WITH_NO_AUTO_EXPIRY`),
  while meal-image uploads are unchanged. See D-030 for the full reasoning, including the carried-over
  M4 gap this does not attempt to fix (meal images' own 30-vs-90-day mismatch).
- **Contracts:** `listWeightLogs`, `createWeightLog`, `deleteWeightLog`, `listProgressPhotos`,
  `createProgressPhoto`, `deleteProgressPhoto`, `getProgress` flipped to `x-noura-status: implemented`.
  `Progress` gained `starting_weight_kg`, `current_weight_kg`, `goal_weight_kg`, `diet_adherence` and
  `workout_adherence` (new `AdherenceSummary` schema), additively. TS and Dart clients regenerated and
  committed.
- **Flutter (`apps/mobile/lib/core/progress/`, `apps/mobile/lib/features/progress/`, new):**
  `ProgressScreen` (starting/current/goal weight, both adherence cards with their no-plan message,
  links to history/photos/comparison), `WeightHistoryScreen` (list, add-entry dialog, swipe-to-delete),
  `ProgressPhotosScreen` (camera/gallery capture via `image_picker`, grid with per-photo signed-URL
  image loading and delete confirmation) and `PhotoComparisonScreen` (two date dropdowns, side-by-side
  images, an explicit "No photo for this date" state) — each with its own loading/empty/error states
  per D-023, reached from the previously-placeholder Progress tab. `MockProgressRepository` provides
  clearly `(mock)`-labelled development data. No Stitch screens exist for this feature (same precedent
  as D-026/D-027/D-028/D-029), so the existing component system is used.
- **Database:** no new migration; a negative-ownership test for `weight_logs`/`progress_photos` was
  added to `supabase/tests/security.test.ts` (select/update/delete/insert-as-another-user all denied),
  per AGENTS.md's requirement for every newly-active user-owned table, plus a dedicated test asserting
  the retention difference (`expires_at is null` for a progress-photo media asset, not null for meal).
- **Docs:** decision D-030; this M8 section.

### Acceptance checks (run 2026-10-02 in the development container)

| Check                                                              | Command                                                                                                                                                                                              | Result                                                                  |
| ------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| Secret scan                                                        | `pnpm secrets:check`                                                                                                                                                                                 | Passed (765 files)                                                      |
| Lint and format                                                    | `pnpm lint`                                                                                                                                                                                          | Passed                                                                  |
| OpenAPI lint                                                       | `pnpm contracts:lint`                                                                                                                                                                                | Valid. 14 pre-existing example warnings (same as M1-M7)                 |
| Typecheck                                                          | `pnpm typecheck`                                                                                                                                                                                     | Passed (6 workspace projects)                                           |
| Contract, domain and ai unit tests                                 | `pnpm -r --filter './packages/*' run test`                                                                                                                                                           | Passed. contracts 13, domain 184 (14 new), ai 6                         |
| Migrations, RLS, grants, M8 owner-isolation and retention          | `supabase`: `vitest run` against PostgreSQL 16                                                                                                                                                       | Passed. 58 tests (53 from M1-M7, 5 new)                                 |
| API integration (weight-log, progress-photo, progress routes)      | `apps/api`: `vitest run`                                                                                                                                                                             | Passed. 146 tests (133 from M1-M7, 13 new)                              |
| Worker                                                             | `apps/worker`: `vitest run`                                                                                                                                                                          | Passed. 37 tests, unchanged from M7 (no new handler; M8 is synchronous) |
| Flutter format, analyze and tests                                  | `dart format --line-length 120`, `flutter analyze`, `flutter test`                                                                                                                                   | Passed. No issues; 136 tests (125 from M1-M7, 11 new)                   |
| Contract drift                                                     | `pnpm contracts:check`                                                                                                                                                                               | Passed (after committing regenerated TS/Dart clients)                   |
| Weight-history validation                                          | Domain tests: rejects <20kg/>400kg and future-dated entries, accepts boundary values and a small clock-skew; API tests for the same over HTTP (422)                                                  | Passed                                                                  |
| Ownership: weight logs and progress photos                         | API tests: cross-owner delete of a weight log/progress photo 404s, registering another user's media 404s; DB test: user B cannot select/update/delete/insert-as user A's rows even bypassing the API | Passed                                                                  |
| Photo access/deletion                                              | API test: deleting a progress photo also revokes `GET /v1/media/{id}/download` (404 afterward), mirroring M4's media-deletion test                                                                   | Passed                                                                  |
| Progress-photo retention matches the blueprint, not M4's default   | API test + DB test: a `progress_photo` upload slot/media asset gets `expires_at = null`; a `meal` upload still gets a 30-day expiry                                                                  | Passed                                                                  |
| Summary honesty: no active plan is null, never a fabricated 0-of-0 | API test: `diet_adherence`/`workout_adherence` are `{plan_active: false, planned: null, logged: null}` with no plan; domain tests for the same                                                       | Passed                                                                  |
| Summary honesty: a real zero is distinct from "no plan"            | API test: an active diet plan with planned-but-unlogged meals returns `{plan_active: true, planned: 2, logged: 0}`, then `logged: 1` once one is logged                                              | Passed                                                                  |
| Starting/current/goal weight fallback                              | API test: falls back to the profile's onboarding weight with no history, then to the first/latest `weight_logs` entry once recorded                                                                  | Passed                                                                  |
| Idempotent weight/photo writes                                     | API tests: duplicate `createWeightLog`/`createProgressPhoto` (same `client_id`/`media_id`) return the same row, write nothing twice                                                                  | Passed                                                                  |
| Container image                                                    | `docker build .`                                                                                                                                                                                     | **Not run here.** No Docker daemon, unchanged from M1-M7                |
| Local Supabase stack                                               | `supabase start && supabase db reset`                                                                                                                                                                | **Not run here.** Plain-Postgres shim used (D-012)                      |

How the M8 acceptance gate maps to tests:

- **Weight history, starting/current/goal:** `progress.test.ts` covers recording, idempotent replay,
  listing newest-first, deletion with ownership enforcement, and the starting/current fallback chain
  (profile → first/latest history entry); `weight.test.ts` (domain) covers the validation rules in
  isolation, including the exact 20/400 kg boundaries and a tolerated few minutes of clock skew.
- **Honest meal-plan/workout summaries:** `adherence.test.ts` (domain) and `progress.test.ts` (API)
  both assert the no-plan case is `null`, not `0`, and that a real zero (a plan with nothing logged
  yet) is a distinct, correctly-reported value; `countElapsed` is tested to exclude every future date.
- **Progress-photo ownership, access and deletion:** reuses M4's exact pattern —
  `createProgressPhoto` 404s on another user's or a wrong-purpose media asset, `deleteProgressPhoto`
  revokes `getMediaDownload` afterward, and the DB-level negative-ownership test proves RLS denies
  cross-user access even bypassing the API entirely.
- **Blueprint-specified retention:** a dedicated API test and DB test both assert `expires_at` is null
  for a progress-photo media asset and non-null for a meal-image one, directly exercising the
  `PURPOSES_WITH_NO_AUTO_EXPIRY` fix.
- **Comparison view has no analysis:** by construction — `PhotoComparisonScreen` only calls
  `listProgressPhotos`/`getMediaDownload`; there is no new backend route, and no image-processing
  dependency was added anywhere in this milestone's code.
- **Date/timezone cases:** `getProgress`'s diet/workout adherence queries bound by `local_date`/
  `session_date`/`meal_date` computed via `todayInTimezone`, reusing M6's tested timezone-boundary
  convention rather than a new one.

### Known limitations and release gates

- **No licensed nutrition/recipe/exercise catalog, no real AI vision provider, no scheduled media-purge
  job (carried, unchanged from M3-M7).** Progress summaries reference plan/log data that itself still
  depends on the M3/M7 test-fixture catalogs; this milestone adds no new catalog dependency.
- **No wearables, no physique/body-fat analysis, no automatic plan changes from progress data, by
  design.** The comparison view is pure display; `getProgress` never writes to a diet or workout plan.
- **`starting_weight_kg` convention (provisional, open for review).** "Starting" is defined as the
  first-ever `weight_logs` entry, falling back to the profile's onboarding weight — a reasonable,
  documented choice (D-030), but not a reviewed product decision about what "starting weight" should
  mean if a user's onboarding weight and first logged entry disagree by a long margin.
- **Cursor pagination on `/v1/weight-logs`/`/v1/progress-photos` is minimally exercised.** The `cursor`/
  `limit` parameters are implemented (opaque base64 cursor over `(measured_at|captured_at, id)`) but
  only single-page listings are covered by tests in this milestone; a multi-page scenario is a natural
  follow-up test, not a known defect.
- Android/iOS builds, the container image and Google/Apple sign-in remain unverified here, unchanged
  from M1-M7.

### M9 hand-off

See `## M9 AI Coach` below.

## M9 AI Coach

**Ticket.** Context-aware coach chat grounded in the user's own profile/goals, active diet plan,
logged meals and workout schedule; honest disclosure when that context is missing; a server-side AI
provider adapter extending the M4 mock-first pattern (D-010), with input and output validation;
out-of-scope/medical-safety handling (no diagnosis, no medication dosing) enforced both in the prompt
and via output validation; persisted chat history with strict per-user ownership; grounded response
cards; a single confirmable proposed action (meal swap) that never applies itself; and tests for
authorization, context-assembly honesty, prompt/response validation, provider-failure handling, chat
history persistence, and out-of-scope/medical-safety handling (see D-031).

### Delivered

- **No new domain tables; one additive column.** `app.coach_threads`/`app.coach_messages`/
  `app.action_proposals` (`supabase/migrations/20261001000600_insights_coach.sql`) already existed
  from M1, RLS-enabled and granted, unused. This milestone adds
  `supabase/migrations/20261001001300_m9_coach_message_cards.sql` (`app.coach_messages.cards jsonb`,
  additive, default `'[]'`) so a completed reply's structured cards persist with the message.
- **Domain (`packages/domain/src/coach/`, new):** `context.ts`'s `loadCoachContext` (today's active
  diet-plan slot plus a real eligible alternate, today's logged-meal count, today's workout session,
  reusing M3/M6's `loadDietPlanningInputs`/`loadCatalogRecipes`/`filterEligibleRecipes`, never a
  parallel read path) and `safety.ts`'s `checkSafety`/`safeDeclineMessage`/`COACH_SYSTEM_PROMPT` — the
  out-of-scope/medical-safety screen and its paired clinician-redirecting decline text.
- **AI provider (`packages/ai/`):** `MockAiProvider.coachReply` now answers deterministically and
  honestly from the context it is given (explicitly states "no active diet/workout plan" when there
  is none, cites the real logged-meal count and today's session when there is), and only ever proposes
  `swap_meal`, only when the user asked for a swap and a real alternate exists.
  `validators/coach.ts` adds strict Zod schemas for both directions of the provider boundary —
  `validateCoachContextInput` (what the worker sends) and `validateCoachProviderOutput` (what comes
  back: `answer_text`, `evidence_refs`, at most one `proposed_action` of type `swap_meal` only) —
  rejecting anything malformed or carrying unexpected fields.
- **API (`apps/api/src/modules/coach/`, new):** `createCoachThread`, `deleteCoachThread` (new
  operation, cascades to messages/proposals), `listCoachMessages` (cursor-paginated, oldest first),
  `sendCoachMessage` (202-accepted, idempotent on `client_id` even across different
  `Idempotency-Key`s, enforces a 5/day quota via `usage_reservations`), `applyActionProposal` (calls
  the exact same `replacePlanMeal` the existing swap UI uses, apply-once, 409 on a stale revision, 422
  on an expired/already-resolved/unsupported-type proposal) and `cancelActionProposal`. Every query is
  scoped by `user_id` from the verified token; missing and non-owned resources both 404.
- **Worker (`apps/worker/src/handlers/coach-reply.ts`, new; `coach.reply` queue added to
  `packages/domain/src/jobs/queues.ts`):** idempotent on the generation-request id (identical
  crash-recovery shape to `meal-scan-analyze.ts`); runs `checkSafety` on the user's message **before**
  calling the provider at all (an out-of-scope request never reaches it); loads `CoachContext`;
  validates the context payload and the provider's output; runs `checkSafety` again on the returned
  text as defence in depth; builds response cards directly from the real context (never from AI free
  text); re-validates any proposed swap against a freshly loaded context before creating an
  `action_proposals` row (a stale/invented id is silently dropped, never trusted); and handles a
  provider failure or malformed response as a clear failed message, never a crash or a silent swallow.
- **Contracts:** `createCoachThread`, `listCoachMessages`, `sendCoachMessage`, `applyActionProposal`,
  `cancelActionProposal` flipped to `x-noura-status: implemented`; new `deleteCoachThread` operation
  (`DELETE /v1/coach/threads/{id}`) added. TS and Dart clients regenerated and committed.
- **Flutter (`apps/mobile/lib/core/coach/`, `apps/mobile/lib/features/coach/`):** `CoachScreen`
  replaces the M1-M8 placeholder with a real chat UI — message bubbles, a pending spinner, suggested
  prompt chips, per-message cards and a proposal card with explicit Confirm/Cancel actions.
  `CoachController` polls for the real async reply the same way `MealScanController` polls for a scan
  result. `TabPage` gained a `scrollable: false` mode for this screen's full-height flex layout.
  `MockCoachRepository` provides `(mock)`-labelled development replies. No Stitch screens exist for
  this feature (same precedent as M6-M8), so `lib/core/ui` is used throughout.
- **Database:** new negative-ownership test block in `supabase/tests/security.test.ts` ("M9 coach
  thread/message/action-proposal owner isolation") covering all three tables.
- **Docs:** decision D-031; this M9 section.

### Acceptance checks (run 2026-10-03 in the development container)

| Check                                              | Command                                                            | Result                                                   |
| -------------------------------------------------- | ------------------------------------------------------------------ | -------------------------------------------------------- |
| Secret scan                                        | `pnpm secrets:check`                                               | Passed (774 files)                                       |
| Lint and format                                    | `pnpm lint`                                                        | Passed                                                   |
| OpenAPI lint                                       | `pnpm contracts:lint`                                              | Valid. 14 pre-existing example warnings (same as M1-M8)  |
| Typecheck                                          | `pnpm typecheck`                                                   | Passed (6 workspace projects)                            |
| Contract, domain and ai unit tests                 | `pnpm -r --filter './packages/*' run test`                         | Passed. contracts 13, domain 191 (7 new), ai 19 (13 new) |
| Migrations, RLS, grants, M9 owner-isolation        | `supabase`: `vitest run` against PostgreSQL 16                     | Passed. 63 tests (58 from M1-M8, 5 new)                  |
| API integration (coach threads/messages/proposals) | `apps/api`: `vitest run`                                           | Passed. 162 tests (146 from M1-M8, 16 new)               |
| Worker (coach.reply handler + relay)               | `apps/worker`: `vitest run`                                        | Passed. 47 tests (37 from M1-M8, 10 new)                 |
| Flutter format, analyze and tests                  | `dart format --line-length 120`, `flutter analyze`, `flutter test` | Passed. No issues; 139 tests (136 from M1-M8, 3 new)     |
| Contract drift                                     | `pnpm contracts:check`                                             | Passed (after committing regenerated TS/Dart clients)    |

How the M9 acceptance gate maps to tests:

- **Authorization/ownership:** `coach.test.ts` covers 401-without-token on every coach/proposal route
  and cross-user 404s on thread messages/send/delete and on apply/cancel; `security.test.ts` proves
  RLS denies cross-user read/update/delete/insert-as-another-user on all three tables, plus a message
  that tries to attach to another user's thread, at the database level, bypassing the API entirely.
- **Context assembly, including honest gap-handling:** `coach-reply.test.ts` asserts the reply states
  "don't have an active diet plan"/"don't have an active workout plan" honestly when neither exists,
  and is grounded in real data (today's logged-meal count, today's workout session title) when they do.
- **Prompt/response validation:** `coach.test.ts` (ai package) proves malformed/adversarial provider
  output (missing fields, extra fields, an unsupported `proposed_action.type`) is rejected, never
  trusted; `coach-reply.test.ts` proves the same end-to-end (`failed_invalid_response`, never a crash).
- **Provider failure handling:** `coach-reply.test.ts`'s `FailingProvider` case asserts a thrown
  provider error becomes a clear `failed`/`provider_unavailable` message and generation-request state,
  never a crash or a silently swallowed job.
- **Chat history persistence/retrieval:** `coach.test.ts` covers create/list/send/delete end to end,
  including idempotent re-submission by `client_id` and cascade-delete of messages/proposals.
- **Out-of-scope/medical-safety handling:** `safety.test.ts` (domain) unit-tests the four screened
  categories directly; `coach-reply.test.ts` proves a diagnosis request and a medication-dosing request
  are declined **before** the provider is ever called, and that an unsafe provider output (a simulated
  model stating a diagnosis) is overridden by the post-check rather than reaching the user.
- **No silent actions / apply-once:** `coach.test.ts` proves applying a proposal performs the exact
  same `recipe_id`/`revision` change the swap UI's own tests expect, a second apply attempt 422s, an
  expired proposal 422s, and a stale `expected_revision` 409s; `coach-reply.test.ts` proves a proposal
  is only ever created when the AI's referenced ids match a freshly reloaded context.

### Known limitations and release gates

- **`checkSafety` is a keyword/pattern screen, not a reviewed clinical-safety policy.** It covers the
  ticket's named examples (diagnosis, medication dosing) plus two related blueprint categories
  (eating-disorder-risk phrasing, body-fat/physique analysis), deliberately biased toward
  over-flagging; a licensed safety/moderation review is required before production (D-031).
- **Only `swap_meal` is ever proposed or applied, by design.** `regenerate_day`/`reschedule_workout`
  remain valid `ActionProposal.type` values for forward compatibility but have no domain mutation
  logic behind them in this milestone — see D-031 for why.
- **No scheduled 90-day coach-history purge job.** The blueprint specifies 90-day retention; this
  milestone adds user-initiated deletion (`DELETE /v1/coach/threads/{id}`) but not an automatic
  cleanup cron, the same category of gap as M1-M8's other deferred purge jobs.
- **`COACH_REPLY_DAILY_QUOTA = 5` is a provisional engineering number** (blueprint §13's own proposed
  figure), not a reviewed product limit, same caveat as M4's `MEAL_SCAN_DAILY_QUOTA`.
- **No real AI provider.** `AI_PROVIDER=mock` remains the only exercised path in this environment; the
  factory fails closed for any other provider outside development/test, unchanged from M4.
- Android/iOS builds, the container image and Google/Apple sign-in remain unverified here, unchanged
  from M1-M8. No Docker daemon is available in this container; the plain-Postgres shim (D-012) was used
  for all database tests, as in every prior milestone.

### M10 hand-off

Not scoped by this milestone.

## M10 · Release hardening: billing/entitlements, quotas, local reminders, telemetry, export/deletion (FINAL V1 MILESTONE)

This is the last milestone in the blueprint's V1 scope (§16). It does not hand off to an M11 — any item
left open below is tracked in `docs/release-checklist.md`, not in a future milestone ticket.

### Delivered

- **Billing/entitlements (`packages/billing`, `apps/api/src/modules/billing/`):** `BillingProvider` and
  `AuthAdminProvider` adapters (mock-first, fail-closed outside development/test, D-010 pattern).
  `receiveRevenueCatWebhook` verifies the webhook's own authorization header (not a bearer JWT),
  deduplicates by `(provider, provider_event_id)`, and reconciles entitlement state with a
  last-verified-at guard so out-of-order or re-delivered events can never roll back a newer state.
  `GET /v1/entitlements`, `GET /v1/usage`, `POST /v1/billing/sync` (restore purchases) added and
  implemented.
- **Entitlement-aware quotas:** `packages/domain/src/billing/limits.ts` (`isPremiumUser`,
  `dailyQuotaFor`) replaces M4's `MEAL_SCAN_DAILY_QUOTA` and M9's `COACH_REPLY_DAILY_QUOTA` hardcoded
  constants; free-tier numbers are unchanged (3 meal scans/day, 5 coach replies/day), now configurable
  via `MEAL_SCAN_FREE_DAILY_QUOTA`/`MEAL_SCAN_PREMIUM_DAILY_QUOTA`/`COACH_REPLY_FREE_DAILY_QUOTA`/
  `COACH_REPLY_PREMIUM_DAILY_QUOTA`.
- **Local reminders:** `GET`/`PUT /v1/me/notification-preferences` (new operations) persist consent and
  chosen reminder times on `app.user_preferences.reminder_settings`. No push token, device-registration
  endpoint or push-sending code exists anywhere — blueprint §18 scopes V1 to local-device notifications
  only. Flutter's `ReminderScheduler` interface is the integration seam; `NoOpReminderScheduler` is the
  only implementation shipped (see Known limitations).
- **Telemetry:** `TelemetryProvider` (`apps/mobile/lib/core/telemetry/`), a closed event enum plus
  flat coarse properties only — no path for health/meal/chat/photo content or PII to flow through it.
  Opt-in (`enabled: false` by default). `MockTelemetryProvider` is the only implementation wired.
- **Account export/deletion (`apps/worker/src/handlers/account-export.ts`,
  `apps/worker/src/handlers/account-delete.ts`):** both are real transactional-outbox worker jobs (new
  queue-dispatch columns + relay policies in `20261001001400_m10_billing_notifications_account.sql`,
  mirroring the pre-existing `generation_requests` pattern). Deletion cancels queued generation jobs,
  removes Storage objects and owned rows, then deletes the auth identity via `AuthAdminProvider`, in a
  three-transaction structure that avoids a real lock-contention deadlock between the open transaction
  and the identity-deletion cascade (see D-032). Export builds a JSON manifest (profile, plans, logs,
  photo manifest) from the same domain tables every other feature reads, excluding secrets.
  `POST /v1/account/export`, `GET /v1/account/export/{id}`, `POST /v1/account/delete` implemented;
  `requireRecentAuth` rejects a stale token before a deletion is accepted.
- **Flutter:** `BillingRepository`/`NotificationsRepository`/`AccountRepository` (API + mock
  implementations), wired into `core/providers.dart` and `main.dart`; three new settings screens
  (`RemindersScreen`, `BillingScreen`, `AccountDataScreen`) replace the M1-M9 `FeaturePlaceholder`
  entries and are reachable from `SettingsScreen` via `/settings/reminders`, `/settings/billing`,
  `/settings/account-data`.
- **Contracts:** `getEntitlements`, `getUsage`, `syncBilling`, `receiveRevenueCatWebhook`,
  `requestAccountExport`, `getAccountExport`, `deleteAccount` flipped to `x-noura-status: implemented`;
  new `getNotificationPreferences`/`putNotificationPreferences` operations added and implemented. TS and
  Dart clients regenerated and committed.
- **Database:** `supabase/migrations/20261001001400_m10_billing_notifications_account.sql` (additive
  queue-dispatch columns, indexes, worker-relay RLS policies and column-guard triggers for
  `export_requests`/`deletion_requests`); new "M10 entitlements/usage/export/deletion owner isolation"
  block in `supabase/tests/security.test.ts`.
- **Docs:** decision D-032; this M10 section; `docs/release-checklist.md` (new, consolidates every open
  release gate from M1-M10); `docs/runbooks/` (see below).

### Acceptance checks (run 2026-10-03 in the development container)

| Check                                         | Command                                                            | Result                                                     |
| --------------------------------------------- | ------------------------------------------------------------------ | ---------------------------------------------------------- |
| Secret scan                                   | `pnpm secrets:check`                                               | Passed (819 files)                                         |
| Lint and format                               | `pnpm lint`                                                        | Passed                                                     |
| Typecheck                                     | `pnpm typecheck`                                                   | Passed (7 workspace projects)                              |
| Billing package unit tests                    | `packages/billing`: `vitest run`                                   | Passed. 18 tests                                           |
| Domain unit tests                             | `packages/domain`: `vitest run`                                    | Passed. 191 tests                                          |
| Contracts unit tests                          | `packages/contracts`: `vitest run`                                 | Passed. 13 tests                                           |
| AI package unit tests (unchanged by M10)      | `packages/ai`: `vitest run`                                        | Passed. 19 tests                                           |
| Migrations, RLS, grants, M10 owner-isolation  | `supabase`: `vitest run` against PostgreSQL 16                     | Passed. 67 tests (63 from M1-M9, 4 new)                    |
| API integration (billing/account/quotas)      | `apps/api`: `vitest run`                                           | Passed. 177 tests (162 from M1-M9, 15 new)                 |
| Worker (account export/delete handlers+relay) | `apps/worker`: `vitest run`                                        | Passed. 56 tests (47 from M1-M9, 9 new)                    |
| Backend build (api+worker)                    | `pnpm --filter @noura/api --filter @noura/worker run build`        | Passed                                                     |
| Flutter format, analyze and tests             | `dart format --line-length 120`, `flutter analyze`, `flutter test` | Passed. No issues; 147 tests (139 from M1-M9, 8 new)       |
| Contract drift                                | `pnpm contracts:check`                                             | Clean after commit (regenerated TS/Dart clients committed) |

How the M10 acceptance gate maps to tests:

- **Replay-safe billing events:** `billing.test.ts` posts the same webhook event id twice and asserts
  the second delivery is a no-op; `revenuecat-parse.test.ts` and `mock.test.ts` cover malformed payloads
  and webhook-auth rejection. `reconcile.test.ts` (domain) proves an older `last_verified_at` can never
  overwrite a newer entitlement row, directly exercising the "events may arrive out of order" requirement.
- **A forged client premium flag never unlocks paid API features:** `billing.test.ts`/`limits.test.ts`
  assert `dailyQuotaFor` reads `app.entitlements` server-side only; no request body or header the client
  controls is ever consulted for premium status anywhere in `apps/api`.
- **Ownership:** `security.test.ts`'s new M10 block proves cross-user denial on `entitlements`,
  `usage_reservations`, `export_requests` and `deletion_requests`, and that the worker relay's visibility
  is scoped by request state, never by user context, matching the pre-existing `generation_requests`
  precedent exactly.
- **Deletion/export correctness across interruption:** `account-delete.test.ts` and
  `account-export.test.ts` cover precheck idempotency (an already-terminal or missing request is a
  no-op), the full cascade (generation jobs cancelled, Storage objects removed, auth identity deleted via
  a provider that really deletes in the test), and the export manifest excluding secrets.
- **Recently-issued-token requirement for deletion:** `account.test.ts` asserts `deleteAccount` 422s on
  a stale/missing issued-at claim before any deletion request is created.

### Known limitations and release gates

All items below, plus every open item carried from M1-M9 (D-018, D-025–D-031), are consolidated in
`docs/release-checklist.md`. This is the authoritative pre-production list; nothing further is deferred
to a future milestone, because there is no M11.

- **No real billing provider exercised.** `BILLING_PROVIDER=mock` is the only path run in this
  environment; `RevenueCatBillingProvider`/`SupabaseAuthAdminProvider` are unit-tested against fixed
  fixtures only, never a live project (no RevenueCat/Supabase project is configured here).
- **No real push/local-notification plugin wired.** `NoOpReminderScheduler` schedules nothing; a real
  `flutter_local_notifications` integration needs native Android/iOS project changes this environment
  cannot build/verify against a real device.
- **No real analytics/crash-reporting provider wired.** `MockTelemetryProvider` (opt-in, in-memory only)
  is the only implementation; the interface is ready for a real provider, which is unselected.
- **No scheduled purge jobs** for the 24-hour export/failed-upload or 7-day unlogged-scan retention
  windows the blueprint proposes — consistent with every prior milestone's documented gap; deletion
  itself is immediate and user-initiated.
- Android/iOS builds, the container image, Google/Apple sign-in and a production backup/restore drill
  remain unverified here, unchanged from M1-M9. No Docker daemon is available in this container; the
  plain-Postgres shim (D-012) was used for all database tests, as in every prior milestone.
- `MEAL_SCAN_*_DAILY_QUOTA`/`COACH_REPLY_*_DAILY_QUOTA` remain provisional engineering numbers, not
  reviewed product limits (carried from M4/M9).
- The licensed nutrition/exercise catalog and clinical/safety review of M9's `checkSafety` remain open
  (carried from D-025–D-031).

### M11 hand-off

**None. This is the final V1 milestone.** V1 is feature-complete against the blueprint's milestone table
(§16) as of this commit, pending the release gates in `docs/release-checklist.md` — every one of which
requires real external accounts/credentials or a physical device/store this sandboxed environment does
not have, not further engineering work inside this repository.
