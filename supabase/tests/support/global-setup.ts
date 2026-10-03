// Recreates the plain test database once per run. Requires DATABASE_URL to point at a dedicated,
// local test database (for example postgresql://postgres:postgres@127.0.0.1:5432/noura_test).
// @ts-expect-error -- plain ESM script without type declarations
import { resetPlainDatabase } from '../../scripts/reset-plain.mjs';

export default async function setup(): Promise<void> {
  const url = process.env.DATABASE_URL;
  if (!url) throw new Error('DATABASE_URL must be set for database tests');
  await resetPlainDatabase(url, { log: () => undefined });
}
