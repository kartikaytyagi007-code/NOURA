import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../providers.dart' show recommendationsRepositoryProvider;

/// Seven-day nutrition-pattern summary (blueprint §10, §16 M6). Mirrors [DietController]'s
/// conventions: load errors surface to the UI with an explicit retry rather than retrying silently.
class InsightsController extends AsyncNotifier<Insights> {
  @override
  Future<Insights> build() => ref.watch(recommendationsRepositoryProvider).fetchInsights();

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(recommendationsRepositoryProvider).fetchInsights());
  }
}

final insightsControllerProvider = AsyncNotifierProvider<InsightsController, Insights>(InsightsController.new);
