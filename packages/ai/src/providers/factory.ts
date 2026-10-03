import { AppError } from '@noura/domain';
import { MockAiProvider } from './mock.js';
import type { AiProvider, AiResult } from './types.js';

export type AppEnv = 'development' | 'test' | 'staging' | 'production';
export type AiProviderName = 'mock' | 'gemini';

export interface AiProviderConfig {
  appEnv: AppEnv;
  provider: AiProviderName | undefined;
  apiKey?: string | undefined;
  modelId?: string | undefined;
}

/**
 * Fails closed: the mock is only available in development/test, and a real provider requires its key
 * and model id. Real adapters are implemented in M4+; until then a configured real provider answers
 * every call with PROVIDER_UNAVAILABLE rather than silently falling back to the mock.
 */
export function createAiProvider(config: AiProviderConfig): AiProvider {
  if (!config.provider) {
    throw new Error('AI_PROVIDER is not configured');
  }
  if (config.provider === 'mock') {
    if (config.appEnv !== 'development' && config.appEnv !== 'test') {
      throw new Error(`AI_PROVIDER=mock is not allowed when APP_ENV=${config.appEnv}`);
    }
    return new MockAiProvider();
  }
  if (!config.apiKey || !config.modelId) {
    throw new Error(`AI_PROVIDER=${config.provider} requires an API key and model id`);
  }
  return new UnavailableProvider(config.provider);
}

class UnavailableProvider implements AiProvider {
  constructor(readonly name: string) {}

  private fail(): Promise<AiResult<unknown>> {
    return Promise.reject(
      new AppError('PROVIDER_UNAVAILABLE', 'This feature is not available yet.', {
        retryable: false,
      }),
    );
  }

  recognizeMeal = () => this.fail();
  explainMeal = () => this.fail();
  rankDietCandidates = () => this.fail();
  explainWeeklyInsights = () => this.fail();
  coachReply = () => this.fail();
}
