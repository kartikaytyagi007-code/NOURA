import type { FieldError } from '../errors.js';

/**
 * Weight-history validation (blueprint §6, §16 "M8 Progress"). Ranges mirror the
 * `app.weight_logs.weight_kg` database constraint and the OpenAPI schema exactly, so a request that
 * fails here would also fail at the database — this just gives the caller a field-level 422 instead
 * of a generic constraint violation.
 */

export const WEIGHT_MIN_KG = 20;
export const WEIGHT_MAX_KG = 400;

/** Small clock-skew allowance so a client's "now" a few minutes ahead of the server is not rejected. */
const FUTURE_TOLERANCE_MS = 5 * 60 * 1000;

export interface WeightEntryInput {
  measuredAtIso: string;
  weightKg: number;
}

/** Pure validation; returns field errors (empty when the entry is valid). Never throws. */
export function validateWeightEntry(
  input: WeightEntryInput,
  nowUtc: Date = new Date(),
): FieldError[] {
  const errors: FieldError[] = [];

  if (
    !Number.isFinite(input.weightKg) ||
    input.weightKg < WEIGHT_MIN_KG ||
    input.weightKg > WEIGHT_MAX_KG
  ) {
    errors.push({
      field: 'body.weight_kg',
      code: 'out_of_range',
      message: `must be between ${WEIGHT_MIN_KG} and ${WEIGHT_MAX_KG} kg`,
    });
  }

  const measuredAt = new Date(input.measuredAtIso);
  if (Number.isNaN(measuredAt.getTime())) {
    errors.push({ field: 'body.measured_at', code: 'invalid', message: 'not a valid date-time' });
  } else if (measuredAt.getTime() - nowUtc.getTime() > FUTURE_TOLERANCE_MS) {
    errors.push({
      field: 'body.measured_at',
      code: 'future_date',
      message: 'cannot be in the future',
    });
  }

  return errors;
}
