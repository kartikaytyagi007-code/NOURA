/** Standard API error codes (blueprint §11) plus INTERNAL_ERROR for unexpected failures. */
export const ERROR_CODES = [
  'VALIDATION_ERROR',
  'UNAUTHENTICATED',
  'NOT_FOUND',
  'REVISION_CONFLICT',
  'QUOTA_EXCEEDED',
  'PROVIDER_UNAVAILABLE',
  'UNSUPPORTED_INPUT',
  'CONSTRAINT_CONFLICT',
  'INTERNAL_ERROR',
] as const;

export type ErrorCode = (typeof ERROR_CODES)[number];

export const ERROR_STATUS: Record<ErrorCode, number> = {
  VALIDATION_ERROR: 422,
  UNAUTHENTICATED: 401,
  NOT_FOUND: 404,
  REVISION_CONFLICT: 409,
  QUOTA_EXCEEDED: 429,
  PROVIDER_UNAVAILABLE: 503,
  UNSUPPORTED_INPUT: 422,
  CONSTRAINT_CONFLICT: 422,
  INTERNAL_ERROR: 500,
};

export interface FieldError {
  field: string;
  code: string;
  message: string;
}

/** A user-safe application error. Message text must never contain secrets or provider internals. */
export class AppError extends Error {
  readonly code: ErrorCode;
  readonly statusCode: number;
  readonly fieldErrors: FieldError[];
  readonly retryable: boolean;

  constructor(
    code: ErrorCode,
    message: string,
    options: { fieldErrors?: FieldError[]; retryable?: boolean; cause?: unknown } = {},
  ) {
    super(message, { cause: options.cause });
    this.name = 'AppError';
    this.code = code;
    this.statusCode = ERROR_STATUS[code];
    this.fieldErrors = options.fieldErrors ?? [];
    this.retryable = options.retryable ?? code === 'PROVIDER_UNAVAILABLE';
  }
}
