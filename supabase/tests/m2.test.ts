import { randomUUID } from 'node:crypto';
import { afterAll, describe, expect, it } from 'vitest';
import { adminPool, asOwner, asRole, createAuthUser } from './support/db.js';

afterAll(async () => {
  await adminPool.end();
});

async function profileFor(userId: string) {
  await asOwner((c) => c.query('insert into app.profiles (user_id) values ($1)', [userId]));
}

async function queuedRequest(userId: string, type = 'diet_plan') {
  const { rows } = await asOwner((c) =>
    c.query<{ id: string }>(
      `insert into app.generation_requests (user_id, request_type, input_revision)
       values ($1, $2, 2) returning id`,
      [userId, type],
    ),
  );
  return rows[0]!.id;
}

describe('M2 profile columns and constraints', () => {
  it('stores weight and bounds it to the plausibility range', async () => {
    const userId = await createAuthUser();
    await profileFor(userId);
    await asRole('noura_api', userId, async (c) => {
      await c.query('update app.profiles set weight_kg = 72.5 where user_id = $1', [userId]);
      const { rows } = await c.query(
        'select weight_kg::text from app.profiles where user_id = $1',
        [userId],
      );
      expect(rows[0]).toEqual({ weight_kg: '72.50' });
    });
    for (const bad of [19.99, 400.01]) {
      await expect(
        asRole('noura_api', userId, (c) =>
          c.query('update app.profiles set weight_kg = $2 where user_id = $1', [userId, bad]),
        ),
      ).rejects.toThrow(/weight_kg/);
    }
  });

  it('only allows the minimal screening flag vocabulary', async () => {
    const userId = await createAuthUser();
    await profileFor(userId);
    await asRole('noura_api', userId, (c) =>
      c.query(
        "update app.profiles set screening_flags = array['medical_diet_condition', 'eating_disorder_concern:declined'] where user_id = $1",
        [userId],
      ),
    );
    await expect(
      asRole('noura_api', userId, (c) =>
        c.query(
          "update app.profiles set screening_flags = array['diagnosis_details'] where user_id = $1",
          [userId],
        ),
      ),
    ).rejects.toThrow(/screening_flags_vocabulary/);
  });

  it('refuses to mark onboarding completed without weight or answered screening', async () => {
    const userId = await createAuthUser();
    await profileFor(userId);
    const core = `display_name = 'Asha', age_years = 30, height_cm = 165, activity_band = 'light',
                  eligibility_status = 'eligible', onboarding_status = 'completed'`;
    await expect(
      asRole('noura_api', userId, (c) =>
        c.query(
          `update app.profiles set ${core}, screening_answered_at = now() where user_id = $1`,
          [userId],
        ),
      ),
    ).rejects.toThrow(/completed_requires_core/);
    await expect(
      asRole('noura_api', userId, (c) =>
        c.query(`update app.profiles set ${core}, weight_kg = 60 where user_id = $1`, [userId]),
      ),
    ).rejects.toThrow(/completed_requires_core/);
    await asRole('noura_api', userId, (c) =>
      c.query(
        `update app.profiles set ${core}, weight_kg = 60, screening_answered_at = now() where user_id = $1`,
        [userId],
      ),
    );
  });

  it('defaults target snapshots to the test policy label and rejects unknown statuses', async () => {
    const userId = await createAuthUser();
    await profileFor(userId);
    await asRole('noura_api', userId, async (c) => {
      const { rows } = await c.query<{ policy_status: string }>(
        `insert into app.target_snapshots (user_id, profile_revision, policy_version, selected_targets, method, eligibility)
         values ($1, 2, 'test-v0', '{}', 'policy', 'eligible') returning policy_status`,
        [userId],
      );
      expect(rows[0]!.policy_status).toBe('test');
    });
    await expect(
      asRole('noura_api', userId, (c) =>
        c.query(
          `insert into app.target_snapshots (user_id, profile_revision, policy_version, selected_targets, method, eligibility, policy_status)
           values ($1, 2, 'v', '{}', 'policy', 'eligible', 'reviewed-ish')`,
          [userId],
        ),
      ),
    ).rejects.toThrow(/policy_status/);
  });

  it('allows one active consent per type and version, and a new version alongside it', async () => {
    const userId = await createAuthUser();
    await asRole('noura_api', userId, async (c) => {
      await c.query(
        "insert into app.consent_records (user_id, consent_type, version) values ($1, 'terms', 'v0-draft')",
        [userId],
      );
      await c.query(
        "insert into app.consent_records (user_id, consent_type, version) values ($1, 'terms', 'v1')",
        [userId],
      );
      await expect(
        c.query(
          "insert into app.consent_records (user_id, consent_type, version) values ($1, 'terms', 'v0-draft')",
          [userId],
        ),
      ).rejects.toThrow(/consent_records_one_active/);
    });
  });
});

