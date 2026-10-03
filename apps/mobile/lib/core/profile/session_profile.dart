import 'package:flutter/foundation.dart';
import 'package:noura_api_client/noura_api_client.dart';

enum OnboardingState { notStarted, inProgress, completed }

/// The slice of GET /v1/me the router needs. Server-owned; never edited locally.
@immutable
class SessionProfile {
  const SessionProfile({
    required this.userId,
    required this.displayName,
    required this.onboarding,
    required this.onboardingStep,
  });

  factory SessionProfile.fromMe(Me me) => SessionProfile(
    userId: me.userId,
    displayName: me.profile.displayName,
    onboarding: switch (me.onboarding.status) {
      OnboardingStatus.notStarted => OnboardingState.notStarted,
      OnboardingStatus.inProgress => OnboardingState.inProgress,
      OnboardingStatus.completed => OnboardingState.completed,
    },
    onboardingStep: me.onboarding.step?.value,
  );

  final String userId;
  final String? displayName;
  final OnboardingState onboarding;
  final String? onboardingStep;

  @override
  bool operator ==(Object other) =>
      other is SessionProfile &&
      other.userId == userId &&
      other.displayName == displayName &&
      other.onboarding == onboarding &&
      other.onboardingStep == onboardingStep;

  @override
  int get hashCode => Object.hash(userId, displayName, onboarding, onboardingStep);
}
