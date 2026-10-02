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

### M5 hand-off

Versioned Meal Balance, evidence and keep/reduce/add suggestions with a scenario calculator
(blueprint §16, `createPlateFixes`, already drafted in the contract as `x-noura-status: planned`,
`x-noura-milestone: M5`). Not started.
