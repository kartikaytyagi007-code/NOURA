import 'package:flutter/foundation.dart';
import 'package:noura_api_client/noura_api_client.dart';

/// "What should I eat next?" load states (blueprint §4 "Next meal", §16 M6), following the same
/// idle/loading/loaded/error shape [PlateFixesState] (M5) uses.
@immutable
sealed class NextMealState {
  const NextMealState();
}

class NextMealIdle extends NextMealState {
  const NextMealIdle();
}

class NextMealLoading extends NextMealState {
  const NextMealLoading();
}

class NextMealLoaded extends NextMealState {
  const NextMealLoaded(this.nextMeal);
  final NextMeal nextMeal;
}

class NextMealError extends NextMealState {
  const NextMealError(this.message, {this.retryable = true});
  final String message;
  final bool retryable;
}
