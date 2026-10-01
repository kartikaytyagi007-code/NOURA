import { describe, expect, it } from 'vitest';
import {
  isUuid,
  withSystemTransaction,
  withUserTransaction,
  type PoolClientLike,
} from './user-transaction.js';

function fakePool(failOn?: string) {
  const statements: string[] = [];
  let released = false;
  const client: PoolClientLike = {
    async query(text: string) {
      statements.push(text);
      if (failOn && text.includes(failOn)) throw new Error('boom');
      return { rows: [], rowCount: 0 };
    },
    release() {
      released = true;
    },
  };
  return { pool: { connect: async () => client }, statements, isReleased: () => released };
}

const USER = '0d1f8a52-6f2b-4b8e-9a51-6f0f3b0f9a77';

describe('withUserTransaction', () => {
  it('assumes the restricted role and sets the user context before running queries', async () => {
    const { pool, statements, isReleased } = fakePool();
    await withUserTransaction(pool, 'noura_api', USER, (c) => c.query('select 1'));
    expect(statements).toEqual([
      'begin',
      'set local role noura_api',
      "select set_config('noura.user_id', $1, true)",
      'select 1',
      'commit',
    ]);
    expect(isReleased()).toBe(true);
  });

  it('rolls back and rethrows on failure', async () => {
    const { pool, statements } = fakePool('select 1');
    await expect(
      withUserTransaction(pool, 'noura_worker', USER, (c) => c.query('select 1')),
    ).rejects.toThrow('boom');
    expect(statements.at(-1)).toBe('rollback');
  });

  it('rejects non-UUID user ids and unknown roles', async () => {
    const { pool } = fakePool();
    await expect(
      withUserTransaction(pool, 'noura_api', "x'; drop table", async () => 1),
    ).rejects.toThrow(/UUID/);
    await expect(
      withUserTransaction(pool, 'postgres' as never, USER, async () => 1),
    ).rejects.toThrow(/Unsupported/);
  });

  it('validates UUIDs', () => {
    expect(isUuid(USER)).toBe(true);
    expect(isUuid('not-a-uuid')).toBe(false);
  });
});

describe('withSystemTransaction', () => {
  it('assumes the role with the user context explicitly cleared', async () => {
    const { pool, statements } = fakePool();
    await withSystemTransaction(pool, 'noura_worker', (c) => c.query('select 1'));
    expect(statements).toEqual([
      'begin',
      'set local role noura_worker',
      "select set_config('noura.user_id', '', true)",
      'select 1',
      'commit',
    ]);
  });

  it('rolls back on failure and rejects unknown roles', async () => {
    const { pool, statements } = fakePool('select 1');
    await expect(
      withSystemTransaction(pool, 'noura_worker', (c) => c.query('select 1')),
    ).rejects.toThrow('boom');
    expect(statements.at(-1)).toBe('rollback');
    await expect(withSystemTransaction(pool, 'postgres' as never, async () => 1)).rejects.toThrow(
      /Unsupported/,
    );
  });
});
