import type { CatalogExercise, CatalogExerciseSubstitution } from '../catalog/types.js';
import { filterEligibleExercises, type TrainingConstraints } from './eligibility.js';

/** Matches the contract's `Substitutions.candidates` maxItems: 10. */
const MAX_CANDIDATES = 10;

export interface SubstitutionCandidate {
  exercise: CatalogExercise;
  reason: string;
}

/**
 * Compatible substitutions for one exercise (blueprint §11): only catalog-declared relationships
 * (`app.exercise_substitutions`) are ever offered, filtered to what the user's equipment, location,
 * limitations and experience can actually support — never an invented "similar" exercise.
 */
export function substitutionsFor(input: {
  exerciseId: string;
  exercises: readonly CatalogExercise[];
  relationships: readonly CatalogExerciseSubstitution[];
  constraints: TrainingConstraints;
}): SubstitutionCandidate[] {
  const byId = new Map(input.exercises.map((e) => [e.id, e]));
  const substituteIds = input.relationships
    .filter((r) => r.exercise_id === input.exerciseId)
    .map((r) => r.substitute_id);
  const candidates = substituteIds
    .map((id) => byId.get(id))
    .filter((e): e is CatalogExercise => e !== undefined);
  const eligible = filterEligibleExercises(candidates, input.constraints);
  return eligible.slice(0, MAX_CANDIDATES).map((exercise) => ({
    exercise,
    reason:
      exercise.equipment_tags.length === 0
        ? 'Trains the same movement pattern with no equipment required.'
        : `Trains the same movement pattern using ${exercise.equipment_tags.join(', ')}.`,
  }));
}
