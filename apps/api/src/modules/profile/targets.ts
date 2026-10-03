import {
  computeTargets,
  planningGate,
  type AppEnv,
  type EligibilityStatus,
  type Queryable,
  type TargetInput,
  type TargetPolicy,
} from '@noura/domain';
import type { components } from '@noura/contracts';

type TargetSnapshot = components['schemas']['TargetSnapshot'];

export interface PlanningContext {
  appEnv: AppEnv;
  /** Null when no policy is configured; planning is then unavailable (fails closed). */
  policy: TargetPolicy | null;
}

interface SnapshotRow {
  id: string;
  profile_revision: number;
  policy_version: string;
  policy_status: 'test' | 'approved';
  estimated_energy_kcal_min: number | null;
  estimated_energy_kcal_max: number | null;
  selected_targets: {
    basis: TargetSnapshot['basis'];
    targets: TargetSnapshot['targets'];
    warnings: TargetSnapshot['warnings'];
  };
  method: TargetSnapshot['method'];
  method_reference: string | null;
  eligibility: EligibilityStatus;
  valid_from: Date;
}

const EMPTY_TARGETS: TargetSnapshot['targets'] = {
  energy_kcal: null,
  protein_g: null,
  fibre_g: null,
  carbohydrate_g: null,
  fat_g: null,
};

/**
 * Closes the current snapshot and records a new one for this profile revision. Numbers exist only
 * when the user is eligible AND the environment's planning gate allows the configured policy;
 * otherwise a "not_calculated" snapshot records the eligibility outcome without inventing targets.
 * Returns whether targets were calculated (i.e. whether planning may proceed).
 */
export async function writeTargetSnapshot(
  client: Queryable,
  userId: string,
  input: {
    profileRevision: number;
    eligibility: EligibilityStatus;
    target: TargetInput;
  },
  context: PlanningContext,
): Promise<{ calculated: boolean }> {
  const gate = planningGate(context.appEnv, context.policy);
  const result =
    input.eligibility === 'eligible' && gate.allowed && context.policy
      ? computeTargets(input.target, context.policy)
      : null;

  await client.query(
    'update app.target_snapshots set valid_to = now() where user_id = $1 and valid_to is null',
    [userId],
  );
  await client.query(
    `insert into app.target_snapshots
       (user_id, profile_revision, policy_version, policy_status, estimated_energy_kcal_min,
        estimated_energy_kcal_max, selected_targets, method, method_reference, eligibility)
     values ($1, $2, $3, $4, $5, $6, $7::jsonb, 'policy', $8, $9)`,
    [
      userId,
      input.profileRevision,
      result?.policy_version ?? 'not_calculated',
      // A snapshot without numbers is labelled "test" so it can never read as reviewed.
      result?.policy_status ?? 'test',
      result?.estimated_energy_kcal.min ?? null,
      result?.estimated_energy_kcal.max ?? null,
      JSON.stringify({
        basis: result?.basis ?? 'not_calculated',
        targets: result?.targets ?? EMPTY_TARGETS,
        warnings: result?.warnings ?? [],
      }),
      result?.method_reference ?? null,
      input.eligibility,
    ],
  );
  return { calculated: result !== null };
}

export async function loadCurrentSnapshot(
  client: Queryable,
  userId: string,
): Promise<TargetSnapshot | null> {
  const row = (
    await client.query<SnapshotRow>(
      `select id, profile_revision, policy_version, policy_status, estimated_energy_kcal_min,
              estimated_energy_kcal_max, selected_targets, method, method_reference, eligibility,
              valid_from
         from app.target_snapshots where user_id = $1 and valid_to is null`,
      [userId],
    )
  ).rows[0];
  if (!row) return null;
  const min = row.estimated_energy_kcal_min;
  const max = row.estimated_energy_kcal_max;
  return {
    id: row.id,
    profile_revision: row.profile_revision,
    policy_version: row.policy_version,
    policy_status: row.policy_status,
    method: row.method,
    method_reference: row.method_reference,
    eligibility: row.eligibility,
    basis: row.selected_targets.basis,
    estimated_energy_kcal: min !== null && max !== null ? { min, max } : null,
    targets: row.selected_targets.targets,
    warnings: row.selected_targets.warnings,
    valid_from: row.valid_from.toISOString(),
  };
}
