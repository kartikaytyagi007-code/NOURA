import { describe, expect, it } from 'vitest';
import { validateWeightEntry, WEIGHT_MAX_KG, WEIGHT_MIN_KG } from './weight.js';

const NOW = new Date('2026-10-02T12:00:00Z');

describe('validateWeightEntry', () => {
  it('accepts a realistic, past-dated entry', () => {
    expect(
      validateWeightEntry({ measuredAtIso: '2026-10-01T08:00:00Z', weightKg: 72.4 }, NOW),
    ).toEqual([]);
  });

  it('accepts the range boundaries', () => {
    expect(
      validateWeightEntry({ measuredAtIso: '2026-10-01T08:00:00Z', weightKg: WEIGHT_MIN_KG }, NOW),
    ).toEqual([]);
    expect(
      validateWeightEntry({ measuredAtIso: '2026-10-01T08:00:00Z', weightKg: WEIGHT_MAX_KG }, NOW),
    ).toEqual([]);
  });

  it('rejects an unrealistic weight below the minimum', () => {
    const errors = validateWeightEntry({ measuredAtIso: '2026-10-01T08:00:00Z', weightKg: 5 }, NOW);
    expect(errors).toEqual([
      { field: 'body.weight_kg', code: 'out_of_range', message: expect.any(String) },
    ]);
  });

  it('rejects an unrealistic weight above the maximum', () => {
    const errors = validateWeightEntry(
      { measuredAtIso: '2026-10-01T08:00:00Z', weightKg: 1000 },
      NOW,
    );
    expect(errors[0]?.code).toBe('out_of_range');
  });

  it('rejects a future date', () => {
    const errors = validateWeightEntry(
      { measuredAtIso: '2026-10-03T12:00:00Z', weightKg: 70 },
      NOW,
    );
    expect(errors).toEqual([
      { field: 'body.measured_at', code: 'future_date', message: expect.any(String) },
    ]);
  });

  it('tolerates a few minutes of clock skew', () => {
    const errors = validateWeightEntry(
      { measuredAtIso: '2026-10-02T12:02:00Z', weightKg: 70 },
      NOW,
    );
    expect(errors).toEqual([]);
  });

  it('rejects an unparsable date', () => {
    const errors = validateWeightEntry({ measuredAtIso: 'not-a-date', weightKg: 70 }, NOW);
    expect(errors).toEqual([
      { field: 'body.measured_at', code: 'invalid', message: expect.any(String) },
    ]);
  });

  it('reports both errors when both are wrong', () => {
    const errors = validateWeightEntry(
      { measuredAtIso: '2026-10-03T12:00:00Z', weightKg: 1000 },
      NOW,
    );
    expect(errors).toHaveLength(2);
  });
});
