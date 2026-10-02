import type { CatalogExercise } from '../catalog/types.js';

/**
 * How a `workout_plan_exercises.prescription_snapshot` jsonb column is shaped (an object, per the M1
 * check constraint `jsonb_typeof(prescription_snapshot) = 'object'`). Keeping the exercise's name and
 * instructions alongside the row means a session can be displayed without a join back to the catalog,
 * and keeps the prescription stable even if the catalog entry is later edited.
 */
export interface PrescriptionSnapshot {
  exercise_slug: string;
  exercise_name: string;
  movement_pattern: string;
  equipment_tags: string[];
  instructions: string[];
}

export function buildPrescriptionSnapshot(exercise: CatalogExercise): PrescriptionSnapshot {
  return {
    exercise_slug: exercise.slug,
    exercise_name: exercise.name,
    movement_pattern: exercise.movement_pattern,
    equipment_tags: exercise.equipment_tags,
    instructions: exercise.instructions,
  };
}

export function instructionsOf(snapshot: unknown): string[] {
  const instructions = (snapshot as Partial<PrescriptionSnapshot> | null)?.instructions;
  return Array.isArray(instructions) ? instructions : [];
}
