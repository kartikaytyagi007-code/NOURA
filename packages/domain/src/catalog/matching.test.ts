import { describe, expect, it } from 'vitest';
import { bestCatalogMatch, catalogCandidatesFor, matchFoodExact } from './matching.js';
import { PANEER, RICE, VEGETABLES } from './test-fixtures.js';

const FOODS = [RICE, VEGETABLES, PANEER];

describe('matchFoodExact', () => {
  it('matches case- and space-insensitively', () => {
    expect(matchFoodExact(FOODS, '  rice  ')).toBe(RICE);
    expect(matchFoodExact(FOODS, 'RICE')).toBe(RICE);
  });

  it('returns null for an unmatched label rather than guessing', () => {
    expect(matchFoodExact(FOODS, 'Pizza')).toBeNull();
  });
});

describe('catalogCandidatesFor', () => {
  it('ranks an exact match first', () => {
    expect(catalogCandidatesFor(FOODS, 'Rice')[0]).toBe(RICE.id);
  });

  it('finds a substring match', () => {
    expect(catalogCandidatesFor(FOODS, 'vegetables')).toContain(VEGETABLES.id);
  });

  it('returns an empty list for a label with no plausible match', () => {
    expect(catalogCandidatesFor(FOODS, 'Spacecraft fuel')).toEqual([]);
  });
});

describe('bestCatalogMatch', () => {
  it('returns the catalog food for an honest match', () => {
    expect(bestCatalogMatch(FOODS, 'Paneer')?.id).toBe(PANEER.id);
  });

  it('returns null, not a guess, when nothing matches', () => {
    expect(bestCatalogMatch(FOODS, 'Unidentified flying dish')).toBeNull();
  });
});
