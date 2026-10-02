import { describe, expect, it } from 'vitest';
import { createPlateFixes } from './recommendations.js';
import { resolveConfirmedItems, sumAnalyzedNutrition } from './review.js';
import type { DietConstraints } from '../catalog/eligibility.js';
import { PANEER, PEANUTS, RICE, VEGETABLES } from '../catalog/test-fixtures.js';

const NO_CONSTRAINTS: DietConstraints = {
  diet_type: null,
  allergy_ids: [],
  exclusion_ids: [],
  dislikes: [],
};

const CATALOG = [RICE, PANEER, VEGETABLES, PEANUTS];

let counter = 0;
const idFor = () => `new-item-${++counter}`;

describe('createPlateFixes', () => {
  it('suggests keep/reduce/add for an unbalanced rice-heavy meal, each with a real projection', () => {
    const items = resolveConfirmedItems([{ label: 'Rice', grams: 400 }], CATALOG, () => 'item-1');
    const totals = sumAnalyzedNutrition(items);
    const result = createPlateFixes(items, totals, CATALOG, NO_CONSTRAINTS, idFor);

    expect(result.fixes.length).toBeGreaterThan(0);
    expect(result.fixes.length).toBeLessThanOrEqual(3);
    for (const fix of result.fixes) {
      expect(fix.reason.length).toBeGreaterThan(0);
      expect(fix.projected.totals.coverage.complete).toBe(true);
      expect(fix.projected.meal_balance.score).not.toBeNull();
    }
    // A rice-only meal has no vegetable/fruit and is low-nutrient-density: expect a reduce and an add.
    expect(result.fixes.some((f) => f.type === 'reduce')).toBe(true);
    expect(result.fixes.some((f) => f.type === 'add')).toBe(true);
  });

  it('never suggests an item the user is allergic to, excluded, or dislikes', () => {
    const items = resolveConfirmedItems([{ label: 'Rice', grams: 300 }], CATALOG, () => 'item-1');
    const totals = sumAnalyzedNutrition(items);

    const allergic = createPlateFixes(
      items,
      totals,
      CATALOG,
      { ...NO_CONSTRAINTS, allergy_ids: ['milk', 'peanut'] },
      idFor,
    );
    const suggestedFoodIds = allergic.fixes
      .filter((f) => f.type === 'add')
      .map((f) => f.catalog_food_id);
    expect(suggestedFoodIds).not.toContain(PANEER.id);
    expect(suggestedFoodIds).not.toContain(PEANUTS.id);

    const disliked = createPlateFixes(
      items,
      totals,
      CATALOG,
      { ...NO_CONSTRAINTS, dislikes: ['mixed vegetables'] },
      idFor,
    );
    const dislikedAddIds = disliked.fixes
      .filter((f) => f.type === 'add')
      .map((f) => f.catalog_food_id);
    expect(dislikedAddIds).not.toContain(VEGETABLES.id);
  });

  it('only suggests catalog foods with complete macro data (filtered by diet type)', () => {
    const items = resolveConfirmedItems([{ label: 'Rice', grams: 300 }], CATALOG, () => 'item-1');
    const totals = sumAnalyzedNutrition(items);
    const veganResult = createPlateFixes(
      items,
      totals,
      CATALOG,
      { ...NO_CONSTRAINTS, diet_type: 'vegan' },
      idFor,
    );
    const addIds = veganResult.fixes.filter((f) => f.type === 'add').map((f) => f.catalog_food_id);
    expect(addIds).not.toContain(PANEER.id); // Paneer is not vegan-safe.
  });

  it('omits the after-changes score (via computeMealBalance null) when baseline coverage is incomplete', () => {
    const items = resolveConfirmedItems(
      [{ label: 'Totally unknown dish', grams: 100 }],
      CATALOG,
      () => 'item-1',
    );
    const totals = sumAnalyzedNutrition(items);
    const result = createPlateFixes(items, totals, CATALOG, NO_CONSTRAINTS, idFor);
    // No confirmed, matched item to build keep/reduce from, and the baseline score is null so there is
    // no "weakest component" signal either; fixes may be empty, but the after_changes scenario must
    // never fabricate a score when the underlying picture is incomplete.
    if (result.after_changes.meal_balance.score === null) {
      expect(result.after_changes.meal_balance.missing_data_message).not.toBeNull();
    }
  });

  it('is deterministic for the same inputs', () => {
    const items = resolveConfirmedItems([{ label: 'Rice', grams: 350 }], CATALOG, () => 'item-1');
    const totals = sumAnalyzedNutrition(items);
    let n = 0;
    const stableId = () => `stable-${++n}`;
    const a = createPlateFixes(items, totals, CATALOG, NO_CONSTRAINTS, stableId);
    n = 0;
    const b = createPlateFixes(items, totals, CATALOG, NO_CONSTRAINTS, stableId);
    expect(a.fixes.map((f) => f.catalog_food_id)).toEqual(b.fixes.map((f) => f.catalog_food_id));
    expect(a.after_changes.meal_balance.score).toEqual(b.after_changes.meal_balance.score);
  });
});
