# NOURA (working name)

Indian-first nutrition and fitness coach. V1 is specified in [`docs/blueprint.md`](docs/blueprint.md);
progress is tracked in [`docs/milestones.md`](docs/milestones.md) and decisions in
[`docs/decisions.md`](docs/decisions.md).

**Current state: M2 (profile and onboarding) on top of the M1 foundation.** Auth, the app shell, resumable onboarding, profile editing, eligibility, the target-policy framework, API/worker, the database
schema and contracts exist. Later features (plans, scanning, coach, billing…) are
labelled placeholders until their milestones.

```text
apps/mobile      Flutter app (Riverpod, go_router, Dio + generated client)
apps/api         Fastify API: auth, business rules, all domain writes
apps/worker      pg-boss worker (same image, separate process)
packages/contracts  OpenAPI 3.0.3 contract (authority) + generated TS types
packages/domain  Shared TS domain modules (errors, jobs, DB user context)
packages/ai      AI provider adapter (mock in development; fails closed elsewhere)
supabase         SQL migrations (schema authority), config, DB security tests
data             Reserved for licensed catalog data (empty)
```

## Prerequisites

- Node.js 22.12+ (`.nvmrc`) and pnpm 10.28.0 (`corepack enable`)
- Flutter 3.47.5 (Dart 3.13)
- PostgreSQL 16 for tests (any local instance), **or** Docker for the full Supabase CLI stack
- Java 11+ only to regenerate the Dart API client

## Setup

```bash
corepack enable
pnpm install --frozen-lockfile
pnpm -r --filter './packages/*' run build        # shared packages used by API/worker
(cd apps/mobile && flutter pub get --enforce-lockfile)
```

### Option A: full local Supabase (Docker)

```bash
scripts/supabase-local-signing-key.sh            # local ES256 key so tokens verify via JWKS
cp supabase/.env.example supabase/.env           # optional SMS gateway placeholder
pnpm exec supabase start                         # prints the local publishable key
pnpm exec supabase db reset                      # applies supabase/migrations
cp apps/api/.env.example apps/api/.env
cp apps/worker/.env.example apps/worker/.env
pnpm dev:api                                     # http://127.0.0.1:8080/health/ready
pnpm dev:worker                                  # http://127.0.0.1:8081/health/ready
```

### Option B: plain PostgreSQL (no Docker)

```bash
DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:5432/noura_dev pnpm db:reset:local
```

This applies a test-only Supabase shim plus all migrations. It is enough for the API, worker and
tests. Real sign-in (phone + SMS code, D-033) needs a Supabase Auth instance (Option A or a hosted
project); with mocks the code is `123456`.

### Mobile

```bash
cd apps/mobile
cp env/development.example.json env/development.json   # fill in the local publishable key
flutter run --dart-define-from-file=env/development.json

# No backend at all: explicit development mocks (debug builds only, banner shown)
flutter run --dart-define-from-file=env/mock.example.json
```

The Android emulator reaches the host at `10.0.2.2`; use your machine's LAN IP for a physical device.
Never put server secrets in these files: only the API URL, Supabase URL and _publishable_ key.

## Checks

```bash
pnpm secrets:check            # no secrets or server-only settings committed / in the app
pnpm lint                     # eslint + prettier
pnpm contracts:lint           # Redocly
pnpm typecheck
pnpm -r --filter './packages/*' run test
(cd supabase   && DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:5432/noura_db_test     pnpm exec vitest run)
(cd apps/api   && DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:5432/noura_api_test    pnpm exec vitest run)
(cd apps/worker && DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:5432/noura_worker_test pnpm exec vitest run)
pnpm contracts:check          # regenerate TS + Dart clients, fail on drift (needs Java + Flutter)
cd apps/mobile && flutter analyze && flutter test && flutter build web --release --dart-define-from-file=env/development.example.json
```

Each test suite drops and recreates its own local database. The reset script refuses non-local hosts.

## Configuration and secrets

Templates with placeholders only: `apps/api/.env.example`, `apps/worker/.env.example`,
`supabase/.env.example`, `apps/mobile/env/*.example.json`. Real `.env` files and mobile `env/*.json`
are gitignored. Staging/production refuse mocks and missing provider secrets at startup.
Provider setup: [`docs/auth-providers.md`](docs/auth-providers.md). Database roles and release steps:
[`docs/runbooks/database.md`](docs/runbooks/database.md).
