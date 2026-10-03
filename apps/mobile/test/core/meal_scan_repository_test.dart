import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noura/core/api/api_client.dart';
import 'package:noura/core/api/api_failure.dart';
import 'package:noura/core/auth/auth_state.dart';
import 'package:noura/core/auth/mock_auth_repository.dart';
import 'package:noura/core/meals/meal_scan_repository.dart';
import 'package:noura_api_client/noura_api_client.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.responses);
  final List<(int, Object?)> responses;
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
      body == null ? '' : jsonEncode(body),
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

void main() {
  test('uploadMealImage reserves a slot, PUTs raw bytes without the bearer token, then completes', () async {
    final apiAdapter = _Adapter([
      (
        201,
        {
          'data': {
            'media_id': 'media-1',
            'upload_url': 'http://upload.test/dev-storage/meal-images/u/media-1',
            'expires_at': '2026-10-02T00:05:00Z',
          },
          'meta': {'request_id': 'r'},
        },
      ),
      (
        200,
        {
          'data': {
            'id': 'media-1',
            'purpose': 'meal',
            'status': 'verified',
            'verified_mime': 'image/jpeg',
            'byte_size': 3,
            'created_at': '2026-10-02T00:00:00Z',
          },
          'meta': {'request_id': 'r'},
        },
      ),
    ]);
    final uploadAdapter = _Adapter([(200, null)]);
    final repo = ApiMealScanRepository(
      buildApiClient(buildDio(baseUrl: 'http://api.test', auth: _Auth(), adapter: apiAdapter)),
      uploadDio: Dio()..httpClientAdapter = uploadAdapter,
    );

    final mediaId = await repo.uploadMealImage(Uint8List.fromList([1, 2, 3]), mime: ImageMime.imageSlashJpeg);

    expect(mediaId, 'media-1');
    expect(apiAdapter.requests, hasLength(2));
    expect(apiAdapter.requests[0].path, '/v1/media/upload-slots');
    expect(_body(apiAdapter.requests[0]), {'purpose': 'meal', 'mime': 'image/jpeg', 'size_bytes': 3});
    expect(apiAdapter.requests[1].path, '/v1/media/{id}/complete'.replaceAll('{id}', 'media-1'));

    // The raw upload PUT never carries this app's bearer token (it is a pre-signed URL).
    expect(uploadAdapter.requests.single.method, 'PUT');
    expect(uploadAdapter.requests.single.headers.containsKey('authorization'), isFalse);
  });

  test('startScan posts the media id and returns the accepted job/scan ids', () async {
    final adapter = _Adapter([
      (
        202,
        {
          'data': {'job_id': 'job-1', 'scan_id': 'scan-1'},
          'meta': {'request_id': 'r'},
        },
      ),
    ]);
    final repo = ApiMealScanRepository(
      buildApiClient(buildDio(baseUrl: 'http://api.test', auth: _Auth(), adapter: adapter)),
    );
    final accepted = await repo.startScan('media-1');
    expect(accepted.jobId, 'job-1');
    expect(accepted.scanId, 'scan-1');
    expect(_body(adapter.requests.single), {'media_id': 'media-1'});
  });

  test('confirmItems sends expected_revision and items, and a stale revision becomes a conflict failure', () async {
    final adapter = _Adapter([
      (
        409,
        {
          'error': {'code': 'REVISION_CONFLICT', 'message': 'stale'},
        },
      ),
    ]);
    final repo = ApiMealScanRepository(
      buildApiClient(buildDio(baseUrl: 'http://api.test', auth: _Auth(), adapter: adapter)),
    );
    await expectLater(
      repo.confirmItems(
        scanId: 'scan-1',
        expectedRevision: 1,
        items: [ConfirmedItemInput(label: 'Rice', grams: 150)],
      ),
      throwsA(isA<ApiFailure>().having((e) => e.kind, 'kind', ApiFailureKind.conflict)),
    );
    expect(_body(adapter.requests.single), {
      'expected_revision': 1,
      'items': [
        {'label': 'Rice', 'grams': 150},
      ],
    });
  });

  test('getScan surfaces a 404 as a not-found ApiFailure (cross-owner or unknown scan)', () async {
    final adapter = _Adapter([
      (
        404,
        {
          'error': {'code': 'NOT_FOUND', 'message': 'Scan not found.'},
        },
      ),
    ]);
    final repo = ApiMealScanRepository(
      buildApiClient(buildDio(baseUrl: 'http://api.test', auth: _Auth(), adapter: adapter)),
    );
    await expectLater(
      repo.getScan('scan-x'),
      throwsA(isA<ApiFailure>().having((e) => e.kind, 'kind', ApiFailureKind.notFound)),
    );
  });
}
