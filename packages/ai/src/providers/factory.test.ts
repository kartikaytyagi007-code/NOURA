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

  it('never returns nutrition-like data from the mock recognizer', async () => {
    const provider = createAiProvider({ appEnv: 'test', provider: 'mock' });
    const { output } = await provider.recognizeMeal(
      { bytes: new Uint8Array(), mime: 'image/jpeg' },
      {},
    );
    expect(output).toMatchObject({ image_is_food: false, items: [] });
  });
});
