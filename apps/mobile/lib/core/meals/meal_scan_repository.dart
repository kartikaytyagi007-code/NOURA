import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../api/api_failure.dart';
import '../profile/profile_repository.dart' show newIdempotencyKey;

/// Server-owned meal scanning data (M4: media upload, recognition and meal logging). Widgets use
/// this through [MealScanController]; they never call the generated client directly (same
/// convention as [DietRepository]).
abstract interface class MealScanRepository {
  /// Uploads [bytes] (already captured/picked) as a meal photo and returns the verified media id.
  /// Internally: reserve an upload slot, PUT the bytes to the signed URL, then confirm the upload.
  Future<String> uploadMealImage(Uint8List bytes, {required ImageMime mime});

  /// Starts (or, for a duplicate submission of the same media, rejoins) recognition. Returns the
  /// scan id the caller then polls with [getScan].
  Future<MealScanAccepted> startScan(String mediaId);

  /// Current scan state: queued/recognizing/needs_confirmation/ready/failed/... (blueprint §8).
  Future<MealScan> getScan(String scanId);

  /// Confirms (possibly user-edited) recognized items and returns the calculated analysis.
  Future<MealAnalysis> confirmItems({
    required String scanId,
    required int expectedRevision,
    required List<ConfirmedItemInput> items,
  });

  /// Logs a confirmed meal (from a scan, or directly from edited items) to the diary.
  Future<MealLog> logMeal({
    required DateTime consumedAt,
    required String timezone,
    required MealSlot slot,
    String? scanId,
    required List<ConfirmedItemInput> items,
    String? clientId,
  });
}

final _random = Random.secure();

String _newClientId() => 'scan-${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(1 << 32)}';

class ApiMealScanRepository implements MealScanRepository {
  ApiMealScanRepository(this._client, {Dio? uploadDio}) : _uploadDio = uploadDio ?? Dio();

  final NouraApiClient _client;

  /// A plain Dio with no auth interceptor: upload URLs are pre-signed (dev-storage token or a
  /// Supabase signed URL) and must not carry this app's bearer token.
  final Dio _uploadDio;

