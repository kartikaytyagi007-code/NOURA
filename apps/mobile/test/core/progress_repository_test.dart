import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noura/core/api/api_client.dart';
import 'package:noura/core/api/api_failure.dart';
import 'package:noura/core/auth/auth_state.dart';
import 'package:noura/core/auth/mock_auth_repository.dart';
import 'package:noura/core/progress/progress_repository.dart';
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
        initial: const SignedIn(userId: MockAuthRepository.mockUserId, phone: '+919876543210'),
      );
  @override
  Future<String?> accessToken() async => 'token';
}

Map<String, Object?> _body(RequestOptions r) => jsonDecode(r.data as String) as Map<String, Object?>;

ApiProgressRepository _repo(_Adapter adapter, {Dio? uploadDio}) => ApiProgressRepository(
  buildApiClient(buildDio(baseUrl: 'http://api.test', auth: _Auth(), adapter: adapter)),
  uploadDio: uploadDio,
);

void main() {
  test('createWeightLog sends an Idempotency-Key header and the request body, never a user id', () async {
    final adapter = _Adapter([
      (
        201,
        {
          'data': {'id': 'w-1', 'client_id': 'c-1', 'measured_at': '2026-10-01T07:00:00Z', 'weight_kg': 72.5},
          'meta': {'request_id': 'r'},
        },
      ),
    ]);
    final log = await _repo(adapter)
        .recordWeight(measuredAt: DateTime.utc(2026, 10, 1, 7), weightKg: 72.5, clientId: 'c-1');
    expect(log.id, 'w-1');
    final sent = adapter.requests.single;
    expect(sent.method, 'POST');
    expect(sent.path, '/v1/weight-logs');
    expect(sent.headers.containsKey('Idempotency-Key'), isTrue);
    expect(_body(sent)['weight_kg'], 72.5);
    expect(_body(sent).containsKey('user_id'), isFalse);
  });

  test('createWeightLog surfaces a 422 as a validation failure with field errors', () async {
    final adapter = _Adapter([
      (
        422,
        {
          'error': {
            'code': 'VALIDATION_ERROR',
            'message': 'Invalid weight entry.',
            'field_errors': [
              {'field': 'body.weight_kg', 'code': 'out_of_range', 'message': 'must be between 20 and 400 kg'},
            ],
          },
        },
      ),
    ]);
    await expectLater(
      _repo(adapter).recordWeight(measuredAt: DateTime.now(), weightKg: 1000),
      throwsA(
        isA<ApiFailure>()
            .having((e) => e.kind, 'kind', ApiFailureKind.validation)
            .having((e) => e.fieldErrors.single.code, 'field error code', 'out_of_range'),
      ),
    );
  });

  test('listWeightLogs reads the items newest first as returned by the server', () async {
    final adapter = _Adapter([
      (
        200,
        {
          'data': {
            'items': [
              {'id': 'w-2', 'client_id': 'c-2', 'measured_at': '2026-10-02T07:00:00Z', 'weight_kg': 71},
              {'id': 'w-1', 'client_id': 'c-1', 'measured_at': '2026-10-01T07:00:00Z', 'weight_kg': 72.5},
            ],
            'next_cursor': null,
          },
          'meta': {'request_id': 'r'},
        },
      ),
    ]);
    final list = await _repo(adapter).listWeightLogs();
    expect(list.items.map((w) => w.id), ['w-2', 'w-1']);
  });

  test('deleteWeightLog sends DELETE with an Idempotency-Key and a 404 becomes a not-found failure', () async {
    final notFound = _Adapter([
      (
        404,
        {
          'error': {'code': 'NOT_FOUND', 'message': 'Resource not found.'},
        },
      ),
    ]);
    await expectLater(
      _repo(notFound).deleteWeightLog('w-1'),
      throwsA(isA<ApiFailure>().having((e) => e.kind, 'kind', ApiFailureKind.notFound)),
    );

    final ok = _Adapter([
      (
        200,
        {
          'data': {'id': 'w-1', 'deleted': true},
          'meta': {'request_id': 'r'},
        },
      ),
    ]);
    await _repo(ok).deleteWeightLog('w-1');
    final sent = ok.requests.single;
    expect(sent.method, 'DELETE');
    expect(sent.path, '/v1/weight-logs/w-1');
    expect(sent.headers.containsKey('Idempotency-Key'), isTrue);
  });

  test('uploadProgressPhoto reserves a progress_photo upload slot, PUTs bytes without the bearer token, '
      'then registers the photo', () async {
    final adapter = _Adapter([
      (
        201,
        {
          'data': {
            'media_id': 'media-1',
            'upload_url': 'https://storage.test/upload',
            'expires_at': '2026-10-01T00:05:00Z',
          },
          'meta': {'request_id': 'r'},
        },
      ),
      (
        200,
        {
          'data': {
            'id': 'media-1',
            'purpose': 'progress_photo',
            'status': 'verified',
            'verified_mime': null,
            'byte_size': null,
            'created_at': '2026-10-01T00:00:00Z',
          },
          'meta': {'request_id': 'r'},
        },
      ),
      (
        201,
        {
          'data': {'id': 'p-1', 'media_id': 'media-1', 'captured_at': '2026-10-01T08:00:00Z', 'angle': 'front'},
          'meta': {'request_id': 'r'},
        },
      ),
    ]);
    final uploadAdapter = _Adapter([(200, const {})]);
    final uploadDio = Dio()..httpClientAdapter = uploadAdapter;

    final photo = await _repo(adapter, uploadDio: uploadDio).uploadProgressPhoto(
      bytes: Uint8List.fromList([1, 2, 3]),
      mime: ImageMime.imageSlashPng,
      capturedAt: DateTime.utc(2026, 10, 1, 8),
      angle: PhotoAngle.front,
    );
    expect(photo.id, 'p-1');

    final slotRequest = adapter.requests[0];
    expect(_body(slotRequest)['purpose'], 'progress_photo');

    // The raw upload must never carry this app's own bearer token.
    final uploadRequest = uploadAdapter.requests.single;
    expect(uploadRequest.headers.containsKey('authorization'), isFalse);

    final registerRequest = adapter.requests[2];
    expect(registerRequest.path, '/v1/progress-photos');
    expect(_body(registerRequest)['media_id'], 'media-1');
    expect(_body(registerRequest)['angle'], 'front');
  });

  test('deleteProgressPhoto sends DELETE with an Idempotency-Key', () async {
    final adapter = _Adapter([
      (
        200,
        {
          'data': {'id': 'p-1', 'deleted': true},
          'meta': {'request_id': 'r'},
        },
      ),
    ]);
    await _repo(adapter).deleteProgressPhoto('p-1');
    final sent = adapter.requests.single;
    expect(sent.method, 'DELETE');
    expect(sent.path, '/v1/progress-photos/p-1');
    expect(sent.headers.containsKey('Idempotency-Key'), isTrue);
  });

  test('fetchProgress requests the 30-day period and surfaces honest null adherence', () async {
    final adapter = _Adapter([
      (
        200,
        {
          'data': {
            'period_start': '2026-09-03',
            'period_end': '2026-10-02',
            'weight_points': <Object?>[],
            'starting_weight_kg': null,
            'current_weight_kg': null,
            'goal_weight_kg': null,
            'meal_logged_days': 0,
            'diet_adherence': {'plan_active': false, 'planned': null, 'logged': null},
            'workouts_completed': 0,
            'workouts_scheduled_elapsed': 0,
            'workout_adherence': {'plan_active': false, 'planned': null, 'logged': null},
          },
          'meta': {'request_id': 'r'},
        },
      ),
    ]);
    final progress = await _repo(adapter).fetchProgress();
    expect(progress.dietAdherence.planActive, isFalse);
    expect(progress.dietAdherence.planned, isNull);
    final sent = adapter.requests.single;
    expect(sent.queryParameters['period'], '30d');
  });
}
