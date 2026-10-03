import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noura/core/api/api_client.dart';
import 'package:noura/core/api/api_failure.dart';
import 'package:noura/core/auth/auth_state.dart';
import 'package:noura/core/auth/mock_auth_repository.dart';
import 'package:noura/core/diet/diet_repository.dart';

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
        initial: const SignedIn(userId: MockAuthRepository.mockUserId, phone: '+919876543210'),
      );
  @override
  Future<String?> accessToken() async => 'token';
}

Map<String, Object?> _body(RequestOptions r) => jsonDecode(r.data as String) as Map<String, Object?>;

ApiDietRepository _repo(_Adapter adapter) =>
    ApiDietRepository(buildApiClient(buildDio(baseUrl: 'http://api.test', auth: _Auth(), adapter: adapter)));

void main() {
  test('generateDietPlan sends an Idempotency-Key header and the request body, never a user id', () async {
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
        .requestGeneration(profileRevision: 3, startDate: DateTime(2026, 10, 5), idempotencyKey: 'key-1');
    expect(jobId, 'job-1');
    final sent = adapter.requests.single;
    expect(sent.method, 'POST');
    expect(sent.path, '/v1/diet-plans/generate');
    expect(sent.headers['Idempotency-Key'], 'key-1');
    expect(_body(sent)['profile_revision'], 3);
    expect(_body(sent)['start_date'], startsWith('2026-10-05'));
    expect(_body(sent).containsKey('user_id'), isFalse);
  });

  test('getCurrentDietPlan returns null on a 404 instead of throwing', () async {
    final adapter = _Adapter([
      (
        404,
        {
          'error': {'code': 'NOT_FOUND', 'message': 'No active diet plan.'},
        },
      ),
    ]);
    final plan = await _repo(adapter).fetchCurrentPlan();
    expect(plan, isNull);
  });

  test('getCurrentDietPlan rethrows a non-404 failure', () async {
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

  test('getSwapOptions sends the expected_revision and no idempotency key (read-only)', () async {
    final adapter = _Adapter([
      (
        200,
        {
          'data': {'plan_meal_id': 'meal-1', 'revision': 2, 'candidates': <Object?>[]},
          'meta': {'request_id': 'r'},
        },
      ),
    ]);
    final options = await _repo(adapter).swapOptions(planMealId: 'meal-1', expectedRevision: 2);
    expect(options.candidates, isEmpty);
    final sent = adapter.requests.single;
    expect(sent.method, 'POST');
    expect(sent.path, '/v1/diet-plan-meals/meal-1/swap-options');
    expect(_body(sent), {'expected_revision': 2});
    expect(sent.headers.containsKey('Idempotency-Key'), isFalse);
  });

  test('replacePlanMeal sends an Idempotency-Key and the candidate id', () async {
    final adapter = _Adapter([
      (
        200,
        {
          'data': {
            'id': 'meal-1',
            'date': '2026-10-05',
            'slot': 'lunch',
            'slot_ordinal': 1,
            'recipe': {'id': 'r2', 'name': 'Alt'},
            'portions': <Object?>[],
            'nutrition': {
              'nutrients': {'energy_kcal': 400, 'protein_g': 10, 'carbohydrate_g': 40, 'fat_g': 10, 'fibre_g': 5},
              'coverage': {'items_total': 1, 'items_with_nutrition': 1, 'complete': true},
            },
            'revision': 2,
          },
          'meta': {'request_id': 'r'},
        },
      ),
    ]);
    final meal = await _repo(adapter)
        .replaceMeal(planMealId: 'meal-1', expectedRevision: 1, candidateId: 'r2', idempotencyKey: 'key-2');
    expect(meal.revision, 2);
    final sent = adapter.requests.single;
    expect(sent.method, 'PUT');
    expect(sent.headers['Idempotency-Key'], 'key-2');
    expect(_body(sent), {'expected_revision': 1, 'candidate_id': 'r2'});
  });

  test('a 409 becomes a conflict failure', () async {
    final adapter = _Adapter([
      (
        409,
        {
          'error': {'code': 'REVISION_CONFLICT', 'message': 'stale'},
        },
      ),
    ]);
    await expectLater(
      _repo(adapter).replaceMeal(planMealId: 'meal-1', expectedRevision: 1, candidateId: 'r2'),
      throwsA(isA<ApiFailure>().having((e) => e.kind, 'kind', ApiFailureKind.conflict)),
    );
  });
}
