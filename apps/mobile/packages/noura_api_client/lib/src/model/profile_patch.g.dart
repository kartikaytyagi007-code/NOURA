// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_patch.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ProfilePatchCWProxy {
  ProfilePatch expectedRevision(int expectedRevision);

  ProfilePatch displayName(String? displayName);

  ProfilePatch ageYears(int? ageYears);

  ProfilePatch calculationSex(CalculationSex? calculationSex);

  ProfilePatch heightCm(num? heightCm);

  ProfilePatch weightKg(num? weightKg);

  ProfilePatch activityBand(ActivityBand? activityBand);

  ProfilePatch timezone(String? timezone);

  ProfilePatch unitSystem(UnitSystem? unitSystem);

  ProfilePatch primaryGoal(GoalInput? primaryGoal);

  ProfilePatch onboardingStep(OnboardingStep? onboardingStep);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ProfilePatch(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ProfilePatch(...).copyWith(id: 12, name: "My name")
  /// ````
  ProfilePatch call({
    int expectedRevision,
    String? displayName,
    int? ageYears,
    CalculationSex? calculationSex,
    num? heightCm,
    num? weightKg,
    ActivityBand? activityBand,
    String? timezone,
    UnitSystem? unitSystem,
    GoalInput? primaryGoal,
    OnboardingStep? onboardingStep,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfProfilePatch.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfProfilePatch.copyWith.fieldName(...)`
class _$ProfilePatchCWProxyImpl implements _$ProfilePatchCWProxy {
  const _$ProfilePatchCWProxyImpl(this._value);

  final ProfilePatch _value;

  @override
  ProfilePatch expectedRevision(int expectedRevision) =>
      this(expectedRevision: expectedRevision);

  @override
  ProfilePatch displayName(String? displayName) =>
      this(displayName: displayName);

  @override
  ProfilePatch ageYears(int? ageYears) => this(ageYears: ageYears);

  @override
  ProfilePatch calculationSex(CalculationSex? calculationSex) =>
      this(calculationSex: calculationSex);

  @override
  ProfilePatch heightCm(num? heightCm) => this(heightCm: heightCm);

  @override
  ProfilePatch weightKg(num? weightKg) => this(weightKg: weightKg);

  @override
  ProfilePatch activityBand(ActivityBand? activityBand) =>
      this(activityBand: activityBand);

  @override
  ProfilePatch timezone(String? timezone) => this(timezone: timezone);

  @override
  ProfilePatch unitSystem(UnitSystem? unitSystem) =>
      this(unitSystem: unitSystem);

  @override
  ProfilePatch primaryGoal(GoalInput? primaryGoal) =>
      this(primaryGoal: primaryGoal);

  @override
  ProfilePatch onboardingStep(OnboardingStep? onboardingStep) =>
      this(onboardingStep: onboardingStep);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ProfilePatch(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ProfilePatch(...).copyWith(id: 12, name: "My name")
  /// ````
  ProfilePatch call({
    Object? expectedRevision = const $CopyWithPlaceholder(),
    Object? displayName = const $CopyWithPlaceholder(),
    Object? ageYears = const $CopyWithPlaceholder(),
    Object? calculationSex = const $CopyWithPlaceholder(),
    Object? heightCm = const $CopyWithPlaceholder(),
    Object? weightKg = const $CopyWithPlaceholder(),
    Object? activityBand = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
    Object? unitSystem = const $CopyWithPlaceholder(),
    Object? primaryGoal = const $CopyWithPlaceholder(),
    Object? onboardingStep = const $CopyWithPlaceholder(),
  }) {
    return ProfilePatch(
      expectedRevision: expectedRevision == const $CopyWithPlaceholder()
          ? _value.expectedRevision
          // ignore: cast_nullable_to_non_nullable
          : expectedRevision as int,
      displayName: displayName == const $CopyWithPlaceholder()
          ? _value.displayName
          // ignore: cast_nullable_to_non_nullable
          : displayName as String?,
      ageYears: ageYears == const $CopyWithPlaceholder()
          ? _value.ageYears
          // ignore: cast_nullable_to_non_nullable
          : ageYears as int?,
      calculationSex: calculationSex == const $CopyWithPlaceholder()
          ? _value.calculationSex
          // ignore: cast_nullable_to_non_nullable
          : calculationSex as CalculationSex?,
      heightCm: heightCm == const $CopyWithPlaceholder()
          ? _value.heightCm
          // ignore: cast_nullable_to_non_nullable
          : heightCm as num?,
      weightKg: weightKg == const $CopyWithPlaceholder()
          ? _value.weightKg
          // ignore: cast_nullable_to_non_nullable
          : weightKg as num?,
      activityBand: activityBand == const $CopyWithPlaceholder()
          ? _value.activityBand
          // ignore: cast_nullable_to_non_nullable
          : activityBand as ActivityBand?,
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String?,
      unitSystem: unitSystem == const $CopyWithPlaceholder()
          ? _value.unitSystem
          // ignore: cast_nullable_to_non_nullable
          : unitSystem as UnitSystem?,
      primaryGoal: primaryGoal == const $CopyWithPlaceholder()
          ? _value.primaryGoal
          // ignore: cast_nullable_to_non_nullable
          : primaryGoal as GoalInput?,
      onboardingStep: onboardingStep == const $CopyWithPlaceholder()
          ? _value.onboardingStep
          // ignore: cast_nullable_to_non_nullable
          : onboardingStep as OnboardingStep?,
    );
  }
}

extension $ProfilePatchCopyWith on ProfilePatch {
  /// Returns a callable class that can be used as follows: `instanceOfProfilePatch.copyWith(...)` or like so:`instanceOfProfilePatch.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ProfilePatchCWProxy get copyWith => _$ProfilePatchCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfilePatch _$ProfilePatchFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ProfilePatch',
      json,
      ($checkedConvert) {
        $checkKeys(json, requiredKeys: const ['expected_revision']);
        final val = ProfilePatch(
          expectedRevision: $checkedConvert(
            'expected_revision',
            (v) => (v as num).toInt(),
          ),
          displayName: $checkedConvert('display_name', (v) => v as String?),
          ageYears: $checkedConvert('age_years', (v) => (v as num?)?.toInt()),
          calculationSex: $checkedConvert(
            'calculation_sex',
            (v) => $enumDecodeNullable(_$CalculationSexEnumMap, v),
          ),
          heightCm: $checkedConvert('height_cm', (v) => v as num?),
          weightKg: $checkedConvert('weight_kg', (v) => v as num?),
          activityBand: $checkedConvert(
            'activity_band',
            (v) => $enumDecodeNullable(_$ActivityBandEnumMap, v),
          ),
          timezone: $checkedConvert('timezone', (v) => v as String?),
          unitSystem: $checkedConvert(
            'unit_system',
            (v) => $enumDecodeNullable(_$UnitSystemEnumMap, v),
          ),
          primaryGoal: $checkedConvert(
            'primary_goal',
            (v) => v == null
                ? null
                : GoalInput.fromJson(v as Map<String, dynamic>),
          ),
          onboardingStep: $checkedConvert(
            'onboarding_step',
            (v) => $enumDecodeNullable(_$OnboardingStepEnumMap, v),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'expectedRevision': 'expected_revision',
        'displayName': 'display_name',
        'ageYears': 'age_years',
        'calculationSex': 'calculation_sex',
        'heightCm': 'height_cm',
        'weightKg': 'weight_kg',
        'activityBand': 'activity_band',
        'unitSystem': 'unit_system',
        'primaryGoal': 'primary_goal',
        'onboardingStep': 'onboarding_step',
      },
    );

Map<String, dynamic> _$ProfilePatchToJson(ProfilePatch instance) =>
    <String, dynamic>{
      'expected_revision': instance.expectedRevision,
      'display_name': ?instance.displayName,
      'age_years': ?instance.ageYears,
      'calculation_sex': ?_$CalculationSexEnumMap[instance.calculationSex],
      'height_cm': ?instance.heightCm,
      'weight_kg': ?instance.weightKg,
      'activity_band': ?_$ActivityBandEnumMap[instance.activityBand],
      'timezone': ?instance.timezone,
      'unit_system': ?_$UnitSystemEnumMap[instance.unitSystem],
      'primary_goal': ?instance.primaryGoal?.toJson(),
      'onboarding_step': ?_$OnboardingStepEnumMap[instance.onboardingStep],
    };

const _$CalculationSexEnumMap = {
  CalculationSex.female: 'female',
  CalculationSex.male: 'male',
};

const _$ActivityBandEnumMap = {
  ActivityBand.sedentary: 'sedentary',
  ActivityBand.light: 'light',
  ActivityBand.moderate: 'moderate',
  ActivityBand.active: 'active',
  ActivityBand.veryActive: 'very_active',
};

const _$UnitSystemEnumMap = {
  UnitSystem.metric: 'metric',
  UnitSystem.imperial: 'imperial',
};

const _$OnboardingStepEnumMap = {
  OnboardingStep.basics: 'basics',
  OnboardingStep.goals: 'goals',
  OnboardingStep.diet: 'diet',
  OnboardingStep.training: 'training',
  OnboardingStep.eligibility: 'eligibility',
  OnboardingStep.review: 'review',
};
