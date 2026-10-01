//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
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

    required this.mealLoggedDays,

    required this.workoutsCompleted,

    required this.workoutsScheduledElapsed,
  });

  @JsonKey(name: r'period_start', required: true, includeIfNull: false)
  final DateTime periodStart;

  @JsonKey(name: r'period_end', required: true, includeIfNull: false)
  final DateTime periodEnd;

  @JsonKey(name: r'weight_points', required: true, includeIfNull: false)
  final List<WeightPoint> weightPoints;

  // minimum: 0
  @JsonKey(name: r'meal_logged_days', required: true, includeIfNull: false)
  final int mealLoggedDays;

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

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Progress &&
            runtimeType == other.runtimeType &&
            equals(
              [
                periodStart,
                periodEnd,
                weightPoints,
                mealLoggedDays,
                workoutsCompleted,
                workoutsScheduledElapsed,
              ],
              [
                other.periodStart,
                other.periodEnd,
                other.weightPoints,
                other.mealLoggedDays,
                other.workoutsCompleted,
                other.workoutsScheduledElapsed,
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
        mealLoggedDays,
        workoutsCompleted,
        workoutsScheduledElapsed,
      ]);

  factory Progress.fromJson(Map<String, dynamic> json) =>
      _$ProgressFromJson(json);

  Map<String, dynamic> toJson() => _$ProgressToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
