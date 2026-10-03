import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth/auth_repository.dart';
import 'auth/auth_state.dart';
import 'config/app_config.dart';
import 'profile/session_profile.dart';

/// Overridden in main.dart (and tests) with validated, environment-specific instances.
final appConfigProvider = Provider<AppConfig>((ref) => throw UnimplementedError('appConfigProvider'));
final authRepositoryProvider = Provider<AuthRepository>((ref) => throw UnimplementedError('authRepositoryProvider'));
final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => throw UnimplementedError('profileRepositoryProvider'),
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

/// GET /v1/me for the signed-in user. Errors surface to the UI (with an explicit retry action)
/// instead of being retried silently, so the router can show a recoverable error screen.
final sessionProfileProvider = FutureProvider<SessionProfile?>((ref) async {
  final auth = ref.watch(authControllerProvider);
  if (auth is! SignedIn) return null;
  return ref.watch(profileRepositoryProvider).fetchSessionProfile();
}, retry: (retryCount, error) => null);
