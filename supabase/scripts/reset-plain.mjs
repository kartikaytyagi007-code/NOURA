#!/usr/bin/env node
// Recreates a PLAIN PostgreSQL database and applies the test-only Supabase shim plus every migration
// in filename order. Used by CI and DB tests. Refuses non-local hosts unless explicitly allowed, and
// always refuses when APP_ENV=production. Real Supabase environments use `supabase db reset` (local)
// or reviewed `supabase db push` release steps, never this script.
import { readdir, readFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import pg from 'pg';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '..');

export async function resetPlainDatabase(databaseUrl, { log = console.log } = {}) {
  if (!databaseUrl) throw new Error('DATABASE_URL is required');
  if (process.env.APP_ENV === 'production')
    throw new Error('Refusing to reset a database with APP_ENV=production');
  const url = new URL(databaseUrl);
  const localHosts = new Set(['localhost', '127.0.0.1', '::1', 'postgres']);
  if (!localHosts.has(url.hostname) && process.env.ALLOW_PLAIN_DB_RESET !== '1') {
    throw new Error(`Refusing to reset non-local host ${url.hostname}`);
  }
  const dbName = decodeURIComponent(url.pathname.slice(1));
  if (!/^[a-z0-9_]+$/.test(dbName) || dbName === 'postgres') {
    throw new Error(`Refusing to reset database "${dbName}"; use a dedicated database name`);
  }

  const adminUrl = new URL(databaseUrl);
  adminUrl.pathname = '/postgres';
  const admin = new pg.Client({ connectionString: adminUrl.toString() });
  await admin.connect();
  try {
    await admin.query(`drop database if exists ${dbName} with (force)`);
    await admin.query(`create database ${dbName}`);
  } finally {
    await admin.end();
  }

  const client = new pg.Client({ connectionString: databaseUrl });
  await client.connect();
  try {
    await client.query(await readFile(path.join(root, 'tests/support/supabase_shim.sql'), 'utf8'));
    const files = (await readdir(path.join(root, 'migrations')))
      .filter((f) => f.endsWith('.sql'))
      .sort();
    for (const file of files) {
      const sql = await readFile(path.join(root, 'migrations', file), 'utf8');
      try {
        await client.query(sql);
      } catch (error) {
        throw new Error(`Migration ${file} failed: ${error.message}`, { cause: error });
      }
      log(`applied ${file}`);
    }
    await client.query(await readFile(path.join(root, 'seed.sql'), 'utf8'));
    log(`database ${dbName} ready (${files.length} migrations)`);
  } finally {
    await client.end();
  }
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  resetPlainDatabase(process.env.DATABASE_URL).catch((error) => {
    console.error(error.message);
    process.exit(1);
  });
}
