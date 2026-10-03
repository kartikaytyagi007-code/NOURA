# Decision log

Each entry records the reason, the affected contracts and migrations, test implications, and the
scope impact the owner will see (blueprint §20). "Provisional" means it is a reversible M1 default
that a later milestone may revise through a new entry.

---

## D-001 · Frozen stack and pinned versions (M1)

**Decision.** These versions were current, mutually compatible stable releases on 2026-10-01. All are
pinned exactly, and the lockfiles are committed (`pnpm-lock.yaml`, `apps/mobile/pubspec.lock`,
`apps/mobile/packages/noura_api_client/pubspec.lock`).

| Area                                                          | Version                                |
| ------------------------------------------------------------- | -------------------------------------- |
| Flutter / Dart                                                | 3.47.5 / 3.13.4                        |
| flutter_riverpod, go_router, supabase_flutter, dio            | 3.4.3, 18.0.2, 2.18.0, 5.11.1          |
| Node.js, pnpm, TypeScript                                     | 22.x (`.nvmrc`), 10.28.0, 6.0.3        |
| fastify, jose, pg, pg-boss, zod                               | 5.12.5, 6.2.12, 8.23.1, 12.35.1, 4.6.5 |
| vitest, eslint, typescript-eslint, prettier                   | 5.0.3, 10.11.0, 8.71.0, 3.9.9          |
| supabase CLI (dev dependency)                                 | 2.119.0                                |
| openapi-typescript, OpenAPI Generator (dart-dio), Redocly CLI | 7.13.0, 7.25.0, 2.57.0                 |

**Notes.** TypeScript is held below 6.1 because typescript-eslint 8.71 supports `<6.1`. In the
generated Dart client, `build_runner` and its friends are left as `any` in its pubspec and pinned by
its lockfile. Pinning `build_runner` directly conflicts with the generator's `copy_with_extension_gen`
constraint.

**Tests.** CI installs with `--frozen-lockfile` / `--enforce-lockfile`.

## D-002 · Monorepo with pnpm workspaces (M1)

**Decision.** The repository follows the layout in blueprint §3. The pnpm workspaces are `apps/api`,
`apps/worker`, `packages/{contracts,domain,ai}` and `supabase` (which holds the database tests). The
Flutter app lives in `apps/mobile` and is managed by `pub`, not pnpm. `data/` is reserved for
licensed catalog data with provenance. It is empty in M1: no nutrition data is invented.

## D-003 · OpenAPI 3.0.3 is the API contract authority (M1)

**Decision.** `packages/contracts/openapi.yaml` contains all 53 routes from blueprint §11 plus
`/health/live` and `/health/ready`. Each operation carries `x-noura-milestone` and
`x-noura-status: implemented | planned`.

- The API registers only implemented operations. Their request validation and response
  serialisation schemas are built from the spec at startup, so the code cannot drift from it.
- Planned operations are drafts. They return the standard 404 envelope until their milestone
  implements them.
- 3.0.3 is used rather than 3.1 because dart-dio's 3.1 support is incomplete.
- `nullable` + `$ref` is written as `allOf: [$ref] + nullable: true`.

**Generator constraints found.**

- dart-dio cannot generate numeric or boolean `const`/single-value enums. These became ranges and
  plain booleans: `max_score` is an integer from 25 to 25, and `requires_confirmation` is a boolean.
- `Export` is a reserved word, so the schema was renamed `AccountExport`.

**Tests.**

- `packages/contracts/src/contract.test.ts` holds an exact route inventory and compiles every schema
  with strict Ajv.
- The API tests check every response against the contract.
- `pnpm contracts:check` regenerates the TypeScript and Dart clients and fails on drift.

## D-004 · Domain tables live in schema `app`, outside the Data API (M1)

**Decision.** Every domain table lives in `app`, and `supabase/config.toml` exposes only `public` and
`graphql_public`. `anon` and `authenticated` get no grants on `app`, and default privileges are
revoked. Flutter talks to Supabase only for Auth (and, from M4, approved signed media transfer).

**Tests.**

- `supabase/tests/security.test.ts` checks that no mobile role holds any table, sequence or function
  privilege on `app`, even after the shim recreates Supabase's broad default grants.
- Removing the revoke statements made the test report 518 leaked grants, so the test does catch it.

## D-005 · Restricted server roles via `SET LOCAL ROLE` (M1)

**Decision.**

- `noura_api` and `noura_worker` are `NOLOGIN` and have no `BYPASSRLS`. The API and worker connect
  with a login role and run each domain transaction as `SET LOCAL ROLE noura_api|noura_worker`.
- Each role holds only the per-table grants it needs. Catalog tables are read-only, and billing
  events are worker-writable only.
- In deployed environments the login role must be a dedicated, non-superuser role that has been
  granted these roles (see `docs/runbooks/database.md`). Locally the CLI `postgres` user is used.

## D-006 · Per-transaction user context and fail-closed RLS (M1)

**Decision.**

- `withUserTransaction` sets `noura.user_id` with `set_config(..., true)` to the verified token
  subject. Every user-owned table has RLS enabled with the policy
  `user_id = app.request_user_id()`.
- If the user context is missing, no rows are visible and inserts fail.
- Child tables use composite foreign keys on `(parent_id, user_id)`, so a row cannot point at
  another user's parent.
- Application SQL still filters by `user_id` explicitly. RLS is defence in depth.

**Tests.** The database tests cover User A versus User B reads, writes and deletes, the empty
context, the composite FK, the media path prefix, client-UUID dedupe, and the one-active-plan-job
partial unique index. The API tests prove that another user's job returns a 404 indistinguishable
from a missing job, and that client-supplied `user_id` values are ignored.

## D-007 · JWKS-only, asymmetric token verification (M1)

**Decision.**

- The API verifies Supabase access tokens with `jose` against the project JWKS
  (`/auth/v1/.well-known/jwks.json`).
- It checks the issuer, the audience (`authenticated`), expiry, `iat`, that `sub` is a UUID,
  `role = authenticated`, and that `is_anonymous` is not true. Accepted algorithms are ES256, RS256
  and EdDSA. **HS256 / the legacy JWT secret is rejected**, so the API never holds a shared signing
  secret.
- A JWKS outage returns `503 PROVIDER_UNAVAILABLE` (retryable). It is never treated as success.
- Locally, `scripts/supabase-local-signing-key.sh` creates a gitignored ES256 key so local tokens
  match production verification.

**Owner impact.** Every Supabase project (staging and production) must use asymmetric JWT signing
keys. These are the default for new projects. Older projects must migrate in Dashboard → JWT
Signing Keys.

## D-008 · Private Storage buckets with no client policies (M1)

**Decision.**

- The `meal-images` and `progress-photos` buckets (10 MB; JPEG/PNG/WebP) and `exports` (50 MB) are
  private.
- `storage.objects` has no policies for `anon` or `authenticated`, so direct client access is denied.
- From M4, uploads and downloads use short-lived signed URLs issued by the API after it checks
  ownership.
- Object paths must start with `<user_id>/<media_id>`, which is enforced by a check constraint on
  `app.media_assets`.

## D-009 · pg-boss connection mode and queue migrations (M1)

**Decision.**

- The worker uses pg-boss 12 over a direct or session-mode connection. pg-boss needs
  session-level features (`LISTEN`/advisory locks), so the transaction pooler (port 6543) is not
  supported for the worker.
- The queue schema (`pgboss`) is installed by the worker in development and test
  (`PGBOSS_MIGRATE=true`). In deployed environments it runs as a separate release step
  (`queue:migrate`) and the worker runs with `PGBOSS_MIGRATE=false`.
- Queue policies and the dead-letter queue are defined in `packages/domain/src/jobs/queues.ts`.
  M1 defines only `system.ping`. The API exposes `GET /v1/jobs/{id}` but **does not produce jobs in
  M1**. Job producers arrive with the M2 and M3 generation flows.
- Job payloads carry IDs only.

**Tests.** The worker tests check that a separate producer sends a `system.ping` job, which reaches
`completed` with its output, that the readiness endpoint reports the queue schema, and that
shutdown is graceful.

## D-010 · Development mocks are explicit and fail closed (M1)

**Decision.**

- API and worker: `AI_PROVIDER` and `BILLING_PROVIDER` default to `mock` only for
  `APP_ENV=development|test`. `staging` and `production` refuse to start with mocks, plain-http
  Supabase URLs, or missing provider secrets, and configuration errors name variables, never values.
- `MockAiProvider` labels every output as mock and never returns foods or nutrients.
- Flutter: `NOURA_USE_MOCKS` and `NOURA_DEV_BYPASS_ONBOARDING` are accepted only in development
  debug builds. Any other combination shows a configuration error screen instead of the app. A
  persistent banner marks mock mode.
- The app also refuses Supabase keys that look privileged (`sb_secret_…` or `service_role` JWTs).

**Tests.** `apps/api/test/config.test.ts`, `packages/ai/src/providers/factory.test.ts`,
`apps/mobile/test/core/app_config_test.dart`, and the production-mock widget test.

## D-011 · Google and Apple sign-in through Supabase OAuth (browser, PKCE) (M1)

**Decision.**

- M1 integrates Google and Apple through `supabase_flutter`'s `signInWithOAuth`. The flow opens the
  system browser with PKCE and returns through the `noura://auth-callback` deep link, which is
  registered on Android and iOS.
- Native SDK sign-in (Credential Manager / Sign in with Apple sheet) is a later UX improvement. It
  needs the same provider configuration and does not change the API.
- The buttons appear only when `NOURA_GOOGLE_SIGN_IN_ENABLED` / `NOURA_APPLE_SIGN_IN_ENABLED` is set,
  because each provider must also be configured in Supabase and with Google or Apple. See
  `docs/auth-providers.md`.

**Status.** The code is integrated but **not verified against live providers**. That needs the
owner's accounts.

**Superseded by D-033.** Google and Apple sign-in were removed when sign-in became phone + SMS code
only.

## D-012 · Plain-Postgres test harness with a Supabase shim (M1)

**Decision.**

- `supabase/tests/support/supabase_shim.sql` creates the minimal Supabase objects the migrations
  depend on: the `auth.users` and `storage` schemas, the roles, and Supabase's broad default
  privileges. This lets the migrations and security tests run on plain PostgreSQL 16 in CI without
  Docker.
- `supabase db reset` against the real local stack remains the reference for developers.
- `reset-plain.mjs` refuses non-local hosts and `APP_ENV=production`.

## D-013 · Provisional schema details beyond the blueprint text (M1, provisional)

- **Profile.** `activity_band` (sedentary, light, moderate, very_active), `eligibility_status`
  (eligible, tracking_only, needs_review) and minimal `screening_flags` (text[]). Weight is not a
  profile column: it lives in `weight_logs`.
- **Value sets.** `diet_type`, `budget_band`, `cooking_time`, `experience` and `location` are
  provisional and marked in the migration comments. M2 may revise them in a new migration.
- **Catalog nutrients.** These are nullable per-100 g values. An unknown value stays null. The
  `test_fixture` quality flag exists so synthetic test rows can never be mistaken for reviewed data.
- **Error codes.** `INTERNAL_ERROR` was added to the blueprint's error codes for unexpected server
  failures (generic message, request ID only).
- **`GET /v1/me`.** It creates the empty profile row on first access (an idempotent
  `insert … on conflict do nothing`). If the auth identity has been deleted, it returns 401.

## D-014 · Replaceable UI component system pending Stitch (M1)

**Decision.**

- `lib/core/ui` holds the tokens (colors taken from the supplied Stitch palette) and small
  primitives: `NButton`, `NTextField`, the state views, `FeaturePlaceholder` and `MockModeBanner`.
