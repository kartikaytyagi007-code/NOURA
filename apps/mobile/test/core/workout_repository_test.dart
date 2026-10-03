import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noura/core/api/api_client.dart';
import 'package:noura/core/api/api_failure.dart';
import 'package:noura/core/auth/auth_state.dart';
import 'package:noura/core/auth/mock_auth_repository.dart';
import 'package:noura/core/workouts/workout_repository.dart';
import 'package:noura_api_client/noura_api_client.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.responses);
  final List<(int, Map<String, Object?>)> responses;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final (status, body) = responses.removeAt(0);
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _Auth extends MockAuthRepository {
  _Auth()
    : super(
        initial: const SignedIn(userId: MockAuthRepository.mockUserId, email: 'a@example.com'),
      );
  @override
  Future<String?> accessToken() async => 'token';
}

Map<String, Object?> _body(RequestOptions r) => jsonDecode(r.data as String) as Map<String, Object?>;

ApiWorkoutRepository _repo(_Adapter adapter) =>
    ApiWorkoutRepository(buildApiClient(buildDio(baseUrl: 'http://api.test', auth: _Auth(), adapter: adapter)));

void main() {
  test('requestGeneration sends an Idempotency-Key header and the request body, never a user id', () async {
    final adapter = _Adapter([
      (
        202,
        {
          'data': {'job_id': 'job-1'},
          'meta': {'request_id': 'r'},
        },
      ),
    ]);
    final jobId = await _repo(adapter)
        .requestGeneration(profileRevision: 2, startDate: DateTime(2026, 10, 5), idempotencyKey: 'key-1');
    expect(jobId, 'job-1');
    final sent = adapter.requests.single;
    expect(sent.method, 'POST');
    expect(sent.path, '/v1/workout-plans/generate');
    expect(sent.headers['Idempotency-Key'], 'key-1');
    expect(_body(sent)['profile_revision'], 2);
    expect(_body(sent).containsKey('user_id'), isFalse);
  });

  test('fetchCurrentPlan returns null on a 404 instead of throwing', () async {
    final adapter = _Adapter([
      (
        404,
        {
          'error': {'code': 'NOT_FOUND', 'message': 'No active workout plan.'},
        },
      ),
    ]);
    final plan = await _repo(adapter).fetchCurrentPlan();
    expect(plan, isNull);
  });

  test('fetchCurrentPlan rethrows a non-404 failure', () async {
    final adapter = _Adapter([
      (
        500,
        {
          'error': {'code': 'INTERNAL_ERROR', 'message': 'oops'},
        },
      ),
    ]);
    await expectLater(_repo(adapter).fetchCurrentPlan(), throwsA(isA<ApiFailure>()));
  });

  test('getSubstitutions reads candidates from the exercise id path', () async {
    final adapter = _Adapter([
      (
        200,
        {
          'data': {
            'exercise_id': 'ex-1',
            'candidates': [
              {
                'exercise': {'id': 'ex-2', 'name': 'Goblet squat'},
                'equipment_tags': ['dumbbell'],
                'reason': 'Same movement pattern.',
              },
            ],
          },
          'meta': {'request_id': 'r'},
        },
      ),
    ]);
    final subs = await _repo(adapter).getSubstitutions('ex-1');
    expect(subs.candidates, hasLength(1));
    final sent = adapter.requests.single;
    expect(sent.method, 'GET');
    expect(sent.path, '/v1/exercises/ex-1/substitutions');
  });

  test('startLog sends client_id and session_id, with an Idempotency-Key', () async {
    final adapter = _Adapter([
      (
        201,
        {
          'data': {
            'id': 'log-1',
            'client_id': 'client-1',
            'session_id': 'session-1',
            'status': 'in_progress',
            'started_at': '2026-10-05T09:00:00Z',
            'completed_at': null,
            'sets': <Object?>[],
            'revision': 1,
          },
          'meta': {'request_id': 'r'},
        },
      ),
    ]);
    final log = await _repo(adapter).startLog(clientId: 'client-1', sessionId: 'session-1');
    expect(log.id, 'log-1');
    final sent = adapter.requests.single;
    expect(sent.method, 'POST');
    expect(sent.path, '/v1/workout-logs');
    expect(sent.headers.containsKey('Idempotency-Key'), isTrue);
    expect(_body(sent)['client_id'], 'client-1');
    expect(_body(sent)['session_id'], 'session-1');
  });

  test('putSets sends expected_revision and every set', () async {
    final adapter = _Adapter([
      (
        200,
        {
          'data': {
            'id': 'log-1',
            'client_id': 'client-1',
            'session_id': 'session-1',
            'status': 'in_progress',
            'started_at': '2026-10-05T09:00:00Z',
            'completed_at': null,
            'sets': [
              {'exercise_id': 'ex-1', 'set_ordinal': 1, 'reps': 10, 'load_kg': null, 'skipped': false},
            ],
            'revision': 2,
          },
          'meta': {'request_id': 'r'},
        },
      ),
    ]);
    final log = await _repo(adapter).putSets(
      logId: 'log-1',
      expectedRevision: 1,
      sets: [SetLogInput(exerciseId: 'ex-1', setOrdinal: 1, reps: 10, loadKg: null, skipped: false)],
    );
    expect(log.revision, 2);
    final sent = adapter.requests.single;
    expect(sent.method, 'PUT');
    expect(sent.path, '/v1/workout-logs/log-1/sets');
    expect(_body(sent)['expected_revision'], 1);
    expect((_body(sent)['sets'] as List).single, {
      'exercise_id': 'ex-1',
      'set_ordinal': 1,
      'reps': 10,
      'load_kg': null,
      'skipped': false,
    });
  });

  test('patchLog sends the new status and a 409 becomes a conflict failure', () async {
    final conflictAdapter = _Adapter([
      (
        409,
        {
          'error': {'code': 'REVISION_CONFLICT', 'message': 'stale'},
        },
      ),
    ]);
    await expectLater(
      _repo(conflictAdapter)
          .patchLog(logId: 'log-1', expectedRevision: 1, status: PatchWorkoutLogRequestStatusEnum.completed),
      throwsA(isA<ApiFailure>().having((e) => e.kind, 'kind', ApiFailureKind.conflict)),
    );

    final okAdapter = _Adapter([
      (
        200,
        {
          'data': {
            'id': 'log-1',
            'client_id': 'client-1',
            'session_id': 'session-1',
            'status': 'completed',
            'started_at': '2026-10-05T09:00:00Z',
            'completed_at': '2026-10-05T09:40:00Z',
            'sets': <Object?>[],
            'revision': 2,
          },
          'meta': {'request_id': 'r'},
        },
      ),
    ]);
    final log = await _repo(okAdapter)
        .patchLog(logId: 'log-1', expectedRevision: 1, status: PatchWorkoutLogRequestStatusEnum.completed);
    expect(log.status, WorkoutLogStatusEnum.completed);
    expect(_body(okAdapter.requests.single)['status'], 'completed');
  });
}
