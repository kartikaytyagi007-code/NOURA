import { randomUUID } from 'node:crypto';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { adminPool, asOwner, asRole, createAuthUser } from './support/db.js';

afterAll(async () => {
  await adminPool.end();
});

describe('schema-level security posture', () => {
  it('enables RLS with an owner policy on every table that has a user_id column', async () => {
    const { rows } = await adminPool.query<{
      table_name: string;
      rls: boolean;
      has_owner_policy: boolean;
    }>(`
      select c.relname as table_name,
             c.relrowsecurity as rls,
             exists (
               select 1 from pg_policies p
               where p.schemaname = 'app' and p.tablename = c.relname
                 and p.qual like '%request_user_id()%' and p.with_check like '%request_user_id()%'
             ) as has_owner_policy
      from pg_class c
      join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'app' and c.relkind = 'r'
        and exists (select 1 from information_schema.columns col
                    where col.table_schema = 'app' and col.table_name = c.relname and col.column_name = 'user_id')
        and c.relname <> 'billing_events'
    `);
    expect(rows.length).toBeGreaterThan(25);
    const missing = rows.filter((r) => !r.rls || !r.has_owner_policy).map((r) => r.table_name);
    expect(missing).toEqual([]);
  });

  it('enables RLS on every table in schema app', async () => {
    const { rows } = await adminPool.query<{ relname: string }>(`
      select c.relname from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'app' and c.relkind = 'r' and not c.relrowsecurity
    `);
    expect(rows).toEqual([]);
  });

  it('gives mobile roles (anon, authenticated) no privileges on schema app or its tables', async () => {
    const { rows } = await adminPool.query(`
      select grantee, table_name, privilege_type from information_schema.role_table_grants
      where table_schema = 'app' and grantee in ('anon', 'authenticated', 'PUBLIC')
    `);
    expect(rows).toEqual([]);
    const usage = await adminPool.query<{ anon: boolean; authed: boolean }>(`
      select has_schema_privilege('anon', 'app', 'USAGE') as anon,
             has_schema_privilege('authenticated', 'app', 'USAGE') as authed
    `);
    expect(usage.rows[0]).toEqual({ anon: false, authed: false });
  });

  it('keeps server roles restricted: no login, no superuser, no RLS bypass', async () => {
    const { rows } = await adminPool.query(`
      select rolname, rolcanlogin, rolsuper, rolbypassrls from pg_roles
      where rolname in ('noura_api', 'noura_worker') order by rolname
    `);
    expect(rows).toEqual([
      { rolname: 'noura_api', rolcanlogin: false, rolsuper: false, rolbypassrls: false },
      { rolname: 'noura_worker', rolcanlogin: false, rolsuper: false, rolbypassrls: false },
    ]);
  });

  it('denies a mobile role direct access to domain tables', async () => {
    const userId = await createAuthUser();
    await expect(
      asRole('authenticated', userId, (c) => c.query('select * from app.profiles')),
    ).rejects.toThrow(/permission denied/);
    await expect(
      asRole('anon', null, (c) => c.query('select * from app.meal_logs')),
    ).rejects.toThrow(/permission denied/);
  });

  it('makes the catalog read-only for the API role', async () => {
    const userId = await createAuthUser();
    await expect(
      asRole('noura_api', userId, (c) =>
        c.query(
          "insert into app.food_sources (source_name, source_version, license_notes, acquired_at) values ('x', '1', 'x', now())",
        ),
      ),
    ).rejects.toThrow(/permission denied/);
    const { rowCount } = await asRole('noura_api', userId, (c) =>
      c.query('select 1 from app.foods'),
    );
    expect(rowCount).toBe(0);
  });

  it('does not let the API role delete audit-like records', async () => {
    const userId = await createAuthUser();
    await expect(
      asRole('noura_api', userId, (c) => c.query('delete from app.consent_records')),
    ).rejects.toThrow(/permission denied/);
  });
});

