import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../api/api_failure.dart';

enum OnboardingState { notStarted, inProgress, completed }

/// The slice of GET /v1/me the shell needs for routing. Server-owned; never edited locally.
@immutable
class SessionProfile {
  const SessionProfile({
    required this.userId,
    required this.displayName,
    required this.onboarding,
    required this.onboardingStep,
  });

  final String userId;
  final String? displayName;
  final OnboardingState onboarding;
  final String? onboardingStep;
}

abstract interface class ProfileRepository {
  Future<SessionProfile> fetchSessionProfile();
}

class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository(this._client);
  final NouraApiClient _client;

  @override
  Future<SessionProfile> fetchSessionProfile() async {
    try {
      final response = await _client.getProfileApi().getMe();
      final me = response.data!.data;
      return SessionProfile(
        userId: me.userId,
        displayName: me.profile.displayName,
        onboarding: switch (me.onboarding.status) {
          OnboardingStatus.notStarted => OnboardingState.notStarted,
          OnboardingStatus.inProgress => OnboardingState.inProgress,
          OnboardingStatus.completed => OnboardingState.completed,
        },
        onboardingStep: me.onboarding.step?.value,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }
}

/// DEVELOPMENT-ONLY profile source used with mock auth. Returns a not-started profile so the
/// onboarding route guard is exercised; it never fabricates nutrition or plan data.
class MockProfileRepository implements ProfileRepository {
  MockProfileRepository({this.onboarding = OnboardingState.notStarted});
  final OnboardingState onboarding;

  @override
  Future<SessionProfile> fetchSessionProfile() async => SessionProfile(
    userId: '00000000-0000-4000-8000-000000000001',
    displayName: null,
    onboarding: onboarding,
    onboardingStep: null,
  );
}
