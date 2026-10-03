import { describe, expect, it } from 'vitest';
import { AppError, ERROR_CODES, ERROR_STATUS } from './errors.js';

describe('AppError', () => {
  it('maps every code to the blueprint status', () => {
    expect(ERROR_STATUS).toMatchObject({
      VALIDATION_ERROR: 422,
      UNAUTHENTICATED: 401,
      NOT_FOUND: 404,
      REVISION_CONFLICT: 409,
      QUOTA_EXCEEDED: 429,
      PROVIDER_UNAVAILABLE: 503,
    });
    expect(Object.keys(ERROR_STATUS).sort()).toEqual([...ERROR_CODES].sort());
  });

  it('marks provider unavailability retryable by default and others not', () => {
    expect(new AppError('PROVIDER_UNAVAILABLE', 'x').retryable).toBe(true);
    expect(new AppError('NOT_FOUND', 'x').retryable).toBe(false);
  });
});
