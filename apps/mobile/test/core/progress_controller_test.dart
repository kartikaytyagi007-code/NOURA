import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noura/core/profile/profile_repository.dart' show newIdempotencyKey;
import 'package:noura/core/progress/progress_controller.dart';
import 'package:noura/core/progress/progress_repository.dart';
import 'package:noura/core/providers.dart';
import 'package:noura_api_client/noura_api_client.dart';

/// A fake [ProgressRepository] whose behaviour the test controls directly; members unused by the
/// controllers under test throw if ever called (same convention as other controller tests).
class _FakeRepo implements ProgressRepository {
  _FakeRepo({this.progress, List<WeightLog>? weights}) : weights = weights ?? [];

  Progress? progress;
  List<WeightLog> weights;
  final List<ProgressPhoto> photos = [];

  @override
  Future<Progress> fetchProgress() async => progress!;

  @override
  Future<WeightLogList> listWeightLogs() async => WeightLogList(items: List.of(weights), nextCursor: null);

  @override
  Future<WeightLog> recordWeight({required DateTime measuredAt, required double weightKg, String? clientId}) async {
    final log = WeightLog(
      id: 'w-${weights.length + 1}',
      clientId: clientId ?? newIdempotencyKey(),
      measuredAt: measuredAt,
      weightKg: weightKg,
    );
    weights.insert(0, log);
    return log;
  }

  @override
  Future<void> deleteWeightLog(String id) async => weights.removeWhere((w) => w.id == id);

  @override
  Future<ProgressPhotoList> listProgressPhotos() async => ProgressPhotoList(items: List.of(photos), nextCursor: null);

  @override
  Future<ProgressPhoto> uploadProgressPhoto({
    required Uint8List bytes,
    required ImageMime mime,
    required DateTime capturedAt,
    required PhotoAngle angle,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteProgressPhoto(String id) => throw UnimplementedError();

  @override
  Future<String> getPhotoDownloadUrl(String mediaId) => throw UnimplementedError();
}

Progress _progress({
  bool dietPlanActive = false,
  int? dietPlanned,
  int? dietLogged,
  num? starting,
  num? current,
  num? goal,
}) => Progress(
  periodStart: DateTime.utc(2026, 9, 3),
  periodEnd: DateTime.utc(2026, 10, 2),
  weightPoints: const [],
  startingWeightKg: starting,
  currentWeightKg: current,
  goalWeightKg: goal,
  mealLoggedDays: 0,
  dietAdherence: AdherenceSummary(planActive: dietPlanActive, planned: dietPlanned, logged: dietLogged),
  workoutsCompleted: 0,
  workoutsScheduledElapsed: 0,
  workoutAdherence: AdherenceSummary(planActive: false, planned: null, logged: null),
);

ProviderContainer _container(ProgressRepository repo) {
  final container = ProviderContainer(overrides: [progressRepositoryProvider.overrideWithValue(repo)]);
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('build loads progress from the repository', () async {
    final repo = _FakeRepo(progress: _progress(starting: 80, current: 76));
    final container = _container(repo);
    final progress = await container.read(progressControllerProvider.future);
    expect(progress.startingWeightKg, 80);
    expect(progress.currentWeightKg, 76);
  });

  test('no active plan is delivered as null adherence, never a fabricated 0-of-0', () async {
    final repo = _FakeRepo(progress: _progress());
    final container = _container(repo);
    final progress = await container.read(progressControllerProvider.future);
    expect(progress.dietAdherence.planActive, isFalse);
    expect(progress.dietAdherence.planned, isNull);
    expect(progress.dietAdherence.logged, isNull);
  });

  test('an active plan with a real adherence count is distinct from "no plan"', () async {
    final repo = _FakeRepo(progress: _progress(dietPlanActive: true, dietPlanned: 5, dietLogged: 0));
    final container = _container(repo);
    final progress = await container.read(progressControllerProvider.future);
    expect(progress.dietAdherence.planActive, isTrue);
    expect(progress.dietAdherence.planned, 5);
    expect(progress.dietAdherence.logged, 0);
  });

  test('recordWeight reloads the summary with the repository latest data', () async {
    final repo = _FakeRepo(progress: _progress(starting: 80, current: 80));
    final container = _container(repo);
    await container.read(progressControllerProvider.future);

    repo.progress = _progress(starting: 80, current: 78);
    await container.read(progressControllerProvider.notifier).recordWeight(measuredAt: DateTime.now(), weightKg: 78);
    final state = container.read(progressControllerProvider);
    expect(state.value?.currentWeightKg, 78);
  });
}
