import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_failure.dart';
import '../providers.dart' show mealScanRepositoryProvider;
import 'plate_fixes_state.dart';

/// Drives the "Fix My Plate" load (blueprint §8 step 7, M5). One instance is reused per screen
/// visit; [load] is idempotent to call again (e.g. pull-to-retry after an error).
class PlateFixesController extends Notifier<PlateFixesState> {
  @override
  PlateFixesState build() => const PlateFixesIdle();

  Future<void> load({required String scanId, required int expectedRevision}) async {
    state = const PlateFixesLoading();
    try {
      final fixes = await ref
          .read(mealScanRepositoryProvider)
          .getPlateFixes(scanId: scanId, expectedRevision: expectedRevision);
      state = PlateFixesLoaded(fixes);
    } on ApiFailure catch (error) {
      state = PlateFixesError(error.message, retryable: error.retryable || error.isOffline);
    }
  }
}

final plateFixesControllerProvider = NotifierProvider<PlateFixesController, PlateFixesState>(PlateFixesController.new);
