# @noura/contracts

`openapi.yaml` is the API contract authority (blueprint §3, §11).

- `x-noura-status: implemented` operations are registered by the API and validated at runtime
  (request + response schemas are loaded from this file).
- `x-noura-status: planned` operations are drafts for later milestones. They are generated into the
  client so the shape is visible, but the API does not register them.

## Generation

```bash
pnpm contracts:lint        # Redocly lint
pnpm contracts:generate    # TypeScript types + Dart client
pnpm contracts:check       # regenerate and fail if committed output drifted (CI)
```

- TypeScript: `generated/ts/openapi.d.ts` via `openapi-typescript`.
- Dart: `apps/mobile/packages/noura_api_client` via OpenAPI Generator `dart-dio` (pinned in
  `openapitools.json`, requires Java 11+), followed by `build_runner` for `json_serializable`.

## Generator notes

- OpenAPI 3.0.3 is used (not 3.1) because the `dart-dio` generator's 3.1 support is incomplete.
- `nullable` + `$ref` is expressed as `allOf: [$ref] + nullable: true`.
- Webhook payloads use `additionalProperties: true` because they are provider-defined; every
  mutation schema owned by NOURA uses `additionalProperties: false`.
- `json-schema/` is reserved for AI structured-output schemas (M4+, blueprint §12).