describe('generation request relay (worker, no user context)', () => {
  it('sees only requests that are still queued, across users', async () => {
    const [a, b] = [await createAuthUser(), await createAuthUser()];
    await Promise.all([profileFor(a), profileFor(b)]);
    const queuedA = await queuedRequest(a);
    const queuedB = await queuedRequest(b);
    const dispatched = await asOwner((c) =>
      c.query<{ id: string }>(
        `insert into app.generation_requests (user_id, request_type, status, queue_job_id, started_at)
         values ($1, 'workout_plan', 'running', $2, now()) returning id`,
        [a, randomUUID()],
      ),
    );

    const visible = await asRole('noura_worker', null, (c) =>
      c.query<{ id: string }>('select id from app.generation_requests order by created_at'),
    );
    const ids = visible.rows.map((r) => r.id);
    expect(ids).toContain(queuedA);
    expect(ids).toContain(queuedB);
    expect(ids).not.toContain(dispatched.rows[0]!.id);
  });

  it('can record dispatch on a queued request', async () => {
    const userId = await createAuthUser();
    await profileFor(userId);
    const id = await queuedRequest(userId);
    const jobId = randomUUID();
    await asRole('noura_worker', null, async (c) => {
      const result = await c.query(
        `update app.generation_requests set queue_name = 'diet-plan.generate', queue_job_id = $2 where id = $1`,
        [id, jobId],
      );
      expect(result.rowCount).toBe(1);
    });
  });

  it('cannot change anything else about a request without a user context', async () => {
    const userId = await createAuthUser();
    await profileFor(userId);
    const id = await queuedRequest(userId);
    const attempts = [
      "status = 'completed', completed_at = now(), queue_job_id = gen_random_uuid()::text",
      "input_revision = 99, queue_job_id = 'x'",
      'result_ids = \'{"plan":"x"}\'::jsonb, queue_job_id = \'x\'',
      "safe_error_code = 'E', queue_job_id = 'x'",
    ];
    for (const set of attempts) {
      await expect(
        asRole('noura_worker', null, (c) =>
          c.query(`update app.generation_requests set ${set} where id = $1`, [id]),
        ),
        set,
      ).rejects.toThrow();
    }
    const { rows } = await adminPool.query(
      'select status, input_revision, queue_job_id from app.generation_requests where id = $1',
      [id],
    );
    expect(rows[0]).toEqual({ status: 'queued', input_revision: 2, queue_job_id: null });
  });

  it('cannot read or touch other tables or rows through the relay policies', async () => {
    const userId = await createAuthUser();
    await profileFor(userId);
    await queuedRequest(userId);
    const profiles = await asRole('noura_worker', null, (c) =>
      c.query('select * from app.profiles'),
    );
    expect(profiles.rows).toEqual([]);
    const consent = await asRole('noura_worker', null, (c) =>
      c.query('select * from app.consent_records'),
    );
    expect(consent.rows).toEqual([]);
  });

  it('keeps per-user job handling working when a user context is set', async () => {
    const userId = await createAuthUser();
    await profileFor(userId);
    const id = await queuedRequest(userId);
    await asRole('noura_worker', userId, async (c) => {
      const result = await c.query(
        `update app.generation_requests set status = 'running', started_at = now(), attempts = 1 where id = $1 and user_id = $1`.replace(
          'and user_id = $1',
          'and user_id = $2',
        ),
        [id, userId],
      );
      expect(result.rowCount).toBe(1);
    });
  });

  it('does not give the API role cross-user queue visibility', async () => {
    const [a, b] = [await createAuthUser(), await createAuthUser()];
    await Promise.all([profileFor(a), profileFor(b)]);
    await queuedRequest(a);
    const idB = await queuedRequest(b);
    const rows = await asRole('noura_api', a, (c) =>
      c.query<{ id: string }>('select id from app.generation_requests'),
    );
    expect(rows.rows.map((r) => r.id)).not.toContain(idB);
    const noContext = await asRole('noura_api', null, (c) =>
      c.query('select id from app.generation_requests'),
    );
    expect(noContext.rows).toEqual([]);
  });
});
