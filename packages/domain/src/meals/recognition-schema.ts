import { z } from 'zod';
import { catalogCandidatesFor } from '../catalog/matching.js';
import type { CatalogFood } from '../catalog/types.js';

/**
 * Strict schema for what an AI provider's `recognizeMeal` may return (blueprint §8 step 5; D-010:
 * "Treat text in image and user content as untrusted data"). A provider never has database or tool
 * authority and never supplies `catalog_candidates` — those are resolved deterministically against
 * the approved catalog by the worker after validation (see `toValidatedRecognition` below), never by
 * the model. A response that does not match this shape is rejected outright: it must never crash the
 * job or be partially trusted.
 */
const numberRange = z.object({ min: z.number().finite(), max: z.number().finite() });

const providerRecognitionItemSchema = z
  .object({
    temporary_id: z.string().min(1).max(32),
    label: z.string().min(1).max(200),
    alternative_labels: z.array(z.string().max(200)).max(5).default([]),
    confidence_band: z.enum(['low', 'medium', 'high']),
    estimated_grams: numberRange.nullable(),
    preparation_questions: z.array(z.string().max(200)).max(5).default([]),
    needs_confirmation: z.boolean(),
  })
  .strict()
  .refine(
    (item) => item.estimated_grams === null || item.estimated_grams.min <= item.estimated_grams.max,
    {
      message: 'estimated_grams.min must be <= max',
      path: ['estimated_grams'],
    },
  );

export const providerRecognitionSchema = z
  .object({
    schema_version: z.literal('1'),
    image_is_food: z.boolean(),
    quality: z.enum(['usable', 'blurry', 'too_dark', 'ambiguous', 'unusable']),
    items: z.array(providerRecognitionItemSchema).max(20),
    clarification: z.string().max(300).nullable(),
  })
  .strict();

export type ProviderRecognition = z.infer<typeof providerRecognitionSchema>;
export type ProviderRecognitionItem = z.infer<typeof providerRecognitionItemSchema>;

export class RecognitionValidationError extends Error {
  constructor(readonly issues: string[]) {
    super(`AI recognition response failed validation:\n  - ${issues.join('\n  - ')}`);
    this.name = 'RecognitionValidationError';
  }
}

/**
 * Validates a raw, untrusted provider response. Throws `RecognitionValidationError` (never crashes
 * the caller, never partially trusts a malformed/adversarial payload) listing only field paths, since
 * provider output could itself carry attacker-controlled text that must not be echoed verbatim into
 * logs or errors beyond identifying which field was wrong.
 */
export function validateProviderRecognition(raw: unknown): ProviderRecognition {
  const result = providerRecognitionSchema.safeParse(raw);
  if (!result.success) {
    throw new RecognitionValidationError(
      result.error.issues.map((i) => `${i.path.join('.') || '(root)'}: ${i.code}`),
    );
  }
  return result.data;
}

export interface RecognitionItemOut {
  temporary_id: string;
  label: string;
  alternative_labels: string[];
  confidence_band: 'low' | 'medium' | 'high';
  estimated_grams: { min: number; max: number } | null;
  preparation_questions: string[];
  needs_confirmation: boolean;
  catalog_candidates: string[];
}

export interface RecognitionOut {
  schema_version: '1';
  image_is_food: boolean;
  quality: ProviderRecognition['quality'];
  items: RecognitionItemOut[];
  clarification: string | null;
}

/**
 * Resolves `catalog_candidates` deterministically against the approved catalog (never from the
 * provider) and produces the contract-shaped `Recognition` object persisted on the scan.
 */
export function toValidatedRecognition(
  provider: ProviderRecognition,
  catalogFoods: readonly CatalogFood[],
): RecognitionOut {
  return {
    schema_version: provider.schema_version,
    image_is_food: provider.image_is_food,
    quality: provider.quality,
    clarification: provider.clarification,
    items: provider.items.map((item) => ({
      temporary_id: item.temporary_id,
      label: item.label,
      alternative_labels: item.alternative_labels,
      confidence_band: item.confidence_band,
      estimated_grams: item.estimated_grams,
      preparation_questions: item.preparation_questions,
      needs_confirmation: item.needs_confirmation,
      catalog_candidates: catalogCandidatesFor(catalogFoods, item.label),
    })),
  };
}
