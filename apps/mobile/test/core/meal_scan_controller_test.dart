import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noura/core/api/api_failure.dart';
import 'package:noura/core/meals/meal_scan_controller.dart';
import 'package:noura/core/meals/meal_scan_repository.dart';
import 'package:noura/core/meals/meal_scan_state.dart';
import 'package:noura/core/providers.dart';
import 'package:noura_api_client/noura_api_client.dart';

Nutrients _n(num kcal) => Nutrients(energyKcal: kcal, proteinG: 10, carbohydrateG: 20, fatG: 5, fibreG: 3);

/// A fake [MealScanRepository] whose scan status sequence the test controls directly (mirrors
/// `FakeDietRepository`'s role for diet-plan tests), so polling/terminal-state handling can be
/// exercised deterministically without a server or timers.
class FakeMealScanRepository implements MealScanRepository {
  FakeMealScanRepository({required this.statuses, this.recognition, this.error, this.failOnStart});

  List<MealScanStatus> statuses;
  Recognition? recognition;
  SafeError? error;
  ApiFailure? failOnStart;
  Never Function()? confirmItemsOverride;
  int confirmCalls = 0;
  int logCalls = 0;
  int statusIndex = 0;

  @override
  Future<String> uploadMealImage(Uint8List bytes, {required ImageMime mime}) async => 'media-1';

  @override
  Future<MealScanAccepted> startScan(String mediaId) async {
    final failure = failOnStart;
    if (failure != null) throw failure;
    return MealScanAccepted(jobId: 'job-1', scanId: 'scan-1');
  }

  @override
  Future<MealScan> getScan(String scanId) async {
    final status = statuses[statusIndex.clamp(0, statuses.length - 1)];
    statusIndex++;
    return MealScan(
      id: scanId,
      status: status,
      recognition: recognition,
      revision: 1,
      error: error,
      createdAt: DateTime.utc(2026, 10, 2),
    );
  }

