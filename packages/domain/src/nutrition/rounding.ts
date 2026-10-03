/**
 * Shared rounding so a meal's stored nutrition and a day/week total always reconcile exactly
 * (blueprint §7). Each nutrient is rounded once, at the meal level; totals are produced by summing
 * the already-rounded integer-tenths representation of each value, never by re-summing floating
 * point numbers, so there is no silent drift between a meal's `nutrition_snapshot` and the total
 * that sums it.
 */

/** Energy is reported as a whole kcal. */
export function roundEnergy(value: number): number {
  return Math.round(value);
}

/** Grams-denominated macros (protein/carbohydrate/fat/fibre) are reported to 1 decimal place. */
export function roundGrams(value: number): number {
  return Math.round(value * 10) / 10;
}

/** Scales an already 1-decimal value to an integer so it can be summed without floating-point drift. */
function tenths(value: number): number {
  return Math.round(value * 10);
}

/** Sums values that are each already rounded to 1 decimal, reconciling exactly. */
export function sumGrams(values: readonly number[]): number {
  return values.reduce((total, v) => total + tenths(v), 0) / 10;
}

/** Sums values that are each already rounded to a whole kcal. */
export function sumEnergy(values: readonly number[]): number {
  return values.reduce((total, v) => total + Math.round(v), 0);
}
