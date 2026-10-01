//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/insight_summary.dart';
import 'package:noura_api_client/src/model/plan_meal_preview.dart';
import 'package:noura_api_client/src/model/nutrient_totals.dart';
import 'package:noura_api_client/src/model/workout_session_preview.dart';
import 'package:noura_api_client/src/model/job.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'home.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Home {
  /// Returns a new [Home] instance.
  Home({
    required this.date,

    required this.nutrition,

    required this.nextMeal,

    required this.todaysWorkout,

    required this.insight,

    required this.planGeneration,
  });

  @JsonKey(name: r'date', required: true, includeIfNull: false)
  final DateTime date;

  @JsonKey(name: r'nutrition', required: true, includeIfNull: false)
  final NutrientTotals nutrition;

  @JsonKey(name: r'next_meal', required: true, includeIfNull: true)
  final PlanMealPreview? nextMeal;

  @JsonKey(name: r'todays_workout', required: true, includeIfNull: true)
  final WorkoutSessionPreview? todaysWorkout;

  @JsonKey(name: r'insight', required: true, includeIfNull: true)
  final InsightSummary? insight;

  @JsonKey(name: r'plan_generation', required: true, includeIfNull: true)
  final Job? planGeneration;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Home &&
            runtimeType == other.runtimeType &&
            equals(
              [
                date,
                nutrition,
                nextMeal,
                todaysWorkout,
                insight,
                planGeneration,
              ],
              [
                other.date,
                other.nutrition,
                other.nextMeal,
                other.todaysWorkout,
                other.insight,
                other.planGeneration,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        date,
        nutrition,
        nextMeal,
        todaysWorkout,
        insight,
        planGeneration,
      ]);

  factory Home.fromJson(Map<String, dynamic> json) => _$HomeFromJson(json);

  Map<String, dynamic> toJson() => _$HomeToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
