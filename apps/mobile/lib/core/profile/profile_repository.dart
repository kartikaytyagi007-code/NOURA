import 'dart:math';

import 'package:dio/dio.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../api/api_failure.dart';

/// The consent text is owned by legal review. Until counsel supplies final documents the server
/// publishes only this DRAFT placeholder version (docs/decisions.md D-021) and rejects any other.
const String kDraftConsentVersion = 'v0-draft';

/// Server-owned profile data (GET/PATCH /v1/me and friends). Widgets use this through
/// [MeController]; they never call the generated client directly.
///
/// Every write carries an idempotency key. Pass the same key when retrying the same submission so a
/// request that reached the server but whose response was lost is not applied twice.
abstract interface class ProfileRepository {
  Future<Me> fetchMe();
  Future<Me> patchProfile(ProfilePatch patch, {String? idempotencyKey});
  Future<Preferences> savePreferences(PreferencesInput input, {String? idempotencyKey});
  Future<TrainingPreferences> saveTraining(TrainingPreferencesInput input, {String? idempotencyKey});
  Future<OnboardingComplete> completeOnboarding(OnboardingCompleteRequest request, {String? idempotencyKey});
}

final _random = Random.secure();

/// A random 128-bit key formatted like a UUID v4.
String newIdempotencyKey() {
  final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-'
      '${hex.substring(16, 20)}-${hex.substring(20)}';
}

class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository(this._client);
  final NouraApiClient _client;

  ProfileApi get _api => _client.getProfileApi();

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<Me> fetchMe() => _guard(() async => (await _api.getMe()).data!.data);

  @override
  Future<Me> patchProfile(ProfilePatch patch, {String? idempotencyKey}) => _guard(
    () async =>
        (await _api.patchMe(idempotencyKey: idempotencyKey ?? newIdempotencyKey(), profilePatch: patch)).data!.data,
  );

  @override
  Future<Preferences> savePreferences(PreferencesInput input, {String? idempotencyKey}) => _guard(
    () async => (await _api.putPreferences(
      idempotencyKey: idempotencyKey ?? newIdempotencyKey(),
      preferencesInput: input,
    )).data!.data,
  );

  @override
  Future<TrainingPreferences> saveTraining(TrainingPreferencesInput input, {String? idempotencyKey}) => _guard(
    () async => (await _api.putTrainingPreferences(
      idempotencyKey: idempotencyKey ?? newIdempotencyKey(),
      trainingPreferencesInput: input,
    )).data!.data,
  );

  @override
  Future<OnboardingComplete> completeOnboarding(OnboardingCompleteRequest request, {String? idempotencyKey}) => _guard(
    () async => (await _api.completeOnboarding(
      idempotencyKey: idempotencyKey ?? newIdempotencyKey(),
      onboardingCompleteRequest: request,
    )).data!.data,
  );
}

/// DEVELOPMENT-ONLY profile source used with mock auth. It keeps answers in memory with the same
/// revision rules as the server so the onboarding screens can be exercised, but it computes no
/// eligibility, targets or plans: a completed mock profile reports planning as unavailable. It is
/// wired only when the app config enables mocks, which production configuration refuses.
class MockProfileRepository implements ProfileRepository {
  MockProfileRepository();

  static const mockUserId = '00000000-0000-4000-8000-000000000001';

  Me _me = Me(
    userId: mockUserId,
    profile: Profile(
      displayName: null,
      ageYears: null,
      calculationSex: null,
      heightCm: null,
      weightKg: null,
      activityBand: null,
      timezone: 'UTC',
      unitSystem: UnitSystem.metric,
      revision: 1,
    ),
    goal: null,
    preferences: null,
    trainingPreferences: null,
    eligibilityStatus: null,
    screening: null,
    onboarding: Onboarding(status: OnboardingStatus.notStarted, step: null),
    planning: null,
  );

  @override
  Future<Me> fetchMe() async => _me;

