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
    // Reads are allowed (catalog_read policy); M3 seeds a labelled test_fixture catalog (D-025), so
    // this no longer asserts the table is empty, only that the role can read and never write it.
    const { rowCount } = await asRole('noura_api', userId, (c) =>
      c.query('select 1 from app.foods'),
    );
    expect(rowCount).toBeGreaterThanOrEqual(0);
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

// M4: app.media_assets, app.meal_scans, app.meal_logs and app.meal_log_items are newly active
// user-owned tables this milestone (AGENTS.md requires a negative ownership test for each).
describe('M4 meal-scan/meal-log owner isolation (user A vs user B)', () => {
  let userA: string;
  let userB: string;
  let mediaB: string;
  let scanB: string;
  let logB: string;

  beforeAll(async () => {
    userA = await createAuthUser();
    userB = await createAuthUser();
    mediaB = randomUUID();
    scanB = randomUUID();
    logB = randomUUID();
    await asOwner(async (c) => {
      await c.query(
        `insert into app.media_assets (id, user_id, purpose, bucket, object_path, declared_mime, status)
         values ($1, $2, 'meal', 'meal-images', $3, 'image/png', 'verified')`,
        [mediaB, userB, `${userB}/${mediaB}.png`],
      );
      await c.query(
        `insert into app.meal_scans (id, user_id, media_asset_id, status) values ($1, $2, $3, 'needs_confirmation')`,
        [scanB, userB, mediaB],
      );
      await c.query(
        `insert into app.meal_logs (id, user_id, client_id, consumed_at, local_date, timezone, slot, totals_snapshot)
         values ($1, $2, gen_random_uuid(), now(), current_date, 'UTC', 'lunch', '{}')`,
        [logB, userB],
      );
    });
  });

  it('cannot read user B media, meal scans or meal logs even filtering for them explicitly', async () => {
    const result = await asRole('noura_api', userA, async (c) => {
      const media = await c.query('select 1 from app.media_assets where id = $1', [mediaB]);
      const scans = await c.query('select 1 from app.meal_scans where id = $1', [scanB]);
      const logs = await c.query('select 1 from app.meal_logs where id = $1', [logB]);
      return { media: media.rowCount, scans: scans.rowCount, logs: logs.rowCount };
    });
    expect(result).toEqual({ media: 0, scans: 0, logs: 0 });
  });

  it('cannot update or delete user B media, meal scans or meal logs', async () => {
    const result = await asRole('noura_api', userA, async (c) => {
      const media = await c.query("update app.media_assets set status = 'deleted' where id = $1", [
        mediaB,
      ]);
      const scans = await c.query("update app.meal_scans set status = 'cancelled' where id = $1", [
        scanB,
      ]);
      const logs = await c.query('delete from app.meal_logs where id = $1', [logB]);
      return { media: media.rowCount, scans: scans.rowCount, logs: logs.rowCount };
    });
    expect(result).toEqual({ media: 0, scans: 0, logs: 0 });
    const stillThere = await adminPool.query('select id from app.meal_logs where id = $1', [logB]);
    expect(stillThere.rowCount).toBe(1);
  });

  it('cannot insert a meal scan or meal log owned by user B (client-supplied user_id is rejected)', async () => {
    await expect(
      asRole('noura_api', userA, (c) =>
        c.query(
          "insert into app.meal_scans (user_id, media_asset_id, status) values ($1, $2, 'queued')",
          [userB, mediaB],
        ),
      ),
    ).rejects.toThrow(/row-level security/);
    await expect(
      asRole('noura_api', userA, (c) =>
        c.query(
          `insert into app.meal_logs (user_id, client_id, consumed_at, local_date, timezone, slot, totals_snapshot)
           values ($1, gen_random_uuid(), now(), current_date, 'UTC', 'dinner', '{}')`,
          [userB],
        ),
      ),
    ).rejects.toThrow(/row-level security/);
  });

  it('applies the same isolation to the worker role for meal scans', async () => {
    const { rowCount } = await asRole('noura_worker', userA, (c) =>
      c.query('select 1 from app.meal_scans where id = $1', [scanB]),
    );
    expect(rowCount).toBe(0);
  });
});