describe('owner isolation through RLS (user A vs user B)', () => {
  let userA: string;
  let userB: string;

  beforeAll(async () => {
    userA = await createAuthUser();
    userB = await createAuthUser();
    await asOwner(async (c) => {
      await c.query(
        "insert into app.profiles (user_id, display_name) values ($1, 'A'), ($2, 'B')",
        [userA, userB],
      );
      await c.query(
        `insert into app.weight_logs (user_id, client_id, measured_at, weight_kg)
         values ($1, gen_random_uuid(), now(), 70), ($2, gen_random_uuid(), now(), 80)`,
        [userA, userB],
      );
    });
  });

  it('returns only the current user rows', async () => {
    const rows = await asRole('noura_api', userA, async (c) => {
      const profiles = await c.query('select user_id from app.profiles');
      const weights = await c.query('select user_id from app.weight_logs');
      return [...profiles.rows, ...weights.rows].map((r: { user_id: string }) => r.user_id);
    });
    expect(rows.length).toBe(2);
    expect(new Set(rows)).toEqual(new Set([userA]));
  });

  it('cannot read user B rows even when filtering for them explicitly', async () => {
    const { rowCount } = await asRole('noura_api', userA, (c) =>
      c.query('select * from app.profiles where user_id = $1', [userB]),
    );
    expect(rowCount).toBe(0);
  });

  it('cannot update or delete user B rows', async () => {
    const result = await asRole('noura_api', userA, async (c) => {
      const updated = await c.query(
        "update app.profiles set display_name = 'hacked' where user_id = $1",
        [userB],
      );
      const deleted = await c.query('delete from app.weight_logs where user_id = $1', [userB]);
      return { updated: updated.rowCount, deleted: deleted.rowCount };
    });
    expect(result).toEqual({ updated: 0, deleted: 0 });
    const check = await adminPool.query(
      'select display_name from app.profiles where user_id = $1',
      [userB],
    );
    expect(check.rows[0].display_name).toBe('B');
  });

  it('cannot insert rows owned by user B (client-supplied user_id is rejected)', async () => {
    await expect(
      asRole('noura_api', userA, (c) =>
        c.query(
          'insert into app.weight_logs (user_id, client_id, measured_at, weight_kg) values ($1, gen_random_uuid(), now(), 60)',
          [userB],
        ),
      ),
    ).rejects.toThrow(/row-level security/);
  });

  it('cannot re-assign an owned row to user B', async () => {
    await expect(
      asRole('noura_api', userA, (c) =>
        c.query('update app.weight_logs set user_id = $1 where user_id = $2', [userB, userA]),
      ),
    ).rejects.toThrow(/row-level security/);
  });

  it('sees nothing and can write nothing without a verified user context (fail closed)', async () => {
    const { rowCount } = await asRole('noura_api', null, (c) =>
      c.query('select * from app.profiles'),
    );
    expect(rowCount).toBe(0);
    await expect(
      asRole('noura_worker', null, (c) =>
        c.query(
          'insert into app.weight_logs (user_id, client_id, measured_at, weight_kg) values ($1, gen_random_uuid(), now(), 60)',
          [userA],
        ),
      ),
    ).rejects.toThrow(/row-level security/);
  });

  it('applies the same isolation to the worker role', async () => {
    const { rows } = await asRole('noura_worker', userB, (c) =>
      c.query('select user_id from app.weight_logs'),
    );
    expect(rows.map((r: { user_id: string }) => r.user_id)).toEqual([userB]);
  });
});

