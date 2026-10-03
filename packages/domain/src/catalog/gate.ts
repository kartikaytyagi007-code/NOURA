import { isDeployedEnv, type AppEnv } from '../env.js';
import type { QualityFlag } from './types.js';

/**
 * Catalog planning gate (docs/decisions.md D-025), mirroring the target-policy gate (D-018). No
 * licensed nutrition dataset is available yet, so the repository ships only a clearly labelled
 * `test_fixture` catalog for exercising the pipeline. Development and test may plan from it.
 * Staging and production must not: automated plan generation there requires at least one recipe
 * per required meal slot whose `quality_flag` is `verified` or `reviewed` (not `provisional` or
 * `test_fixture`). With nothing usable, planning is unavailable (fails closed) and the generation
 * request records an honest "catalog unavailable" outcome instead of a fabricated plan.
 *
 * Reused unchanged for the exercise catalog in M7 (docs/decisions.md D-029): no licensed exercise
 * dataset is available either, and the same fail-closed rule applies to workout-plan generation.
 */
export type CatalogGate =
  | { allowed: true }
  | { allowed: false; reason: 'no_catalog' | 'test_fixture_not_allowed_in_deployed_env' };

const PRODUCTION_READY: ReadonlySet<QualityFlag> = new Set(['verified', 'reviewed']);

export function catalogGate(
  appEnv: AppEnv,
  items: readonly { quality_flag: QualityFlag }[],
): CatalogGate {
  if (items.length === 0) return { allowed: false, reason: 'no_catalog' };
  if (!isDeployedEnv(appEnv)) return { allowed: true };
  const hasProductionReady = items.some((r) => PRODUCTION_READY.has(r.quality_flag));
  if (!hasProductionReady)
    return { allowed: false, reason: 'test_fixture_not_allowed_in_deployed_env' };
  return { allowed: true };
}
