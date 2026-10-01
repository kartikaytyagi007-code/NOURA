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
