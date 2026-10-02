import { describe, expect, it } from 'vitest';
import { catalogGate } from './gate.js';
import { ALL_RECIPES } from './test-fixtures.js';
import type { CatalogRecipe } from './types.js';

describe('catalogGate (docs/decisions.md D-025)', () => {
  it('allows the test_fixture catalog in development and test', () => {
    expect(catalogGate('development', ALL_RECIPES)).toEqual({ allowed: true });
    expect(catalogGate('test', ALL_RECIPES)).toEqual({ allowed: true });
  });

  it('refuses a test_fixture-only catalog in staging and production', () => {
    expect(catalogGate('staging', ALL_RECIPES)).toEqual({
      allowed: false,
      reason: 'test_fixture_not_allowed_in_deployed_env',
    });
    expect(catalogGate('production', ALL_RECIPES)).toEqual({
      allowed: false,
      reason: 'test_fixture_not_allowed_in_deployed_env',
    });
  });

  it('refuses an empty catalog everywhere', () => {
    expect(catalogGate('development', [])).toEqual({ allowed: false, reason: 'no_catalog' });
    expect(catalogGate('production', [])).toEqual({ allowed: false, reason: 'no_catalog' });
  });

  it('allows a deployed environment once at least one verified or reviewed recipe exists', () => {
    const reviewed: CatalogRecipe = {
      ...(ALL_RECIPES[0] as CatalogRecipe),
      id: 'reviewed-1',
      quality_flag: 'reviewed',
    };
    expect(catalogGate('production', [...ALL_RECIPES, reviewed])).toEqual({ allowed: true });
  });
});
