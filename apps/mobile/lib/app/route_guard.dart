import 'package:flutter/foundation.dart';

import '../core/auth/auth_state.dart';
import '../core/profile/session_profile.dart';
import 'routes.dart';

/// Profile loading state as seen by the router.
@immutable
sealed class ProfileGate {
  const ProfileGate();
}

final class ProfileLoading extends ProfileGate {
  const ProfileLoading();
}

final class ProfileFailed extends ProfileGate {
  const ProfileFailed();
}

final class ProfileReady extends ProfileGate {
  const ProfileReady(this.profile);
  final SessionProfile profile;
}

/// Pure navigation policy (blueprint §4):
/// cold start → restore auth → signed out: welcome/auth screens;
/// signed in with unfinished onboarding → onboarding (resume step is M2);
/// completed profile → app shell. A profile that cannot be loaded never traps the user: they get
/// a recoverable error screen with retry and sign-out. Password recovery always wins.
String? resolveRedirect({
  required String location,
  required AuthStatus auth,
  required ProfileGate profile,
  bool devBypassOnboarding = false,
}) {
  String? goTo(String target) => location == target ? null : target;

  switch (auth) {
    case AuthRestoring():
      return goTo(Routes.splash);
    case PasswordRecovery():
      return goTo(Routes.updatePassword);
    case SignedOut():
      if (Routes.isPublic(location) && location != Routes.updatePassword) return null;
      return goTo(Routes.welcome);
    case SignedIn():
      switch (profile) {
        case ProfileLoading():
          return goTo(Routes.splash);
        case ProfileFailed():
          return goTo(Routes.sessionError);
        case ProfileReady(:final profile):
          final onboardingDone = profile.onboarding == OnboardingState.completed || devBypassOnboarding;
          if (!onboardingDone) {
            return location == Routes.onboarding || location == Routes.settings ? null : Routes.onboarding;
          }
          final outsideApp =
              Routes.isPublic(location) ||
              location == Routes.splash ||
              location == Routes.onboarding ||
              location == Routes.sessionError;
          return outsideApp ? Routes.home : null;
      }
  }
}
