import type { CatalogExercise, ExperienceLevel, TrainingLocation } from '../catalog/types.js';

/**
 * Equipment/location/limitation/experience filtering for workout-plan generation (blueprint §11,
 * docs/decisions.md D-029), the exercise-catalog equivalent of `catalog/eligibility.ts`'s diet rules.
 * Every rule is re-derived from the catalog's own tags, never trusted from a cache, so a stale value
 * can never relax a safety constraint (ticket: "never includes an exercise the user's equipment/
 * location/limitations can't support").
 */
export interface TrainingConstraints {
  location: TrainingLocation | null;
  /** Free-text equipment ids the user declared they have (blueprint §5/§11). */
  equipmentIds: readonly string[];
  experience: ExperienceLevel | null;
  /** Recorded limitation tags (blueprint §5); matched against `contraindication_tags`. */
  limitationTags: readonly string[];
}

const LEVEL_ORDER: Record<ExperienceLevel, number> = {
  beginner: 0,
  intermediate: 1,
  advanced: 2,
};

/**
 * A `gym` or `both` location is assumed to give full gym equipment access (blueprint §11); only a
 * `home`-only location restricts exercises to the user's declared equipment. An exercise with no
 * equipment tags is bodyweight and always available.
 */
export function isEquipmentEligible(
  exercise: CatalogExercise,
  location: TrainingLocation | null,
  equipmentIds: readonly string[],
): boolean {
  if (exercise.equipment_tags.length === 0) return true;
  if (location === 'gym' || location === 'both') return true;
  const have = new Set(equipmentIds);
  return exercise.equipment_tags.every((tag) => have.has(tag));
}

/** An exercise is excluded entirely if ANY of its contraindication tags matches a recorded limitation. */
export function isLimitationSafe(
  exercise: CatalogExercise,
  limitationTags: readonly string[],
): boolean {
  if (limitationTags.length === 0) return true;
  const limitations = new Set(limitationTags);
  return !exercise.contraindication_tags.some((tag) => limitations.has(tag));
}

/**
 * Experience is a ceiling, not a floor: a beginner only sees beginner-level exercises, while an
 * advanced user sees the full progression (beginner through advanced), consistent with the catalog
 * gate's never-degrade-silently convention — an exercise above the user's level is never offered.
 */
export function isExperienceEligible(
  exercise: CatalogExercise,
  experience: ExperienceLevel | null,
): boolean {
  if (!experience) return exercise.level === 'beginner';
  return LEVEL_ORDER[exercise.level] <= LEVEL_ORDER[experience];
}

export function isExerciseEligible(
  exercise: CatalogExercise,
  constraints: TrainingConstraints,
): boolean {
  return (
    isEquipmentEligible(exercise, constraints.location, constraints.equipmentIds) &&
    isLimitationSafe(exercise, constraints.limitationTags) &&
    isExperienceEligible(exercise, constraints.experience)
  );
}

export function filterEligibleExercises(
  exercises: readonly CatalogExercise[],
  constraints: TrainingConstraints,
): CatalogExercise[] {
  return exercises.filter((e) => isExerciseEligible(e, constraints));
}
