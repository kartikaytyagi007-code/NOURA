# Milestones

Status of each milestone from blueprint §16. A milestone counts as complete only when its
acceptance gate passes. A schema that exists without the feature does not count.

| Milestone     | Status                                                        |
| ------------- | ------------------------------------------------------------- |
| M1 Foundation | **Implemented, awaiting review**                              |
| M2 Profile    | Not started. Proposed ticket below                            |
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

## Proposed M2 ticket: Profile and onboarding

**Goal.** Resumable onboarding, eligibility, preferences, and the deterministic target-policy
framework (blueprint §5, §16 M2).

**Scope**

1. **API.** Implement `patchMe`, `putPreferences`, `putTrainingPreferences`, `completeOnboarding`
   and `getTargets` (currently planned in the contract). Revise the provisional value sets through a
   new migration if needed (D-013).
   - Writes use optimistic concurrency on `expected_revision` and return `REVISION_CONFLICT` on a
     stale revision.
   - The server owns all validation: adult age, plausible metric ranges, an IANA timezone, unit
     handling, and actionable field errors.
2. **Eligibility.**
   - `packages/domain/eligibility` returns eligible, tracking_only or needs_review from minimal
     screening answers.
   - Only minimal flags and consent versions are persisted.
   - Tracking-only users get neutral tracking and an explanation; plan generation is gated.
3. **Targets.**
   - `packages/domain/nutrition` holds a versioned, deterministic target-policy framework with test
     fixtures clearly marked as test policy. Production refuses to run test policies.
   - If the sex parameter is declined, offer a range or manually supplied targets.
   - Real clinical thresholds stay a release decision.
4. **Completing onboarding.** One transaction writes the profile revision, the goal version, the
   target snapshot, and the plan `generation_requests` row, plus the pg-boss job. This is the first
   API job producer. A job failure keeps the inputs.
5. **Flutter onboarding.** Basics → goals → diet/preferences → training → eligibility/consent →
   review → submit.
   - Each step saves to the server and the flow resumes at `onboarding.step` after a restart.
   - Units are displayed in kg/lb and cm/ft.
   - Every screen has loading, offline and validation states.
   - Uses Stitch screens where provided (§15 corrections apply).
6. **Settings.** Profile and preference editing. A successful edit increments the revision.

**Acceptance gate.**

- Onboarding resumes after an app restart.
- Unit and timezone validation is enforced.
- Edits increment revisions, and stale writes conflict.
- Unsupported users cannot reach planning.
- Duplicate submits create one generation request.
- The tests are API integration tests (PostgreSQL), domain unit tests and Flutter flow tests.

**Out of scope.** Plan generation content (M3), catalog data, and AI.
