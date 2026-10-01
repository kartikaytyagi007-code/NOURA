/**
 * Provider interface from blueprint §12. Model text never has database or tool authority; every
 * output is validated by the worker before use. Only IDs and verified facts cross this boundary.
 *
 * Method payload types are intentionally minimal in M1 and are refined, with JSON Schema/Zod
 * validators in ../validators, by the milestone that first uses each method (M4, M5, M6, M9).
 */
export interface AiCallMeta {
  provider: string;
  model_id: string;
  prompt_version: string;
  latency_ms: number;
  input_tokens: number | null;
  output_tokens: number | null;
  /** true when produced by the development mock: never user-facing truth */
  mock: boolean;
}

export interface AiResult<T> {
  output: T;
  meta: AiCallMeta;
}

export interface AiProvider {
  readonly name: string;
  recognizeMeal(
    image: { bytes: Uint8Array; mime: string },
    context: Record<string, unknown>,
  ): Promise<AiResult<unknown>>;
  explainMeal(verifiedFacts: Record<string, unknown>): Promise<AiResult<unknown>>;
  rankDietCandidates(
    candidates: unknown[],
    constraints: Record<string, unknown>,
  ): Promise<AiResult<unknown>>;
  explainWeeklyInsights(evidence: Record<string, unknown>): Promise<AiResult<unknown>>;
  coachReply(
    context: Record<string, unknown>,
    allowedActions: string[],
  ): Promise<AiResult<unknown>>;
}
