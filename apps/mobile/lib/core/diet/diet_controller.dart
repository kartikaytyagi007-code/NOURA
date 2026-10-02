import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../providers.dart' show dietRepositoryProvider;
import 'diet_repository.dart' show DietRepository;

/// The signed-in user's active diet plan (GET /v1/diet-plans/current), swaps and regeneration.
/// Mirrors [MeController]'s conventions: a write replaces the state with the server's answer, and
/// load errors surface to the UI with an explicit retry instead of being retried silently.
class DietController extends AsyncNotifier<DietPlan?> {
  @override
  Future<DietPlan?> build() => ref.watch(dietRepositoryProvider).fetchCurrentPlan();

  DietRepository get _repository => ref.read(dietRepositoryProvider);

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.fetchCurrentPlan());
  }

  /// Requests the first plan, or a regeneration when one is already active. Does not itself wait
  /// for the job to finish: the caller re-fetches (for example via [reload]) once it expects the
  /// worker to be done, or polls `/v1/jobs/{id}` with the returned job id.
  Future<String> requestGeneration({required int profileRevision, DateTime? startDate}) {
    return _repository.requestGeneration(profileRevision: profileRevision, startDate: startDate ?? DateTime.now());
  }

  Future<SwapOptions> swapOptions(PlanMeal meal) =>
      _repository.swapOptions(planMealId: meal.id, expectedRevision: meal.revision);

  /// Replaces one slot and merges the result back into the loaded plan in place.
  Future<void> replaceMeal(PlanMeal meal, String candidateId) async {
    final updated = await _repository.replaceMeal(
      planMealId: meal.id,
      expectedRevision: meal.revision,
      candidateId: candidateId,
    );
    final plan = state.value;
    if (plan == null) return;
    state = AsyncData(
      DietPlan(
        id: plan.id,
        version: plan.version,
        startsOn: plan.startsOn,
        status: plan.status,
        targetSnapshotId: plan.targetSnapshotId,
        days: [
          for (final day in plan.days)
            if (day.date == updated.date)
              PlanDay(
                date: day.date,
                totals: day.totals,
                meals: [
                  for (final m in day.meals)
                    if (m.id == updated.id) updated else m,
                ],
              )
            else
              day,
        ],
      ),
    );
  }
}

final dietControllerProvider = AsyncNotifierProvider<DietController, DietPlan?>(DietController.new);
