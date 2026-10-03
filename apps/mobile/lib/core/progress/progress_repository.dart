import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../api/api_failure.dart';
import '../profile/profile_repository.dart' show newIdempotencyKey;

/// Server-owned progress data (M8: weight history, meal-plan/workout adherence summaries, private
/// progress photos). Widgets use this through [ProgressController]; they never call the generated
/// client directly (same convention as [DietRepository]/[WorkoutRepository]).
abstract interface class ProgressRepository {
  /// Weight/goal trends and honest, data-only adherence summaries (blueprint §6, §16 M8).
  Future<Progress> fetchProgress();

  Future<WeightLogList> listWeightLogs();

  Future<WeightLog> recordWeight({required DateTime measuredAt, required double weightKg, String? clientId});

  Future<void> deleteWeightLog(String id);

  Future<ProgressPhotoList> listProgressPhotos();

  /// Uploads [bytes] as a progress photo and registers it. Internally: reserve an upload slot (with
  /// the `progress_photo` purpose, which never auto-expires — blueprint §14, docs/decisions.md D-030),
  /// PUT the bytes, confirm the upload, then create the `ProgressPhoto` reference.
  Future<ProgressPhoto> uploadProgressPhoto({
    required Uint8List bytes,
    required ImageMime mime,
    required DateTime capturedAt,
    required PhotoAngle angle,
  });

  Future<void> deleteProgressPhoto(String id);

  /// A short-lived signed URL to view one progress photo's image.
  Future<String> getPhotoDownloadUrl(String mediaId);
}

final _random = Random.secure();
String _newClientId() => 'weight-${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(1 << 32)}';

class ApiProgressRepository implements ProgressRepository {
  ApiProgressRepository(this._client, {Dio? uploadDio}) : _uploadDio = uploadDio ?? Dio();

  final NouraApiClient _client;

  /// A plain Dio with no auth interceptor: upload URLs are pre-signed and must not carry this app's
  /// bearer token (same convention as [ApiMealScanRepository]).
  final Dio _uploadDio;

  ProgressApi get _progress => _client.getProgressApi();
  MediaApi get _media => _client.getMediaApi();

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<Progress> fetchProgress() => _guard(() async => (await _progress.getProgress(period: '30d')).data!.data);

  @override
  Future<WeightLogList> listWeightLogs() => _guard(() async => (await _progress.listWeightLogs()).data!.data);

  @override
  Future<WeightLog> recordWeight({required DateTime measuredAt, required double weightKg, String? clientId}) => _guard(
    () async => (await _progress.createWeightLog(
      idempotencyKey: newIdempotencyKey(),
      createWeightLogRequest: CreateWeightLogRequest(
        clientId: clientId ?? _newClientId(),
        measuredAt: measuredAt,
        weightKg: weightKg,
      ),
    )).data!.data,
  );

  @override
  Future<void> deleteWeightLog(String id) =>
      _guard(() async => _progress.deleteWeightLog(id: id, idempotencyKey: newIdempotencyKey()));

  @override
  Future<ProgressPhotoList> listProgressPhotos() =>
      _guard(() async => (await _progress.listProgressPhotos()).data!.data);

