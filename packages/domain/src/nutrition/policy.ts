import { z } from 'zod';
import { isDeployedEnv, type AppEnv } from '../env.js';

/**
 * Target policy framework (blueprint §7). The targets engine is deterministic and versioned. Every
 * coefficient, activity factor, goal adjustment and macro rule lives in policy configuration with a
 * method reference and reviewer sign-off. This repository ships only a clearly marked TEST policy:
 * its numbers are development placeholders, not reviewed values, and not medical advice. Staging and
 * production run automated planning only with a policy whose status is "approved" (docs/decisions.md
 * D-018). The blueprint deliberately sets no calorie floor; `minimum_energy_kcal` is therefore a
 * reviewer-supplied option that is null in the test policy.
 */

export const ACTIVITY_BANDS = ['sedentary', 'light', 'moderate', 'active', 'very_active'] as const;
export type ActivityBand = (typeof ACTIVITY_BANDS)[number];

export const GOAL_TYPES = ['lose_fat', 'maintain', 'gain_muscle', 'general_health'] as const;
export type GoalType = (typeof GOAL_TYPES)[number];

export type CalculationSex = 'female' | 'male';

const record = <K extends readonly string[]>(keys: K, value: z.ZodNumber) =>
  z.object(Object.fromEntries(keys.map((k) => [k, value])) as Record<K[number], z.ZodNumber>);

export const targetPolicySchema = z
  .object({
    policy_id: z.string().min(1).max(64),
    version: z.string().min(1).max(32),
    status: z.enum(['test', 'approved']),
    method_reference: z.string().min(1).max(500),
    approval: z
      .object({
        reviewer: z.string().min(1).max(120),
        approved_on: z.iso.date(),
        reference: z.string().min(1).max(300),
      })
      .nullable(),
    energy: z.object({
      equation: z.literal('mifflin_st_jeor'),
      coefficients: z.object({
        weight_kg: z.number(),
        height_cm: z.number(),
        age_years: z.number(),
        sex_offset: z.object({ female: z.number(), male: z.number() }),
      }),
      activity_factors: record(ACTIVITY_BANDS, z.number().positive()),
      /** Fraction of maintenance energy added (+) or removed (-) for each goal. */
      goal_adjustment_fraction: record(GOAL_TYPES, z.number().min(-0.5).max(0.5)),
      /** Reviewer-supplied floor. Null means none configured. */
      minimum_energy_kcal: z.number().positive().nullable(),
    }),
    macros: z.object({
      protein_g_per_kg: z.number().positive(),
      fat_energy_fraction: z.number().gt(0).lt(1),
      fibre_g_per_1000_kcal: z.number().positive(),
      kcal_per_g: z.object({
        protein: z.number().positive(),
        carbohydrate: z.number().positive(),
        fat: z.number().positive(),
      }),
    }),
  })
  .strict()
  .refine((p) => p.status === 'test' || p.approval !== null, {
    message: 'an approved policy must record its approval (reviewer, date, reference)',
    path: ['approval'],
  });

export type TargetPolicy = z.infer<typeof targetPolicySchema>;

/** Throws a readable error (field paths only, no values) when the policy file is invalid. */
export function parseTargetPolicy(raw: unknown): TargetPolicy {
  const parsed = targetPolicySchema.safeParse(raw);
  if (!parsed.success) {
    const problems = parsed.error.issues.map(
      (i) => `${i.path.join('.') || '(root)'}: ${i.message}`,
    );
    throw new Error(`Invalid target policy: ${problems.join('; ')}`);
  }
  return parsed.data;
}

/**
 * TEST POLICY. Development placeholder values, NOT reviewed, NOT medical advice.
 * Resting energy uses the published Mifflin-St Jeor equation with conventional activity multipliers.
 * The goal adjustments and macro rules are arbitrary conservative test values.
 */
export const TEST_TARGET_POLICY: TargetPolicy = {
  policy_id: 'noura-targets',
  version: 'test-v0',
  status: 'test',
  method_reference:
    'TEST POLICY, not reviewed and not medical advice. Mifflin-St Jeor resting energy (Mifflin et al., 1990) with conventional activity multipliers; goal and macro values are development placeholders.',
  approval: null,
  energy: {
    equation: 'mifflin_st_jeor',
    coefficients: {
      weight_kg: 10,
      height_cm: 6.25,
      age_years: -5,
      sex_offset: { female: -161, male: 5 },
    },
    activity_factors: {
      sedentary: 1.2,
      light: 1.375,
      moderate: 1.55,
      active: 1.725,
      very_active: 1.9,
    },
    goal_adjustment_fraction: { lose_fat: -0.1, maintain: 0, gain_muscle: 0.05, general_health: 0 },
    minimum_energy_kcal: null,
  },
  macros: {
    protein_g_per_kg: 1.2,
    fat_energy_fraction: 0.3,
    fibre_g_per_1000_kcal: 14,
    kcal_per_g: { protein: 4, carbohydrate: 4, fat: 9 },
  },
};

export type PlanningGate =
  { allowed: true } | { allowed: false; reason: 'no_policy' | 'test_policy_not_allowed' };

/**
 * Automated planning is allowed with the test policy in development/test only. Deployed
 * environments need an approved policy; without one planning is unavailable (fails closed) while the
 * rest of the product keeps working.
 */
export function planningGate(appEnv: AppEnv, policy: TargetPolicy | null): PlanningGate {
  if (!policy) return { allowed: false, reason: 'no_policy' };
  if (isDeployedEnv(appEnv) && policy.status !== 'approved') {
    return { allowed: false, reason: 'test_policy_not_allowed' };
  }
  return { allowed: true };
}
