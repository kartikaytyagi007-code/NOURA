import { AppError, type ErrorCode, type FieldError } from '@noura/domain';
import type { FastifyError, FastifyInstance, FastifyReply, FastifyRequest } from 'fastify';

export interface ErrorEnvelope {
  error: { code: ErrorCode; message: string; field_errors: FieldError[]; retryable: boolean };
  meta: { request_id: string };
}

export function errorEnvelope(
  request: FastifyRequest,
  code: ErrorCode,
  message: string,
  fieldErrors: FieldError[] = [],
  retryable = false,
): ErrorEnvelope {
  return {
    error: { code, message, field_errors: fieldErrors, retryable },
    meta: { request_id: request.id },
  };
}

/** Converts Ajv validation errors to field errors: "body/weight_kg" -> "body.weight_kg". */
function fieldErrorsFrom(error: FastifyError): FieldError[] {
  const context = error.validationContext ?? 'request';
  return (error.validation ?? []).slice(0, 50).map((v) => {
    const missing =
      v.keyword === 'required'
        ? `/${String((v.params as { missingProperty?: string }).missingProperty)}`
        : '';
    const extra =
      v.keyword === 'additionalProperties'
        ? `/${String((v.params as { additionalProperty?: string }).additionalProperty)}`
        : '';
    const pointer = `${v.instancePath}${missing}${extra}`;
    return {
      field: `${context}${pointer.replace(/\//g, '.')}`,
      code: v.keyword,
      message: (v.message ?? 'is invalid').slice(0, 300),
    };
  });
}

function send(reply: FastifyReply, status: number, body: ErrorEnvelope) {
  return reply.status(status).send(body);
}

/**
 * Standardized error responses (blueprint §11). Unexpected errors return a generic message; the
 * details go to structured logs with the request id, never to the client.
 */
export function registerErrorHandling(app: FastifyInstance): void {
  app.setErrorHandler((error: FastifyError, request, reply) => {
    if (error instanceof AppError) {
      if (error.statusCode >= 500) request.log.error({ err: error }, 'application error');
      return send(
        reply,
        error.statusCode,
        errorEnvelope(request, error.code, error.message, error.fieldErrors, error.retryable),
      );
    }
    if (error.validation) {
      return send(
        reply,
        422,
        errorEnvelope(
          request,
          'VALIDATION_ERROR',
          'Request validation failed.',
          fieldErrorsFrom(error),
        ),
      );
    }
    if (error.code === 'FST_ERR_CTP_INVALID_MEDIA_TYPE') {
      return send(
        reply,
        422,
        errorEnvelope(request, 'UNSUPPORTED_INPUT', 'Unsupported content type.'),
      );
    }
    if (error.code === 'FST_ERR_CTP_BODY_TOO_LARGE') {
      return send(
        reply,
        413,
        errorEnvelope(request, 'VALIDATION_ERROR', 'Request body is too large.'),
      );
    }
    if (typeof error.statusCode === 'number' && error.statusCode >= 400 && error.statusCode < 500) {
      // Malformed JSON, empty bodies and similar client errors.
      return send(
        reply,
        422,
        errorEnvelope(request, 'VALIDATION_ERROR', 'Request could not be processed.'),
      );
    }
    request.log.error({ err: error }, 'unhandled error');
    return send(
      reply,
      500,
      errorEnvelope(request, 'INTERNAL_ERROR', 'Something went wrong. Please try again.', [], true),
    );
  });

  app.setNotFoundHandler((request, reply) =>
    send(reply, 404, errorEnvelope(request, 'NOT_FOUND', 'Resource not found.')),
  );
}
