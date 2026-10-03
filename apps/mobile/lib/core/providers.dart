import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import 'auth/auth_repository.dart';
import 'auth/auth_state.dart';
import 'config/app_config.dart';
import 'diet/diet_repository.dart';
import 'meals/meal_scan_repository.dart';
import 'profile/profile_repository.dart';
import 'profile/session_profile.dart';
import 'recommendations/recommendations_repository.dart';
import 'workouts/workout_repository.dart';

/// Overridden in main.dart (and tests) with validated, environment-specific instances.
final appConfigProvider = Provider<AppConfig>((ref) => throw UnimplementedError('appConfigProvider'));
final authRepositoryProvider = Provider<AuthRepository>((ref) => throw UnimplementedError('authRepositoryProvider'));
final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => throw UnimplementedError('profileRepositoryProvider'),
);
final dietRepositoryProvider = Provider<DietRepository>((ref) => throw UnimplementedError('dietRepositoryProvider'));
final mealScanRepositoryProvider = Provider<MealScanRepository>(
  (ref) => throw UnimplementedError('mealScanRepositoryProvider'),
);
final recommendationsRepositoryProvider = Provider<RecommendationsRepository>(
  (ref) => throw UnimplementedError('recommendationsRepositoryProvider'),
);
final workoutRepositoryProvider = Provider<WorkoutRepository>(
  (ref) => throw UnimplementedError('workoutRepositoryProvider'),
);

class AuthController extends Notifier<AuthStatus> {
  @override
  AuthStatus build() {
    final repository = ref.watch(authRepositoryProvider);
    final StreamSubscription<AuthStatus> subscription = repository.changes.listen((status) => state = status);
    ref.onDispose(subscription.cancel);
    return repository.current;
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthStatus>(AuthController.new);

/// The signed-in user's server-owned profile (GET /v1/me) and the only writer of it. Every
/// successful write replaces the state with the server's answer, so the UI never edits profile data
/// locally. A write never puts the state back into loading: that would send the router to the
/// splash screen mid-flow. Load errors surface to the UI (with an explicit retry action) instead of
/// being retried silently.
class MeController extends AsyncNotifier<Me?> {
  @override
  Future<Me?> build() async {
    final auth = ref.watch(authControllerProvider);
    if (auth is! SignedIn) return null;
    return ref.watch(profileRepositoryProvider).fetchMe();
  }

  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  Me get _current {
    final me = state.value;
    if (me == null) throw StateError('MeController used without a loaded profile');
    return me;
  }

  /// Re-reads the profile (for example after a revision conflict). Keeps the current value on
  /// failure so the open screen stays put; the error is rethrown for the caller to show.
  Future<void> reload() async {
    state = AsyncData(await _repository.fetchMe());
    ref.read(meReloadGenerationProvider.notifier).bump();
  }

  /// PATCH /v1/me with the current profile revision.
  Future<Me> patchProfile(ProfilePatch Function(int revision) build, {String? idempotencyKey}) async {
    final updated = await _repository.patchProfile(build(_current.profile.revision), idempotencyKey: idempotencyKey);
    state = AsyncData(updated);
    return updated;
  }

  Future<void> savePreferences(PreferencesInput Function(int revision) build, {String? idempotencyKey}) async {
    final saved = await _repository.savePreferences(
      build(_current.preferences?.revision ?? 0),
      idempotencyKey: idempotencyKey,
    );
    state = AsyncData(_current.copyWith(preferences: saved));
  }

  Future<void> saveTraining(TrainingPreferencesInput Function(int revision) build, {String? idempotencyKey}) async {
    final saved = await _repository.saveTraining(
      build(_current.trainingPreferences?.revision ?? 0),
      idempotencyKey: idempotencyKey,
    );
    state = AsyncData(_current.copyWith(trainingPreferences: saved));
  }

  Future<OnboardingComplete> completeOnboarding(List<ConsentInput> consents, {required String idempotencyKey}) async {
    final result = await _repository.completeOnboarding(
      OnboardingCompleteRequest(expectedRevision: _current.profile.revision, consents: consents),
      idempotencyKey: idempotencyKey,
    );
    state = AsyncData(result.me);
    return result;
  }
}

/// Counts explicit reloads of the profile. Open forms include it in their key so a reload (for
/// example after a revision conflict) rebuilds them with the server's values, while an ordinary save
/// does not recreate the form that is still finishing its own submit.
class ReloadGeneration extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final meReloadGenerationProvider = NotifierProvider<ReloadGeneration, int>(ReloadGeneration.new);

final meControllerProvider = AsyncNotifierProvider<MeController, Me?>(
  MeController.new,
  retry: (retryCount, error) => null,
);

/// The routing slice of the profile, derived from [meControllerProvider].
final sessionProfileProvider = Provider<AsyncValue<SessionProfile?>>((ref) {
  return ref.watch(meControllerProvider).whenData((me) => me == null ? null : SessionProfile.fromMe(me));
});
