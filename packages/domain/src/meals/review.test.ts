import { describe, expect, it } from 'vitest';
import { AppError } from '../errors.js';
import { PANEER, RICE } from '../catalog/test-fixtures.js';
import { resolveConfirmedItems, sumAnalyzedNutrition } from './review.js';

const foods = [RICE, PANEER];

describe('resolveConfirmedItems', () => {
  it('resolves a catalog-matched item deterministically from grams, never from the AI', () => {
    const [item] = resolveConfirmedItems([{ label: 'Rice', grams: 100 }], foods, () => 'id-1');
    expect(item!.food_id).toBe(RICE.id);
    expect(item!.nutrients).toEqual({
      energy_kcal: 130,
      protein_g: 2.7,
      carbohydrate_g: 28,
      fat_g: 0.3,
      fibre_g: 0.4,
    });
    expect(item!.uncertainty).toBe('low');
  });

  it('honestly surfaces an item the catalog cannot match, with no nutrition claim', () => {
    const [item] = resolveConfirmedItems(
      [{ label: 'Grandma’s secret casserole', grams: 150 }],
      foods,
      () => 'id-1',
    );
    expect(item!.food_id).toBeNull();
    expect(item!.nutrients).toBeNull();
    expect(item!.uncertainty).toBe('high');
  });

  it('lets a client pin an explicit food_id even if the label differs (user correction)', () => {
    const [item] = resolveConfirmedItems(
      [{ label: 'Some paneer dish', food_id: PANEER.id, grams: 80 }],
      foods,
      () => 'id-1',
    );
    expect(item!.food_id).toBe(PANEER.id);
    expect(item!.nutrients).not.toBeNull();
  });

  it('rejects an item with neither grams nor a serving', () => {
    expect(() => resolveConfirmedItems([{ label: 'Rice' }], foods, () => 'id-1')).toThrow(AppError);
  });

  it('batches field errors across multiple invalid items in one VALIDATION_ERROR', () => {
    try {
      resolveConfirmedItems([{ label: 'Rice' }, { label: 'Paneer' }], foods, () => 'id-1');
      expect.unreachable();
    } catch (error) {
      expect(error).toBeInstanceOf(AppError);
      expect((error as AppError).fieldErrors).toHaveLength(2);
    }
  });
});

describe('sumAnalyzedNutrition', () => {
  it('sums matched items exactly (no floating point drift)', () => {
    const items = resolveConfirmedItems(
      [
        { label: 'Rice', grams: 100 },
        { label: 'Paneer', grams: 100 },
      ],
      foods,
      (i) => `id-${i}`,
    );
    const totals = sumAnalyzedNutrition(items);
    expect(totals.nutrients.energy_kcal).toBe(130 + 265);
    expect(totals.coverage.complete).toBe(true);
  });

  it('reports the total as unknown (not a partial guess) when any item is unmatched', () => {
    const items = resolveConfirmedItems(
      [
        { label: 'Rice', grams: 100 },
        { label: 'Unknown dish', grams: 50 },
      ],
      foods,
      (i) => `id-${i}`,
    );
    const totals = sumAnalyzedNutrition(items);
    expect(totals.nutrients.energy_kcal).toBeNull();
    expect(totals.coverage.complete).toBe(false);
    expect(totals.coverage.items_total).toBe(2);
  });
});
