//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/activity_band.dart';
import 'package:noura_api_client/src/model/screening_answers.dart';
import 'package:noura_api_client/src/model/calculation_sex_input.dart';
import 'package:noura_api_client/src/model/onboarding_step.dart';
import 'package:noura_api_client/src/model/goal_input.dart';
import 'package:noura_api_client/src/model/unit_system.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'profile_patch.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ProfilePatch {
  /// Returns a new [ProfilePatch] instance.
  ProfilePatch({
    required this.expectedRevision,

    this.displayName,

    this.ageYears,

    this.calculationSex,

    this.heightCm,

    this.weightKg,

    this.activityBand,

    this.timezone,

    this.unitSystem,

    this.primaryGoal,

    this.screening,

    this.onboardingStep,
  });

  // minimum: 1
  @JsonKey(name: r'expected_revision', required: true, includeIfNull: false)
  final int expectedRevision;

  @JsonKey(name: r'display_name', required: false, includeIfNull: false)
  final String? displayName;

  // minimum: 1
  // maximum: 120
  @JsonKey(name: r'age_years', required: false, includeIfNull: false)
  final int? ageYears;

  @JsonKey(name: r'calculation_sex', required: false, includeIfNull: false)
  final CalculationSexInput? calculationSex;

  // minimum: 50
  // maximum: 272
  @JsonKey(name: r'height_cm', required: false, includeIfNull: false)
  final num? heightCm;

  // minimum: 20
  // maximum: 400
  @JsonKey(name: r'weight_kg', required: false, includeIfNull: false)
  final num? weightKg;

  @JsonKey(name: r'activity_band', required: false, includeIfNull: false)
  final ActivityBand? activityBand;

  @JsonKey(name: r'timezone', required: false, includeIfNull: false)
  final String? timezone;

  @JsonKey(name: r'unit_system', required: false, includeIfNull: false)
  final UnitSystem? unitSystem;

  @JsonKey(name: r'primary_goal', required: false, includeIfNull: false)
  final GoalInput? primaryGoal;

  @JsonKey(name: r'screening', required: false, includeIfNull: false)
  final ScreeningAnswers? screening;

  @JsonKey(name: r'onboarding_step', required: false, includeIfNull: false)
  final OnboardingStep? onboardingStep;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProfilePatch &&
            runtimeType == other.runtimeType &&
            equals(
              [
                expectedRevision,
                displayName,
                ageYears,
                calculationSex,
                heightCm,
                weightKg,
                activityBand,
                timezone,
                unitSystem,
                primaryGoal,
                screening,
                onboardingStep,
              ],
              [
                other.expectedRevision,
                other.displayName,
                other.ageYears,
                other.calculationSex,
                other.heightCm,
                other.weightKg,
                other.activityBand,
                other.timezone,
                other.unitSystem,
                other.primaryGoal,
                other.screening,
                other.onboardingStep,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        expectedRevision,
        displayName,
        ageYears,
        calculationSex,
        heightCm,
        weightKg,
        activityBand,
        timezone,
        unitSystem,
        primaryGoal,
        screening,
        onboardingStep,
      ]);

  factory ProfilePatch.fromJson(Map<String, dynamic> json) =>
      _$ProfilePatchFromJson(json);

  Map<String, dynamic> toJson() => _$ProfilePatchToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
