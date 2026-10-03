import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noura/app/app.dart';
import 'package:noura/core/auth/auth_state.dart';
import 'package:noura/core/auth/mock_auth_repository.dart';
import 'package:noura/core/config/app_config.dart';
import 'package:noura/core/diet/diet_repository.dart';
import 'package:noura/core/profile/profile_repository.dart';
import 'package:noura/core/profile/session_profile.dart';
import 'package:noura/core/providers.dart';
import 'package:noura_api_client/noura_api_client.dart';

import 'fake_profile_server.dart';

AppConfig testConfig({
  AppEnvironment? environment = AppEnvironment.development,
  bool useMocks = false,
  bool devBypassOnboarding = false,
  String apiBaseUrl = 'http://127.0.0.1:8080',
  String supabaseUrl = 'http://127.0.0.1:54321',
  String publishableKey = 'sb_publishable_placeholder',
  String redirect = 'noura://auth-callback',
  bool google = false,
  bool apple = false,
}) => AppConfig(
  environment: environment,
  environmentName: environment?.name ?? 'bogus',
  apiBaseUrl: apiBaseUrl,
  supabaseUrl: supabaseUrl,
  supabasePublishableKey: publishableKey,
  authRedirectUrl: redirect,
  useMocks: useMocks,
  googleSignInEnabled: google,
  appleSignInEnabled: apple,
  devBypassOnboarding: devBypassOnboarding,
);

/// Profile source for the shell and auth tests: a fake server that starts in a given onboarding
/// state, with an optional load error and a count of load attempts to prove retry behaviour.
class FakeProfileRepository extends FakeProfileServer {
  FakeProfileRepository({OnboardingState onboarding = OnboardingState.completed, this.error})
    : super(
        initial: onboarding == OnboardingState.completed
            ? FakeProfileServer.completedMe()
            : FakeProfileServer.emptyMe().copyWith(
                profile: FakeProfileServer.emptyMe().profile.copyWith(displayName: 'Asha'),
                onboarding: Onboarding(
                  status: onboarding == OnboardingState.inProgress
                      ? OnboardingStatus.inProgress
                      : OnboardingStatus.notStarted,
                  step: null,
                ),
              ),
      );

  Object? error;
  int get loads => calls.where((c) => c == 'fetchMe').length;

  @override
  Future<Me> fetchMe() async {
    final failure = error;
    if (failure != null) {
      calls.add('fetchMe');
      throw failure;
    }
    return super.fetchMe();
  }
}

/// Recording auth repository: the mock, plus a log of calls the UI made.
class RecordingAuthRepository extends MockAuthRepository {
  RecordingAuthRepository({super.initial});
  final calls = <String>[];

  @override
  Future<void> signInWithEmail({required String email, required String password}) {
    calls.add('signIn:$email');
    return super.signInWithEmail(email: email, password: password);
  }

  @override
  Future<void> sendPasswordReset({required String email}) {
    calls.add('reset:$email');
    return super.sendPasswordReset(email: email);
  }

  @override
  Future<void> updatePassword({required String newPassword}) {
    calls.add('updatePassword');
    return super.updatePassword(newPassword: newPassword);
  }

  @override
  Future<void> signOut({SignOutReason? reason}) {
    calls.add('signOut:${reason?.name}');
    return super.signOut(reason: reason);
  }
}

const signedIn = SignedIn(userId: MockAuthRepository.mockUserId, email: 'asha@example.com');

Future<void> pumpNoura(
  WidgetTester tester, {
  required RecordingAuthRepository auth,
  required ProfileRepository profiles,
  DietRepository? diet,
  AppConfig? config,
  Size size = const Size(1080, 2340),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config ?? testConfig()),
        authRepositoryProvider.overrideWithValue(auth),
        profileRepositoryProvider.overrideWithValue(profiles),
        if (diet != null) dietRepositoryProvider.overrideWithValue(diet),
      ],
      child: const NouraApp(),
    ),
  );
  await tester.pumpAndSettle();
}

/// Lets stream events and futures resolve, then settles animations.
Future<void> settle(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await tester.pumpAndSettle();
}
