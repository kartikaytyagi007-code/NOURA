import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../api/api_failure.dart';
import '../providers.dart' show recommendationsRepositoryProvider;
import 'next_meal_state.dart';

/// Drives the "What should I eat next?" load and its add/swap/dismiss actions (blueprint §9, M6).
/// One instance is reused per screen visit; [load] is idempotent to call again (pull-to-retry).
class NextMealController extends Notifier<NextMealState> {
  @override
  NextMealState build() => const NextMealIdle();

  DateTime? _lastDate;
  MealSlot? _lastSlot;

  Future<void> load({DateTime? date, MealSlot? slot}) async {
    _lastDate = date;
    _lastSlot = slot;
    state = const NextMealLoading();
    try {
      final nextMeal = await ref.read(recommendationsRepositoryProvider).fetchNextMeal(date: date, slot: slot);
      state = NextMealLoaded(nextMeal);
    } on ApiFailure catch (error) {
      state = NextMealError(error.message, retryable: error.retryable || error.isOffline);
    }
  }

  Future<void> reload() => load(date: _lastDate, slot: _lastSlot);

  /// Adds the chosen option to today's plan (only valid for a slot the active plan doesn't cover
  /// yet). Reloads the recommendation afterwards so the screen reflects the new plan state.
  Future<void> add(NextMeal nextMeal, NextMealOption option) =>
      _act(nextMeal, NextMealActionType.add, candidateId: option.candidateId);

  /// Swaps the chosen option into an existing planned slot (delegates to the same domain logic the
  /// diet-plan screen's swap uses, server-side).
  Future<void> swap(NextMeal nextMeal, NextMealOption option, {required int expectedRevision}) => _act(
    nextMeal,
    NextMealActionType.swap,
    candidateId: option.candidateId,
    targetPlanMealId: option.planMealId,
    expectedRevision: expectedRevision,
  );

  /// Dismisses the recommendation for this date/slot. Sticky: a later load for the same date/slot
  /// will honestly report the dismissal instead of recomputing the same suggestion.
  Future<void> dismiss(NextMeal nextMeal) => _act(nextMeal, NextMealActionType.dismiss);

  Future<void> _act(
    NextMeal nextMeal,
    NextMealActionType action, {
    String? candidateId,
    String? targetPlanMealId,
    int? expectedRevision,
  }) async {
    await ref
        .read(recommendationsRepositoryProvider)
        .performAction(
          date: nextMeal.date,
          slot: nextMeal.slot,
          action: action,
          candidateId: candidateId,
          targetPlanMealId: targetPlanMealId,
          expectedRevision: expectedRevision,
        );
    await load(date: nextMeal.date, slot: nextMeal.slot);
  }
}

final nextMealControllerProvider = NotifierProvider<NextMealController, NextMealState>(NextMealController.new);
