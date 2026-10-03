# Instructions for coding agents

- `docs/blueprint.md` is the V1 scope and architecture authority. Work one milestone at a time and
  stop for review at the end of each; do not start the next milestone unprompted.
- Do not change the frozen stack, add deferred features, or invent nutrition/exercise data. Future
  features may appear only as non-interactive, labelled placeholders.
- Record meaningful decisions in `docs/decisions.md` (next free D-number) and keep
  `docs/milestones.md` current with checks actually run. Never report an unexecuted check as passed.
- SQL migrations are the schema authority; add new numbered files, never edit applied ones.
  Domain tables go in schema `app` with RLS (`app.enable_owner_rls`) and explicit grants to
  `noura_api`/`noura_worker` only. Add a negative ownership test for every new user-owned table.
- `packages/contracts/openapi.yaml` is the API authority. Change it first, run
  `pnpm contracts:generate`, and commit the regenerated clients with the change. Mark operations
  `x-noura-status: implemented` only when the route and its tests exist.
- The API derives the user only from the verified token; never accept `user_id` or premium flags
  from clients. Domain queries run through `withUserTransaction` and still filter by `user_id`.
- No secrets in Flutter, in commits, or in logs. Mocks are development-only and must fail closed.
- Before pushing: `pnpm secrets:check && pnpm lint && pnpm typecheck`, the relevant test suites, and
  `flutter analyze && flutter test` for mobile changes. Format Dart with `dart format --line-length 120`.
