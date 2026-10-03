import 'package:noura/core/api/api_failure.dart';
import 'package:noura/core/profile/profile_repository.dart';
import 'package:noura_api_client/noura_api_client.dart';

const _offline = ApiFailure(
  kind: ApiFailureKind.offline,
  message: "You're offline or the server can't be reached.",
  retryable: true,
);

/// An in-memory stand-in for the API used by the Flutter flow tests. It applies the same revision
/// rules (expected_revision, 0 meaning "none yet") and a minimal copy of the eligibility outcome so
/// flows can be exercised end to end. It is test code only; the real rules live in the server.
class FakeProfileServer implements ProfileRepository {
  FakeProfileServer({Me? initial}) : me = initial ?? emptyMe();

  Me me;

  /// Method names in call order (for example `patchProfile`), to assert what the UI sent.
  final calls = <String>[];
  final patches = <ProfilePatch>[];
  final completions = <OnboardingCompleteRequest>[];
  final completionKeys = <String?>[];

  /// Every completion attempt's idempotency key, including attempts that failed.
  final completionAttemptKeys = <String?>[];

  /// When set, the next call throws this and clears it.
  Object? failNext;

  /// Set true to make every write fail as if the device were offline.
  bool offline = false;

  int get completedJobs => completions.length;

  static Me emptyMe({String name = 'Asha'}) => Me(
    userId: '00000000-0000-4000-8000-000000000001',
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

  /// A user who has finished onboarding (for Home and Settings tests).
  static Me completedMe({EligibilityStatus eligibility = EligibilityStatus.eligible, PlanningStatus? planning}) {
    final status =
        planning ??
        switch (eligibility) {
          EligibilityStatus.eligible => PlanningStatus.requested,
          EligibilityStatus.trackingOnly => PlanningStatus.unavailableTrackingOnly,
          EligibilityStatus.needsReview => PlanningStatus.unavailableNeedsReview,
        };
    return Me(
      userId: '00000000-0000-4000-8000-000000000001',
      profile: Profile(
        displayName: 'Asha',
        ageYears: 30,
        calculationSex: CalculationSex.female,
        heightCm: 162.5,
        weightKg: 62,
        activityBand: ActivityBand.moderate,
        timezone: 'Asia/Kolkata',
        unitSystem: UnitSystem.metric,
        revision: 9,
      ),
      goal: Goal(goalType: GoalType.loseFat, targetWeightKg: 58),
      preferences: Preferences(
        dietType: DietType.vegetarian,
        allergyIds: const ['peanut'],
        exclusionIds: const [],
        dislikes: const ['okra'],
        cuisines: const ['north_indian'],
        budgetBand: BudgetBand.medium,
        cookingTime: CookingTime.moderate,
        mealsPerDay: 4,
        revision: 2,
      ),
      trainingPreferences: TrainingPreferences(
        experience: ExperienceLevel.beginner,
        location: TrainingLocation.home,
        equipmentIds: const ['bodyweight'],
        weekdays: const {1, 3, 5},
        daysPerWeek: 3,
        durationMinutes: 45,
        limitationTags: const [],
        revision: 1,
      ),
      eligibilityStatus: eligibility,
      screening: ScreeningAnswers(
        pregnancyOrBreastfeeding: eligibility == EligibilityStatus.trackingOnly
            ? ScreeningAnswer.yes
            : ScreeningAnswer.no,
        eatingDisorderConcern: ScreeningAnswer.no,
        medicalDietCondition: eligibility == EligibilityStatus.needsReview
            ? ScreeningAnswer.preferNotToSay
            : ScreeningAnswer.no,
      ),
      onboarding: Onboarding(status: OnboardingStatus.completed, step: OnboardingStep.review),
      planning: Planning(
        status: status,
        jobId: status == PlanningStatus.requested ? '11111111-1111-4111-8111-111111111111' : null,
      ),
    );
  }

  void _enter(String name) {
    calls.add(name);
    final error = failNext;
    if (error != null) {
      failNext = null;
      throw error;
    }
  }

  void _write(String name) {
    _enter(name);
    if (offline) throw _offline;
  }

  void _checkRevision(int expected, int actual) {
    if (expected != actual) {
      throw const ApiFailure(
        kind: ApiFailureKind.conflict,
        code: 'REVISION_CONFLICT',
        message: 'Your profile changed since you loaded it. Reload and try again.',
        statusCode: 409,
      );
    }
  }

  @override
  Future<Me> fetchMe() async {
    _enter('fetchMe');
    return me;
  }

  EligibilityStatus? _eligibility(int? age, ScreeningAnswers? s) {
    if (age == null || s == null) return null;
    final answers = [s.pregnancyOrBreastfeeding, s.eatingDisorderConcern, s.medicalDietCondition];
    if (age < 18 || answers.contains(ScreeningAnswer.yes)) return EligibilityStatus.trackingOnly;
    if (answers.contains(ScreeningAnswer.preferNotToSay)) return EligibilityStatus.needsReview;
    return EligibilityStatus.eligible;
  }

  @override
  Future<Me> patchProfile(ProfilePatch patch, {String? idempotencyKey}) async {
    _write('patchProfile');
    _checkRevision(patch.expectedRevision, me.profile.revision);
    patches.add(patch);
    final p = me.profile;
    final sex = patch.calculationSex;
    final age = patch.ageYears ?? p.ageYears;
    final screening = patch.screening ?? me.screening;
    me = me.copyWith(
      profile: Profile(
        displayName: patch.displayName ?? p.displayName,
        ageYears: age,
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
          ? me.goal
          : Goal(goalType: patch.primaryGoal!.goalType, targetWeightKg: patch.primaryGoal!.targetWeightKg),
      screening: screening,
      eligibilityStatus: _eligibility(age, screening),
      onboarding: me.onboarding.status == OnboardingStatus.completed
          ? me.onboarding
          : Onboarding(status: OnboardingStatus.inProgress, step: patch.onboardingStep ?? me.onboarding.step),
    );
    if (me.onboarding.status == OnboardingStatus.completed) {
      // Like the server, eligibility always wins over an earlier plan request.
      final previous = me.planning;
      me = me.copyWith(
        planning: switch (me.eligibilityStatus) {
          EligibilityStatus.trackingOnly => Planning(status: PlanningStatus.unavailableTrackingOnly, jobId: null),
          EligibilityStatus.needsReview => Planning(status: PlanningStatus.unavailableNeedsReview, jobId: null),
          _ => previous?.jobId != null ? previous : Planning(status: PlanningStatus.unavailablePolicy, jobId: null),
        },
      );
    }
    return me;
  }

  @override
  Future<Preferences> savePreferences(PreferencesInput input, {String? idempotencyKey}) async {
    _write('savePreferences');
    _checkRevision(input.expectedRevision, me.preferences?.revision ?? 0);
    final saved = Preferences(
      dietType: input.dietType,
      allergyIds: [for (final t in input.allergyIds) t.value],
      exclusionIds: [for (final t in input.exclusionIds) t.value],
      dislikes: [...?input.dislikes],
      cuisines: [for (final t in input.cuisines) t.value],
      budgetBand: input.budgetBand,
      cookingTime: input.cookingTime,
      mealsPerDay: input.mealsPerDay,
      revision: (me.preferences?.revision ?? 0) + 1,
    );
    me = me.copyWith(preferences: saved);
    return saved;
  }

  @override
  Future<TrainingPreferences> saveTraining(TrainingPreferencesInput input, {String? idempotencyKey}) async {
    _write('saveTraining');
    _checkRevision(input.expectedRevision, me.trainingPreferences?.revision ?? 0);
    final saved = TrainingPreferences(
      experience: input.experience,
      location: input.location,
      equipmentIds: [for (final t in input.equipmentIds) t.value],
      weekdays: input.weekdays,
      daysPerWeek: input.daysPerWeek,
      durationMinutes: input.durationMinutes,
      limitationTags: [for (final t in input.limitationTags) t.value],
      revision: (me.trainingPreferences?.revision ?? 0) + 1,
    );
    me = me.copyWith(trainingPreferences: saved);
    return saved;
  }

  @override
  Future<OnboardingComplete> completeOnboarding(OnboardingCompleteRequest request, {String? idempotencyKey}) async {
    completionAttemptKeys.add(idempotencyKey);
    _write('completeOnboarding');
    if (me.onboarding.status == OnboardingStatus.completed) {
      throw const ApiFailure(
        kind: ApiFailureKind.validation,
        code: 'CONSTRAINT_CONFLICT',
        message: 'Onboarding is already complete.',
        statusCode: 422,
      );
    }
    _checkRevision(request.expectedRevision, me.profile.revision);
    completions.add(request);
    completionKeys.add(idempotencyKey);
    final eligible = me.eligibilityStatus == EligibilityStatus.eligible;
    const job = '22222222-2222-4222-8222-222222222222';
    me = me.copyWith(
      profile: me.profile.copyWith(revision: me.profile.revision + 1),
      onboarding: Onboarding(status: OnboardingStatus.completed, step: OnboardingStep.review),
      planning: Planning(
        status: switch (me.eligibilityStatus) {
          EligibilityStatus.trackingOnly => PlanningStatus.unavailableTrackingOnly,
          EligibilityStatus.needsReview => PlanningStatus.unavailableNeedsReview,
          _ => PlanningStatus.requested,
        },
        jobId: eligible ? job : null,
      ),
    );
    return OnboardingComplete(me: me, jobIds: eligible ? const [job] : const []);
  }
}
