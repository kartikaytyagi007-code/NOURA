import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noura/core/api/api_failure.dart';
import 'package:noura/core/meals/meal_scan_repository.dart';
import 'package:noura/core/meals/plate_fixes_controller.dart';
import 'package:noura/core/meals/plate_fixes_state.dart';
import 'package:noura/core/providers.dart';
import 'package:noura_api_client/noura_api_client.dart';

Nutrients _n(num kcal) => Nutrients(energyKcal: kcal, proteinG: 10, carbohydrateG: 20, fatG: 5, fibreG: 3);

/// A fake [MealScanRepository] whose [getPlateFixes] behaviour the test controls (mirrors
/// `FakeMealScanRepository`'s role in `meal_scan_controller_test.dart`), so the plate-fixes load
/// state machine can be exercised without a server.
class _FakeRepo implements MealScanRepository {
  _FakeRepo({this.result, this.failure});
  final PlateFixes? result;
  final ApiFailure? failure;

  @override
  Future<String> uploadMealImage(Uint8List bytes, {required ImageMime mime}) => throw UnimplementedError();
  @override
  Future<MealScanAccepted> startScan(String mediaId) => throw UnimplementedError();
  @override
  Future<MealScan> getScan(String scanId) => throw UnimplementedError();
  @override
  Future<MealAnalysis> confirmItems({
    required String scanId,
    required int expectedRevision,
    required List<ConfirmedItemInput> items,
  }) => throw UnimplementedError();
  @override
  Future<MealLog> logMeal({
    required DateTime consumedAt,
    required String timezone,
    required MealSlot slot,
    String? scanId,
    required List<ConfirmedItemInput> items,
    String? clientId,
  }) => throw UnimplementedError();

  @override
  Future<PlateFixes> getPlateFixes({required String scanId, required int expectedRevision}) async {
    final failure = this.failure;
    if (failure != null) throw failure;
    return result!;
  }
}

ProviderContainer _container(MealScanRepository repo) {
  final container = ProviderContainer(overrides: [mealScanRepositoryProvider.overrideWithValue(repo)]);
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('load goes Idle -> Loading -> Loaded with the fixes from the repository', () async {
    final fixes = PlateFixes(
      scanId: 'scan-1',
      revision: 2,
      fixes: [
        PlateAction(
          type: PlateActionTypeEnum.add,
          itemId: null,
          catalogFoodId: 'food-veg',
          proposedGrams: 80,
          reason: 'Add vegetables.',
          projected: ProjectedScenario(
            label: ProjectedScenarioLabelEnum.projected,
            totals: NutrientTotals(
              nutrients: _n(300),
              coverage: Coverage(itemsTotal: 2, itemsWithNutrition: 2, complete: true),
            ),
            mealBalance: MealBalance(score: 60, policyVersion: 'v1', components: const [], missingDataMessage: null),
          ),
          requiresConfirmation: true,
        ),
      ],
      afterChanges: AfterChangesScenario(
        totals: NutrientTotals(
          nutrients: _n(300),
          coverage: Coverage(itemsTotal: 2, itemsWithNutrition: 2, complete: true),
        ),
        mealBalance: MealBalance(score: 60, policyVersion: 'v1', components: const [], missingDataMessage: null),
        assumptions: const ['Assumes adding 80g of vegetables.'],
      ),
    );
    final container = _container(_FakeRepo(result: fixes));
    expect(container.read(plateFixesControllerProvider), isA<PlateFixesIdle>());

    await container.read(plateFixesControllerProvider.notifier).load(scanId: 'scan-1', expectedRevision: 2);
    final state = container.read(plateFixesControllerProvider);
    expect(state, isA<PlateFixesLoaded>());
    expect((state as PlateFixesLoaded).fixes.fixes, hasLength(1));
    expect(state.fixes.afterChanges.assumptions, ['Assumes adding 80g of vegetables.']);
  });

  test('a repository failure surfaces as a labelled, retryable error state', () async {
    final container = _container(
      _FakeRepo(
        failure: const ApiFailure(kind: ApiFailureKind.unavailable, message: 'try later', retryable: true),
      ),
    );
    await container.read(plateFixesControllerProvider.notifier).load(scanId: 'scan-1', expectedRevision: 1);
    final state = container.read(plateFixesControllerProvider);
    expect(state, isA<PlateFixesError>());
    expect((state as PlateFixesError).message, 'try later');
    expect(state.retryable, isTrue);
  });
}
