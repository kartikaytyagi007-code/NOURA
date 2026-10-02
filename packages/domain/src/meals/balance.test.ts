import { describe, expect, it } from 'vitest';
import { computeMealBalance } from './balance.js';
import { resolveConfirmedItems, sumAnalyzedNutrition } from './review.js';
import { PANEER, RICE } from '../catalog/test-fixtures.js';

describe('computeMealBalance', () => {
  it('is null with a message when nutrition coverage is incomplete', () => {
    const items = resolveConfirmedItems(
      [{ label: 'Unknown dish', grams: 100 }],
      [RICE],
      () => 'id-1',
    );
    const totals = sumAnalyzedNutrition(items);
    const balance = computeMealBalance(items, totals);
    expect(balance.score).toBeNull();
    expect(balance.missing_data_message).not.toBeNull();
  });

  it('scores a fully-matched meal with four components, never a medical claim', () => {
    const items = resolveConfirmedItems(
      [
        { label: 'Rice', grams: 150 },
        { label: 'Paneer', grams: 100 },
      ],
      [RICE, PANEER],
      (i) => `id-${i}`,
    );
    const totals = sumAnalyzedNutrition(items);
    const balance = computeMealBalance(items, totals);
    expect(balance.score).not.toBeNull();
    expect(balance.components).toHaveLength(4);
    expect(balance.components.every((c) => (c.score ?? 0) <= c.max_score)).toBe(true);
  });

  it('is null for an empty item list', () => {
    const balance = computeMealBalance([], sumAnalyzedNutrition([]));
    expect(balance.score).toBeNull();
  });
});
