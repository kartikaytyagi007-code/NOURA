import { afterAll, describe, expect, it } from 'vitest';
import { adminPool, asRole, createAuthUser } from './support/db.js';

afterAll(async () => {
  await adminPool.end();
});

describe('M7 synthetic test-fixture exercise catalog (D-029)', () => {
  it('is entirely labelled test_fixture and never claims a licensed source', async () => {
    const { rows } = await adminPool.query<{ n: string }>(
      "select count(*)::text as n from app.exercises where quality_flag <> 'test_fixture'",
    );
    expect(rows[0]!.n).toBe('0');
  });

  it('seeds enough exercises across movement patterns to exercise generation (blueprint §11)', async () => {
    const { rows } = await adminPool.query<{ n: string }>(
      'select count(*)::text as n from app.exercises',
    );
    expect(Number(rows[0]!.n)).toBeGreaterThanOrEqual(20);
    const patterns = await adminPool.query<{ movement_pattern: string }>(
      'select distinct movement_pattern from app.exercises',
    );
    for (const p of ['squat', 'hinge', 'horizontal_push', 'horizontal_pull', 'core']) {
      expect(patterns.rows.map((r) => r.movement_pattern)).toContain(p);
    }
  });

  it('has at least one bodyweight (no-equipment) exercise per core movement pattern, for home-only users', async () => {
    const { rows } = await adminPool.query<{ movement_pattern: string }>(
      "select distinct movement_pattern from app.exercises where equipment_tags = '{}'",
    );
    for (const p of ['squat', 'hinge', 'horizontal_push', 'core']) {
      expect(rows.map((r) => r.movement_pattern)).toContain(p);
    }
  });

  it('declares at least one substitution relationship', async () => {
    const { rows } = await adminPool.query<{ n: string }>(
      'select count(*)::text as n from app.exercise_substitutions',
    );
    expect(Number(rows[0]!.n)).toBeGreaterThan(0);
  });

  it('both server roles can read the catalog, neither can write it', async () => {
    const userId = await createAuthUser();
    for (const role of ['noura_api', 'noura_worker'] as const) {
      const { rowCount } = await asRole(role, userId, (c) =>
        c.query('select 1 from app.exercises'),
      );
      expect(rowCount).toBeGreaterThan(0);
      await expect(
        asRole(role, userId, (c) =>
          c.query(
            `update app.exercises set name = 'x' where id = '00000000-0000-4000-b001-000000000001'`,
          ),
        ),
      ).rejects.toThrow(/permission denied/);
    }
  });
});
