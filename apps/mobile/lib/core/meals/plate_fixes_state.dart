import 'package:flutter/foundation.dart';
import 'package:noura_api_client/noura_api_client.dart';

/// "Fix My Plate" load states (blueprint §8 step 7, M5): loading, loaded (which may itself be
/// "empty" — zero fixes — handled by the screen), or error. Kept separate from [MealScanFlowState]
/// because fetching plate fixes is a side quest from the analyzed step, not a step of the main scan
/// state machine itself.
@immutable
sealed class PlateFixesState {
  const PlateFixesState();
}

class PlateFixesIdle extends PlateFixesState {
  const PlateFixesIdle();
}

class PlateFixesLoading extends PlateFixesState {
  const PlateFixesLoading();
}

class PlateFixesLoaded extends PlateFixesState {
  const PlateFixesLoaded(this.fixes);
  final PlateFixes fixes;
}

class PlateFixesError extends PlateFixesState {
  const PlateFixesError(this.message, {this.retryable = true});
  final String message;
  final bool retryable;
}