  MediaApi get _media => _client.getMediaApi();
  MealsApi get _meals => _client.getMealsApi();

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<String> uploadMealImage(Uint8List bytes, {required ImageMime mime}) => _guard(() async {
    final slot = (await _media.createUploadSlot(
      idempotencyKey: newIdempotencyKey(),
      uploadSlotRequest: UploadSlotRequest(purpose: MediaPurpose.meal, mime: mime, sizeBytes: bytes.length),
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
    return slot.mediaId;
  });

  @override
  Future<MealScanAccepted> startScan(String mediaId) => _guard(
    () async => (await _meals.createMealScan(
      idempotencyKey: newIdempotencyKey(),
      createMealScanRequest: CreateMealScanRequest(mediaId: mediaId),
    )).data!.data,
  );

  @override
  Future<MealScan> getScan(String scanId) => _guard(() async => (await _meals.getMealScan(id: scanId)).data!.data);

  @override
  Future<MealAnalysis> confirmItems({
    required String scanId,
    required int expectedRevision,
    required List<ConfirmedItemInput> items,
  }) => _guard(
    () async => (await _meals.confirmMealScanItems(
      id: scanId,
      idempotencyKey: newIdempotencyKey(),
      confirmItemsRequest: ConfirmItemsRequest(expectedRevision: expectedRevision, items: items),
    )).data!.data,
  );

  @override
  Future<MealLog> logMeal({
    required DateTime consumedAt,
    required String timezone,
    required MealSlot slot,
    String? scanId,
    required List<ConfirmedItemInput> items,
    String? clientId,
  }) => _guard(
    () async => (await _meals.createMealLog(
      idempotencyKey: newIdempotencyKey(),
      createMealLogRequest: CreateMealLogRequest(
        clientId: clientId ?? _newClientId(),
        consumedAt: consumedAt,
        timezone: timezone,
        slot: slot,
        scanId: scanId,
        items: items,
      ),
    )).data!.data,
  );
}

/// DEVELOPMENT-ONLY meal-scan source used with mock auth (same convention as [MockDietRepository]).
/// It never fabricates nutrition data beyond the catalog-free demo items below, which are clearly
/// labelled "(mock)"; it simulates the upload → recognize → review pipeline entirely in memory so
/// the scan screens can be exercised without a server.
class MockMealScanRepository implements MealScanRepository {
  int _scanCounter = 0;
  final Map<String, MealScan> _scans = {};

  static final _mockRecognition = Recognition(
    schemaVersion: RecognitionSchemaVersionEnum.n1,
    imageIsFood: true,
    quality: RecognitionQualityEnum.usable,
    clarification: null,
    items: [
      RecognitionItem(
        temporaryId: 'mock-item-1',
        label: 'Grilled chicken (mock)',
        alternativeLabels: const [],
        confidenceBand: RecognitionItemConfidenceBandEnum.high,
        estimatedGrams: NumberRange(min: 120, max: 160),
        preparationQuestions: const [],
        needsConfirmation: false,
        catalogCandidates: const [],
      ),
      RecognitionItem(
        temporaryId: 'mock-item-2',
        label: 'Mixed salad (mock)',
        alternativeLabels: const [],
        confidenceBand: RecognitionItemConfidenceBandEnum.medium,
        estimatedGrams: NumberRange(min: 80, max: 120),
        preparationQuestions: const [],
        needsConfirmation: true,
        catalogCandidates: const [],
      ),
    ],
  );

  @override
  Future<String> uploadMealImage(Uint8List bytes, {required ImageMime mime}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return 'mock-media-${DateTime.now().microsecondsSinceEpoch}';
  }

  @override
  Future<MealScanAccepted> startScan(String mediaId) async {
    _scanCounter += 1;
    final scanId = 'mock-scan-$_scanCounter';
    _scans[scanId] = MealScan(
      id: scanId,
      status: MealScanStatus.recognizing,
      recognition: null,
      revision: 1,
      error: null,
      createdAt: DateTime.now().toUtc(),
    );
    return MealScanAccepted(jobId: 'mock-job-$_scanCounter', scanId: scanId);
  }

  @override
  Future<MealScan> getScan(String scanId) async {
    final current = _scans[scanId];
    if (current == null) {
      throw const ApiFailure(kind: ApiFailureKind.notFound, message: 'Scan not found.');
    }
    if (current.status == MealScanStatus.recognizing) {
      // Resolve to "needs_confirmation" on the first poll after creation, simulating the async job.
      final resolved = MealScan(
        id: current.id,
        status: MealScanStatus.needsConfirmation,
        recognition: _mockRecognition,
        revision: current.revision,
        error: null,
        createdAt: current.createdAt,
      );
      _scans[scanId] = resolved;
      return resolved;
    }
    return current;
  }

  static Nutrients _n(num kcal) => Nutrients(energyKcal: kcal, proteinG: 25, carbohydrateG: 10, fatG: 8, fibreG: 3);

  @override
  Future<MealAnalysis> confirmItems({
    required String scanId,
    required int expectedRevision,
    required List<ConfirmedItemInput> items,
  }) async {
    final analyzed = [
      for (final item in items)
        AnalyzedItem(
          itemId: item.temporaryId ?? item.label,
          label: item.label,
          foodId: null,
          recipeId: null,
          source_: null,
          grams: item.grams,
          gramsRange: null,
          nutrients: _n(180),
          uncertainty: Uncertainty.medium,
        ),
    ];
    final totals = NutrientTotals(
      nutrients: _n(180 * items.length),
      coverage: Coverage(itemsTotal: items.length, itemsWithNutrition: items.length, complete: true),
    );
    final scan = _scans[scanId];
    if (scan != null) {
      _scans[scanId] = MealScan(
        id: scan.id,
        status: MealScanStatus.ready,
        recognition: scan.recognition,
        revision: scan.revision + 1,
        error: null,
        createdAt: scan.createdAt,
      );
    }
    return MealAnalysis(
      scanId: scanId,
      revision: expectedRevision + 1,
      items: analyzed,
      totals: totals,
      mealBalance: MealBalance(
        score: 70,
        policyVersion: 'mock-meal-balance',
        components: const [],
        missingDataMessage: null,
      ),
    );
  }

  @override
  Future<MealLog> logMeal({
    required DateTime consumedAt,
    required String timezone,
    required MealSlot slot,
    String? scanId,
    required List<ConfirmedItemInput> items,
    String? clientId,
  }) async {
    final analysis = await confirmItems(scanId: scanId ?? 'mock-scan-manual', expectedRevision: 1, items: items);
    return MealLog(
      id: 'mock-log-${DateTime.now().microsecondsSinceEpoch}',
      clientId: clientId ?? _newClientId(),
      consumedAt: consumedAt,
      localDate: DateTime(consumedAt.year, consumedAt.month, consumedAt.day),
      slot: slot,
      scanId: scanId,
      planMealId: null,
      items: analysis.items,
      totals: analysis.totals,
      mealBalance: analysis.mealBalance,
      revision: 1,
    );
  }
}
