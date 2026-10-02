import { describe, expect, it } from 'vitest';
import { createAiProvider } from './factory.js';

describe('createAiProvider', () => {
  it('allows the mock in development and test, labelled as mock', async () => {
    for (const appEnv of ['development', 'test'] as const) {
      const provider = createAiProvider({ appEnv, provider: 'mock' });
      const result = await provider.coachReply({}, []);
      expect(result.meta.mock).toBe(true);
    }
  });

  it('refuses the mock in staging and production (fails closed)', () => {
    for (const appEnv of ['staging', 'production'] as const) {
      expect(() => createAiProvider({ appEnv, provider: 'mock' })).toThrow(/not allowed/);
    }
  });

  it('refuses a missing provider and a real provider without credentials', () => {
    expect(() => createAiProvider({ appEnv: 'production', provider: undefined })).toThrow(
      /not configured/,
    );
    expect(() => createAiProvider({ appEnv: 'production', provider: 'gemini' })).toThrow(
      /requires/,
    );
  });

  it('answers PROVIDER_UNAVAILABLE for a configured real provider until its adapter exists', async () => {
    const provider = createAiProvider({
      appEnv: 'production',
      provider: 'gemini',
      apiKey: 'k',
      modelId: 'm',
    });
    await expect(
      provider.recognizeMeal({ bytes: new Uint8Array(), mime: 'image/jpeg' }, {}),
    ).rejects.toMatchObject({
      code: 'PROVIDER_UNAVAILABLE',
    });
  });

  it('labels mock recognition output as mock and never includes a nutrition value', async () => {
    const provider = createAiProvider({ appEnv: 'test', provider: 'mock' });
    const result = await provider.recognizeMeal(
      { bytes: new Uint8Array([1, 2, 3]), mime: 'image/jpeg' },
      {},
    );
    expect(result.meta.mock).toBe(true);
    // The mock returns food labels and gram estimates (D-026) but never a kcal/macro number.
    expect(JSON.stringify(result.output)).not.toMatch(/kcal|protein_g|carbohydrate_g|fat_g/);
  });

  it('can simulate a non-food photo for the mock recognizer', async () => {
    const provider = createAiProvider({ appEnv: 'test', provider: 'mock' });
    const { output } = await provider.recognizeMeal(
      { bytes: new Uint8Array([9, 9, 9]), mime: 'image/jpeg' },
      { mock_scenario: 'non_food' },
    );
    expect(output).toMatchObject({ image_is_food: false, items: [] });
  });
});
