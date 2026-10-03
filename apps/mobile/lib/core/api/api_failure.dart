import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

enum ApiFailureKind {
  offline,
  timeout,
  unauthenticated,
  notFound,
  validation,
  conflict,
  quota,
  unavailable,
  server,
  unknown,
}

@immutable
class FieldError {
  const FieldError({required this.field, required this.code, required this.message});
  final String field;
  final String code;
  final String message;
}

/// Standardized failure for every API call (blueprint §11 error envelope). Widgets render these;
/// they never inspect Dio exceptions directly.
@immutable
class ApiFailure implements Exception {
  const ApiFailure({
    required this.kind,
    required this.message,
    this.code,
    this.fieldErrors = const [],
    this.retryable = false,
    this.requestId,
    this.statusCode,
  });

  final ApiFailureKind kind;
  final String message;
  final String? code;
  final List<FieldError> fieldErrors;
  final bool retryable;
  final String? requestId;
  final int? statusCode;

  bool get isOffline => kind == ApiFailureKind.offline || kind == ApiFailureKind.timeout;

  static const _kindForCode = {
    'UNAUTHENTICATED': ApiFailureKind.unauthenticated,
    'NOT_FOUND': ApiFailureKind.notFound,
    'VALIDATION_ERROR': ApiFailureKind.validation,
    'UNSUPPORTED_INPUT': ApiFailureKind.validation,
    'CONSTRAINT_CONFLICT': ApiFailureKind.validation,
    'REVISION_CONFLICT': ApiFailureKind.conflict,
    'QUOTA_EXCEEDED': ApiFailureKind.quota,
    'PROVIDER_UNAVAILABLE': ApiFailureKind.unavailable,
    'INTERNAL_ERROR': ApiFailureKind.server,
  };

  factory ApiFailure.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionError:
        return const ApiFailure(
          kind: ApiFailureKind.offline,
          message: "You're offline or the server can't be reached.",
          retryable: true,
        );
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiFailure(
          kind: ApiFailureKind.timeout,
          message: 'The server took too long to respond.',
          retryable: true,
        );
      case DioExceptionType.cancel:
        return const ApiFailure(kind: ApiFailureKind.unknown, message: 'The request was cancelled.');
      case DioExceptionType.badCertificate:
        return const ApiFailure(kind: ApiFailureKind.unknown, message: 'The connection is not secure.');
      case DioExceptionType.badResponse:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.unknown:
        break;
    }

    final response = error.response;
    final status = response?.statusCode;
    final requestId = response?.headers.value('x-request-id');
    final data = response?.data;
    if (data is Map && data['error'] is Map) {
      final body = data['error'] as Map;
      final code = body['code'] is String ? body['code'] as String : null;
      final fields = <FieldError>[
        if (body['field_errors'] is List)
          for (final f in body['field_errors'] as List)
            if (f is Map) FieldError(field: '${f['field']}', code: '${f['code']}', message: '${f['message']}'),
      ];
      return ApiFailure(
        kind: _kindForCode[code] ?? _kindForStatus(status),
        message: body['message'] is String ? body['message'] as String : 'Something went wrong.',
        code: code,
        fieldErrors: fields,
        retryable: body['retryable'] == true,
        requestId: requestId,
        statusCode: status,
      );
    }
    if (status == null) {
      // A serialization failure or other client-side problem, never shown with raw details.
      return const ApiFailure(kind: ApiFailureKind.unknown, message: 'Something went wrong. Please try again.');
    }
    return ApiFailure(
      kind: _kindForStatus(status),
      message: status >= 500 ? 'The server had a problem. Please try again.' : 'Something went wrong.',
      retryable: status >= 500,
      requestId: requestId,
      statusCode: status,
    );
  }

  static ApiFailureKind _kindForStatus(int? status) => switch (status) {
    401 => ApiFailureKind.unauthenticated,
    404 => ApiFailureKind.notFound,
    409 => ApiFailureKind.conflict,
    422 => ApiFailureKind.validation,
    429 => ApiFailureKind.quota,
    503 => ApiFailureKind.unavailable,
    final int s when s >= 500 => ApiFailureKind.server,
    _ => ApiFailureKind.unknown,
  };

  @override
  String toString() => 'ApiFailure($kind, $code, request_id=$requestId)';
}
