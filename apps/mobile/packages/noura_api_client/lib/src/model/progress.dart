//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/adherence_summary.dart';
import 'package:noura_api_client/src/model/weight_point.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'progress.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Progress {
  /// Returns a new [Progress] instance.
  Progress({
    required this.periodStart,

    required this.periodEnd,

    required this.weightPoints,

    required this.startingWeightKg,

    required this.currentWeightKg,

    required this.goalWeightKg,

    required this.mealLoggedDays,

    required this.dietAdherence,

    required this.workoutsCompleted,

    required this.workoutsScheduledElapsed,

    required this.workoutAdherence,
  });

  @JsonKey(name: r'period_start', required: true, includeIfNull: false)
  final DateTime periodStart;

  @JsonKey(name: r'period_end', required: true, includeIfNull: false)
  final DateTime periodEnd;

  @JsonKey(name: r'weight_points', required: true, includeIfNull: false)
  final List<WeightPoint> weightPoints;

  /// The user's first-ever recorded weight (weight-history entry, or the onboarding value).
  @JsonKey(name: r'starting_weight_kg', required: true, includeIfNull: true)
  final num? startingWeightKg;

  /// The latest weight-history entry, falling back to the profile's recorded weight.
  @JsonKey(name: r'current_weight_kg', required: true, includeIfNull: true)
  final num? currentWeightKg;

  /// The active goal's target weight, when one is set.
  @JsonKey(name: r'goal_weight_kg', required: true, includeIfNull: true)
  final num? goalWeightKg;

  // minimum: 0
  @JsonKey(name: r'meal_logged_days', required: true, includeIfNull: false)
  final int mealLoggedDays;

  @JsonKey(name: r'diet_adherence', required: true, includeIfNull: false)
  final AdherenceSummary dietAdherence;

  // minimum: 0
  @JsonKey(name: r'workouts_completed', required: true, includeIfNull: false)
  final int workoutsCompleted;

  /// Scheduled sessions already elapsed; excludes future sessions and rest days.
  // minimum: 0
  @JsonKey(
    name: r'workouts_scheduled_elapsed',
    required: true,
    includeIfNull: false,
  )
  final int workoutsScheduledElapsed;

  @JsonKey(name: r'workout_adherence', required: true, includeIfNull: false)
  final AdherenceSummary workoutAdherence;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Progress &&
            runtimeType == other.runtimeType &&
            equals(
              [
                periodStart,
                periodEnd,
                weightPoints,
                startingWeightKg,
                currentWeightKg,
                goalWeightKg,
                mealLoggedDays,
                dietAdherence,
                workoutsCompleted,
                workoutsScheduledElapsed,
                workoutAdherence,
              ],
              [
                other.periodStart,
                other.periodEnd,
                other.weightPoints,
                other.startingWeightKg,
                other.currentWeightKg,
                other.goalWeightKg,
                other.mealLoggedDays,
                other.dietAdherence,
                other.workoutsCompleted,
                other.workoutsScheduledElapsed,
                other.workoutAdherence,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        periodStart,
        periodEnd,
        weightPoints,
        startingWeightKg,
        currentWeightKg,
        goalWeightKg,
        mealLoggedDays,
        dietAdherence,
        workoutsCompleted,
        workoutsScheduledElapsed,
        workoutAdherence,
      ]);

  factory Progress.fromJson(Map<String, dynamic> json) =>
      _$ProgressFromJson(json);

  Map<String, dynamic> toJson() => _$ProgressToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
