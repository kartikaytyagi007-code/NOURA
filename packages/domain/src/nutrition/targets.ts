import type { ActivityBand, CalculationSex, GoalType, TargetPolicy } from './policy.js';

export interface TargetInput {
  age_years: number;
  /** Optional parameter for the energy equation only. Null means the user declined to provide it. */
  calculation_sex: CalculationSex | null;
  height_cm: number;
  weight_kg: number;
  activity_band: ActivityBand;
  goal_type: GoalType;
}

export interface MacroTargets {
  energy_kcal: number | null;
  protein_g: number | null;
  fibre_g: number | null;
  carbohydrate_g: number | null;
  fat_g: number | null;
}

export interface TargetResult {
  policy_id: string;
  policy_version: string;
  policy_status: TargetPolicy['status'];
  method_reference: string;
  /** "point": one energy value. "range": the calculation sex was declined, so only a range is offered. */
  basis: 'point' | 'range';
  estimated_energy_kcal: { min: number; max: number };
  targets: MacroTargets;
  warnings: TargetWarning[];
}

export type TargetWarning = 'energy_floor_applied' | 'macro_budget_conflict';

const round1 = (value: number): number => Math.round(value * 10) / 10;

function adjustedEnergy(
  input: TargetInput,
  sex: CalculationSex,
  policy: TargetPolicy,
  warnings: Set<TargetWarning>,
): number {
  const { coefficients, activity_factors, goal_adjustment_fraction, minimum_energy_kcal } =
    policy.energy;
  const resting =
    coefficients.weight_kg * input.weight_kg +
    coefficients.height_cm * input.height_cm +
    coefficients.age_years * input.age_years +
    coefficients.sex_offset[sex];
  const maintenance = resting * activity_factors[input.activity_band];
  let energy = maintenance * (1 + goal_adjustment_fraction[input.goal_type]);
  if (minimum_energy_kcal !== null && energy < minimum_energy_kcal) {
    energy = minimum_energy_kcal;
    warnings.add('energy_floor_applied');
  }
  return Math.round(energy);
}

/**
 * Deterministic target calculation from a policy. Same input and policy always give the same output.
 * Nothing is inferred about sex: when it is declined the energy is reported as a range and the
 * energy-dependent targets stay null (blueprint §5, §7).
 */
export function computeTargets(input: TargetInput, policy: TargetPolicy): TargetResult {
  const warnings = new Set<TargetWarning>();
  const { macros } = policy;
  const protein = round1(input.weight_kg * macros.protein_g_per_kg);
  const base = {
    policy_id: policy.policy_id,
    policy_version: policy.version,
    policy_status: policy.status,
    method_reference: policy.method_reference,
  };

  if (input.calculation_sex === null) {
    const female = adjustedEnergy(input, 'female', policy, warnings);
    const male = adjustedEnergy(input, 'male', policy, warnings);
    return {
      ...base,
      basis: 'range',
      estimated_energy_kcal: { min: Math.min(female, male), max: Math.max(female, male) },
      targets: {
        energy_kcal: null,
        protein_g: protein,
        fibre_g: null,
        carbohydrate_g: null,
        fat_g: null,
      },
      warnings: [...warnings],
    };
  }

  const energy = adjustedEnergy(input, input.calculation_sex, policy, warnings);
  const fat = round1((energy * macros.fat_energy_fraction) / macros.kcal_per_g.fat);
  const carbEnergy = energy - protein * macros.kcal_per_g.protein - fat * macros.kcal_per_g.fat;
  let carbohydrate: number | null = null;
  if (carbEnergy >= 0) carbohydrate = round1(carbEnergy / macros.kcal_per_g.carbohydrate);
  else warnings.add('macro_budget_conflict');
  return {
    ...base,
    basis: 'point',
    estimated_energy_kcal: { min: energy, max: energy },
    targets: {
      energy_kcal: energy,
      protein_g: protein,
      fibre_g: round1((energy / 1000) * macros.fibre_g_per_1000_kcal),
      carbohydrate_g: carbohydrate,
      fat_g: fat,
    },
    warnings: [...warnings],
  };
}
