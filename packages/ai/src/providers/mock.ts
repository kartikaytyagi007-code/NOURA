import { createHash } from 'node:crypto';
import type { AiProvider, AiResult } from './types.js';

/**
 * DEVELOPMENT/TEST ONLY. The factory refuses this provider outside development/test (docs/decisions.md
 * D-010). Every output is labelled `meta.mock: true`.
 *
 * `recognizeMeal` is the one method that now returns deterministic, clearly-synthetic food labels and
 * portion estimates instead of an always-empty result. This is an explicit, documented extension of
 * D-010 for M4 (see D-026 in docs/decisions.md): there is no real vision-model key available in this
 * environment, so the mock is what actually exercises the meal-scan pipeline (upload → recognition →
 * catalog matching → review) end to end. It still never invents a nutrition number — it only returns
 * food name labels and gram estimates, exactly like a real provider would; nutrition is always
 * resolved afterwards, deterministically, against the approved catalog. The scenario is chosen from a
 * fixed, non-secret lookup keyed by a hash of the image bytes, so specific checked-in test fixtures
 * exercise specific paths (a clean match, an unmatched item, a low-confidence/ambiguous photo, a
 * non-food photo, or a simulated provider failure) while any other image gets a plausible default.
 */
export type MockRecognitionScenario =
  'default' | 'all_matched' | 'unmatched_item' | 'low_confidence' | 'non_food' | 'provider_error';

function sha256Hex(bytes: Uint8Array): string {
  return createHash('sha256').update(bytes).digest('hex');
}

/** Exported so tests can compute which scenario a given fixture buffer will trigger. */
export const MOCK_SCENARIO_FIXTURES: Record<string, MockRecognitionScenario> = {};

export function registerMockScenarioFixture(
  bytes: Uint8Array,
  scenario: MockRecognitionScenario,
): void {
  MOCK_SCENARIO_FIXTURES[sha256Hex(bytes)] = scenario;
}

function scenarioFor(bytes: Uint8Array, context: Record<string, unknown>): MockRecognitionScenario {
  const explicit = context['mock_scenario'];
  if (typeof explicit === 'string' && isScenario(explicit)) return explicit;
  return MOCK_SCENARIO_FIXTURES[sha256Hex(bytes)] ?? 'default';
}

function isScenario(value: string): value is MockRecognitionScenario {
  return [
    'default',
    'all_matched',
    'unmatched_item',
    'low_confidence',
    'non_food',
    'provider_error',
  ].includes(value);
}

export class MockProviderSimulatedError extends Error {
  constructor() {
    super('Mock AI provider: simulated upstream failure (development/test only).');
    this.name = 'MockProviderSimulatedError';
  }
}

export class MockAiProvider implements AiProvider {
  readonly name = 'mock';

  private result<T>(output: T): Promise<AiResult<T>> {
    return Promise.resolve({
      output,
      meta: {
        provider: 'mock',
        model_id: 'mock',
        prompt_version: 'mock-recognition-v1',
        latency_ms: 0,
        input_tokens: null,
        output_tokens: null,
        mock: true,
      },
    });
  }

  recognizeMeal(
    image: { bytes: Uint8Array; mime: string },
    context: Record<string, unknown> = {},
  ): Promise<AiResult<unknown>> {
    const scenario = scenarioFor(image.bytes, context);

    if (scenario === 'provider_error') {
      return Promise.reject(new MockProviderSimulatedError());
    }
    if (scenario === 'non_food') {
      return this.result({
        schema_version: '1',
        image_is_food: false,
        quality: 'unusable',
        items: [],
        clarification: 'Development mock provider: this does not look like a food photo.',
      });
    }
    if (scenario === 'low_confidence') {
      return this.result({
        schema_version: '1',
        image_is_food: true,
        quality: 'blurry',
        items: [
          {
            temporary_id: 'item-1',
            label: 'Mixed vegetables',
            alternative_labels: ['Vegetable curry'],
            confidence_band: 'low',
            estimated_grams: { min: 80, max: 220 },
            preparation_questions: ['Was this cooked with oil?'],
            needs_confirmation: true,
          },
        ],
        clarification: 'Development mock provider: the photo is too blurry to be confident.',
      });
    }
    if (scenario === 'unmatched_item') {
      return this.result({
        schema_version: '1',
        image_is_food: true,
        quality: 'usable',
        items: [
          {
            temporary_id: 'item-1',
            label: 'White rice',
            alternative_labels: [],
            confidence_band: 'high',
            estimated_grams: { min: 150, max: 200 },
            preparation_questions: [],
            needs_confirmation: false,
          },
          {
            temporary_id: 'item-2',
            label: 'Development mock unlisted dish',
            alternative_labels: [],
            confidence_band: 'medium',
            estimated_grams: { min: 50, max: 120 },
            preparation_questions: [],
            needs_confirmation: true,
          },
        ],
        clarification: null,
      });
    }
    if (scenario === 'all_matched') {
      return this.result({
        schema_version: '1',
        image_is_food: true,
        quality: 'usable',
        items: [
          {
            temporary_id: 'item-1',
            label: 'White rice',
            alternative_labels: [],
            confidence_band: 'high',
            estimated_grams: { min: 150, max: 180 },
            preparation_questions: [],
            needs_confirmation: false,
          },
          {
            temporary_id: 'item-2',
            label: 'Chicken breast',
            alternative_labels: ['Grilled chicken'],
            confidence_band: 'high',
            estimated_grams: { min: 100, max: 140 },
            preparation_questions: [],
            needs_confirmation: false,
          },
          {
            temporary_id: 'item-3',
            label: 'Mixed vegetables',
            alternative_labels: [],
            confidence_band: 'medium',
            estimated_grams: { min: 60, max: 100 },
            preparation_questions: [],
            needs_confirmation: false,
          },
        ],
        clarification: null,
      });
    }
    // default: one confident catalog match plus one item the catalog cannot match, medium confidence
    return this.result({
      schema_version: '1',
      image_is_food: true,
      quality: 'usable',
      items: [
        {
          temporary_id: 'item-1',
          label: 'Banana',
          alternative_labels: [],
          confidence_band: 'medium',
          estimated_grams: { min: 90, max: 130 },
          preparation_questions: [],
          needs_confirmation: true,
        },
      ],
      clarification: null,
    });
  }

