//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/goal_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'goal.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Goal {
  /// Returns a new [Goal] instance.
  Goal({required this.goalType, required this.targetWeightKg});

  @JsonKey(name: r'goal_type', required: true, includeIfNull: false)
  final GoalType goalType;

  // minimum: 20
  // maximum: 400
  @JsonKey(name: r'target_weight_kg', required: true, includeIfNull: true)
  final num? targetWeightKg;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Goal &&
            runtimeType == other.runtimeType &&
            equals(
              [goalType, targetWeightKg],
              [other.goalType, other.targetWeightKg],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([goalType, targetWeightKg]);

  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);

  Map<String, dynamic> toJson() => _$GoalToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
