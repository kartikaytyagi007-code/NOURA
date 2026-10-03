import 'dart:math';

import 'package:dio/dio.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../auth/auth_repository.dart';
import '../auth/auth_state.dart';

const _retriedKey = 'noura_auth_retried';

/// Builds the Dio instance used by the generated client: base URL, timeouts, bearer token,
/// request ids and one refresh-and-retry on 401.
Dio buildDio({required String baseUrl, required AuthRepository auth, HttpClientAdapter? adapter}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'accept': 'application/json'},
    ),
  );
  if (adapter != null) dio.httpClientAdapter = adapter;
  dio.interceptors.add(AuthInterceptor(auth: auth, dio: dio));
  return dio;
}

NouraApiClient buildApiClient(Dio dio) => NouraApiClient(dio: dio, interceptors: const []);

/// Attaches the current Supabase access token. On a 401 it refreshes once and retries; if the
/// session cannot be refreshed it signs out with [SignOutReason.sessionExpired]. The user id is
/// never sent by the app: the API derives it from the verified token.
///
/// Concurrent 401s share one refresh. This is a plain (not queued) interceptor so the retried
/// request's own error can pass through without waiting on the handler that issued it.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.auth, required this.dio});

  final AuthRepository auth;
  final Dio dio;
  Future<String?>? _refreshing;
  static final _random = Random.secure();

  static String newRequestId() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await auth.accessToken();
    if (token != null) options.headers['authorization'] = 'Bearer $token';
    options.headers.putIfAbsent('x-request-id', newRequestId);
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final unauthorized = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra[_retriedKey] == true;
    if (!unauthorized || alreadyRetried) {
      if (unauthorized) await auth.signOut(reason: SignOutReason.sessionExpired);
      handler.next(err);
      return;
    }
    final token = await (_refreshing ??= _refresh().whenComplete(() => _refreshing = null));
    if (token == null) {
      handler.next(err);
      return;
    }
    try {
      final original = err.requestOptions;
      final retry = original.copyWith(
        headers: {...original.headers, 'authorization': 'Bearer $token'},
        extra: {...original.extra, _retriedKey: true},
      );
      handler.resolve(await dio.fetch<dynamic>(retry));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<String?> _refresh() async {
    final refreshed = await auth.refreshSession();
    final token = refreshed ? await auth.accessToken() : null;
    if (token == null) await auth.signOut(reason: SignOutReason.sessionExpired);
    return token;
  }
}