  @override
  Future<ProgressPhoto> uploadProgressPhoto({
    required Uint8List bytes,
    required ImageMime mime,
    required DateTime capturedAt,
    required PhotoAngle angle,
  }) => _guard(() async {
    final slot = (await _media.createUploadSlot(
      idempotencyKey: newIdempotencyKey(),
      uploadSlotRequest: UploadSlotRequest(purpose: MediaPurpose.progressPhoto, mime: mime, sizeBytes: bytes.length),
    )).data!.data;
    try {
      await _uploadDio.putUri(
        Uri.parse(slot.uploadUrl),
        data: Stream.fromIterable([bytes]),
        options: Options(contentType: mime.value, headers: {'content-length': bytes.length}),
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
    await _media.completeUpload(id: slot.mediaId, idempotencyKey: newIdempotencyKey());
    return (await _progress.createProgressPhoto(
      idempotencyKey: newIdempotencyKey(),
      createProgressPhotoRequest: CreateProgressPhotoRequest(
        mediaId: slot.mediaId,
        capturedAt: capturedAt,
        angle: angle,
      ),
    )).data!.data;
  });

  @override
  Future<void> deleteProgressPhoto(String id) =>
      _guard(() async => _progress.deleteProgressPhoto(id: id, idempotencyKey: newIdempotencyKey()));

  @override
  Future<String> getPhotoDownloadUrl(String mediaId) =>
      _guard(() async => (await _media.getMediaDownload(id: mediaId)).data!.data.url);
}

/// DEVELOPMENT-ONLY progress source used with mock auth (same convention as [MockWorkoutRepository]).
/// It never fabricates a weight trend beyond a small, clearly `(mock)` in-memory history, and it
/// never performs any image analysis — photos are stored only as opaque placeholder references.
class MockProgressRepository implements ProgressRepository {
  final List<WeightLog> _weights = [
    WeightLog(
      id: 'mock-w-1',
      clientId: 'mock-w-1',
      measuredAt: DateTime.now().subtract(const Duration(days: 20)),
      weightKg: 78,
    ),
    WeightLog(
      id: 'mock-w-2',
      clientId: 'mock-w-2',
      measuredAt: DateTime.now().subtract(const Duration(days: 6)),
      weightKg: 76.4,
    ),
  ];
  final List<ProgressPhoto> _photos = [];
  int _photoCounter = 0;

  @override
  Future<Progress> fetchProgress() async {
    final sorted = [..._weights]..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
    final now = DateTime.now();
    return Progress(
      periodStart: now.subtract(const Duration(days: 29)),
      periodEnd: now,
      weightPoints: [for (final w in sorted) WeightPoint(date: w.measuredAt, weightKg: w.weightKg)],
      startingWeightKg: sorted.isEmpty ? null : sorted.first.weightKg,
      currentWeightKg: sorted.isEmpty ? null : sorted.last.weightKg,
      goalWeightKg: 72,
      mealLoggedDays: 4,
      dietAdherence: AdherenceSummary(planActive: true, planned: 14, logged: 9),
      workoutsCompleted: 2,
      workoutsScheduledElapsed: 3,
      workoutAdherence: AdherenceSummary(planActive: true, planned: 3, logged: 2),
    );
  }

  @override
  Future<WeightLogList> listWeightLogs() async {
    final sorted = [..._weights]..sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
    return WeightLogList(items: sorted, nextCursor: null);
  }

  @override
  Future<WeightLog> recordWeight({required DateTime measuredAt, required double weightKg, String? clientId}) async {
    final id = clientId ?? _newClientId();
    final existing = _weights.where((w) => w.clientId == id).firstOrNull;
    if (existing != null) return existing;
    final log = WeightLog(
      id: 'mock-w-${_weights.length + 1}',
      clientId: id,
      measuredAt: measuredAt,
      weightKg: weightKg,
    );
    _weights.add(log);
    return log;
  }

  @override
  Future<void> deleteWeightLog(String id) async {
    _weights.removeWhere((w) => w.id == id);
  }

  @override
  Future<ProgressPhotoList> listProgressPhotos() async {
    final sorted = [..._photos]..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
    return ProgressPhotoList(items: sorted, nextCursor: null);
  }

  @override
  Future<ProgressPhoto> uploadProgressPhoto({
    required Uint8List bytes,
    required ImageMime mime,
    required DateTime capturedAt,
    required PhotoAngle angle,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _photoCounter += 1;
    final photo = ProgressPhoto(
      id: 'mock-photo-$_photoCounter',
      mediaId: 'mock-media-$_photoCounter',
      capturedAt: capturedAt,
      angle: angle,
    );
    _photos.add(photo);
    return photo;
  }

  @override
  Future<void> deleteProgressPhoto(String id) async {
    _photos.removeWhere((p) => p.id == id);
  }

  @override
  Future<String> getPhotoDownloadUrl(String mediaId) async => 'mock://progress-photo/$mediaId';
}