- Screens use only these primitives, so the Stitch designs can replace the visuals without touching
  routing or state.
- Plus Jakarta Sans is not bundled yet; the platform font is used until font licensing and assets
  arrive with the designs.
- Future features appear only as non-interactive "Not available yet · Mx" placeholders.
- Section 15 corrections apply. For example, Home says "Today's progress" and has no readiness,
  water or streak elements.

**Tests.** The widget tests run Flutter's tap-target (48 dp), labelled-tap-target and text-contrast
guidelines on the auth and shell screens.

## D-015 · Build checks available in this environment (M1)

The development container could not reach `dl.google.com`, so the Android SDK could not be installed
and `flutter build apk` was not run here. CI runs it. `flutter build web --release` is the build check
executed locally. iOS builds need macOS and the owner's Apple configuration (blueprint §18). The
Dockerfile was written but not built (no Docker daemon).

## D-016 · Standard error envelope and request IDs (M1)

**Decision.**

- Every error is returned as
  `{error: {code, message, field_errors[], retryable}, meta: {request_id}}`.
- Validation errors name fields as `body.x`, `params.id` or `query.y`. Unknown query parameters
  and unknown body fields are rejected.
- Request IDs: an incoming `x-request-id` is kept only if it is well formed (otherwise a new one is
  generated). The ID is echoed in the response header and logged as `request_id`.
- Authorization headers and cookies are redacted from logs. Unexpected errors log details
  server-side and return only a generic message.

## D-017 · Generation requests reach the queue through a worker relay (M2)

**Decision.**

- Completing onboarding writes a durable `generation_requests` row (type `diet_plan`, status
  `queued`) in the same transaction as the profile, consents and target snapshot. The API never
  talks to the queue and holds no queue privileges.
- The worker relays requests that are still `queued` with no `queue_job_id` to pg-boss
  (`diet-plan.generate`) and records `queue_name` and `queue_job_id`.
  - The job id is the request id. If the worker dies between sending and recording, the next run
    re-sends (a no-op for an existing id) and records the dispatch. Delivery is at-least-once, so
    handlers must be idempotent on the request id.
  - The payload is ids only (`generation_request_id`, `user_id`). A handler reloads everything under
    the user's own context.
  - Rows are claimed with `FOR UPDATE SKIP LOCKED`, so overlapping relays never double-send.
  - Interval: `WORKER_RELAY_INTERVAL_MS` (default 2000).
- A queue outage or a failing generation cannot lose profile data: the inputs were committed with the
  request. The M1 note "the API does not produce jobs" (D-009) now means "the API records durable
  requests; the worker produces queue jobs".

**Database.**

- The `noura_worker` role gets two narrow cross-user policies on `generation_requests`: it may see
  rows that are still `queued`, and update only an undispatched row into a dispatched one.
- A trigger limits what the worker may change without a user context to `queue_name` and
  `queue_job_id` (policies cannot restrict columns). PostgreSQL also checks the SELECT policy against
  an updated row, so the select policy must keep matching after dispatch (found by the DB tests).
- Per-user job handling with a user context is unchanged.

**Limits.** No handler consumes `diet-plan.generate` until M3, so relayed jobs wait in the queue. M3
registers the handler and decides what to do with requests queued before it existed.

## D-018 · Versioned, deterministic target-policy framework (M2)

**Decision.**

- The targets engine (`packages/domain/src/nutrition`) is a pure function of a profile and a policy.
  The same input and policy always give the same output. Every number lives in the policy: energy
  equation coefficients (Mifflin-St Jeor form), activity factors, goal adjustments, protein per kg,
  fat share, fibre per 1000 kcal and energy per gram.
- A policy has an id, a version, a method reference and a status: `test` or `approved`. An `approved`
  policy must record its approval (reviewer, date, reference). The schema is strict and zod-validated.
- The repository ships only `TEST_TARGET_POLICY`: development placeholders, not reviewed values and
  not medical advice. The blueprint sets no calorie floor, so `minimum_energy_kcal` is null in the test
  policy and is an option for the reviewer.
- Gate: development and test may run the test policy. Staging and production plan only with an
  approved policy. API startup refuses a `test` policy file in those environments (the error names the
  variable, never values). With no policy configured, planning is unavailable (fails closed) and the
  rest of the product works.
- Configuration: `PLANNING_POLICY_FILE` points at a JSON policy. Development and test default to the
  test policy.
- If the calculation sex is declined, the energy is an estimated range (the lowest and highest of the
  two equation variants) and the energy-dependent targets are null. Nothing is inferred about sex.
- Snapshots record `policy_version` and `policy_status`. A snapshot with no numbers
  (`basis: not_calculated`) is written for users who are not eligible or when the gate is closed. It is
  labelled `test` so it can never read as reviewed.
- The app does not show calorie or nutrient targets in M2.

**Release gate (open).** A reviewer must supply and approve a real policy and its method reference
before staging or production can plan. This is a clinical and product decision, not an engineering one.

## D-019 · Eligibility rules v1 (M2)

**Decision.** `packages/domain/src/eligibility` is a pure function from age and three screening answers
to `eligible`, `tracking_only` or `needs_review`, with a rules version (`eligibility-v1`).

- Under the minimum adult age, or any "yes" answer: `tracking_only`.
- Otherwise any "prefer not to say": `needs_review`. Eligibility cannot be confirmed, so planning stays
  off and the user can update the answers later.
- Otherwise `eligible`.
- Questions: pregnancy or breastfeeding, an eating-disorder concern, a condition that needs a
  specific medical diet. Only the answers are stored (`screening_flags`, with `screening_answered_at`).
  No free text is collected.
- Eligibility is recomputed on every profile save. After onboarding, an edit that makes the user
  ineligible switches planning off and records a `not_calculated` snapshot.
- `tracking_only` and `needs_review` users complete onboarding and keep every tracking feature.

**Provisional.** The minimum adult age (18) is jurisdiction-specific, and the question wording and the
explanatory copy need legal and clinical review. They are product-scope definitions, not clinical
thresholds. They are release-gate items.

## D-020 · Provisional vocabularies, units and timezone list (M2, provisional)

- **Tag sets** for allergies, excluded foods, cuisines, equipment and limitations are OpenAPI input
  enums, validated by the API. They are provisional, not a medical allergy list, and are revised with
  the food and exercise catalogs (M5 to M7). Responses use plain strings and the app drops values it
  does not know, so a newer server vocabulary cannot break an older app.
- **Weight** is stored on the profile (`weight_kg`, 20 to 400, a plausibility bound only). D-013 said
  weight lives only in `weight_logs`; M2 needs a starting weight for targets, and M8 may update it.
- **Units.** The server stores and validates metric only. Imperial (lb, ft and in) is a display and
  input convenience, converted in the app with exact definitions. Validation messages use the user's
  units.
- **Calculation sex input** is `female`, `male` or `declined`. JSON null cannot be sent by the
  generated client, and an explicit value lets a user clear an earlier answer. The profile still
  reads null for a declined answer.
- **Timezones** are chosen from a curated list in the app (no timezone database dependency). The
  server accepts any valid IANA name. The app suggests a timezone only when the device offset maps to
  exactly one zone without daylight saving (+05:30 gives Asia/Kolkata).
- **YAML pitfall.** Unquoted `yes` and `no` in `openapi.yaml` parse as booleans in the Dart generator.
  The screening enum quotes them.

## D-021 · Consent catalogue and recording (M2)

- Completing onboarding requires consent to `terms`, `privacy` and `health_data_processing`. The
  optional `ai_meal_processing` and `progress_photo_storage` consents are asked where they are used
  (M4, M8).
- The server publishes versions in `packages/domain/src/consent`. Every published version is the
  draft placeholder `v0-draft` until counsel supplies the documents. The server rejects unknown
  versions, so a client can never record consent to text that does not exist.
- A partial unique index allows one active record per user, type and version. Recording is part of
  the completion transaction.
- The review screen says the wording is a draft placeholder.

**Release gate (open).** Final legal documents and their version identifiers.

## D-022 · Revisions, idempotency and transactions for profile writes (M2)

- **Independent revisions.** The profile, preferences and training preferences each have their own
  revision. `expected_revision` must match or the write returns `REVISION_CONFLICT` (409). For the two
  preference objects `0` means "none yet" and the first save creates revision 1. Every profile save
  increments by one. A profile save that includes `onboarding_step` is refused once onboarding is
  complete.
- **Idempotency.** Every write requires an `Idempotency-Key`. The key, the route and a hash of the
  body are stored with the response in `app.idempotency_records` (24 hours), in the same transaction
  as the work. A replay returns the stored response and writes nothing. The same key with a different
  body is rejected. A concurrent duplicate waits on the unique index and then replays. Failed requests
  roll back with their record, so they are retried normally.
- **Completion** locks the profile row (`FOR UPDATE`) and runs in one transaction. A second completion
  returns `CONSTRAINT_CONFLICT` ("already complete"), and a stale revision returns the conflict. A
  rejected completion writes nothing, including the lazily created profile row. Duplicate submits
  therefore create exactly one generation request (tested with concurrent same-key requests, a new
  key and a stale revision).
- Completion, preference writes and goal changes always filter on the verified user id through
  `withUserTransaction`; the API accepts no `user_id` or premium flag from a client.

## D-023 · Flutter onboarding and Settings editing (M2)

- The Stitch export contains no onboarding or profile screens, so M2 uses the existing component
  system (D-014). Replacing the visuals later does not touch routing or state.
- Six steps: About you, Your goal, Food preferences, Training, Eligibility, Review and finish.
  Each step saves to the server before moving on. The server stores the furthest step reached
  (`onboarding.step`), and the app resumes there after a restart. Going back never discards saved data
  and never moves the stored step backwards.
- Consent is on the review step, because consents are recorded by the completion call itself.
- Forms are shared between onboarding and Settings (Profile, Goal, Food preferences, Training,
  Eligibility). Settings saves do not touch the onboarding step.
- `MeController` is the only writer of profile state. A write never puts the provider back into
  loading (that would send the router to the splash screen). Failed saves keep the inputs on screen:
  offline shows a retry message, a conflict offers "Load latest", and validation lists the server's
  messages.
- Completing uses one idempotency key per consent selection and reuses it on retry.
- Home shows a status card derived from the server's planning state. It makes no plan or nutrition
  claim, and shows that plans are unavailable for tracking-only, needs-review or no-policy states.
- The development mock profile source keeps answers in memory with the server's revision rules. It
  computes no eligibility, targets or plans.

## D-024 · Notes for M3 (not started)

- Plan staleness: compare a plan's `profile_revision` with the current profile revision. The preference
  revisions are separate, so staleness should consider all three.
- With `basis: range` (sex declined) the energy target is null. Plan generation must work against the
  range or ask for manual targets.
- Register the `diet-plan.generate` handler. It must be idempotent on `generation_request_id` and
  reload the profile, preferences and snapshot under the user's context. Decide how to treat requests
  relayed before a handler existed.
- The target snapshot refreshes when target-relevant fields change after onboarding, but nothing
  regenerates plans automatically.

## D-025 · Synthetic test-fixture catalog and the catalog planning gate (M3)

**Blocker.** `data/foods`, `data/recipes`, `data/exercises` and `data/provenance` are empty beyond
their README placeholders: no licensed nutrition dataset is available in this environment, and
AGENTS.md forbids inventing nutrition data. Diet-plan generation (filtering, portions, nutrition
totals, swaps) could not otherwise be built or exercised end to end.

**Decision.**

