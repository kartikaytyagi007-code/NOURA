import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../auth/auth_state.dart';
import '../providers.dart' show authControllerProvider, recommendationsRepositoryProvider;

/// Home summary (GET /v1/home, blueprint §4, M6). Null before/without a session, same pattern as
/// [MeController]. Build re-runs on auth changes so signing out clears it immediately.
class HomeController extends AsyncNotifier<Home?> {
  @override
  Future<Home?> build() async {
    final auth = ref.watch(authControllerProvider);
    if (auth is! SignedIn) return null;
    return ref.watch(recommendationsRepositoryProvider).fetchHome();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(recommendationsRepositoryProvider).fetchHome());
  }
}

final homeControllerProvider = AsyncNotifierProvider<HomeController, Home?>(HomeController.new);
