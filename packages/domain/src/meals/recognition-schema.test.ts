import { describe, expect, it } from 'vitest';
import { RICE, PANEER } from '../catalog/test-fixtures.js';
import {
  RecognitionValidationError,
  toValidatedRecognition,
  validateProviderRecognition,
} from './recognition-schema.js';

const VALID = {
  schema_version: '1',
  image_is_food: true,
  quality: 'usable',
  items: [
    {
      temporary_id: 'a',
      label: 'Rice',
      alternative_labels: [],
      confidence_band: 'high',
      estimated_grams: { min: 100, max: 150 },
      preparation_questions: [],
      needs_confirmation: false,
    },
  ],
  clarification: null,
};

describe('validateProviderRecognition', () => {
  it('accepts a well-formed response', () => {
    expect(() => validateProviderRecognition(VALID)).not.toThrow();
  });

  it('rejects a response missing required fields rather than crashing', () => {
    expect(() => validateProviderRecognition({ schema_version: '1' })).toThrow(
      RecognitionValidationError,
    );
  });

  it('rejects an unknown schema_version (forward compatibility)', () => {
    expect(() => validateProviderRecognition({ ...VALID, schema_version: '2' })).toThrow(
      RecognitionValidationError,
    );
  });

  it('rejects extra/unexpected fields (strict shape, adversarial-response safe)', () => {
    expect(() =>
      validateProviderRecognition({
        ...VALID,
        items: [{ ...VALID.items[0], catalog_candidates: ['x'] }],
      }),
    ).toThrow(RecognitionValidationError);
  });

  it('rejects a malformed estimated_grams range', () => {
    expect(() =>
      validateProviderRecognition({
        ...VALID,
        items: [{ ...VALID.items[0], estimated_grams: { min: 200, max: 100 } }],
      }),
    ).toThrow(RecognitionValidationError);
  });

  it('rejects more than 20 items (bounded field)', () => {
    const items = Array.from({ length: 21 }, (_, i) => ({
      ...VALID.items[0],
      temporary_id: `i${i}`,
    }));
    expect(() => validateProviderRecognition({ ...VALID, items })).toThrow(
      RecognitionValidationError,
    );
  });

  it('never crashes on completely garbage/adversarial input', () => {
    for (const garbage of [null, undefined, 'a string', 42, [], { toString: () => 'x' }]) {
      expect(() => validateProviderRecognition(garbage)).toThrow(RecognitionValidationError);
    }
  });
});

describe('toValidatedRecognition', () => {
  it('attaches catalog_candidates deterministically from the catalog, never from the provider', () => {
    const validated = validateProviderRecognition(VALID);
    const out = toValidatedRecognition(validated, [RICE, PANEER]);
    expect(out.items[0]!.catalog_candidates).toEqual([RICE.id]);
  });

  it('returns no candidates for a label that matches nothing in the catalog', () => {
    const validated = validateProviderRecognition({
      ...VALID,
      items: [{ ...VALID.items[0], label: 'Development mock unlisted dish' }],
    });
    const out = toValidatedRecognition(validated, [RICE, PANEER]);
    expect(out.items[0]!.catalog_candidates).toEqual([]);
  });
});