  @override
  Future<Me> patchProfile(ProfilePatch patch, {String? idempotencyKey}) async {
    _checkRevision(patch.expectedRevision, _me.profile.revision);
    final p = _me.profile;
    final sex = patch.calculationSex;
    _me = _me.copyWith(
      profile: Profile(
        displayName: patch.displayName ?? p.displayName,
        ageYears: patch.ageYears ?? p.ageYears,
        calculationSex: sex == null
            ? p.calculationSex
            : switch (sex) {
                CalculationSexInput.female => CalculationSex.female,
                CalculationSexInput.male => CalculationSex.male,
                CalculationSexInput.declined => null,
              },
        heightCm: patch.heightCm ?? p.heightCm,
        weightKg: patch.weightKg ?? p.weightKg,
        activityBand: patch.activityBand ?? p.activityBand,
        timezone: patch.timezone ?? p.timezone,
        unitSystem: patch.unitSystem ?? p.unitSystem,
        revision: p.revision + 1,
      ),
      goal: patch.primaryGoal == null
          ? _me.goal
          : Goal(goalType: patch.primaryGoal!.goalType, targetWeightKg: patch.primaryGoal!.targetWeightKg),
      screening: patch.screening ?? _me.screening,
      onboarding: _me.onboarding.status == OnboardingStatus.completed
          ? _me.onboarding
          : Onboarding(status: OnboardingStatus.inProgress, step: patch.onboardingStep ?? _me.onboarding.step),
    );
    return _me;
  }

  @override
  Future<Preferences> savePreferences(PreferencesInput input, {String? idempotencyKey}) async {
    _checkRevision(input.expectedRevision, _me.preferences?.revision ?? 0);
    final saved = Preferences(
      dietType: input.dietType,
      allergyIds: [for (final t in input.allergyIds) t.value],
      exclusionIds: [for (final t in input.exclusionIds) t.value],
      dislikes: [...?input.dislikes],
      cuisines: [for (final t in input.cuisines) t.value],
      budgetBand: input.budgetBand,
      cookingTime: input.cookingTime,
      mealsPerDay: input.mealsPerDay,
      revision: (_me.preferences?.revision ?? 0) + 1,
    );
    _me = _me.copyWith(preferences: saved);
    return saved;
  }

  @override
  Future<TrainingPreferences> saveTraining(TrainingPreferencesInput input, {String? idempotencyKey}) async {
    _checkRevision(input.expectedRevision, _me.trainingPreferences?.revision ?? 0);
    final saved = TrainingPreferences(
      experience: input.experience,
      location: input.location,
      equipmentIds: [for (final t in input.equipmentIds) t.value],
      weekdays: input.weekdays,
      daysPerWeek: input.daysPerWeek,
      durationMinutes: input.durationMinutes,
      limitationTags: [for (final t in input.limitationTags) t.value],
      revision: (_me.trainingPreferences?.revision ?? 0) + 1,
    );
    _me = _me.copyWith(trainingPreferences: saved);
    return saved;
  }

  @override
  Future<OnboardingComplete> completeOnboarding(OnboardingCompleteRequest request, {String? idempotencyKey}) async {
    _checkRevision(request.expectedRevision, _me.profile.revision);
    _me = _me.copyWith(
      profile: _me.profile.copyWith(revision: _me.profile.revision + 1),
      onboarding: Onboarding(status: OnboardingStatus.completed, step: OnboardingStep.review),
      planning: Planning(status: PlanningStatus.unavailablePolicy, jobId: null),
    );
    return OnboardingComplete(me: _me, jobIds: const []);
  }

  void _checkRevision(int expected, int actual) {
    if (expected != actual) {
      throw const ApiFailure(
        kind: ApiFailureKind.conflict,
        code: 'REVISION_CONFLICT',
        message: 'Your data changed since you loaded it. Reload and try again.',
      );
    }
  }
}
