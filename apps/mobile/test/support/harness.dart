import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noura/app/app.dart';
import 'package:noura/core/auth/auth_state.dart';
import 'package:noura/core/auth/mock_auth_repository.dart';
import 'package:noura/core/config/app_config.dart';
import 'package:noura/core/profile/session_profile.dart';
import 'package:noura/core/providers.dart';

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

/// Profile source whose result each test controls; counts calls to prove retry behaviour.
class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({this.onboarding = OnboardingState.completed, this.error});

  OnboardingState onboarding;
  Object? error;
  int calls = 0;

  @override
  Future<SessionProfile> fetchSessionProfile() async {
    calls++;
    final failure = error;
    if (failure != null) throw failure;
    return SessionProfile(
      userId: MockAuthRepository.mockUserId,
      displayName: 'Asha',
      onboarding: onboarding,
      onboardingStep: null,
    );
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
  AppConfig? config,
}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config ?? testConfig()),
        authRepositoryProvider.overrideWithValue(auth),
        profileRepositoryProvider.overrideWithValue(profiles),
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
