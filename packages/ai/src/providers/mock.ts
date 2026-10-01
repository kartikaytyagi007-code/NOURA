import type { AiProvider, AiResult } from './types.js';

/**
 * DEVELOPMENT/TEST ONLY. Returns explicitly labelled mock outputs so flows can be exercised without
 * a paid provider. It never returns food labels, portions or nutrient values: a mock must not look
 * like a recognition result or nutrition fact. The factory refuses it outside development/test.
 */
export class MockAiProvider implements AiProvider {
  readonly name = 'mock';

  private result<T>(output: T): Promise<AiResult<T>> {
    return Promise.resolve({
      output,
      meta: {
        provider: 'mock',
        model_id: 'mock',
        prompt_version: 'mock',
        latency_ms: 0,
        input_tokens: null,
        output_tokens: null,
        mock: true,
      },
    });
  }

  recognizeMeal(): Promise<AiResult<unknown>> {
    return this.result({
      schema_version: '1',
      image_is_food: false,
      quality: 'unusable',
      items: [],
      clarification: 'Development mock provider: no recognition was performed.',
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

  coachReply(): Promise<AiResult<unknown>> {
    return this.result({
      answer_text: 'Development mock provider: the coach is not available in this build.',
      evidence_refs: [],
      cards: [],
      action_proposal: null,
    });
  }
}
