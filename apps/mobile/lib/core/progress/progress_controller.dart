import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../providers.dart' show progressRepositoryProvider;

/// Weight trend, starting/current/goal weight and honest adherence summaries (blueprint §6, M8).
/// Mirrors [InsightsController]'s conventions: load errors surface with an explicit retry.
class ProgressController extends AsyncNotifier<Progress> {
  @override
  Future<Progress> build() => ref.watch(progressRepositoryProvider).fetchProgress();

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(progressRepositoryProvider).fetchProgress());
  }

  Future<void> recordWeight({required DateTime measuredAt, required double weightKg}) async {
    await ref.read(progressRepositoryProvider).recordWeight(measuredAt: measuredAt, weightKg: weightKg);
    await reload();
  }
}

final progressControllerProvider = AsyncNotifierProvider<ProgressController, Progress>(ProgressController.new);

/// Weight history (separate from the summary above, since it is its own paged list, blueprint §6).
class WeightHistoryController extends AsyncNotifier<WeightLogList> {
  @override
  Future<WeightLogList> build() => ref.watch(progressRepositoryProvider).listWeightLogs();

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(progressRepositoryProvider).listWeightLogs());
  }

  Future<void> addEntry({required DateTime measuredAt, required double weightKg}) async {
    await ref.read(progressRepositoryProvider).recordWeight(measuredAt: measuredAt, weightKg: weightKg);
    await reload();
    // The at-a-glance summary (starting/current/goal) depends on history too.
    await ref.read(progressControllerProvider.notifier).reload();
  }

  Future<void> deleteEntry(String id) async {
    await ref.read(progressRepositoryProvider).deleteWeightLog(id);
    await reload();
    await ref.read(progressControllerProvider.notifier).reload();
  }
}

final weightHistoryControllerProvider = AsyncNotifierProvider<WeightHistoryController, WeightLogList>(
  WeightHistoryController.new,
);

/// Private progress photos: list, upload and delete (blueprint §6, §14; D-030 retention).
class ProgressPhotosController extends AsyncNotifier<ProgressPhotoList> {
  @override
  Future<ProgressPhotoList> build() => ref.watch(progressRepositoryProvider).listProgressPhotos();

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(progressRepositoryProvider).listProgressPhotos());
  }

  Future<void> upload({
    required Uint8List bytes,
    required ImageMime mime,
    required DateTime capturedAt,
    required PhotoAngle angle,
  }) async {
    await ref
        .read(progressRepositoryProvider)
        .uploadProgressPhoto(bytes: bytes, mime: mime, capturedAt: capturedAt, angle: angle);
    await reload();
  }

  Future<void> delete(String id) async {
    await ref.read(progressRepositoryProvider).deleteProgressPhoto(id);
    await reload();
  }
}

final progressPhotosControllerProvider = AsyncNotifierProvider<ProgressPhotosController, ProgressPhotoList>(
  ProgressPhotosController.new,
);
