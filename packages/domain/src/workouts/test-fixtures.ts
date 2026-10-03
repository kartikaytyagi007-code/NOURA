import type { CatalogExercise, CatalogExerciseSubstitution } from '../catalog/types.js';

/** Small in-memory exercise catalog mirroring the shape of the M7 test-fixture seed, for pure unit tests. */

function exercise(
  partial: Partial<CatalogExercise> &
    Pick<CatalogExercise, 'id' | 'slug' | 'name' | 'movement_pattern'>,
): CatalogExercise {
  return {
    muscle_tags: [],
    equipment_tags: [],
    level: 'beginner',
    contraindication_tags: [],
    instructions: ['Do the exercise.'],
    quality_flag: 'test_fixture',
    ...partial,
  };
}

export const BODYWEIGHT_SQUAT = exercise({
  id: 'ex-bw-squat',
  slug: 'bodyweight-squat',
  name: 'Bodyweight squat',
  movement_pattern: 'squat',
  contraindication_tags: ['knee'],
});
export const BARBELL_SQUAT = exercise({
  id: 'ex-barbell-squat',
  slug: 'barbell-squat',
  name: 'Barbell back squat',
  movement_pattern: 'squat',
  equipment_tags: ['barbell'],
  level: 'advanced',
  contraindication_tags: ['knee', 'lower_back'],
});
export const GLUTE_BRIDGE = exercise({
  id: 'ex-glute-bridge',
  slug: 'glute-bridge',
  name: 'Glute bridge',
  movement_pattern: 'hinge',
  contraindication_tags: ['lower_back'],
});
export const PUSH_UP = exercise({
  id: 'ex-push-up',
  slug: 'push-up',
  name: 'Push-up',
  movement_pattern: 'horizontal_push',
  contraindication_tags: ['wrist', 'shoulder'],
});
export const DUMBBELL_ROW = exercise({
  id: 'ex-dumbbell-row',
  slug: 'dumbbell-row',
  name: 'Dumbbell row',
  movement_pattern: 'horizontal_pull',
  equipment_tags: ['dumbbell'],
  level: 'beginner',
  contraindication_tags: ['lower_back'],
});
export const PLANK = exercise({
  id: 'ex-plank',
  slug: 'plank',
  name: 'Plank',
  movement_pattern: 'core',
  contraindication_tags: ['lower_back', 'wrist'],
});

export const ALL_EXERCISES: CatalogExercise[] = [
  BODYWEIGHT_SQUAT,
  BARBELL_SQUAT,
  GLUTE_BRIDGE,
  PUSH_UP,
  DUMBBELL_ROW,
  PLANK,
];

export const ALL_SUBSTITUTIONS: CatalogExerciseSubstitution[] = [
  { exercise_id: BODYWEIGHT_SQUAT.id, substitute_id: BARBELL_SQUAT.id },
  { exercise_id: BARBELL_SQUAT.id, substitute_id: BODYWEIGHT_SQUAT.id },
];