  @override
  Future<MealAnalysis> confirmItems({
    required String scanId,
    required int expectedRevision,
    required List<ConfirmedItemInput> items,
  }) async {
    confirmCalls++;
    confirmItemsOverride?.call();
    return MealAnalysis(
      scanId: scanId,
      revision: expectedRevision + 1,
      items: const [],
      totals: NutrientTotals(
        nutrients: _n(300),
        coverage: Coverage(itemsTotal: items.length, itemsWithNutrition: items.length, complete: true),
      ),
      mealBalance: MealBalance(score: 50, policyVersion: 'v1', components: const [], missingDataMessage: null),
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
    logCalls++;
    return MealLog(
      id: 'log-1',
      clientId: clientId ?? 'client-1',
      consumedAt: consumedAt,
      localDate: consumedAt,
      slot: slot,
      scanId: scanId,
      planMealId: null,
      items: const [],
      totals: NutrientTotals(
        nutrients: _n(300),
        coverage: Coverage(itemsTotal: items.length, itemsWithNutrition: items.length, complete: true),
      ),
      mealBalance: null,
      revision: 1,
    );
  }
}

final _recognition = Recognition(
  schemaVersion: RecognitionSchemaVersionEnum.n1,
  imageIsFood: true,
  quality: RecognitionQualityEnum.usable,
  clarification: null,
  items: [
    RecognitionItem(
      temporaryId: 'item-1',
      label: 'White rice',
      alternativeLabels: const [],
      confidenceBand: RecognitionItemConfidenceBandEnum.high,
      estimatedGrams: NumberRange(min: 100, max: 200),
      preparationQuestions: const [],
      needsConfirmation: false,
      catalogCandidates: const [],
    ),
  ],
);

ProviderContainer _container(FakeMealScanRepository repo) {
  final container = ProviderContainer(overrides: [mealScanRepositoryProvider.overrideWithValue(repo)]);
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('captureAndAnalyze goes Idle -> Uploading -> Processing -> Reviewing on success', () async {
    final repo = FakeMealScanRepository(statuses: [MealScanStatus.needsConfirmation], recognition: _recognition);
    final container = _container(repo);
    expect(container.read(mealScanControllerProvider), isA<MealScanIdle>());

    final future = container
        .read(mealScanControllerProvider.notifier)
        .captureAndAnalyze(Uint8ListFixture.bytes, mime: ImageMime.imageSlashJpeg);

    await future;
    final state = container.read(mealScanControllerProvider);
    expect(state, isA<MealScanReviewing>());
    final reviewing = state as MealScanReviewing;
    expect(reviewing.scanId, 'scan-1');
    expect(reviewing.items.single.label, 'White rice');
    // The pre-filled grams come from the midpoint of the recognizer's estimated range.
    expect(reviewing.items.single.grams, 150);
  });

  test('a non-food photo surfaces as a labelled failure, never a generic crash', () async {
    final nonFood = Recognition(
      schemaVersion: RecognitionSchemaVersionEnum.n1,
      imageIsFood: false,
      quality: RecognitionQualityEnum.usable,
      clarification: null,
      items: const [],
    );
    final repo = FakeMealScanRepository(statuses: [MealScanStatus.needsConfirmation], recognition: nonFood);
    final container = _container(repo);
    await container
        .read(mealScanControllerProvider.notifier)
        .captureAndAnalyze(Uint8ListFixture.bytes, mime: ImageMime.imageSlashJpeg);
    final state = container.read(mealScanControllerProvider);
    expect(state, isA<MealScanFailed>());
    expect((state as MealScanFailed).notFood, isTrue);
  });

  test('a provider/job failure surfaces the safe server message', () async {
    final repo = FakeMealScanRepository(
      statuses: [MealScanStatus.failed],
      error: SafeError(code: 'provider_unavailable', message: 'The scanner is temporarily unavailable.'),
    );
    final container = _container(repo);
    await container
        .read(mealScanControllerProvider.notifier)
        .captureAndAnalyze(Uint8ListFixture.bytes, mime: ImageMime.imageSlashJpeg);
    final state = container.read(mealScanControllerProvider);
    expect(state, isA<MealScanFailed>());
    expect((state as MealScanFailed).message, 'The scanner is temporarily unavailable.');
  });

  test('an upload failure never reaches the review step', () async {
    final repo = FakeMealScanRepository(
      statuses: [MealScanStatus.needsConfirmation],
      failOnStart: const ApiFailure(kind: ApiFailureKind.unavailable, message: 'Scanning is unavailable.'),
    );
    final container = _container(repo);
    await container
        .read(mealScanControllerProvider.notifier)
        .captureAndAnalyze(Uint8ListFixture.bytes, mime: ImageMime.imageSlashJpeg);
    final state = container.read(mealScanControllerProvider);
    expect(state, isA<MealScanFailed>());
    expect((state as MealScanFailed).message, 'Scanning is unavailable.');
  });

  test('removed items are excluded from confirmation and logging', () async {
    final repo = FakeMealScanRepository(statuses: [MealScanStatus.needsConfirmation], recognition: _recognition);
    final container = _container(repo);
    final controller = container.read(mealScanControllerProvider.notifier);
    await controller.captureAndAnalyze(Uint8ListFixture.bytes, mime: ImageMime.imageSlashJpeg);
    controller.removeItem('item-1');
    controller.addManualItem('Banana');

    final log = await controller.confirmAndLog(
      consumedAt: DateTime(2026, 10, 2, 8),
      timezone: 'UTC',
      slot: MealSlot.breakfast,
    );

    expect(log.id, 'log-1');
    expect(repo.confirmCalls, 1);
    expect(repo.logCalls, 1);
    expect(container.read(mealScanControllerProvider), isA<MealScanSaved>());
  });

  test('confirmAndLog restores the review step (with edits) on a server failure', () async {
    final repo = FakeMealScanRepository(statuses: [MealScanStatus.needsConfirmation], recognition: _recognition);
    final container = _container(repo);
    final controller = container.read(mealScanControllerProvider.notifier);
    await controller.captureAndAnalyze(Uint8ListFixture.bytes, mime: ImageMime.imageSlashJpeg);
    controller.updateItem('item-1', grams: 175);

    repo.confirmItemsOverride = () => throw const ApiFailure(kind: ApiFailureKind.conflict, message: 'stale');

    await expectLater(
      controller.confirmAndLog(consumedAt: DateTime(2026, 10, 2, 8), timezone: 'UTC', slot: MealSlot.breakfast),
      throwsA(isA<ApiFailure>()),
    );
    final state = container.read(mealScanControllerProvider);
    expect(state, isA<MealScanReviewing>());
    expect((state as MealScanReviewing).items.single.grams, 175);
  });
}

/// A minimal fixed byte payload; its content is irrelevant to these tests (the fake repository
/// never inspects it).
abstract final class Uint8ListFixture {
  static final bytes = Uint8List.fromList([1, 2, 3]);
}