- A new, additive migration (`20261001001000_catalog_test_fixture.sql`) seeds ~30 foods and 16
  recipes into the M1 catalog tables, all `quality_flag = 'test_fixture'`, under one `food_sources`
  row named "NOURA synthetic test fixture" whose `license_notes` explicitly states it is **not a
  licensed source** and must never be used in production. Values are deliberately round,
  obviously-synthetic placeholder numbers (blueprint §7's "never invent nutrition data" bars
  invented _production_ data; a labelled, disclaimed development fixture used only to exercise the
  pipeline is the documented, approved resolution for this milestone, mirroring the M1
  `test_fixture` quality flag and its existing DB comment). The set deliberately covers: a vegan
  base (safe for every diet), dairy-only additions (vegetarian+), egg additions (eggatarian+),
  meat/fish (non_vegetarian only), one ingredient per `AllergyTag` value (gluten, crustacean, milk,
  egg, fish, peanut, tree_nut, soy, sesame), `food_group_tags` for a few `ExclusionTag` values
  (chicken, mutton, seafood, onion_garlic, root_vegetables, mushroom), and one ingredient with
  `allergen_coverage = 'unknown'` to exercise the allergen-safety rule below. At least one recipe
  exists per (meal slot × diet type) combination.
- **Catalog planning gate** (`packages/domain/src/catalog/gate.ts`, mirroring D-018's
  `planningGate`): development and test may plan from a `test_fixture`-only catalog. A deployed
  environment (`APP_ENV` staging/production) requires at least one recipe per generation whose
  `quality_flag` is `verified` or `reviewed`; otherwise generation fails closed with
  `generation_requests.safe_error_code = 'catalog_unavailable'` and a user-safe message, never a
  fabricated plan. This is enforced in the worker handler, not just at startup, because the catalog
  can change between deploys without a restart.
- **Diet/allergy/exclusion/dislike filtering** (`packages/domain/src/catalog/eligibility.ts`):
  - A recipe is diet-safe only if **every** ingredient's `diet_tags` include the user's diet type
    (vegan ⊂ vegetarian ⊂ eggatarian ⊂ non_vegetarian in permissiveness; vegetarian excludes
    meat/fish/eggs, eggatarian permits eggs/dairy but excludes meat/fish, vegan excludes all animal
    products — blueprint §7).
  - **Allergen safety rule:** with any allergy constraint, an ingredient whose `allergen_coverage`
    is not `complete` is treated as unsafe regardless of its declared `allergen_tags` — unknown or
    partial coverage can never be certified safe. With no allergy constraint at all, incomplete
    coverage is not itself disqualifying.
  - Exclusions match `food_group_tags`; dislikes are a case-insensitive substring match against the
    recipe name and each ingredient's food name. Both are intentionally simple (string/tag
    matching) rather than NLP; this is noted as a release-gate-quality item alongside D-020's
    vocabularies, not a clinical threshold.
- **Portion scaling and nutrition totals** (`packages/domain/src/catalog/nutrition.ts`,
  `packages/domain/src/nutrition/rounding.ts`): each ingredient's contribution is rounded once
  (whole kcal; 1 decimal place for grams-denominated macros), and every total — a recipe, a swap
  preview, a day, or eventually a week — is produced by summing those already-rounded integer/tenths
  representations, never by re-deriving from raw grams or re-summing floating point decimals. This
  is what guarantees a day's total always reconciles exactly with the meals that make it up. A
  nutrient that any ingredient lacks is reported as unknown (`null`), never zero.
- **Plan generation** (`packages/domain/src/planning/generate.ts`) is a pure, deterministic function
  of the eligible-recipe pool, a start date and an optional point energy target: for each of 7 days
  and each of 3–4 slots (breakfast/lunch/dinner, plus snack once preferences ask for more than 3
  meals a day), it deterministically rotates through the slot's eligible recipes (varying by day and
  slot index, so the same inputs always produce the same plan) and scales the recipe's portions
  toward an even per-meal share of the daily energy target, clamped to **50%–175%** of the recipe's
  base quantities (a provisional tolerance band chosen to keep portions plausible; not a clinical
  value). With `basis: range` (D-024: calculation sex declined), there is no single energy number to
  scale against, so every meal is served at its base portion rather than guessing a number.
  Infeasibility (no eligible recipe for some required slot) is returned as an explicit result, never
  a crash or a silently-relaxed constraint.
