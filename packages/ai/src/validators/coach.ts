import { z } from 'zod';

/**
 * Coach chat input/output validation (blueprint §12; docs/decisions.md D-031). Mirrors M4's
 * `recognition-schema.ts` precedent: strict, additive-free schemas on both sides of the provider
 * boundary, since text in a chat message is exactly the kind of untrusted content D-010 and this
 * module's `checkSafety` call already guard against.
 *
 * `CoachProviderOutputSchema` intentionally has no field for nutrition/exercise numbers or for a
 * finished "card" — those are always built by the worker from real app data (blueprint §9 "no
 * fabricated authoritative nutrition"; this milestone's scope note 6). The provider may only return
 * prose (`answer_text`), which evidence it drew on (`evidence_refs`, opaque keys the worker already
 * knows how to resolve), and at most one proposed action the worker will re-validate against real
 * data before ever creating an `action_proposals` row.
 *
 * `swap_meal` is the only `proposed_action.type` this schema accepts. `regenerate_day` and
 * `reschedule_workout` remain valid on the `ActionProposal` API schema for forward compatibility
 * (blueprint §16 "limited action proposals"), but applying either safely would require new
 * plan-mutation domain logic this milestone does not build (AGENTS.md: no deferred features) — see
 * docs/decisions.md D-031.
 */
export const CoachProposedActionSchema = z
  .object({
    type: z.literal('swap_meal'),
    plan_meal_id: z.string().uuid(),
    candidate_recipe_id: z.string().uuid(),
    reason: z.string().min(1).max(300),
  })
  .strict();

export const CoachProviderOutputSchema = z
  .object({
    answer_text: z.string().min(1).max(4000),
    evidence_refs: z.array(z.string().max(100)).max(10).default([]),
    proposed_action: CoachProposedActionSchema.nullable().default(null),
  })
  .strict();

export type CoachProposedAction = z.infer<typeof CoachProposedActionSchema>;
export type CoachProviderOutput = z.infer<typeof CoachProviderOutputSchema>;

export class InvalidCoachProviderOutput extends Error {
  constructor(public readonly issues: unknown) {
    super('Coach AI provider returned a response that failed validation.');
    this.name = 'InvalidCoachProviderOutput';
  }
}

export function validateCoachProviderOutput(raw: unknown): CoachProviderOutput {
  const result = CoachProviderOutputSchema.safeParse(raw);
  if (!result.success) throw new InvalidCoachProviderOutput(result.error.issues);
  return result.data;
}

/**
 * What the worker is allowed to send the provider as context (blueprint §2 "job payloads/prompts
 * contain IDs, not chat histories" — restated here for the live API→provider call, not the queue
 * payload). Validated before every call so a bug can never leak an unexpected shape or extra PII
 * field to the provider boundary.
 */
const CoachTodayMealSchema = z
  .object({
    slot: z.string().max(20),
    plan_meal_id: z.string().uuid(),
    plan_meal_revision: z.number().int().min(1),
    recipe_name: z.string().max(200),
    alternate_candidate_id: z.string().uuid().nullable(),
    alternate_candidate_name: z.string().max(200).nullable(),
  })
  .strict();

export const CoachContextInputSchema = z
  .object({
    user_message: z.string().min(1).max(2000),
    profile: z.object({
      has_goals: z.boolean(),
      diet_preference: z.string().nullable(),
    }),
    diet: z.object({
      has_active_plan: z.boolean(),
      today: CoachTodayMealSchema.nullable(),
      today_logged_meal_count: z.number().int().min(0),
    }),
    workout: z.object({
      has_active_plan: z.boolean(),
      today_session_title: z.string().nullable(),
      today_session_status: z.string().nullable(),
    }),
  })
  .strict();

export type CoachContextInput = z.infer<typeof CoachContextInputSchema>;

export class InvalidCoachProviderInput extends Error {
  constructor(public readonly issues: unknown) {
    super('Coach AI provider call was built with an invalid context payload.');
    this.name = 'InvalidCoachProviderInput';
  }
}

export function validateCoachContextInput(raw: unknown): CoachContextInput {
  const result = CoachContextInputSchema.safeParse(raw);
  if (!result.success) throw new InvalidCoachProviderInput(result.error.issues);
  return result.data;
}

export const COACH_ALLOWED_ACTIONS = ['swap_meal'] as const;
