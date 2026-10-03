//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

// ignore: unused_import
import 'dart:convert';
import 'package:noura_api_client/src/deserialize.dart';
import 'package:dio/dio.dart';

import 'package:noura_api_client/src/model/error_response.dart';
import 'package:noura_api_client/src/model/insights_response.dart';

class InsightsApi {
  final Dio _dio;

  const InsightsApi(this._dio);

  /// Seven-day nutrition patterns.
  /// Daily and seven-day nutrition-pattern summaries from recorded meals (blueprint §10, §16 M6). A protein/fibre gap is identified only when the underlying data supports it: a day with no logs or incomplete nutrition coverage is excluded from the seven-day average and named in &#x60;excluded_days&#x60;/&#x60;coverage_uncertain&#x60; rather than silently counted as zero, and a gap is only ever reported once enough usable days exist to support the conclusion.
  ///
  /// Parameters:
  /// * [period]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [InsightsResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<InsightsResponse>> getInsights({
    required String period,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/insights';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {'type': 'http', 'scheme': 'bearer', 'name': 'bearerAuth'},
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{r'period': period};

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    InsightsResponse? _responseData;

    try {
      final rawData = _response.data;
      _responseData = rawData == null
          ? null
          : deserialize<InsightsResponse, InsightsResponse>(
              rawData,
              'InsightsResponse',
              growable: true,
            );
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<InsightsResponse>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }
}