- **Worker handler** (`apps/worker/src/handlers/diet-plan-generate.ts`, registered in
  `apps/worker/src/runtime.ts` on `diet-plan.generate`) is idempotent on `generation_request_id`: it
  reloads the request, profile, preferences and target snapshot fresh under the user's own
  `noura_worker` transaction context (never trusting the job payload beyond the two ids, per D-017),
  and is a no-op if the request is already terminal or if a `diet_plans` row already references it
  (recovering a crash between committing the plan and marking the request terminal without ever
  generating a second plan). `GENERATION_REQUEST_QUEUES` now also maps `plan_regeneration` to
  `diet-plan.generate`, so the same handler serves both request types; regeneration supersedes the
  previous active plan (`status = 'superseded'`, `supersedes_id` set) and inserts a new one with
  `version + 1`, so exactly one plan is ever `active`. Requests relayed before this handler existed
  (D-017's open question) are simply processed now — itself a demonstration of idempotent
  at-least-once delivery — and the worker test suite covers exactly this case.
- **API** (`apps/api/src/modules/diet`): `generateDietPlan` records or reuses a durable
  `generation_requests` row (type `diet_plan` the first time, `plan_regeneration` once an active
  plan exists) and is safe under concurrency via the existing partial unique index plus the
  idempotency table (D-022); `getCurrentDietPlan` reads the active plan and computes day totals as
  above; `getSwapOptions` is read-only (no Idempotency-Key, per the contract) and recomputes
  eligibility fresh so a swap can never offer something unsafe even if preferences changed since
  generation; `replacePlanMeal` requires an Idempotency-Key and `expected_revision`, re-validates the
  candidate against fresh eligibility (rejecting one that is not actually eligible, even if it was
  offered as a candidate a moment earlier and preferences changed in between), and updates the slot
  in place with `revision + 1`.

**Release gate (open).** Same shape as D-018: a licensed, reviewed food/recipe dataset (blueprint
§7, M5–M7 scope) must replace the test fixture before staging or production can plan; the catalog
gate above enforces this mechanically rather than by convention. The 50%–175% portion-scale clamp is
a provisional engineering bound (plausible serving sizes), not a clinical or reviewed energy
tolerance; a reviewer-set tolerance (the ticket proposed ±10% of the per-meal target as a starting
point) is a release-gate item alongside the target policy itself (D-018) and should replace this
clamp, or add an explicit tolerance check on top of it, once set.

## D-026 · Meal photo scanning: storage, recognition adapter and honest catalog resolution (M4)

**Scope.** Private photo upload, async recognition, a user review/correction step, and manual meal
logging (blueprint §8). No part of this generates or guesses nutrition: the AI provider only ever
identifies foods and estimates portions; nutrition is computed exclusively from the M3 catalog,
exactly as AGENTS.md requires.

**Image storage and retention** (`packages/domain/src/media/storage.ts`):

- A `MediaStorage` interface (`createUploadUrl`, `createDownloadUrl`, `readObject`, `deleteObject`)
  is implemented by `LocalMediaStorage` (development/test: local disk, HMAC-signed, time-limited
  tokenized URLs served back by the API's own `/dev-storage/*` route — mirroring how a real signed
  URL behaves, with no external dependency) and `SupabaseMediaStorage` (a REST adapter against
  Supabase Storage's sign/object endpoints for staging/production). `createMediaStorage` fails
  closed exactly like D-010's `createAiProvider`: the `local` driver is refused outside
  development/test, and the `supabase` driver requires a real service-role key. `SupabaseMediaStorage`
  has not been exercised against a live Supabase project in this environment — this is a limitation,
  not a design claim, and should be verified before staging use.
- Ownership: every `media_assets` row's `object_path` is constrained by
  `media_assets_owner_path` (`<user_id>/<media_id>/...`, M1 migration) and RLS, so a signed URL
  scoped to one user's object can never be reused for another's even if guessed; `apps/api`'s media
  routes additionally re-check `user_id` on every read/write through `withUserTransaction`.
  `supabase/tests/security.test.ts` adds a negative ownership test for `media_assets`, `meal_scans`
  and `meal_logs` (select/update/delete/insert-as-another-user all denied), per AGENTS.md's
  requirement for every newly user-owned table.
- **Retention/deletion policy:** `RETENTION_DAYS = 30` (`apps/api/src/modules/media/service.ts`), a
  provisional default pending a privacy/legal release-gate review (the blueprint does not set a
  number). `deleteMedia` is user-invokable at any time (soft-deletes the row, best-effort removes the
  stored object) rather than only passively expiring — meal photos are consent-sensitive and
  AGENTS.md requires "no secrets ... in logs"-level care for user media generally. A scheduled
  purge job for the 30-day expiry itself is not implemented in M4 (noted as a release-gate item,
  alongside D-018/D-025's other open items) — only on-demand deletion and the schema-level
  retention intent exist today.

**Recognition adapter and the mock extension** (`packages/ai/src/providers/mock.ts`,
`apps/worker/src/handlers/meal-scan-analyze.ts`): no real AI vision provider or key is available in
this environment (as flagged in the M4 ticket), so `MockAiProvider.recognizeMeal` is what the test
suite actually exercises. It is extended from D-010's existing mock-first pattern, not a new
mechanism: output is deterministic, keyed by a sha256 hash of the image bytes (or an explicit
`context.mock_scenario` for tests), with five canned scenarios (`default`, `all_matched`,
`unmatched_item`, `low_confidence`, `non_food`, and a `provider_error` throw path for retry/failure
tests) — the matched-food scenarios reference real M3 test-fixture catalog names so the
catalog-matching path is exercised honestly. Like every other mock in this codebase, it never
returns a nutrition value (asserted directly in `packages/ai/src/providers/factory.test.ts`) and
`createAiProvider` still fails closed in staging/production without a real provider and key.

**Schema-validated recognition, resolved against the catalog, never invented**
(`packages/domain/src/meals/recognition-schema.ts`, `review.ts`):

- The provider's raw JSON is validated against a strict, versioned zod schema
  (`providerRecognitionSchema`, `schema_version: '1'`, bounded array sizes) before anything touches
  the database; anything malformed or adversarial becomes a safe `invalid_provider_response` job
  failure, never a crash and never partially-trusted data.
- `catalog_candidates` for each recognized item are attached server-side from the real M3 catalog
  (`catalog/matching.ts`'s simple exact/prefix/substring matcher — intentionally not NLP, same
  provisional-matching caveat as D-025's dislike filter) — the provider is never trusted to supply
  catalog ids itself.
- At confirmation (`resolveConfirmedItems`), an item is resolved by its explicit `food_id` or an
  exact label match; anything else is **honestly surfaced as unmatched**: `nutrients: null`,
  `uncertainty: 'high'`, and it is excluded from the meal's nutrient totals (which therefore become
  `coverage.complete = false` rather than silently omitting the item's contribution) — consistent
  with D-025's "unknown nutrient stays null, never zero" rule applied to whole items, not just
  individual nutrients.

**Job/state model:** reuses, rather than duplicates, the two states the M1 schema already
defines — `generation_requests` (the D-017 transactional-outbox/idempotency envelope: queued →
running → completed/failed, safe retries via `FOR UPDATE SKIP LOCKED`, `GENERATION_REQUEST_QUEUES`
now also maps `meal_scan` to the new `meal-scan.analyze` queue) and `meal_scans`'s own status column
(blueprint §8's richer state machine: `awaiting_upload → queued → recognizing → needs_confirmation →
ready/failed/cancelled/expired`). The worker handler (`meal-scan-analyze.ts`) mirrors
`diet-plan-generate.ts`'s idempotency precedent exactly: it short-circuits on an already-terminal
`generation_requests` row, and separately short-circuits (without overwriting an existing
recognition) if the `meal_scans` row was already resolved but the request row had not yet been
marked terminal — the crash-recovery case, covered by its own test.

**Mandatory review before saving:** `confirmMealScanItems` is a confirm step, not an auto-apply —
nothing is written to `meal_logs` from recognition alone. It requires `expected_revision`
(409 `REVISION_CONFLICT` on a stale confirm, D-022's convention) and an `Idempotency-Key` on both
the confirm and the subsequent `createMealLog` call, so a user can safely retry a submission whose
response was lost.

**Meal Balance v1** (`packages/domain/src/meals/balance.ts`): an explainable, provisional, explicitly
non-medical heuristic (`policy_version: 'meal-balance-v1-provisional'`) scoring protein, fibre,
vegetable/fruit presence and variety (0–25 each); it returns a null score with a message whenever
nutrition coverage is incomplete, rather than a misleadingly precise number over partial data.

**Provisional daily scan quota:** `MEAL_SCAN_DAILY_QUOTA = 20` (`apps/api/src/modules/meals/scan-service.ts`),
tracked via the existing `usage_reservations` table. Like the portion-scale clamp in D-025, this is
an engineering placeholder pending the real entitlements/quota policy (M10 billing scope), not a
reviewed product limit.

**Flutter:** `apps/mobile/lib/core/meals/` follows the M3 `DietRepository`/`DietController`
structural precedent exactly — an abstract `MealScanRepository`, an `ApiMealScanRepository` (uses a
second, unauthenticated `Dio` instance for the raw upload PUT, since a pre-signed upload URL must
never carry this app's bearer token), and a development-only `MockMealScanRepository` that
simulates the whole upload → recognize → review pipeline in memory with obviously-labelled "(mock)"
items. Because this flow has more steps than a single resource, `MealScanController` models an
explicit state machine (`MealScanFlowState`: idle → uploading → processing → reviewing → saving →
saved/failed) rather than a plain `AsyncNotifier<T>`; `image_picker` (exact-pinned, like every other
dependency in `pubspec.yaml`) is the camera/gallery capture package, added as an implementation of
the blueprint's already-scoped scanning capability, not a stack change.

## D-027 · Meal Balance formalized to v1, and "Fix My Plate" keep/reduce/add recommendations (M5)

**Scope.** Blueprint §7 "Meal Balance policy v1", §8 step 7, §16 M5: a versioned, documented,
explainable Meal Balance score; per-component nutrient indicators; backend keep/reduce/add
recommendations respecting diet/allergy/exclusion/dislike constraints; and an "after changes"
projected score, calculated only when fully supported by catalog data. No AI model is involved in
scoring or recommending anywhere in this milestone — everything here is a pure function over the
same catalog-derived numbers M3/M4 already compute.

**Meal Balance: formalized from provisional to `meal-balance-v1`
(`packages/domain/src/meals/balance.ts`).** M4 shipped the score under the name
`meal-balance-v1-provisional` as a side effect of building the meal-scan review flow (D-026). Its
four-component math (protein/fibre adequacy, vegetable-fruit presence, variety, each capped at 25,
summed to 100, null with a message whenever nutrition coverage is incomplete) already matched
blueprint §7 exactly, so M5 does not change the rules — it formalizes them: every threshold that was
previously an inline magic number (protein grams for max score, fibre grams for max score, distinct
foods for max variety) now lives in an exported `MEAL_BALANCE_POLICY` constant, documented inline,
and the policy version becomes the real `meal-balance-v1` (no longer "-provisional") since this is now
the milestone that makes it a first-class, user-facing, documented feature rather than an M4
side effect. Each component now also carries a qualitative `band` (`low` / `adequate` / `good`,
derived from the same thresholds) — this is the ticket's "meal-level nutrient indicators... with
uncertainty shown" requirement, read directly off the already-deterministic component scores rather
than a second parallel calculation. `band` is `null` only when the whole score is null (incomplete
coverage), so a null band is never silently mistaken for "low".

**Recommendations (`packages/domain/src/meals/recommendations.ts`, new).** `createPlateFixes`
deterministically proposes up to one `keep`, one `reduce` and one `add` action (fewer when no safe,
catalog-grounded candidate exists for a type — the function never invents a weak suggestion to fill
three slots):

- **keep**: the confirmed, catalog-matched item contributing the most protein, as positive evidence.
- **reduce**: the largest confirmed item whose food is simultaneously low-protein (<5 g/100 g),
  low-fibre (<2 g/100 g) but calorie-bearing — a deterministic stand-in for "refined-carb-like",
  chosen because the catalog carries no such tag yet (same provisional-matching caveat as D-025's
  dislike filter). Its portion is cut to 60% (rounded to the nearest 5 g, floor 10 g).
- **add**: addresses the meal's single weakest-scoring component (vegetable/fruit → a keyword-matched
  vegetable/fruit food; fibre/protein → the eligible food highest in that nutrient; variety → a
  vegetable/fruit or, failing that, the highest-fibre food not already present), at a fixed,
  documented default gram amount per type (80 g vegetable/fruit, 40 g fibre add, 100 g protein add,
  60 g variety add) — an explicit engineering assumption, not a portion recommendation backed by any
  review, stated as such in the response's `reason`/`assumptions` text.

Every candidate is drawn from `filterEligibleFoods` (new, `packages/domain/src/catalog/eligibility.ts`):
the exact same diet/allergy/exclusion/dislike rules D-025 already applies to recipe ingredients
(`isFoodDietSafe`/`isFoodAllergySafe`/`isFoodExclusionSafe`/`isFoodDislikeSafe`, reusing — not
reimplementing — the allergen-coverage rule: incomplete coverage is unsafe under any allergy
constraint), applied to a bare catalog food. A suggestion is additionally restricted to foods with
**complete** macro data (energy/protein/carb/fat/fibre all non-null) and not already present in the
meal, so every `projected` scenario attached to a fix is a real calculation, never an estimate.

**"After changes" projection, honestly gated.** `createPlateFixes` also returns `after_changes`: the
combined totals/Meal Balance if every proposed fix were applied together, plus the gram-level
`assumptions` made (stated as text, e.g. "Assumes X is reduced from 350g to 210g"). Because `reduce`
only edits an already-matched item and `add` only uses foods with complete macro data, the combined
scenario is almost always calculable — but it reuses `computeMealBalance`'s own null-score-plus-message
convention rather than a second success/failure flag, so if the meal also contains an unrelated
unmatched item untouched by any suggestion, `after_changes.meal_balance.score` is honestly `null`
with the same message a user would see on the original analysis. The contract (`AfterChangesScenario`
schema) therefore always returns the container object; "omitting the score when not calculable" means
the nested `meal_balance.score` is null, consistent with every other nullable score in this API,
rather than a different shape for the "can't calculate" case.

**Persistence: none.** Plate fixes are a pure computation over the scan's already-stored, already-
confirmed `confirmed_analysis` (M4) plus the live catalog and the user's live preferences — nothing
new is written. `createPlateFixesForScan` (`apps/api/src/modules/meals/plate-fixes-service.ts`)
therefore needed no new migration and no new user-owned table (so no new negative-ownership test is
owed under AGENTS.md's rule — the scan row it reads from already has one, from D-026). The route still
requires `expected_revision` (checked against the scan's post-confirmation revision, 409 on stale) and
an `Idempotency-Key` (wrapped in the same `withIdempotency` helper every other mutating route uses),
so duplicate taps and retries are exactly as safe as everywhere else in this API, even though nothing
is persisted beyond the idempotency record itself.

**API.** `POST /v1/meal-scans/{id}/plate-fixes` (`createPlateFixes`) flips from `x-noura-status:
planned` to `implemented`. It 422s (`CONSTRAINT_CONFLICT`) if the scan has not been confirmed yet
(`confirmMealScanItems` must run first — plate fixes need calculated nutrition, not raw recognition),
409s on a stale `expected_revision`, and 404s for another user's scan (ownership check reused from
`loadOwnedScan`, D-026).

**Contract.** `MealBalanceComponent` gained `band`; `PlateFixes` gained `after_changes`
(new `AfterChangesScenario` schema). TS and Dart clients regenerated and committed.

**Flutter.** The meal-scan flow (`MealScanController`) gains an explicit `MealScanAnalyzed` step
between confirmation and logging (blueprint §8: confirm → Meal Balance → Fix My Plate → log), replacing
the old single-shot `confirmAndLog` with `confirmItems()` (reviewing → analyzed) and
`logConfirmedMeal()` (analyzed → saving → saved); `backToReview()` returns to the M4 correction step
with the confirmed items pre-filled, so the M5 ticket's "user-correction state" reuses M4's existing
review UI instead of duplicating it. `MealBalanceView` (shown inline in the scan flow) shows the score,
per-component bands and a loading/empty path to `FixMyPlateScreen` (a separate pushed screen with its
own idle/loading/loaded/error states via a new `PlateFixesController`), which lists up to three
`PlateAction` cards (each showing its own projected score or a stated reason it isn't calculable) and
the combined after-changes card with its assumptions. `MockMealScanRepository.getPlateFixes` returns a
single clearly `(mock)`-labelled suggestion for development without a server.

**Catalog-honesty note (carried from D-025/D-026, restated for this milestone's reviewer).** Every
recommendation and score in this milestone is only as trustworthy as the catalog beneath it, which
remains the synthetic `test_fixture` seed (D-025) — no licensed nutrition dataset is available in this
environment. The catalog planning gate (D-025) already refuses automated generation in a deployed
environment without verified/reviewed data; this milestone adds no separate gate for plate fixes
because they read the same catalog through the same `loadCatalogFoods`, so a deployed environment
without real catalog data would simply have no eligible foods to suggest (an empty `fixes` array, not
a fabricated one) rather than silently using test-fixture numbers in production — but this has not been
exercised against a real deployed-environment configuration in this container, and should be verified
before staging/production use, same as D-025's open release gate.

**Release gate (open, carried forward).** Same as D-025/D-026: a licensed, reviewed catalog must
replace the test fixture, and the Meal Balance thresholds (`MEAL_BALANCE_POLICY`) and the
recommendation defaults (the 60%/80g/40g/100g/60g constants above) are engineering placeholders, not
reviewed nutrition guidance, and should be confirmed by a reviewer before this is presented as
anything more than an explainable heuristic.

## D-028 · "What should I eat next?" and honest nutrition-gap tracking (M6)

**Scope.** A synchronous, deterministic next-meal recommendation over today's meal log, the active
diet plan (if any), goals/preferences/allergies/dislikes and the verified catalog, with add/swap/
dismiss actions; and daily/seven-day nutrition-pattern summaries that name a protein/fibre gap only
when the underlying data actually supports the conclusion. No AI model computes any of this — it is
pure, testable TypeScript over catalog, logged and planned rows, in the same vein as Meal Balance
(D-027) and the eligibility/target frameworks (D-018/D-019).

**Next-meal selection algorithm.** `buildNextMealRecommendation`
(`packages/domain/src/meals/next-meal.ts`) first decides the target slot: the caller's requested slot,
or else the first slot in `SLOT_ORDER = [breakfast, lunch, dinner, snack]` with no logged meal today.
If the active diet plan covers that slot, the plan's own planned recipe is the primary option
(`source: 'plan'`, reason "This is the next unlogged slot in your plan") — the recommendation is
grounded in a plan the user already approved, not a fresh guess. Alternatives to a planned slot
deliberately carry the _same_ `plan_meal_id`/`plan_meal_revision` as the primary option, so a user can
swap any alternative directly into that slot without a second lookup. When there is no active plan (or
no plan meal for that slot), the engine falls back to a deterministic catalog pick: eligible recipes
(`filterEligibleRecipes`, reusing M3/M5's allergy/diet/dislike/exclusion filtering — an allergen whose
coverage is unknown is still treated as unsafe, per D-019) are ranked by which recorded nutrient the
day is currently weakest on (`weakestDailyGap`, protein or fibre against the profile's daily targets),
with a stable id-order tiebreak so the same inputs always produce the same answer — required for the
duplicate-request and determinism tests, and for an honest "this is the same reasoning every time"
property. A prior `dismiss` for that date/slot is sticky: the engine returns no options and an
explanation rather than silently recomputing the same suggestion the user already turned down.

**Gap-detection honesty (the ticket's hard constraint, upheld at two layers).**
`packages/domain/src/meals/nutrition-patterns.ts` never treats a day with no logged meals, or with
logged meals whose nutrition coverage is incomplete, as a zero — it marks that day `coverage_complete:
false` with an explicit note and computes no gap for it at all. Daily gaps
(`computeDailyPattern`) are only named when `coverage_complete && targets` both hold, gated at
`GAP_THRESHOLD_FRACTION = 0.8` of the target. The seven-day summary (`computeWeeklyPattern`) averages
only over `usable = days.filter(d => d.logged_meals > 0 && d.coverage_complete)`, and always lists every
excluded day by date so the person can see _why_ a day was dropped rather than guessing. A weekly gap
is reported only once `usable.length >= MIN_USABLE_DAYS_FOR_WEEKLY_GAPS = 3`; with fewer usable days the
API still returns the insights payload (never an error) but with `coverage_uncertain: true` and an
empty gap list, so the UI can say "not enough data yet" instead of fabricating a pattern from two days.
This mirrors Meal Balance's (D-027) and the nutrient-totals module's (`sumNutrientTotals`) existing
convention of a null/absent result over a fabricated zero, applied here to averages and gap claims.

**Timezone-bucketing approach.** "Today" and the seven-day window are computed in the user's own
profile timezone, never UTC, via a new `packages/domain/src/time/timezone.ts`
(`localDateInTimezone`, `todayInTimezone`, `subtractDays`, `dateRange`) built on
`Intl.DateTimeFormat('en-CA', { timeZone })` for a `YYYY-MM-DD` local date — the same pattern M4's
`localDateOf` already established for meal-log dates, now factored into a shared, directly-tested
module (`timezone.test.ts` asserts a meal logged at 18:29 UTC falls on one local date and one at
18:31 UTC on the next, for a +05:30 offset). `modules/recommendations/context.ts` and
`insights-service.ts` resolve "today"/"this week" this way before any query, so a user in a timezone
ahead of UTC sees their own midnight boundary, not the server's.

**Dismiss-persistence decision.** Dismissing a recommendation is persisted server-side, in a new,
minimal `app.dismissed_recommendations (user_id, local_date, slot)` table — not just discarded on the
client — so a dismissal survives app restarts and other devices, and so the ticket's "safe retries and
duplicate-request handling" requirement has something durable to be idempotent _against_: the insert is
`ON CONFLICT (user_id, local_date, slot) DO NOTHING`, making a repeated dismiss (retry, double-tap, or
a second device) a no-op rather than an error. The table stores no recommendation content, only the
fact and moment of dismissal, keeping it a thin, auditable record rather than a cache. The alternative
(client-only, ephemeral dismissal) was rejected because it would silently re-offer the same suggestion
on a fresh session or device, which is the opposite of what a "dismiss" action should honestly do.

**Swap reuses M3, does not duplicate it.** The `swap` action in
`modules/recommendations/actions-service.ts` calls `replacePlanMeal` from
`apps/api/src/modules/diet/service.ts` directly — the same revision-checked, allergy-filtered
replace-a-plan-meal logic the diet-plan screen's own swap flow uses (D-022's revision/idempotency
convention) — rather than re-implementing slot replacement. The `add` action is new (no plan-meal
existed before), and `dismiss` is new and specific to this milestone.

**A bugfix carried forward into this migration, not into the applied M1 migration.** Building this
milestone's new user-owned table exposed a long-standing gap in the M1 grants migration: its
`alter default privileges in schema app revoke all on tables from public;` statement names only
`public`, not `anon`/`authenticated`, while the plain-Postgres test shim's schema-independent "grant
all to anon, authenticated" default-privilege statement therefore applied, unnoticed, to any new `app`
table created after that migration — this was never exercised before because M2–M5 added no new `app`
schema table after M1's grants ran. Per AGENTS.md ("never edit an applied migration"), the fix is a
corrective `alter default privileges ... revoke all on tables/functions from public, anon,
authenticated;` plus an explicit `revoke all on app.dismissed_recommendations from public, anon,
authenticated;` inside the new M6 migration itself, documented inline, rather than a retroactive edit
to M1. The new table's negative-ownership test (`supabase/tests/security.test.ts`) exercises this
directly: user B cannot select, insert into, or delete from user A's dismissal row.

**Flutter.** Two new screens, `NextMealScreen` and `NutritionInsightsScreen`
(`apps/mobile/lib/features/meals/`), reached from Meals → "What should I eat next?" / "Seven-day
patterns", plus a wired (no longer placeholder) next-meal preview and nutrition summary on Home. Both
screens follow the established idle/loading/loaded/error controller-state convention (D-023,
`PlateFixesState`/`MealScanState`), show the limited-context/coverage-uncertain notices Home and
Insights carry from the API rather than re-deriving them, and name every excluded day instead of only
a count. No Stitch screens exist for next-meal or nutrition-insights (same as D-023/D-026/D-027's
precedent — the Stitch export has no screens for this feature), so this milestone again uses the
existing `lib/core/ui` component system (D-014); the visuals can be replaced later without touching
routing or state. `MockRecommendationsRepository` provides clearly `(mock)`-labelled development data,
including a sticky in-memory dismissal so the mock flow matches the real one's honesty.

**Catalog-honesty note (carried from D-025/D-026/D-027, restated for this milestone's reviewer).**
Every suggestion and gap claim in this milestone is only as trustworthy as the catalog and the user's
logged data beneath it; the catalog itself remains the synthetic `test_fixture` seed (D-025) and no
licensed nutrition dataset is available in this environment. This milestone adds no new catalog gate —
it reads eligible recipes through the same `filterEligibleRecipes`/`loadCatalogFoods` path Meal Balance
and Fix My Plate already use, so a deployed environment without real catalog data would surface no
eligible options (an empty option list with an honest explanation) rather than a fabricated one.

**Scope limits (explicit, per the ticket).** No 30/90-day analysis — only daily and seven-day. No
automatic plan adaptation: every action here is a recommendation the user explicitly accepts (add),
swaps in, or dismisses; the engine never writes to a plan on its own. M7 is not started by this
milestone.

**Release gate (open, carried forward).** Same as D-025/D-026/D-027: a licensed, reviewed catalog must
replace the test fixture, and the gap thresholds (`GAP_THRESHOLD_FRACTION = 0.8`,
`MIN_USABLE_DAYS_FOR_WEEKLY_GAPS = 3`) are engineering placeholders, not reviewed nutrition guidance,
and should be confirmed by a reviewer before this is presented as anything more than an explainable
heuristic.

## D-029 · Synthetic test-fixture exercise catalog, the workout-plan generation algorithm, and session-logging schema reuse (M7)

**Scope.** Personalized weekly workout plans and workout session logging (blueprint §11), built the
same way as M3's diet-plan generation (D-025): a deterministic, seed-free backend algorithm over a
verified exercise catalog, with the same async `generation_requests`/queue/worker pattern and the
same catalog-honesty gate — no AI model invents exercise names, prescriptions or substitution safety.

**Exercise-catalog test-fixture seed, mirroring D-025 exactly.** No licensed exercise dataset is
available in this environment (`data/exercises` has no content beyond its README placeholder).
`supabase/migrations/20261001001200_m7_exercise_test_fixture.sql` seeds 29 exercises, all
`quality_flag = 'test_fixture'`, spanning squat, hinge, horizontal/vertical push, horizontal/vertical
pull, core and carry/conditioning movement patterns, across beginner/intermediate/advanced levels and
bodyweight/dumbbell/barbell/bench/pull-up-bar/kettlebell/resistance-band/gym-machine/bike equipment,
plus 19 symmetric `exercise_substitutions` relationships. The seed's own comment states plainly that
these are synthetic development placeholders, not a reviewed exercise-science source.

**Catalog gate reused, not duplicated.** `packages/domain/src/catalog/gate.ts`'s `catalogGate()`
(D-025) is generalized to take any `{ quality_flag }` item rather than only `CatalogRecipe`, so the
exact same fail-closed rule — staging/production refuse to generate from a catalog with no
`verified`/`reviewed` entries — now also governs workout-plan generation
(`apps/worker/src/handlers/workout-plan-generate.ts`), with no separate gate implementation to drift
out of sync.

**Workout-plan generation algorithm.** `packages/domain/src/workouts/generate.ts`'s
`generateWorkoutPlan` is the structural counterpart to M3's `generatePlan`: pure, deterministic and
seed-free, so the same eligible-exercise pool, weekday selection and session duration always produce
the same week. It schedules one session per selected weekday (ISO 1–7, the earliest `days_per_week` of
the user's declared `weekdays`), sizes each session's exercise count from `duration_minutes` (one
exercise per ~8 minutes, clamped to 3–6), and rotates through each available movement pattern's
eligible-exercise pool deterministically by session index so the week varies without randomness. Set/
rep/rest prescriptions are assigned by the exercise's own level (`prescriptionForLevel`) — fixed,
documented placeholder norms (e.g. beginner: 3×10-12, 60s rest), explicitly noted in code as
engineering defaults, not reviewed exercise-science guidance, exactly like D-025's diet thresholds.

**Equipment/location/limitation/experience eligibility (`packages/domain/src/workouts/eligibility.ts`),
the exercise-catalog counterpart to `catalog/eligibility.ts`'s diet rules.** An exercise with no
equipment tags is bodyweight and always eligible. A `gym` or `both` training location is treated as
full gym equipment access; a `home`-only location restricts eligibility to the exercise's equipment
tags all being present in the user's declared `equipment_ids` — this is what makes a barbell exercise
correctly unavailable to a home-only user with no barbell, and correctly available once they declare
one, or once their location includes gym access. Any overlap between an exercise's
`contraindication_tags` and the user's recorded `limitation_tags` excludes it outright (never a
softened "lower effort" variant — the exercise simply does not appear). Experience is a ceiling, not a
floor (`LEVEL_ORDER`): a beginner sees only beginner-level exercises; an advanced user sees the full
beginner-through-advanced progression. All four rules combine with AND, mirroring D-025's "every rule
re-derived from the catalog's own tags" convention so a stale cache can never relax a safety
constraint.

**Substitutions (`packages/domain/src/workouts/substitutions.ts`) are catalog-declared only.**
`substitutionsFor` reads `app.exercise_substitutions` relationships for the requested exercise, then
filters the candidates through the exact same `filterEligibleExercises` eligibility rules — so a
substitution offered to the user is always both a real catalog relationship and something they can
currently do, never an invented "similar" exercise and never one their equipment/limitations rule out.

**Infeasibility handling, mirroring D-025 exactly.** `generateWorkoutPlan` returns
`{ ok: false, reason: 'no_eligible_exercises' }` when the user's equipment/location/limitations/
experience combination leaves nothing eligible at all, and
`{ ok: false, reason: 'insufficient_weekdays' }` when fewer weekdays are selected than
`days_per_week` requires (defensive: the API/profile layer already validates this, per
`packages/domain/src/profile/validation.ts`'s `validateTraining`). The worker handler
(`handleWorkoutPlanGenerate`) maps both, plus missing/incomplete training preferences and the catalog
gate's refusal, onto an honest `safe_error_code`/`safe_error_message` on the `generation_requests` row
— never a degenerate or silently-wrong plan — surfaced through the existing `GET /v1/jobs/{id}`
endpoint exactly as M3's diet-plan infeasibility is.

**`request_type` decision: always `workout_plan`, never `plan_regeneration`.** The
`generation_requests.request_type` check constraint already lists `plan_regeneration` as a shared
value (added in M1, read as "M7, not relevant now" at the time), but
`packages/domain/src/jobs/queues.ts`'s `GENERATION_REQUEST_QUEUES` can only map each request type to
one queue, and `plan_regeneration` already maps to the diet-plan queue (D-025). Rather than overload
that mapping or special-case the relay, M7's `requestWorkoutPlanGeneration`
(`apps/api/src/modules/workouts/service.ts`) always records `request_type = 'workout_plan'`, for both
the first plan and every later regeneration; `GENERATION_REQUEST_QUEUES.workout_plan` points at the
new `workout-plan.generate` queue. The existing one-active-job-per-`(user_id, request_type)` partial
unique index already covers `workout_plan`, so repeated generation requests are still deduplicated
exactly like diet plans.

**Session-logging schema: M1's `workout_logs`/`workout_set_logs` already cover it; no new migration
needed.** Before writing any schema, the M1 `supabase/migrations/20261001000400_plans.sql` and
`20261001000500_media_scans_logs.sql` were read in full per the ticket's instruction. They show the
"planned" and "logged" layers were already designed as two separate table families:
`workout_plans`/`workout_plan_sessions`/`workout_plan_exercises` hold the generated prescription
(sets/reps/rest/exercise, never what actually happened), while `workout_logs`
(`client_id`-deduplicated, `status: in_progress|completed|skipped|abandoned`, `started_at`/
`completed_at`, `revision`) and `workout_set_logs` (`exercise_id`, `set_ordinal`, `reps`, `load_kg`,
`skipped`, unique per `(workout_log_id, exercise_id, set_ordinal)`) already exist as exactly the
"actually happened" layer the M7 ticket asks for. Both were present since M1 but unused until this
milestone. This is the only migration this milestone needed beyond the exercise-catalog seed: no new
logging table, only the additive `20261001001200_m7_exercise_test_fixture.sql`.

**API surface, implementing contract operations drafted (as `planned`) since M1-ish.** The OpenAPI
operations `generateWorkoutPlan`, `getCurrentWorkoutPlan`, `getExerciseSubstitutions`,
`createWorkoutLog`, `putWorkoutSets` and `patchWorkoutLog` already existed in
`packages/contracts/openapi.yaml` tagged `x-noura-milestone: M7, x-noura-status: planned`; this
milestone implements the routes/service (`apps/api/src/modules/workouts/`) and flips each to
`implemented` only once its route and tests exist, per AGENTS.md. `putWorkoutSets` additionally
verifies every logged `exercise_id` belongs to the log's own session (not just that the log itself is
owned by the caller) before accepting a write — extending the ownership/consistency convention beyond
the row level to the exercise identity within a session.

**Home's "Today's workout" placeholder is wired to real data.** `getHome`
(`apps/api/src/modules/recommendations/home-service.ts`) now reads today's session from the active
workout plan, with its status derived from the most recent `workout_logs` row for that session when
one is `completed` or `skipped` (falling back to the plan's own `scheduled`/`rescheduled`/`cancelled`
status otherwise), matching the `WorkoutSessionPreview` contract exactly. `todays_workout: null` simply
means no session is scheduled for that date, consistent with `next_meal`'s existing null convention.

**Flutter.** `WorkoutScreen` replaces the M1-M6 placeholder with the real weekly schedule (one card per
session), `WorkoutSessionScreen` shows one session's prescribed exercises with a "Replace" action per
exercise, `ActiveSessionScreen` drives the real set-by-set logging flow with a genuine countdown rest
timer (`ActiveSessionController`, a plain `Notifier` whose state machine advances
exercise/set/rest/finished exactly once per `logSet`/`finish` call, with a real `Timer.periodic` between
sets), `ExerciseReplacementScreen` lists only catalog-approved, currently-eligible substitutes, and
`CompletionSummaryScreen` shows completed-vs-skipped sets per exercise. All four follow the established
loading/empty/error convention (D-023). Exercise replacement is informational only in this milestone —
there is no API operation to permanently swap an exercise within an already-generated plan (only the
substitutions lookup and, separately, per-session logging), so picking a replacement changes what the
user logs for that session, not the stored plan itself; a persisted "replace a planned exercise"
endpoint is a natural M8-or-later extension, not something this milestone invents an undocumented write
path for. `MockWorkoutRepository` provides clearly `(mock)`-labelled development data, including a
small in-memory log store so the active-session flow can be exercised without a server. No Stitch
screens exist for workouts (same precedent as D-023/D-026/D-027/D-028), so the existing `lib/core/ui`
component system is used throughout.

**Catalog-honesty note (carried from D-025/D-026/D-027/D-028, restated for this milestone's
reviewer).** Every prescribed exercise, substitution and set/rep/rest number in this milestone is only
as trustworthy as the catalog beneath it, which remains the synthetic `test_fixture` seed above — no
licensed exercise dataset is available in this environment. The reused catalog gate already refuses
automated workout-plan generation in a deployed environment without verified/reviewed exercise data.

**Scope limits (explicit, per the ticket).** No adaptive training (plans that change based on logged
performance over time) — every regeneration is a fresh deterministic run from the user's current
training preferences, never influenced by prior session logs. No physique analysis. No wearable
integrations. M8 is not started by this milestone.

**Release gate (open, carried forward).** Same as D-025 through D-028: a licensed, reviewed exercise
catalog must replace the test fixture, and the set/rep/rest prescriptions (`PRESCRIPTION_BY_LEVEL`) and
session-sizing heuristic (one exercise per ~8 minutes) are engineering placeholders, not reviewed
exercise-science guidance, and should be confirmed by a qualified reviewer before this is presented as
anything more than an explainable heuristic.

## D-030 · Basic Progress Tracking: weight history, honest adherence summaries, and progress-photo retention (M8)

**Scope.** Weight history with starting/current/goal weight, read-only meal-plan-adherence and
workout-consistency summaries over already-recorded app data, private progress-photo upload/storage/
deletion, and a pure side-by-side comparison view (blueprint §6, §16 "M8 Progress"). No physique
analysis, body-fat estimation, or medical judgment from photos or weight data; no automatic plan
changes from progress data.

**Schema already existed from M1 — no new migration.** `app.weight_logs` and `app.progress_photos`
(`supabase/migrations/20261001000500_media_scans_logs.sql`) were already defined, RLS-enabled and
granted (`20261001000800_storage_and_grants.sql`), unused, exactly as M1 built ahead for M3's catalog
and M4's media tables. `app.media_assets` already carries a `purpose` discriminator including
`progress_photo` with its own bucket (`progress-photos`), so progress photos reuse M4's exact private-
media-storage pattern (`packages/domain/src/media/storage.ts`, `apps/api/src/modules/media`) rather
than a parallel implementation. The OpenAPI operations and schemas (`WeightLog`, `ProgressPhoto`,
`Progress`, etc.) were also already drafted as `x-noura-status: planned`; this milestone only flips
them to `implemented` and adds a few additive fields (below).

**Starting/current/goal weight.** "Current" is the latest `weight_logs` entry, falling back to the
profile's own `weight_kg` (captured at onboarding) when no history exists yet. "Starting" is the
first-ever `weight_logs` entry by `measured_at`, with the same profile fallback — so a user who never
logs a second weight still sees a starting/current/goal view, rather than an empty one. "Goal" is the
active `app.goals` row's `target_weight_kg` (nullable — a goal need not include a weight target).
These three fields were added to the existing `Progress` schema (`GET /v1/progress`) rather than a new
endpoint, since they are naturally part of the same "at a glance" view the blueprint already specified.

**Progress-photo retention: blueprint-specified, not D-026's default.** The blueprint is explicit and
specific here (§14): "logged meal images 90 days unless deleted sooner... progress photos until user
deletion" — a different retention than meal images, not merely silent on the point. `createUploadSlot`
(`apps/api/src/modules/media/service.ts`) previously applied a flat 30-day `expires_at` to every
upload regardless of purpose (D-026's engineering default, carried from M4, itself already short of the
blueprint's 90-day meal-image figure — an M4-era gap out of this milestone's scope to fix). This
milestone adds `PURPOSES_WITH_NO_AUTO_EXPIRY = {'progress_photo'}`: a progress-photo upload now gets
`expires_at = null` (no scheduled purge), while meal-image uploads are unchanged. Deletion is still
on demand (`DELETE /v1/progress-photos/{id}`, which removes the `progress_photos` row and then deletes
the backing `media_assets` row/object via M4's existing `deleteMedia`), satisfying "until user
deletion" exactly.

**Honest adherence: a new `AdherenceSummary` schema, not a bare count.** The ticket explicitly forbids
presenting a missing plan as a real zero. `buildAdherenceSummary`
(`packages/domain/src/progress/adherence.ts`) returns `{ plan_active: false, planned: null, logged:
null }` whenever the user has no active diet or workout plan, and only returns real integers —
including a genuine `0` — once a plan exists. This mirrors D-028's `coverage_uncertain` convention:
"no data" and "real zero" are different values, never collapsed into each other. `diet_adherence` and
`workout_adherence` (`GET /v1/progress`) count only already-elapsed plan items (`date <= today`, in the
user's own timezone via `packages/domain/src/time/timezone.ts`, reused from M6) — a future planned
meal or scheduled session is never counted as a miss, matching the blueprint's own wording for workout
consistency ("scheduled sessions elapsed, excluding future sessions... and rest days"); a rest day is
simply a day with no `workout_plan_sessions` row, so it is never in the denominator at all.

**Comparison view: pure UI, no new backend surface.** The ticket requires selecting two dates and
viewing the photos side by side, with an explicit instruction not to analyze physique or estimate body
fat. `PhotoComparisonScreen` (`apps/mobile/lib/features/progress/photo_comparison_screen.dart`) fetches
the existing photo list, lets the user pick any two by date, and renders both via M4's existing signed
`GET /v1/media/{id}/download` — no new endpoint, and no image-content processing of any kind anywhere
in the request path. A date with no photo shows an explicit "No photo for this date" state rather than
silently picking a different one.

**Progress-photo upload idempotency.** `createProgressPhoto` is idempotent by `media_id` (one progress-
photo reference per verified media asset, mirroring M4's `createMealScan`'s dedup-by-media-id), so a
retried registration after a flaky response never creates a duplicate reference.

**Release gate (open, carried forward).** `MEAL_SCAN_DAILY_QUOTA`-style quotas, a licensed catalog, a
real AI vision provider, and a scheduled media-purge job remain the same open items as M3-M7; this
milestone adds nothing new to that list, since progress photos are explicitly retained until deletion
rather than purged on a schedule.

## D-031 · AI Coach: context-aware chat, safety screening, limited swap-only proposals (M9)

**Scope.** Context-aware coach chat grounded in the user's own profile/goals, active diet plan,
today's logged meals and workout schedule; honest gap-handling when that context is missing; an
extension of the M4 mock-first AI-provider pattern (D-010) to `coachReply`; out-of-scope/medical-safety
screening on both the user's message and the provider's output; persisted chat history with
per-user RLS; and a single, narrowly-scoped confirmable action (`swap_meal`) applied through the exact
same domain function the existing swap UI uses. No diagnosis, no medication dosing, no invented
nutrition/exercise facts, no silent plan changes (blueprint §1, §10, §12, §16 "M9 Coach").

**Schema already existed from M1 — one additive column, no new tables.**
`app.coach_threads`/`app.coach_messages`/`app.action_proposals`
(`supabase/migrations/20261001000600_insights_coach.sql`), RLS-enabled and granted
(`20261001000800_storage_and_grants.sql`), were already defined, unused, exactly as M1 built ahead for
M3-M8's catalog/media/progress tables. The OpenAPI coach/action-proposal operations and schemas were
also already drafted as `x-noura-status: planned`; this milestone flips them to `implemented`, adds one
new operation (`DELETE /v1/coach/threads/{id}`, below), and adds a single additive column —
`app.coach_messages.cards jsonb` (`supabase/migrations/20261001001300_m9_coach_message_cards.sql`) —
so a completed reply's structured cards (blueprint §16 "grounded responses/cards") persist alongside
the message that produced them, exactly like every other snapshot column in this schema. A new
negative-ownership test block (`supabase/tests/security.test.ts`, "M9 coach thread/message/action-
proposal owner isolation") covers all three tables: cross-user read/update/delete, client-supplied
`user_id` rejection, a message that tries to attach to another user's thread, and worker-role parity.

**Context assembly: `loadCoachContext` in `packages/domain/src/coach/context.ts`, not `apps/api`.**
M6's equivalent (`loadTodayContext`) lives in `apps/api/src/modules/recommendations/context.ts`
because only the API calls it. The coach's reply, by contrast, is generated asynchronously by the
**worker** (see below), so the loader had to live in `packages/domain` where both apps can reach it. It
reuses the exact same domain primitives M3/M6 already built — `loadDietPlanningInputs`,
`loadCatalogRecipes`, `filterEligibleRecipes` — rather than a parallel read path, and is intentionally
narrow: it loads the user's profile/goal presence, whether an active diet plan exists and, if so, only
the single _first_ planned slot for today (with one real, eligible alternate candidate already
resolved), today's logged-meal count, and whether an active workout plan exists with today's session
title/status. Every "has a plan" flag is a real boolean and every missing-data case is a real `null`,
never a fabricated zero (the same honesty convention as D-028's `coverage_uncertain` and D-030's
`AdherenceSummary`).

**Provider boundary: strict Zod schemas in both directions (`packages/ai/src/validators/coach.ts`).**
`validateCoachContextInput` validates the (deliberately small) payload the worker is about to send the
provider; `validateCoachProviderOutput` validates what comes back — `answer_text` (prose only),
`evidence_refs` (opaque keys), and at most one `proposed_action`. The provider **never** returns a
card, a nutrition number, or an exercise prescription: cards are always built server-side, directly
from the already-loaded `CoachContext`, by `buildCards()` in the worker handler — mirroring M5/M6's
"AI explains, domain code computes" split and this milestone's own scope note 6 ("the model's role is
conversational framing, never a source of factual nutrition/exercise claims").

**`proposed_action.type` accepts only `swap_meal` — a deliberate, documented scope limit.** The
blueprint's `ActionProposal.type` enum and the ticket both name three allowed proposals: `swap_meal`,
`regenerate_day`, `reschedule_workout`. Only `swap_meal` has an existing, already-shipped, user-facing
confirmed-action endpoint to delegate to (`replacePlanMeal`, used by M3's swap-options flow and M6's
next-meal swap action). Building new plan-mutation domain logic for whole-day regeneration or workout
rescheduling is exactly the kind of new feature AGENTS.md says not to invent beyond a milestone's scope.
`CoachProposedActionSchema` therefore only validates `swap_meal`; the other two remain valid values on
the `ActionProposal` **API** schema for forward compatibility (so a later milestone can add them without
another contract change), but this milestone's provider/validator never produces them, and
`applyActionProposal` refuses either with `CONSTRAINT_CONFLICT` if one is ever found (defence in depth
only — nothing in this milestone can actually create one).

**No silent actions, enforced structurally, not just by prompt instruction.** `createSwapProposal`
(`apps/worker/src/handlers/coach-reply.ts`) re-resolves the "real" plan meal/candidate from a freshly
loaded `CoachContext` and silently drops the provider's proposal if its ids don't match that fresh
read — a provider can never reference a stale or invented id into an actual proposal row. Applying a
proposal (`POST /v1/action-proposals/{id}/apply`) calls `replacePlanMeal` **exactly as the existing
swap UI does**, with the same revision check, so the coach can never perform a mutation the UI itself
could not already perform, and a message is never more than a _suggestion_ until the user explicitly
taps confirm (blueprint §12 `requires_confirmation=true`; scope note 7).

**Safety: enforced twice, not once.** `checkSafety` (`packages/domain/src/coach/safety.ts`) is a
conservative keyword/pattern screen over four blueprint-named categories (diagnosis requests,
medication dosing, eating-disorder-risk phrasing, body-fat/physique-analysis requests). It runs
**before** the provider is ever called (an out-of-scope user message short-circuits straight to a safe,
clinician-redirecting decline — the mock is never invoked, so this behaves identically once a real
provider is configured), and again on the provider's returned `answer_text` as defence in depth, since
this milestone cannot assume every future provider will honor `COACH_SYSTEM_PROMPT`'s instructions.
Both paths are tested (`packages/domain/src/coach/safety.test.ts`,
`apps/worker/test/coach-reply.test.ts`). This is an engineering placeholder, not a reviewed clinical
safety policy — see the release gate below.

**Async generation via the worker, like M4, not synchronous like M5/M6/M8.** `sendCoachMessage`
(`apps/api/src/modules/coach/service.ts`) only inserts the user message, a pending assistant
placeholder, and an `app.generation_requests` row (`request_type = 'coach_reply'`), exactly like M4's
`createMealScan` — the same transactional-outbox relay (D-017) then hands it to a new `coach.reply`
pg-boss queue, and `handleCoachReply` (`apps/worker/src/handlers/coach-reply.ts`) does the actual
provider call. This was the right call, not just the consistent one: an external AI call is exactly the
kind of bounded-but-sometimes-slow external request the blueprint's queue/retry/idempotency machinery
(§13) already exists for, and it keeps the API request path free of a live provider call, matching the
M4 precedent for "the one other milestone that calls an external AI provider" rather than M5/M6/M8's
synchronous domain-only calculations. Idempotency: the handler is a no-op for an already-terminal
request or an already-resolved message (identical shape to `meal-scan-analyze.ts`'s crash-recovery
logic), and `sendCoachMessage` itself is idempotent on `client_id` even across different
`Idempotency-Key` values, so a dropped response can never double-charge the daily quota or create two
assistant replies for one user message.

**Daily quota: five coach replies/day (blueprint §13's own proposed figure), via the existing
`usage_reservations` mechanism** — identical pattern to M4's `MEAL_SCAN_DAILY_QUOTA`, same
provisional-number caveat.

**Retention: 90 days per the blueprint, not D-030's "until deletion" default.** Blueprint §14 is
explicit and, unlike progress photos, different from the nutrition-log default: "coach history 90
days." This milestone does not build the scheduled purge job that would enforce that automatically —
same documented gap as M4's 90-day meal-image retention and M1-M8's other deferred cleanup jobs — but
it does add `DELETE /v1/coach/threads/{id}` (a new, this-milestone-authored operation; cascades to the
thread's messages and proposals via the FKs M1 already wrote), so a user can delete a conversation
immediately rather than only after 90 days, matching the blueprint's broader "explicit deletion is
always available sooner" posture (§14's account-deletion language) even though this milestone does not
invent a scheduled-purge cron for the 90-day default.

**Flutter.** `CoachScreen` replaces the M1-M8 placeholder with a real chat UI: a message list (user
bubbles right-aligned, assistant left-aligned, a spinner bubble while `pending`), suggested-prompt
chips shown until the first message, one structured card per message for each real meal/workout
surfaced (`_CoachCardView`, built from the server's `cards` field — never free text), and a proposal
card with explicit Confirm/Cancel buttons wired straight to `applyActionProposal`/`cancelActionProposal`
(scope note 7: no proposal ever applies itself). `CoachController` mirrors `MealScanController`'s
capture → processing → terminal polling convention, since a coach reply is generated the same way a
meal scan is (a 202-accepted async job, not an immediate value). `TabPage` gained a `scrollable: false`
mode (a plain `Column`, not a `ListView`) so a chat screen's message list can use `Expanded` above a
pinned input bar — the first feature to need a full-height flex layout instead of the stock scrolling
section list. `MockCoachRepository` provides clearly `(mock)`-labelled development replies, including
its own tiny safety/swap heuristics, so the chat flow is exercisable without a server. No Stitch
screens exist for the coach (same precedent as D-023 and M6-M8's equivalent notes), so the existing
`lib/core/ui` component system is used throughout.

**Voice/image input: explicitly out of scope, confirmed against the blueprint.** The blueprint's coach
section (§4, §12, §16) describes only text messages, cards and proposals; it does not scope voice or
image input into the coach for V1 (image input elsewhere in the app — meal photos — is its own M4
feature, unrelated to chat). This milestone builds text-only chat and omits voice/image input rather
than inventing scope the blueprint does not call for.

**Catalog/AI-honesty note (carried from D-010/D-025/D-028/D-030, restated for this milestone's
reviewer).** The coach never computes or states a nutrition or exercise number itself — every number a
card or the surrounding app ever shows the user still comes from the approved catalog or the user's own
recorded data via the same domain functions M3/M5/M6/M7 already use. `coachReply`'s mock implementation
remains the only exercised path in this environment (no real provider key is available here, same as
every prior AI-backed milestone); the factory still fails closed outside development/test exactly as
D-010 established for `recognizeMeal`.

**Release gate (open, carried forward).** A licensed/reviewed safety and clinical-scope policy must
replace `checkSafety`'s keyword screen before production; `COACH_REPLY_DAILY_QUOTA` is the same kind of
provisional engineering number as M4's `MEAL_SCAN_DAILY_QUOTA`; no scheduled 90-day coach-history purge
job exists yet (user-initiated deletion is available now); and, as with every prior AI-backed
milestone, a real provider adapter, key and model must be benchmarked and reviewed (blueprint §17)
before `AI_PROVIDER=mock` is no longer the only exercised path. M10 is not started or scoped by this
milestone.

## D-032 · Release hardening: billing/entitlements, free-tier quotas, local reminders, telemetry, export/deletion (M10, final V1 milestone)

**Billing/entitlement adapter, mock-first and fail-closed, matching D-010 exactly.** A new
`@noura/billing` package defines `BillingProvider` (`verifyWebhookAuth`, `parseWebhookEvent`,
`fetchSubscriberEntitlements`) and `AuthAdminProvider` (`deleteUser`), each with a `mock` implementation
(development/test only) and a real implementation (`revenuecat`/`supabase`) that calls the real
RevenueCat REST API / Supabase Admin REST API. `createBillingProvider`/`createAuthAdminProvider` refuse
to start with `mock` outside `development`/`test`, and refuse `revenuecat`/`supabase` without their
required secret configured, the identical shape to `createAiProvider`. Neither real adapter has been
exercised against a live RevenueCat or Supabase project in this environment — no such project is
configured here — so, as with D-011's OAuth providers and D-010's `recognizeMeal`, their request/response
shapes are unit-tested against fixed fixtures only. **This is a release gate**, not a limitation
specific to this milestone: production cannot start with `BILLING_PROVIDER=revenuecat` until a real
RevenueCat project, webhook secret and API key exist and have been smoke-tested end to end.

**Webhook handling implements every blueprint §13 requirement, not just signature verification.**
`receiveWebhook` (`apps/api/src/modules/billing/service.ts`) (1) requires `deps.billing.verifyWebhookAuth`
to accept the request's `Authorization` header before the body is trusted at all — this operation uses
the custom `revenueCatWebhookAuth` security scheme, not `bearerAuth`, so `registerOperation` deliberately
skips its normal JWT verification and the route handler checks manually; (2) persists the raw event into
`app.billing_events` keyed by `(provider, provider_event_id)` with `ON CONFLICT ... DO NOTHING RETURNING
id` so a duplicate delivery (RevenueCat's own at-least-once guarantee) is a silent no-op, never processed
twice; (3) maps `app_user_id` to our UUID and marks the event `ignored` rather than erroring when it does
not resolve to a real user (a sandbox/test event, or a user already deleted); (4) reconciles rather than
overwrites: `reconcileEntitlement` (`packages/domain/src/billing/reconcile.ts`) does
`ON CONFLICT (user_id, key) DO UPDATE ... WHERE app.entitlements.last_verified_at <=
excluded.last_verified_at`, so an out-of-order or re-delivered older event can never roll back a newer,
already-applied entitlement state — the blueprint's explicit "events may arrive twice or out of order:
refresh/reconcile provider state rather than setting premium from arrival order." Cancellation retains
access until period end because `normalizeRevenueCatEvent` (`packages/billing/src/revenuecat-parse.ts`)
classifies `CANCELLATION`/`BILLING_ISSUE`/`SUBSCRIPTION_PAUSED` as `RETAINS_ACCESS_UNTIL_EXPIRY` (active
until the provider's own `expires_at`), while only `EXPIRATION`/`REFUND` end access immediately.
**Restore purchases is "restore → server sync → confirmed entitlement", never a local flag**:
`POST /v1/billing/sync` (`syncBilling`) calls `fetchSubscriberEntitlements` against the provider and
reconciles the result the same way a webhook would, then returns the server's own freshly-verified
`Entitlements` — the only thing the Flutter client ever renders as "premium."

**Free-tier quota enforcement is now entitlement-aware, replacing M4/M9's hardcoded constants.**
`packages/domain/src/billing/limits.ts` adds `isPremiumUser` (an active, non-expired `premium` row in
`app.entitlements`) and `dailyQuotaFor(client, userId, quota)`, which `createMealScan` and
`sendCoachMessage` now call instead of the module-level `MEAL_SCAN_DAILY_QUOTA`/`COACH_REPLY_DAILY_QUOTA`
constants those milestones introduced. The reserve-on-request/consume-on-success/release-on-failure
mechanics in `app.usage_reservations` are unchanged from M4/M9 — only the limit a given user is checked
against changes, and a free user still sees exactly the same pre-existing limits (3 meal scans, 5 coach
replies) as before this milestone, so no M4/M9 test needed to change its expected numbers. Limits are
still provisional engineering numbers (blueprint §13's own "proposed initial configurable" language), now
configurable via `MEAL_SCAN_FREE_DAILY_QUOTA`/`MEAL_SCAN_PREMIUM_DAILY_QUOTA`/
`COACH_REPLY_FREE_DAILY_QUOTA`/`COACH_REPLY_PREMIUM_DAILY_QUOTA` rather than hardcoded. `GET
/v1/entitlements` and `GET /v1/usage` are the two new read endpoints the Flutter client uses to decide
what to show — never a client-side guess, never a value the client can forge, consistent with the
project-wide rule that the API derives every fact from the verified token and server state alone.

**Notifications are local-device-only for V1, exactly as the blueprint states, and this milestone does
not pretend otherwise.** `GET`/`PUT /v1/me/notification-preferences` (new operations, added to
`openapi.yaml` and backed by a `reminder_settings` jsonb column on the pre-existing
`app.user_preferences` table rather than a new migration) record consent (`consent_granted_at`, set only
when the user is newly opting in) and the chosen local reminder times. There is no push token, no device
registration endpoint, and no push-sending code anywhere in this milestone — blueprint §18 is explicit
("No push infrastructure needed for V1") and inventing one would be exactly the kind of deferred-feature
scope-creep AGENTS.md forbids. Flutter's `ReminderScheduler` interface is the seam where a real
`flutter_local_notifications` (or equivalent) integration plugs in later; `NoOpReminderScheduler` is the
only implementation shipped here, because wiring a real plugin needs native Android/iOS project changes
this sandboxed environment has no way to verify against a real device — see the release checklist. It
fails safe (schedules nothing) rather than guessing at a plugin API it cannot test.

**Telemetry is a mock-first adapter with no real provider wired, by the same reasoning as
notifications.** `TelemetryProvider` (`apps/mobile/lib/core/telemetry/telemetry_provider.dart`) exposes
only a closed `TelemetryEvent` enum plus a flat `Map<String, Object?>` of properties — there is no
"attach arbitrary payload" method, so a caller cannot pass a meal photo, chat text, an eligibility
answer, an email or any other PII/health content through it even by mistake. It defaults to
`enabled: false` (opt-in, not opt-out, per blueprint §18) and `MockTelemetryProvider` is the only
implementation wired in `main.dart` for both the mock and the "real" branch, because no real
analytics/crash SDK or project (Firebase Analytics, Sentry, etc.) is configured in this environment. A
real provider is release-checklist work, not M10 work: the interface is the deliverable here, matching
D-010's provider-boundary pattern even though a second concrete implementation does not exist yet.

**Account deletion: a real worker job, not a soft flag, with a load-bearing three-transaction
structure.** `requestAccountDeletion` inserts a durable `app.deletion_requests` row (already defined by
M1); `apps/worker/src/handlers/account-delete.ts`'s `handleAccountDelete` then, in order: (1) one
`withUserTransaction` precheck (idempotent no-op if the row is missing or already terminal); (2) one
`withUserTransaction` that marks the row `in_progress`, cancels any queued `generation_requests`
(`completed_at = now()` is required alongside `status = 'cancelled'` by a pre-existing check constraint),
deletes every Storage object the user owns, and marks their `media_assets` rows deleted; (3) **with no
transaction open at all**, calls `authAdmin.deleteUser(userId)`; (4) one final `withUserTransaction`
marking the row `completed`. Step (3) must run outside any open transaction: an earlier single-transaction
design hung until timeout, because `deleteUser`'s own `DELETE FROM auth.users` (on a separate pooled
connection) cascades through foreign keys into rows (e.g. `media_assets`) the still-open transaction had
already written but not committed — real lock contention, not a test artifact, and the same risk exists
in production since the API/worker and the Supabase Admin API ultimately share one Postgres instance.
This is why the handler's doc comment calls the three-transaction split load-bearing. The relay dispatch
pattern for `export_requests`/`deletion_requests` (new queue-tracking columns in
`20261001001400_m10_billing_notifications_account.sql`, plus `worker_relay_select`/`worker_relay_update`
RLS policies and a column-guard trigger) exactly mirrors the pre-existing `generation_requests` pattern
from M2 rather than inventing a new one.

**Account export builds a manifest from the same domain tables every other feature already queries,
never a second copy of nutrition/exercise facts.** `handleAccountExport`'s `buildManifest` runs sequential
(not concurrent — a single transaction connection can only run one query at a time) reads across
profile, preferences, goals, diet/workout plans and logs, weight logs and a progress-photo manifest
(URLs/paths, not re-hosted bytes), excluding secrets and provider internals per blueprint §14, and writes
the JSON via the media storage adapter's new `writeObject` method — the one place in the codebase a
server-generated object is written directly rather than through the client-upload-url flow, because
there is no client upload to verify.

**Release gate (open, the final one — see `docs/release-checklist.md` for the full, consolidated
list).** A real RevenueCat project/webhook secret/API key; a real analytics/crash provider if the product
wants more than the opt-in-but-unwired telemetry interface shipped here; a real
`flutter_local_notifications` integration; a licensed nutrition/exercise catalog and a clinical/safety
review of M9's `checkSafety` (carried from D-025–D-031); Android/iOS builds and app-store accounts; a
production backup/restore drill that respects deletion tombstones (blueprint §14). This is the last V1
milestone — there is no M11 to carry open items into; `docs/release-checklist.md` is where they now live.

## D-033 · Phone number + SMS one-time code is the only sign-in method (post-M10, owner request)

**Decision.** At the owner's request, NOURA signs users in with a phone number and a 6-digit SMS
code only. Email/password sign-up and sign-in, email verification, password reset/update, and
Google/Apple OAuth (D-011) are removed. This supersedes blueprint §1 "Email/password, password
recovery, Google and Apple authentication" and the §5 auth screen list (both edited to point here).

- **One flow for new and returning users.** `AuthRepository.sendPhoneOtp` calls Supabase
  `signInWithOtp(phone, shouldCreateUser: true)`; `verifyPhoneOtp` calls `verifyOTP(type: sms)`.
  The first successful verification creates the `auth.users` row, so there is no sign-up screen.
- **Sessions.** Unchanged mechanism: `supabase_flutter` persists and refreshes the session. It lasts
  until the user signs out or it can no longer be refreshed; then the existing
  `SignedOut(reason: sessionExpired)` path returns the user to welcome and they verify a new code.
  No hard session limit is configured (a paid Supabase plan feature; release decision).
- **Phone numbers.** The app sends E.164. A bare 10-digit Indian mobile number (starting 6-9,
  optional leading 0) gets `+91`; any other country is typed with `+`. Supabase stores the number
  without `+`; the app adds it back for display. Client checks are for fast feedback only.
- **Development.** `MockAuthRepository` sends nothing and accepts only `123456` for the number it was
  asked to send to. Local Supabase has one `[auth.sms.test_otp]` number. Mocks stay
  development-debug-only (D-010).
- **Removed configuration.** `NOURA_AUTH_REDIRECT_URL`, `NOURA_GOOGLE_SIGN_IN_ENABLED`,
  `NOURA_APPLE_SIGN_IN_ENABLED`, and the `noura://auth-callback` deep link on Android/iOS (it only
  served email links and OAuth).

**Affected contracts and migrations.** None. The OpenAPI contract has no auth operations (the app
talks to Supabase Auth directly, blueprint §2), the API identifies users only by the verified JWT
`sub` (D-007), and no table stores an email address. RevenueCat `app_user_id`, export and account
deletion (`AuthAdminProvider.deleteUser`) all key on the user UUID and work unchanged for phone
users. `requireRecentAuth` keeps working: a stale token means "verify a new code" instead of
"sign in with your password".

**Tests.** `apps/mobile/test/core/phone_auth_test.dart` (normalization, code format, mock
verification, Supabase error mapping); `apps/mobile/test/features/app_flow_test.dart` (phone → code
→ onboarding, wrong code, resend cooldown, change number, no password/email text on welcome,
session-ended message); `route_guard_test.dart` (public auth routes).

**Scope impact the owner will see.** Welcome shows one button, "Continue with phone number". Settings
shows the signed-in phone number instead of an email. Every sign-in costs one SMS. Going live needs
an SMS gateway account configured in Supabase and, for Indian numbers, TRAI DLT registration of the
sender and template (see `docs/auth-providers.md`). Not verified against a live Supabase project or
SMS gateway in this environment.