  explainMeal(): Promise<AiResult<unknown>> {
    return this.result({ text: 'Development mock provider: no explanation generated.' });
  }

  rankDietCandidates(candidates: unknown[]): Promise<AiResult<unknown>> {
    // Preserve deterministic order; real ranking never bypasses domain constraints either.
    return this.result({ ranked_indexes: candidates.map((_, i) => i) });
  }

  explainWeeklyInsights(): Promise<AiResult<unknown>> {
    return this.result({ text: 'Development mock provider: no explanation generated.' });
  }

  /**
   * Development mock for coach chat (docs/decisions.md D-031). Deterministic over the validated
   * `context` input (see `../validators/coach.ts`): it never invents a nutrition/exercise number,
   * explicitly says so whenever `context.diet`/`context.workout` reports no active plan or no
   * logged data, and only ever proposes `swap_meal`, and only when the context actually has a
   * today's planned slot to swap. The out-of-scope/medical-safety path never reaches this far — the
   * worker's `checkSafety` pre-check handles it before calling the provider at all — so this mock
   * focuses purely on honest context-grounded framing, exactly like `rankDietCandidates` and
   * `explainWeeklyInsights` focus on their own narrow jobs.
   */
  coachReply(context: Record<string, unknown> = {}): Promise<AiResult<unknown>> {
    const diet = (context['diet'] ?? {}) as {
      has_active_plan?: boolean;
      today_logged_meal_count?: number;
      today?: {
        slot?: string;
        recipe_name?: string;
        plan_meal_id?: string;
        alternate_candidate_id?: string | null;
        alternate_candidate_name?: string | null;
      } | null;
    };
    const workout = (context['workout'] ?? {}) as {
      has_active_plan?: boolean;
      today_session_title?: string | null;
      today_session_status?: string | null;
    };
    const message = typeof context['user_message'] === 'string' ? context['user_message'] : '';
    const wantsSwap = /\bswap\b/i.test(message);

    const lines: string[] = [];
    const evidenceRefs: string[] = [];

    if (!diet.has_active_plan) {
      lines.push(
        "You don't have an active diet plan right now, so I can't look at today's meals yet.",
      );
    } else {
      lines.push(
        `You've logged ${diet.today_logged_meal_count ?? 0} meal(s) today against your active plan.`,
      );
      evidenceRefs.push('diet.today');
      if (diet.today?.recipe_name) {
        lines.push(`Your ${diet.today.slot} is planned as ${diet.today.recipe_name}.`);
      }
    }

    if (!workout.has_active_plan) {
      lines.push("You also don't have an active workout plan yet.");
    } else if (workout.today_session_title) {
      lines.push(
        `Today's workout is "${workout.today_session_title}" (${workout.today_session_status ?? 'scheduled'}).`,
      );
      evidenceRefs.push('workout.today');
    } else {
      lines.push('Today looks like a rest day on your workout schedule.');
    }

    lines.push('Development mock provider: this is a scripted reply, not a live model response.');

    const today = diet.today;
    const canProposeSwap =
      wantsSwap && diet.has_active_plan && !!today?.plan_meal_id && !!today?.alternate_candidate_id;

    if (canProposeSwap && today?.alternate_candidate_name) {
      lines.push(
        `I can swap it for ${today.alternate_candidate_name} if you'd like — just confirm.`,
      );
    }

    return this.result({
      answer_text: lines.join(' '),
      evidence_refs: evidenceRefs,
      proposed_action: canProposeSwap
        ? {
            type: 'swap_meal' as const,
            plan_meal_id: String(today!.plan_meal_id),
            candidate_recipe_id: String(today!.alternate_candidate_id),
            reason: 'You asked for a swap, and an alternative is available for that slot.',
          }
        : null,
    });
  }
}
