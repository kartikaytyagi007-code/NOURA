import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noura/core/api/api_client.dart';
import 'package:noura/core/api/api_failure.dart';
import 'package:noura/core/auth/auth_state.dart';
import 'package:noura/core/auth/mock_auth_repository.dart';
import 'package:noura/core/profile/profile_repository.dart';
import 'package:noura/core/profile/session_profile.dart';

/// Serves scripted responses and records the requests the client sent.
class ScriptedAdapter implements HttpClientAdapter {
  ScriptedAdapter(this.responses);
  final List<(int, Map<String, Object?>)> responses;
  final requests = <RequestOptions>[];
  final authHeaders = <Object?>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    authHeaders.add(options.headers['authorization']);
    final (status, body) = responses.removeAt(0);
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        'x-request-id': ['server-${requests.length}'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Mock auth whose token rotates on refresh, and whose refresh can be made to fail.
class RotatingAuth extends MockAuthRepository {
  RotatingAuth({this.refreshSucceeds = true})
    : super(initial: const SignedIn(userId: MockAuthRepository.mockUserId, email: null));
  bool refreshSucceeds;
  int generation = 1;
  SignOutReason? signedOutWith;
  bool signedOut = false;

  @override
  Future<String?> accessToken() async => current is SignedIn ? 'token-$generation' : null;

  int refreshes = 0;

  @override
  Future<bool> refreshSession() async {
    refreshes++;
    await Future<void>.delayed(const Duration(milliseconds: 5));
    if (!refreshSucceeds) return false;
    generation++;
    return true;
  }

  @override
  Future<void> signOut({SignOutReason? reason}) async {
    signedOut = true;
    signedOutWith = reason;
    await super.signOut(reason: reason);
  }
}

const _unauthorized = (
  401,
  {
    'error': {'code': 'UNAUTHENTICATED', 'message': 'Authentication required.', 'retryable': false},
  },
);

/// A GET /v1/me body shaped exactly like the contract's Me example.
Map<String, Object?> _me(String status) => {
  'data': {
    'user_id': MockAuthRepository.mockUserId,
    'profile': {
      'display_name': 'Asha',
      'age_years': null,
      'calculation_sex': null,
      'height_cm': null,
      'weight_kg': null,
      'activity_band': null,
      'timezone': 'UTC',
      'unit_system': 'metric',
      'revision': 1,
    },
    'goal': null,
    'preferences': null,
    'training_preferences': null,
    'eligibility_status': null,
    'screening': null,
    'onboarding': {'status': status, 'step': null},
    'planning': null,
  },
  'meta': {'request_id': 'server'},
};

void main() {
  test('sends the bearer token and a request id, never a user id', () async {
    final auth = RotatingAuth();
    final adapter = ScriptedAdapter([(200, _me('completed'))]);
    final profile = await ApiProfileRepository(
      buildApiClient(buildDio(baseUrl: 'http://api.test', auth: auth, adapter: adapter)),
    ).fetchMe();
    expect(SessionProfile.fromMe(profile).onboarding, OnboardingState.completed);
    final sent = adapter.requests.single;
    expect(sent.headers['authorization'], 'Bearer token-1');
    expect(sent.headers['x-request-id'], matches(RegExp(r'^[0-9a-f]{32}$')));
    expect(sent.uri.toString(), 'http://api.test/v1/me');
    expect(sent.uri.queryParameters, isEmpty);
    expect(sent.data, isNull);
  });

  test('a 401 refreshes once and retries with the new token', () async {
    final auth = RotatingAuth();
    final adapter = ScriptedAdapter([_unauthorized, (200, _me('not_started'))]);
    final profile = await ApiProfileRepository(
      buildApiClient(buildDio(baseUrl: 'http://api.test', auth: auth, adapter: adapter)),
    ).fetchMe();
    expect(SessionProfile.fromMe(profile).onboarding, OnboardingState.notStarted);
    expect(adapter.authHeaders, ['Bearer token-1', 'Bearer token-2']);
    expect(auth.signedOut, isFalse);
  });

  test('a failed refresh signs out with "session expired" and surfaces UNAUTHENTICATED', () async {
    final auth = RotatingAuth(refreshSucceeds: false);
    final adapter = ScriptedAdapter([_unauthorized]);
    final repo = ApiProfileRepository(
      buildApiClient(buildDio(baseUrl: 'http://api.test', auth: auth, adapter: adapter)),
    );
    await expectLater(
      repo.fetchMe(),
      throwsA(isA<ApiFailure>().having((f) => f.kind, 'kind', ApiFailureKind.unauthenticated)),
    );
    expect(auth.signedOutWith, SignOutReason.sessionExpired);
    expect(adapter.requests, hasLength(1));
  });

  test('a second 401 after refresh does not loop', () async {
    final auth = RotatingAuth();
    final adapter = ScriptedAdapter([_unauthorized, _unauthorized]);
    final repo = ApiProfileRepository(
      buildApiClient(buildDio(baseUrl: 'http://api.test', auth: auth, adapter: adapter)),
    );
    await expectLater(repo.fetchMe(), throwsA(isA<ApiFailure>()));
    expect(adapter.requests, hasLength(2));
    expect(auth.signedOutWith, SignOutReason.sessionExpired);
  });

  test('concurrent 401s share a single refresh', () async {
    final auth = RotatingAuth();
    final adapter = ScriptedAdapter([_unauthorized, _unauthorized, (200, _me('completed')), (200, _me('completed'))]);
    final repo = ApiProfileRepository(
      buildApiClient(buildDio(baseUrl: 'http://api.test', auth: auth, adapter: adapter)),
    );
    await Future.wait([repo.fetchMe(), repo.fetchMe()]);
    expect(auth.refreshes, 1);
    expect(adapter.authHeaders, ['Bearer token-1', 'Bearer token-1', 'Bearer token-2', 'Bearer token-2']);
  });
}
