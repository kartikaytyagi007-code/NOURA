import type { DietConstraints } from '../catalog/eligibility.js';
import type { DietType } from '../catalog/types.js';
import type { Queryable } from '../db/user-transaction.js';
import type { EligibilityStatus } from '../eligibility/index.js';

export interface DietPlanningInputs {
  profileRevision: number;
  eligibilityStatus: EligibilityStatus | null;
  targetSnapshotId: string | null;
  /** Null when the snapshot has no single point energy (basis: range, D-024) or none was calculated. */
  targetEnergyKcal: number | null;
  /** Daily protein/fibre targets from the active snapshot, when calculated (M6 gap-detection, D-028). */
  dailyTargets: { protein_g: number | null; fibre_g: number | null } | null;
  mealsPerDay: number | null;
  constraints: DietConstraints;
}

interface ProfileRow {
  revision: number;
  eligibility_status: EligibilityStatus | null;
}

interface PreferencesRow {
  diet_type: DietType | null;
  allergy_ids: string[];
  exclusion_ids: string[];
  dislikes: string[];
  meals_per_day: number | null;
}

interface SnapshotRow {
  id: string;
  basis: 'point' | 'range' | 'not_calculated';
  energy_kcal: number | null;
  protein_g: number | null;
  fibre_g: number | null;
}

/**
 * Everything diet-plan generation and filtering need, reloaded fresh under the caller's own
 * transaction context (API or worker, both restricted roles with the same owner-RLS). Used by both
 * the API (swaps, manual generation requests) and the worker (D-017, D-025), which is what keeps
 * eligibility and targets consistent between them.
 */
export async function loadDietPlanningInputs(
  client: Queryable,
  userId: string,
): Promise<DietPlanningInputs> {
  const profile = (
    await client.query<ProfileRow>(
      'select revision, eligibility_status from app.profiles where user_id = $1',
      [userId],
    )
  ).rows[0];
  const preferences = (
    await client.query<PreferencesRow>(
      `select diet_type, allergy_ids, exclusion_ids, dislikes, meals_per_day
         from app.user_preferences where user_id = $1`,
      [userId],
    )
  ).rows[0];
  const snapshot = (
    await client.query<SnapshotRow>(
      `select id, selected_targets->>'basis' as basis,
              (selected_targets->'targets'->>'energy_kcal')::numeric as energy_kcal,
              (selected_targets->'targets'->>'protein_g')::numeric as protein_g,
              (selected_targets->'targets'->>'fibre_g')::numeric as fibre_g
         from app.target_snapshots where user_id = $1 and valid_to is null`,
      [userId],
    )
  ).rows[0];

  return {
    profileRevision: profile?.revision ?? 0,
    eligibilityStatus: profile?.eligibility_status ?? null,
    targetSnapshotId: snapshot?.id ?? null,
    targetEnergyKcal: snapshot?.basis === 'point' ? (snapshot.energy_kcal ?? null) : null,
    dailyTargets: snapshot
      ? { protein_g: snapshot.protein_g ?? null, fibre_g: snapshot.fibre_g ?? null }
      : null,
    mealsPerDay: preferences?.meals_per_day ?? null,
    constraints: {
      diet_type: preferences?.diet_type ?? null,
      allergy_ids: preferences?.allergy_ids ?? [],
      exclusion_ids: preferences?.exclusion_ids ?? [],
      dislikes: preferences?.dislikes ?? [],
    },
  };
}
