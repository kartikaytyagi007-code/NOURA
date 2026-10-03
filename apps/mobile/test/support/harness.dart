import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noura/app/app.dart';
import 'package:noura/core/auth/auth_state.dart';
import 'package:noura/core/auth/mock_auth_repository.dart';
import 'package:noura/core/config/app_config.dart';
import 'package:noura/core/diet/diet_repository.dart';
import 'package:noura/core/meals/meal_scan_repository.dart';
import 'package:noura/core/profile/profile_repository.dart';
import 'package:noura/core/profile/session_profile.dart';
import 'package:noura/core/providers.dart';
import 'package:noura/core/recommendations/recommendations_repository.dart';
import 'package:noura/core/workouts/workout_repository.dart';
import 'package:noura_api_client/noura_api_client.dart';

import 'fake_profile_server.dart';

AppConfig testConfig({
  AppEnvironment? environment = AppEnvironment.development,
  bool useMocks = false,
  bool devBypassOnboarding = false,
  String apiBaseUrl = 'http://127.0.0.1:8080',
  String supabaseUrl = 'http://127.0.0.1:54321',
  String publishableKey = 'sb_publishable_placeholder',
}) => AppConfig(
  environment: environment,
  environmentName: environment?.name ?? 'bogus',
  apiBaseUrl: apiBaseUrl,
  supabaseUrl: supabaseUrl,
  supabasePublishableKey: publishableKey,
  useMocks: useMocks,
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
  Future<void> sendPhoneOtp({required String phone}) {
    calls.add('sendOtp:$phone');
    return super.sendPhoneOtp(phone: phone);
  }

  @override
  Future<void> verifyPhoneOtp({required String phone, required String code}) {
    calls.add('verifyOtp:$phone:$code');
    return super.verifyPhoneOtp(phone: phone, code: code);
  }

  @override
  Future<void> signOut({SignOutReason? reason}) {
    calls.add('signOut:${reason?.name}');
    return super.signOut(reason: reason);
  }
}

const signedIn = SignedIn(userId: MockAuthRepository.mockUserId, phone: '+919876543210');

Future<void> pumpNoura(
  WidgetTester tester, {
  required RecordingAuthRepository auth,
  required ProfileRepository profiles,
  DietRepository? diet,
  MealScanRepository? mealScan,
  RecommendationsRepository? recommendations,
  WorkoutRepository? workouts,
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
        if (mealScan != null) mealScanRepositoryProvider.overrideWithValue(mealScan),
        // Home reads this on first build (M6); default to the obviously-labelled mock so tests that
        // don't care about M6 (most of them) don't need to know about it.
        recommendationsRepositoryProvider.overrideWithValue(recommendations ?? MockRecommendationsRepository()),
        workoutRepositoryProvider.overrideWithValue(workouts ?? MockWorkoutRepository()),
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
