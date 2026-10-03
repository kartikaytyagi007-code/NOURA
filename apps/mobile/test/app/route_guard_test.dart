import 'package:flutter_test/flutter_test.dart';
import 'package:noura/app/route_guard.dart';
import 'package:noura/app/routes.dart';
import 'package:noura/core/auth/auth_state.dart';
import 'package:noura/core/profile/session_profile.dart';

const _user = SignedIn(userId: '00000000-0000-4000-8000-000000000001', phone: '+919876543210');

ProfileReady _profile(OnboardingState state) =>
    ProfileReady(SessionProfile(userId: _user.userId, displayName: null, onboarding: state, onboardingStep: null));

String? _redirect(
  String location,
  AuthStatus auth, [
  ProfileGate profile = const ProfileLoading(),
  bool bypass = false,
]) => resolveRedirect(location: location, auth: auth, profile: profile, devBypassOnboarding: bypass);

void main() {
  group('resolveRedirect', () {
    test('holds every location on the splash screen while the session restores', () {
      expect(_redirect(Routes.home, const AuthRestoring()), Routes.splash);
      expect(_redirect(Routes.welcome, const AuthRestoring()), Routes.splash);
      expect(_redirect(Routes.splash, const AuthRestoring()), isNull);
    });

    test('signed-out users only reach public screens', () {
      for (final protected in [Routes.home, Routes.meals, Routes.settings, Routes.onboarding, Routes.splash]) {
        expect(_redirect(protected, const SignedOut()), Routes.welcome, reason: protected);
      }
      for (final public in [Routes.welcome, Routes.signIn, Routes.verifyOtp]) {
        expect(_redirect(public, const SignedOut()), isNull, reason: public);
      }
    });

    test('signed-in users wait for the server profile, and a failure is recoverable', () {
      expect(_redirect(Routes.signIn, _user), Routes.splash);
      expect(_redirect(Routes.home, _user, const ProfileFailed()), Routes.sessionError);
    });

    test('unfinished onboarding is enforced, except for settings (to sign out)', () {
      for (final state in [OnboardingState.notStarted, OnboardingState.inProgress]) {
        expect(_redirect(Routes.home, _user, _profile(state)), Routes.onboarding);
        expect(_redirect(Routes.coach, _user, _profile(state)), Routes.onboarding);
        expect(_redirect(Routes.onboarding, _user, _profile(state)), isNull);
        expect(_redirect(Routes.settings, _user, _profile(state)), isNull);
      }
    });

    test('completed users land in the shell and are kept out of auth and onboarding', () {
      final done = _profile(OnboardingState.completed);
      for (final outside in [Routes.splash, Routes.welcome, Routes.signIn, Routes.onboarding, Routes.sessionError]) {
        expect(_redirect(outside, _user, done), Routes.home, reason: outside);
      }
      for (final tab in [Routes.home, Routes.meals, Routes.coach, Routes.workout, Routes.progress, Routes.settings]) {
        expect(_redirect(tab, _user, done), isNull, reason: tab);
      }
    });

    test('the development onboarding bypass opens the shell', () {
      expect(_redirect(Routes.splash, _user, _profile(OnboardingState.notStarted), true), Routes.home);
    });
  });
}
