import { describe, expect, it } from 'vitest';
import { substitutionsFor } from './substitutions.js';
import {
  ALL_EXERCISES,
  ALL_SUBSTITUTIONS,
  BARBELL_SQUAT,
  BODYWEIGHT_SQUAT,
} from './test-fixtures.js';

describe('substitutionsFor', () => {
  it('offers only catalog-declared, currently-eligible substitutes', () => {
    const candidates = substitutionsFor({
      exerciseId: BODYWEIGHT_SQUAT.id,
      exercises: ALL_EXERCISES,
      relationships: ALL_SUBSTITUTIONS,
      constraints: {
        location: 'gym',
        equipmentIds: [],
        experience: 'advanced',
        limitationTags: [],
      },
    });
    expect(candidates.map((c) => c.exercise.id)).toEqual([BARBELL_SQUAT.id]);
  });

  it('never offers a substitute the user cannot currently do', () => {
    const candidates = substitutionsFor({
      exerciseId: BODYWEIGHT_SQUAT.id,
      exercises: ALL_EXERCISES,
      relationships: ALL_SUBSTITUTIONS,
      // Home-only, no barbell, beginner: the barbell squat substitute is excluded on every axis.
      constraints: {
        location: 'home',
        equipmentIds: [],
        experience: 'beginner',
        limitationTags: [],
      },
    });
    expect(candidates).toEqual([]);
  });

  it('returns nothing for an exercise with no declared relationships', () => {
    const candidates = substitutionsFor({
      exerciseId: 'ex-plank',
      exercises: ALL_EXERCISES,
      relationships: ALL_SUBSTITUTIONS,
      constraints: {
        location: 'gym',
        equipmentIds: [],
        experience: 'advanced',
        limitationTags: [],
      },
    });
    expect(candidates).toEqual([]);
  });
});
