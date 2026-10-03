//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/next_meal_action_type.dart';
import 'package:noura_api_client/src/model/plan_meal.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'next_meal_action_result.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NextMealActionResult {
  /// Returns a new [NextMealActionResult] instance.
  NextMealActionResult({
    required this.action,

    required this.planMeal,

    required this.dismissed,
  });

  @JsonKey(name: r'action', required: true, includeIfNull: false)
  final NextMealActionType action;

  @JsonKey(name: r'plan_meal', required: true, includeIfNull: true)
  final PlanMeal? planMeal;

  @JsonKey(name: r'dismissed', required: true, includeIfNull: false)
  final bool dismissed;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NextMealActionResult &&
            runtimeType == other.runtimeType &&
            equals(
              [action, planMeal, dismissed],
              [other.action, other.planMeal, other.dismissed],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([action, planMeal, dismissed]);

  factory NextMealActionResult.fromJson(Map<String, dynamic> json) =>
      _$NextMealActionResultFromJson(json);

  Map<String, dynamic> toJson() => _$NextMealActionResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
