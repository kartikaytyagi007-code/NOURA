import {
  buildPortionsSnapshot,
  catalogGate,
  filterEligibleRecipes,
  generatePlan,
  loadCatalogRecipes,
  loadDietPlanningInputs,
  withUserTransaction,
  type AppEnv,
  type PoolLike,
  type QueuePayloads,
  type Queryable,
} from '@noura/domain';
import type { Job } from 'pg-boss';
import type { Logger } from 'pino';

interface RequestRow {
  id: string;
  user_id: string;
  request_type: 'diet_plan' | 'plan_regeneration' | string;
  status: 'queued' | 'running' | 'completed' | 'failed' | 'cancelled';
  input_revision: number | null;
}

async function markTerminal(
  client: Queryable,
  requestId: string,
  patch: {
    status: 'completed' | 'failed';
    code?: string;
    message?: string;
    resultIds?: Record<string, string>;
  },
): Promise<void> {
  await client.query(
    `update app.generation_requests
       set status = $2, safe_error_code = $3, safe_error_message = $4, result_ids = $5::jsonb,
           completed_at = now()
       where id = $1`,
    [
      requestId,
      patch.status,
      patch.code ?? null,
      patch.message ?? null,
      JSON.stringify(patch.resultIds ?? {}),
    ],
  );
}

/**
 * Handles `diet-plan.generate` (docs/decisions.md D-025, D-017). Idempotent on `generation_request_id`:
 * everything is reloaded fresh under the user's own transaction context, never trusted from the job
 * payload, and a request that is already terminal (or whose plan already exists) is a no-op. This is
 * also what makes it safe to pick up requests that were relayed before this handler existed (M2's
 * D-017 note): they are simply processed now, once, like any other at-least-once delivery.
 */
export async function handleDietPlanGenerate(
  [job]: Job<QueuePayloads['diet-plan.generate']>[],
  pool: PoolLike,
  appEnv: AppEnv,
  log: Logger,
): Promise<{ status: string }> {
  if (!job) throw new Error('diet-plan.generate handler received an empty batch');
  const { generation_request_id: requestId, user_id: userId } = job.data;

  return withUserTransaction(pool, 'noura_worker', userId, async (client) => {
    const request = (
      await client.query<RequestRow>(
        `select id, user_id, request_type, status, input_revision from app.generation_requests
           where id = $1 and user_id = $2`,
        [requestId, userId],
      )
    ).rows[0];
    if (!request) {
      log.warn({ requestId }, 'diet-plan.generate: request not found for this user, skipping');
      return { status: 'skipped_missing' };
    }
    if (
      request.status === 'completed' ||
      request.status === 'failed' ||
      request.status === 'cancelled'
    ) {
      return { status: 'already_terminal' };
    }

    const existingPlan = (
      await client.query<{ id: string }>(
        'select id from app.diet_plans where user_id = $1 and generation_request_id = $2',
        [userId, requestId],
      )
    ).rows[0];
    if (existingPlan) {
      // A previous attempt committed the plan but the request row was not marked terminal (for
      // example a crash right after). At-least-once delivery must not generate a second plan.
      await markTerminal(client, requestId, {
        status: 'completed',
        resultIds: { diet_plan_id: existingPlan.id },
      });
      return { status: 'already_generated' };
    }

    await client.query(
      `update app.generation_requests
         set status = 'running', attempts = attempts + 1, started_at = coalesce(started_at, now())
         where id = $1`,
      [requestId],
    );

    const inputs = await loadDietPlanningInputs(client, userId);
    if (inputs.eligibilityStatus !== 'eligible' || !inputs.targetSnapshotId) {
      await markTerminal(client, requestId, {
        status: 'failed',
        code: 'planning_unavailable',
        message: 'Automated plans are not available for this account.',
      });
      return { status: 'failed_unavailable' };
    }

    const catalog = await loadCatalogRecipes(client);
    const gate = catalogGate(appEnv, catalog);
    if (!gate.allowed) {
      await markTerminal(client, requestId, {
        status: 'failed',
        code: 'catalog_unavailable',
        message:
          gate.reason === 'no_catalog'
            ? 'No recipe catalog is available yet.'
            : 'A reviewed recipe catalog is required before plans can be generated here.',
      });
      return { status: 'failed_catalog_unavailable' };
    }

    const eligible = filterEligibleRecipes(catalog, inputs.constraints);
    const result = generatePlan({
      startsOn: new Date().toISOString().slice(0, 10),
      mealsPerDay: inputs.mealsPerDay,
      eligibleRecipes: eligible,
      targetEnergyKcal: inputs.targetEnergyKcal,
    });
    if (!result.ok) {
      await markTerminal(client, requestId, {
        status: 'failed',
        code: 'plan_infeasible',
        message: `No eligible recipe is available for ${result.slot}. Adjust your food preferences and try again.`,
      });
      return { status: 'failed_infeasible' };
    }

    // Supersede any existing active plan before inserting the new one (one active plan at a time).
    const previousActive = (
      await client.query<{ id: string; version: number }>(
        "select id, version from app.diet_plans where user_id = $1 and status = 'active' order by version desc limit 1",
        [userId],
      )
    ).rows[0];
    if (previousActive) {
      await client.query("update app.diet_plans set status = 'superseded' where id = $1", [
        previousActive.id,
      ]);
    }
    const version = (previousActive?.version ?? 0) + 1;

    const plan = (
      await client.query<{ id: string }>(
        `insert into app.diet_plans
           (user_id, version, profile_revision, target_snapshot_id, starts_on, status, supersedes_id, generation_request_id)
         values ($1, $2, $3, $4, $5, 'active', $6, $7)
         returning id`,
        [
          userId,
          version,
          inputs.profileRevision,
          inputs.targetSnapshotId,
          result.plan.days[0]!.date,
          previousActive?.id ?? null,
          requestId,
        ],
      )
    ).rows[0]!;

    for (const day of result.plan.days) {
      for (const meal of day.meals) {
        const portionsSnapshot = buildPortionsSnapshot(meal.recipe, meal.grams_scale);
        await client.query(
          `insert into app.diet_plan_meals
             (user_id, plan_id, meal_date, slot, slot_ordinal, recipe_id, portions_snapshot, nutrition_snapshot)
           values ($1, $2, $3, $4, $5, $6, $7::jsonb, $8::jsonb)`,
          [
            userId,
            plan.id,
            meal.date,
            meal.slot,
            meal.slot_ordinal,
            meal.recipe.id,
            JSON.stringify(portionsSnapshot),
            JSON.stringify(meal.nutrition),
          ],
        );
      }
    }

    await markTerminal(client, requestId, {
      status: 'completed',
      resultIds: { diet_plan_id: plan.id },
    });
    log.info({ requestId, userId, planId: plan.id, version }, 'diet-plan.generate completed');
    return { status: 'completed' };
  });
}
