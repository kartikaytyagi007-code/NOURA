import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noura/core/api/api_failure.dart';

DioException _response(int status, Object? data, {Map<String, List<String>> headers = const {}}) {
  final options = RequestOptions(path: '/v1/me');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<Object?>(
      requestOptions: options,
      statusCode: status,
      data: data,
      headers: Headers.fromMap(headers),
    ),
  );
}

void main() {
  test('maps the standard error envelope, field errors and request id', () {
    final failure = ApiFailure.fromDio(
      _response(
        422,
        {
          'error': {
            'code': 'VALIDATION_ERROR',
            'message': 'Some fields are invalid.',
            'retryable': false,
            'field_errors': [
              {'field': 'body.display_name', 'code': 'too_long', 'message': 'Too long.'},
            ],
          },
        },
        headers: {
          'x-request-id': ['req-123'],
        },
      ),
    );
    expect(failure.kind, ApiFailureKind.validation);
    expect(failure.code, 'VALIDATION_ERROR');
    expect(failure.message, 'Some fields are invalid.');
    expect(failure.fieldErrors.single.field, 'body.display_name');
    expect(failure.requestId, 'req-123');
    expect(failure.statusCode, 422);
  });

  test('connection problems are offline and retryable', () {
    final failure = ApiFailure.fromDio(
      DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionError,
      ),
    );
    expect(failure.isOffline, isTrue);
    expect(failure.retryable, isTrue);
  });

  test('a non-envelope server error falls back to a generic, safe message', () {
    final failure = ApiFailure.fromDio(_response(502, '<html>bad gateway</html>'));
    expect(failure.message, isNot(contains('html')));
    expect(failure.statusCode, 502);
  });
}