describe('child rows cannot attach to another user parent', () => {
  it('rejects a meal_log_item for user A pointing at user B meal_log', async () => {
    const userA = await createAuthUser();
    const userB = await createAuthUser();
    const logB = randomUUID();
    await asOwner((c) =>
      c.query(
        `insert into app.meal_logs (id, user_id, client_id, consumed_at, local_date, timezone, slot, totals_snapshot)
         values ($1, $2, gen_random_uuid(), now(), current_date, 'Asia/Kolkata', 'lunch', '{}')`,
        [logB, userB],
      ),
    );
    await expect(
      asRole('noura_api', userA, (c) =>
        c.query(
          `insert into app.meal_log_items (user_id, meal_log_id, label, provenance) values ($1, $2, 'rice', '{}')`,
          [userA, logB],
        ),
      ),
    ).rejects.toThrow(/foreign key/);
  });

  it('rejects a media asset whose storage path is not under the owner uuid', async () => {
    const userA = await createAuthUser();
    const userB = await createAuthUser();
    const mediaId = randomUUID();
    await expect(
      asRole('noura_api', userA, (c) =>
        c.query(
          `insert into app.media_assets (id, user_id, purpose, bucket, object_path, declared_mime)
           values ($1, $2, 'meal', 'meal-images', $3, 'image/jpeg')`,
          [mediaId, userA, `${userB}/${mediaId}.jpg`],
        ),
      ),
    ).rejects.toThrow(/media_assets_owner_path/);
  });
});

describe('integrity constraints used by later milestones', () => {
  it('allows only one active plan generation per user and type', async () => {
    const userId = await createAuthUser();
    await expect(
      asRole('noura_api', userId, async (c) => {
        await c.query(
          "insert into app.generation_requests (user_id, request_type) values ($1, 'diet_plan')",
          [userId],
        );
        await c.query(
          "insert into app.generation_requests (user_id, request_type) values ($1, 'diet_plan')",
          [userId],
        );
      }),
    ).rejects.toThrow(/generation_requests_one_active_plan_job/);
  });

  it('deduplicates offline drafts by (user_id, client_id)', async () => {
    const userId = await createAuthUser();
    const clientId = randomUUID();
    await expect(
      asRole('noura_api', userId, async (c) => {
        const sql =
          'insert into app.weight_logs (user_id, client_id, measured_at, weight_kg) values ($1, $2, now(), 70)';
        await c.query(sql, [userId, clientId]);
        await c.query(sql, [userId, clientId]);
      }),
    ).rejects.toThrow(/weight_logs_client_unique/);
  });

  it('keeps unknown nutrition as NULL rather than defaulting to zero', async () => {
    const { rows } = await adminPool.query(`
      select column_name, column_default, is_nullable from information_schema.columns
      where table_schema = 'app' and table_name = 'foods' and column_name like '%per_100g'
    `);
    expect(rows.length).toBeGreaterThanOrEqual(5);
    for (const row of rows) {
      expect(row.is_nullable).toBe('YES');
      expect(row.column_default).toBeNull();
    }
  });

  it('has no AI analysis columns on progress photos', async () => {
    const { rows } = await adminPool.query<{ column_name: string }>(`
      select column_name from information_schema.columns where table_schema = 'app' and table_name = 'progress_photos'
    `);
    expect(rows.map((r) => r.column_name).sort()).toEqual(
      ['angle', 'captured_at', 'created_at', 'id', 'media_asset_id', 'user_id'].sort(),
    );
  });
});

describe('private storage', () => {
  it('creates the three buckets as private with size and MIME limits', async () => {
    const { rows } = await adminPool.query(
      'select id, public, file_size_limit, allowed_mime_types from storage.buckets order by id',
    );
    expect(rows.map((r) => r.id)).toEqual(['exports', 'meal-images', 'progress-photos']);
    for (const row of rows) {
      expect(row.public).toBe(false);
      expect(Number(row.file_size_limit)).toBeGreaterThan(0);
      expect(row.allowed_mime_types.length).toBeGreaterThan(0);
    }
  });

  it('defines no storage.objects policy for mobile roles, so direct object access is denied', async () => {
    const { rows } = await adminPool.query(`
      select policyname, roles from pg_policies where schemaname = 'storage' and tablename = 'objects'
    `);
    expect(rows).toEqual([]);
    const userA = await createAuthUser();
    const userB = await createAuthUser();
    await asOwner((c) =>
      c.query(
        "insert into storage.objects (bucket_id, name, owner) values ('meal-images', $1, $2)",
        [`${userB}/${randomUUID()}.jpg`, userB],
      ),
    );
    const { rowCount } = await asRole('authenticated', userA, (c) =>
      c.query('select * from storage.objects'),
    );
    expect(rowCount).toBe(0);
  });
});
