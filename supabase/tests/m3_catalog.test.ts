import { afterAll, describe, expect, it } from 'vitest';
import { adminPool, asRole, createAuthUser } from './support/db.js';

afterAll(async () => {
  await adminPool.end();
});

describe('M3 synthetic test-fixture catalog (D-025)', () => {
  it('is entirely labelled test_fixture and never claims a licensed source', async () => {
    const { rows } = await adminPool.query<{ n: string }>(
      "select count(*)::text as n from app.foods where quality_flag <> 'test_fixture'",
    );
    expect(rows[0]!.n).toBe('0');
    const sources = await adminPool.query<{ license_notes: string }>(
      'select license_notes from app.food_sources',
    );
    for (const row of sources.rows) {
      expect(row.license_notes).toMatch(/NOT A LICENSED NUTRITION SOURCE/);
    }
  });

  it('seeds enough foods and recipes to exercise filtering (blueprint §7)', async () => {
    const foods = await adminPool.query<{ n: string }>('select count(*)::text as n from app.foods');
    const recipes = await adminPool.query<{ n: string }>(
      'select count(*)::text as n from app.recipes',
    );
    expect(Number(foods.rows[0]!.n)).toBeGreaterThanOrEqual(20);
    expect(Number(recipes.rows[0]!.n)).toBeGreaterThanOrEqual(10);
  });

  it('both server roles can read the catalog, neither can write it', async () => {
    const userId = await createAuthUser();
    for (const role of ['noura_api', 'noura_worker'] as const) {
      const { rowCount } = await asRole(role, userId, (c) => c.query('select 1 from app.recipes'));
      expect(rowCount).toBeGreaterThan(0);
      await expect(
        asRole(role, userId, (c) =>
          c.query(
            `update app.recipes set name = 'x' where id = '00000000-0000-4000-a002-000000000001'`,
          ),
        ),
      ).rejects.toThrow(/permission denied/);
    }
  });

  it('has at least one recipe eligible for every diet type and meal slot', async () => {
    const { rows } = await adminPool.query<{ tags: string[]; diet_tags: string[] }>(
      'select tags, diet_tags from app.recipes',
    );
    for (const slot of ['breakfast', 'lunch', 'dinner', 'snack']) {
      for (const diet of ['vegan', 'vegetarian', 'eggatarian', 'non_vegetarian']) {
        const match = rows.some((r) => r.tags.includes(slot) && r.diet_tags.includes(diet));
        expect(match, `expected a ${diet} recipe for ${slot}`).toBe(true);
      }
    }
  });

  it('includes at least one unknown-coverage ingredient to exercise the allergen-safety rule', async () => {
    const { rows } = await adminPool.query<{ n: string }>(
      "select count(*)::text as n from app.foods where allergen_coverage <> 'complete'",
    );
    expect(Number(rows[0]!.n)).toBeGreaterThan(0);
  });

  it('negative: no user-owned table was added for the catalog (shared reference data only)', async () => {
    // Guards against accidentally introducing a user-owned catalog table without RLS + ownership
    // tests (AGENTS.md). The M3 catalog seed only adds rows to the existing M1 shared tables.
    const { rows } = await adminPool.query<{ table_name: string }>(
      `select table_name from information_schema.tables
         where table_schema = 'app' and table_name like '%catalog%'`,
    );
    expect(rows).toEqual([]);
  });
});
