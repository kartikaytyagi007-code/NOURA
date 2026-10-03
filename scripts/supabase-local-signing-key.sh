#!/usr/bin/env bash
# Generates a LOCAL-ONLY ES256 signing key for the Supabase CLI so local access tokens are
# asymmetric and verifiable through JWKS, matching production verification (docs/decisions.md D-007).
# The output file is gitignored. Never reuse this key for staging or production.
set -euo pipefail
cd "$(dirname "$0")/.."
target="supabase/signing_keys.json"
if [[ -f "$target" ]]; then
  echo "$target already exists; leaving it unchanged." >&2
  exit 0
fi
key="$(pnpm exec supabase gen signing-key --algorithm ES256 2>/dev/null)"
printf '[%s]\n' "$key" > "$target"
chmod 600 "$target"
echo "Wrote $target (gitignored)."
