// @ts-expect-error -- plain ESM script without type declarations
import { resetPlainDatabase } from '../../../supabase/scripts/reset-plain.mjs';

export default async function setup(): Promise<void> {
  const url = process.env.DATABASE_URL;
  if (!url) throw new Error('DATABASE_URL must point at a dedicated local test database');
  await resetPlainDatabase(url, { log: () => undefined });
}