// M6: app.dismissed_recommendations is a newly active user-owned table this milestone (AGENTS.md
// requires a negative ownership test for each).
describe('M6 dismissed-recommendation owner isolation (user A vs user B)', () => {
  it('cannot read, insert-as or delete user B dismissals', async () => {
    const userA = await createAuthUser();
    const userB = await createAuthUser();
    await asOwner((c) =>
      c.query(
        `insert into app.dismissed_recommendations (user_id, local_date, slot) values ($1, current_date, 'lunch')`,
        [userB],
      ),
    );
    const result = await asRole('noura_api', userA, async (c) => {
      const rows = await c.query('select 1 from app.dismissed_recommendations where user_id = $1', [
        userB,
      ]);
      const deleted = await c.query(
        'delete from app.dismissed_recommendations where user_id = $1',
        [userB],
      );
      return { rows: rows.rowCount, deleted: deleted.rowCount };
    });
    expect(result).toEqual({ rows: 0, deleted: 0 });

    await expect(
      asRole('noura_api', userA, (c) =>
        c.query(
          `insert into app.dismissed_recommendations (user_id, local_date, slot) values ($1, current_date, 'dinner')`,
          [userB],
        ),
      ),
    ).rejects.toThrow(/row-level security/);

    const stillThere = await adminPool.query(
      'select 1 from app.dismissed_recommendations where user_id = $1',
      [userB],
    );
    expect(stillThere.rowCount).toBe(1);
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

// M7: app.workout_plans/workout_plan_sessions/workout_plan_exercises/workout_logs/workout_set_logs
// exist since M1 but become actively used for the first time this milestone (AGENTS.md requires a
// negative ownership test for each table that becomes actively used).
describe('M7 workout plan/session/log owner isolation (user A vs user B)', () => {
  let userA: string;
  let userB: string;
  let planB: string;
  let sessionB: string;
  let exerciseRowB: string;
  let logB: string;
  let exerciseCatalogId: string;

  beforeAll(async () => {
    userA = await createAuthUser();
    userB = await createAuthUser();
    planB = randomUUID();
    sessionB = randomUUID();
    exerciseRowB = randomUUID();
    logB = randomUUID();
    const catalog = await adminPool.query<{ id: string }>('select id from app.exercises limit 1');
    exerciseCatalogId = catalog.rows[0]!.id;
    await asOwner(async (c) => {
      await c.query(
        `insert into app.workout_plans (id, user_id, version, profile_revision, starts_on, status)
         values ($1, $2, 1, 1, current_date, 'active')`,
        [planB, userB],
      );
      await c.query(
        `insert into app.workout_plan_sessions (id, user_id, plan_id, session_date, session_order, title)
         values ($1, $2, $3, current_date, 1, 'Full-body session')`,
        [sessionB, userB, planB],
      );
      await c.query(
        `insert into app.workout_plan_exercises
           (id, user_id, session_id, exercise_id, ordinal, sets, reps_min, reps_max, rest_sec)
         values ($1, $2, $3, $4, 1, 3, 8, 12, 60)`,
        [exerciseRowB, userB, sessionB, exerciseCatalogId],
      );
      await c.query(
        `insert into app.workout_logs (id, user_id, client_id, session_id, status)
         values ($1, $2, gen_random_uuid(), $3, 'in_progress')`,
        [logB, userB, sessionB],
      );
      await c.query(
        `insert into app.workout_set_logs (user_id, workout_log_id, exercise_id, set_ordinal, reps, skipped)
         values ($1, $2, $3, 1, 10, false)`,
        [userB, logB, exerciseCatalogId],
      );
    });
  });

  it('cannot read user B workout plans, sessions, exercises, logs or set logs', async () => {
    const result = await asRole('noura_api', userA, async (c) => {
      const plans = await c.query('select 1 from app.workout_plans where id = $1', [planB]);
      const sessions = await c.query('select 1 from app.workout_plan_sessions where id = $1', [
        sessionB,
      ]);
      const exercises = await c.query('select 1 from app.workout_plan_exercises where id = $1', [
        exerciseRowB,
      ]);
      const logs = await c.query('select 1 from app.workout_logs where id = $1', [logB]);
      const sets = await c.query('select 1 from app.workout_set_logs where workout_log_id = $1', [
        logB,
      ]);
      return {
        plans: plans.rowCount,
        sessions: sessions.rowCount,
        exercises: exercises.rowCount,
        logs: logs.rowCount,
        sets: sets.rowCount,
      };
    });
    expect(result).toEqual({ plans: 0, sessions: 0, exercises: 0, logs: 0, sets: 0 });
  });

  it('cannot update or delete user B workout rows', async () => {
    const result = await asRole('noura_api', userA, async (c) => {
      const plans = await c.query(
        "update app.workout_plans set status = 'cancelled' where id = $1",
        [planB],
      );
      const logs = await c.query('delete from app.workout_logs where id = $1', [logB]);
      return { plans: plans.rowCount, logs: logs.rowCount };
    });
    expect(result).toEqual({ plans: 0, logs: 0 });
    const stillThere = await adminPool.query('select id from app.workout_plans where id = $1', [
      planB,
    ]);
    expect(stillThere.rowCount).toBe(1);
  });

  it('cannot insert a workout plan or log owned by user B (client-supplied user_id is rejected)', async () => {
    await expect(
      asRole('noura_api', userA, (c) =>
        c.query(
          `insert into app.workout_plans (user_id, version, profile_revision, starts_on, status)
           values ($1, 99, 1, current_date, 'draft')`,
          [userB],
        ),
      ),
    ).rejects.toThrow(/row-level security/);
    await expect(
      asRole('noura_api', userA, (c) =>
        c.query(
          `insert into app.workout_logs (user_id, client_id, session_id) values ($1, gen_random_uuid(), $2)`,
          [userB, sessionB],
        ),
      ),
    ).rejects.toThrow(/row-level security/);
  });

  it('applies the same isolation to the worker role', async () => {
    const { rowCount } = await asRole('noura_worker', userA, (c) =>
      c.query('select 1 from app.workout_plans where id = $1', [planB]),
    );
    expect(rowCount).toBe(0);
  });
});

describe('M8 weight-log/progress-photo owner isolation (user A vs user B)', () => {
  let userA: string;
  let userB: string;
  let weightLogB: string;
  let mediaAssetB: string;
  let progressPhotoB: string;

  beforeAll(async () => {
    userA = await createAuthUser();
    userB = await createAuthUser();
    weightLogB = randomUUID();
    mediaAssetB = randomUUID();
    progressPhotoB = randomUUID();
    await asOwner(async (c) => {
      await c.query(
        `insert into app.weight_logs (id, user_id, client_id, measured_at, weight_kg)
         values ($1, $2, gen_random_uuid(), now(), 70)`,
        [weightLogB, userB],
      );
      await c.query(
        `insert into app.media_assets (id, user_id, purpose, bucket, object_path, declared_mime, status)
         values ($1, $2, 'progress_photo', 'progress-photos', $3, 'image/jpeg', 'verified')`,
        [mediaAssetB, userB, `${userB}/${mediaAssetB}.jpg`],
      );
      await c.query(
        `insert into app.progress_photos (id, user_id, media_asset_id, captured_at, angle)
         values ($1, $2, $3, now(), 'front')`,
        [progressPhotoB, userB, mediaAssetB],
      );
    });
  });

  it('cannot read user B weight logs or progress photos even filtering for them explicitly', async () => {
    const result = await asRole('noura_api', userA, async (c) => {
      const weights = await c.query('select 1 from app.weight_logs where id = $1', [weightLogB]);
      const photos = await c.query('select 1 from app.progress_photos where id = $1', [
        progressPhotoB,
      ]);
      return { weights: weights.rowCount, photos: photos.rowCount };
    });
    expect(result).toEqual({ weights: 0, photos: 0 });
  });

  it('cannot update or delete user B weight logs or progress photos', async () => {
    const result = await asRole('noura_api', userA, async (c) => {
      const weights = await c.query('delete from app.weight_logs where id = $1', [weightLogB]);
      const photos = await c.query('delete from app.progress_photos where id = $1', [
        progressPhotoB,
      ]);
      return { weights: weights.rowCount, photos: photos.rowCount };
    });
    expect(result).toEqual({ weights: 0, photos: 0 });
    const stillThere = await adminPool.query('select id from app.weight_logs where id = $1', [
      weightLogB,
    ]);
    expect(stillThere.rowCount).toBe(1);
  });

  it('cannot insert a weight log or progress photo owned by user B (client-supplied user_id is rejected)', async () => {
    await expect(
      asRole('noura_api', userA, (c) =>
        c.query(
          `insert into app.weight_logs (user_id, client_id, measured_at, weight_kg)
           values ($1, gen_random_uuid(), now(), 65)`,
          [userB],
        ),
      ),
    ).rejects.toThrow(/row-level security/);
    await expect(
      asRole('noura_api', userA, (c) =>
        c.query(
          `insert into app.progress_photos (user_id, media_asset_id, captured_at, angle)
           values ($1, $2, now(), 'front')`,
          [userB, mediaAssetB],
        ),
      ),
    ).rejects.toThrow(/row-level security/);
  });

  it('applies the same isolation to the worker role', async () => {
    const { rowCount } = await asRole('noura_worker', userA, (c) =>
      c.query('select 1 from app.weight_logs where id = $1', [weightLogB]),
    );
    expect(rowCount).toBe(0);
  });
});

describe('M9 coach thread/message/action-proposal owner isolation (user A vs user B)', () => {
  let userA: string;
  let userB: string;
  let threadB: string;
  let messageB: string;
  let proposalB: string;

  beforeAll(async () => {
    userA = await createAuthUser();
    userB = await createAuthUser();
    threadB = randomUUID();
    messageB = randomUUID();
    proposalB = randomUUID();
    await asOwner(async (c) => {
      await c.query('insert into app.coach_threads (id, user_id) values ($1, $2)', [
        threadB,
        userB,
      ]);
      await c.query(
        `insert into app.coach_messages (id, user_id, thread_id, role, content, status)
         values ($1, $2, $3, 'user', 'hello', 'completed')`,
        [messageB, userB, threadB],
      );
      await c.query(
        `insert into app.action_proposals
           (id, user_id, thread_id, message_id, proposal_type, payload, expected_plan_revision, expires_at)
         values ($1, $2, $3, $4, 'swap_meal', '{}'::jsonb, 1, now() + interval '15 minutes')`,
        [proposalB, userB, threadB, messageB],
      );
    });
  });

  it('cannot read user B coach threads, messages or action proposals even filtering explicitly', async () => {
    const result = await asRole('noura_api', userA, async (c) => {
      const threads = await c.query('select 1 from app.coach_threads where id = $1', [threadB]);
      const messages = await c.query('select 1 from app.coach_messages where id = $1', [messageB]);
      const proposals = await c.query('select 1 from app.action_proposals where id = $1', [
        proposalB,
      ]);
      return {
        threads: threads.rowCount,
        messages: messages.rowCount,
        proposals: proposals.rowCount,
      };
    });
    expect(result).toEqual({ threads: 0, messages: 0, proposals: 0 });
  });

  it('cannot update or delete user B coach rows', async () => {
    const result = await asRole('noura_api', userA, async (c) => {
      const threads = await c.query('delete from app.coach_threads where id = $1', [threadB]);
      const messages = await c.query('delete from app.coach_messages where id = $1', [messageB]);
      const proposals = await c.query('delete from app.action_proposals where id = $1', [
        proposalB,
      ]);
      return {
        threads: threads.rowCount,
        messages: messages.rowCount,
        proposals: proposals.rowCount,
      };
    });
    expect(result).toEqual({ threads: 0, messages: 0, proposals: 0 });
    const stillThere = await adminPool.query('select id from app.coach_threads where id = $1', [
      threadB,
    ]);
    expect(stillThere.rowCount).toBe(1);
  });

  it('cannot insert a coach thread/message owned by user B (client-supplied user_id is rejected)', async () => {
    await expect(
      asRole('noura_api', userA, (c) =>
        c.query('insert into app.coach_threads (user_id) values ($1)', [userB]),
      ),
    ).rejects.toThrow(/row-level security/);
    await expect(
      asRole('noura_api', userA, (c) =>
        c.query(
          `insert into app.coach_messages (user_id, thread_id, role, content, status)
           values ($1, $2, 'user', 'hi', 'completed')`,
          [userB, threadB],
        ),
      ),
    ).rejects.toThrow(/row-level security/);
  });

  it('cannot attach a message to another user’s thread even as its own owner', async () => {
    await asOwner(async (c) => {
      await c.query('insert into app.coach_threads (id, user_id) values ($1, $2)', [
        randomUUID(),
        userA,
      ]);
    });
    await expect(
      asRole('noura_api', userA, (c) =>
        c.query(
          `insert into app.coach_messages (user_id, thread_id, role, content, status)
           values ($1, $2, 'user', 'hi', 'completed')`,
          [userA, threadB],
        ),
      ),
    ).rejects.toThrow(/coach_messages_thread_owner|row-level security/);
  });

  it('applies the same isolation to the worker role', async () => {
    const { rowCount } = await asRole('noura_worker', userA, (c) =>
      c.query('select 1 from app.coach_messages where id = $1', [messageB]),
    );
    expect(rowCount).toBe(0);
  });
});

describe('M8 progress-photo retention (D-030: no auto-expiry, unlike meal images)', () => {
  it('a progress-photo media asset gets no expires_at, while a meal-image asset does', async () => {
    const userId = await createAuthUser();
    const progressId = randomUUID();
    const mealId = randomUUID();
    await asOwner(async (c) => {
      await c.query(
        `insert into app.media_assets (id, user_id, purpose, bucket, object_path, declared_mime, expires_at)
         values ($1, $2, 'progress_photo', 'progress-photos', $3, 'image/jpeg', null)`,
        [progressId, userId, `${userId}/${progressId}.jpg`],
      );
      await c.query(
        `insert into app.media_assets (id, user_id, purpose, bucket, object_path, declared_mime, expires_at)
         values ($1, $2, 'meal', 'meal-images', $3, 'image/jpeg', now() + interval '30 days')`,
        [mealId, userId, `${userId}/${mealId}.jpg`],
      );
    });
    const { rows } = await adminPool.query<{ id: string; expires_at: Date | null }>(
      'select id, expires_at from app.media_assets where id = any($1::uuid[])',
      [[progressId, mealId]],
    );
    expect(rows.find((r) => r.id === progressId)?.expires_at).toBeNull();
    expect(rows.find((r) => r.id === mealId)?.expires_at).not.toBeNull();
  });
});

describe('M10 entitlements/usage/export/deletion owner isolation (user A vs user B)', () => {
  let userA: string;
  let userB: string;
  let exportB: string;
  let deletionB: string;

  beforeAll(async () => {
    userA = await createAuthUser();
    userB = await createAuthUser();
    exportB = randomUUID();
    deletionB = randomUUID();
    await asOwner(async (c) => {
      await c.query(
        `insert into app.entitlements (user_id, entitlement_key, provider_status, is_active, last_verified_at)
         values ($1, 'premium', 'active', true, now())`,
        [userB],
      );
      await c.query(
        `insert into app.usage_reservations (user_id, feature, quota_period, request_id, state, expires_at)
         values ($1, 'meal_scan', '2026-01-01', $2, 'reserved', now() + interval '1 day')`,
        [userB, randomUUID()],
      );
      await c.query(
        `insert into app.export_requests (id, user_id, state) values ($1, $2, 'queued')`,
        [exportB, userB],
      );
      await c.query(
        `insert into app.deletion_requests (id, user_id, state) values ($1, $2, 'requested')`,
        [deletionB, userB],
      );
    });
  });

  it('cannot read, update or insert another user’s entitlements or usage reservations', async () => {
    const reads = await asRole('noura_api', userA, async (c) => {
      const ent = await c.query('select 1 from app.entitlements where user_id = $1', [userB]);
      const usage = await c.query('select 1 from app.usage_reservations where user_id = $1', [
        userB,
      ]);
      return { ent: ent.rowCount, usage: usage.rowCount };
    });
    expect(reads).toEqual({ ent: 0, usage: 0 });

    await expect(
      asRole('noura_api', userA, (c) =>
        c.query(
          `insert into app.entitlements (user_id, entitlement_key, provider_status, is_active, last_verified_at)
           values ($1, 'premium', 'active', true, now())`,
          [userB],
        ),
      ),
    ).rejects.toThrow(/row-level security/);
  });

  it('cannot read or dispatch-update another user’s export/deletion requests through the API role', async () => {
    const reads = await asRole('noura_api', userA, async (c) => {
      const exp = await c.query('select 1 from app.export_requests where id = $1', [exportB]);
      const del = await c.query('select 1 from app.deletion_requests where id = $1', [deletionB]);
      return { exp: exp.rowCount, del: del.rowCount };
    });
    expect(reads).toEqual({ exp: 0, del: 0 });
  });

  it('lets the worker relay see and dispatch any still-queued export/deletion request, but guards every other column', async () => {
    const seen = await asRole('noura_worker', null, async (c) => {
      const exp = await c.query('select 1 from app.export_requests where id = $1', [exportB]);
      const del = await c.query('select 1 from app.deletion_requests where id = $1', [deletionB]);
      return { exp: exp.rowCount, del: del.rowCount };
    });
    expect(seen).toEqual({ exp: 1, del: 1 });

    await expect(
      asRole('noura_worker', null, (c) =>
        c.query(`update app.export_requests set state = 'completed' where id = $1`, [exportB]),
      ),
    ).rejects.toThrow(/relay may only record queue dispatch/);
    await expect(
      asRole('noura_worker', null, (c) =>
        c.query(`update app.deletion_requests set state = 'completed' where id = $1`, [deletionB]),
      ),
    ).rejects.toThrow(/relay may only record queue dispatch/);

    // The dispatch columns themselves are allowed.
    await asRole('noura_worker', null, (c) =>
      c.query(
        `update app.export_requests set queue_name = 'account.export', queue_job_id = $1 where id = $1`,
        [exportB],
      ),
    );
  });

  it('once a request is no longer queued, the relay-visibility policy no longer matches it', async () => {
    await asOwner((c) =>
      c.query(`update app.export_requests set state = 'completed' where id = $1`, [exportB]),
    );
    const { rowCount } = await asRole('noura_worker', null, (c) =>
      c.query('select 1 from app.export_requests where id = $1', [exportB]),
    );
    expect(rowCount).toBe(0);
  });
});
