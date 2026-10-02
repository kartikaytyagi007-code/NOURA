import { AppError, createPlateFixes as computePlateFixes, loadCatalogFoods } from '@noura/domain';
import { loadDietPlanningInputs } from '@noura/domain';
import type { components } from '@noura/contracts';
import type { Queryable } from '@noura/domain';
import { conflict, loadOwnedScan } from './scan-service.js';

type Schemas = components['schemas'];

interface ConfirmedAnalysisRow {
  items: Schemas['AnalyzedItem'][];
  totals: Schemas['NutrientTotals'];
}

let idCounter = 0;
function freshId(): string {
  // Suggested "add" items are projection-only (never persisted), so a readable, process-unique id is
  // enough; it is never written to the database or trusted as a real item_id.
  idCounter += 1;
  return `suggested-${Date.now()}-${idCounter}`;
}

/**
 * "Fix My Plate" (blueprint §8 step 7, §16 M5; docs/decisions.md D-027). Purely derived from the
 * scan's already-confirmed, catalog-calculated analysis (`confirmMealScanItems` must have run first);
 * nothing new is written to the database — plate fixes are a computation, not a stored resource, so
 * there is no new user-owned table to add RLS/ownership tests for (the scan itself already has them).
 * `withIdempotency` at the route layer still makes duplicate submissions safe and replay the same
 * response, matching every other mutating route in this API.
 */
export async function createPlateFixesForScan(
  client: Queryable,
  userId: string,
  scanId: string,
  body: Schemas['RevisionRequest'],
): Promise<Schemas['PlateFixes']> {
  const scan = await loadOwnedScan(client, userId, scanId);
  if (scan.status !== 'ready' || !scan.confirmed_analysis) {
    throw new AppError(
      'CONSTRAINT_CONFLICT',
      'Confirm this meal’s items before asking for plate fixes.',
    );
  }
  if (scan.revision !== body.expected_revision) throw conflict('meal scan');

  const analysis = scan.confirmed_analysis as ConfirmedAnalysisRow;
  const items = analysis.items.map((item) => ({
    item_id: item.item_id,
    label: item.label,
    food_id: item.food_id,
    recipe_id: item.recipe_id,
    grams: item.grams,
    grams_range: item.grams_range,
    nutrients: item.nutrients,
    uncertainty: item.uncertainty,
  }));

  const [catalogFoods, planningInputs] = await Promise.all([
    loadCatalogFoods(client),
    loadDietPlanningInputs(client, userId),
  ]);

  const result = computePlateFixes(
    items,
    analysis.totals,
    catalogFoods,
    planningInputs.constraints,
    freshId,
  );

  return {
    scan_id: scan.id,
    revision: scan.revision,
    fixes: result.fixes.map((fix) => ({
      type: fix.type,
      item_id: fix.item_id,
      catalog_food_id: fix.catalog_food_id,
      proposed_grams: fix.proposed_grams,
      reason: fix.reason,
      projected: {
        label: 'projected' as const,
        totals: fix.projected.totals,
        meal_balance: fix.projected.meal_balance,
      },
      requires_confirmation: true,
    })),
    after_changes: {
      totals: result.after_changes.totals,
      meal_balance: result.after_changes.meal_balance,
      assumptions: result.after_changes.assumptions,
    },
  };
}
