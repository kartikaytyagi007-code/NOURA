//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/goal_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'goal_input.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GoalInput {
  /// Returns a new [GoalInput] instance.
  GoalInput({required this.goalType, this.targetWeightKg});

  @JsonKey(name: r'goal_type', required: true, includeIfNull: false)
  final GoalType goalType;

  // minimum: 20
  // maximum: 400
  @JsonKey(name: r'target_weight_kg', required: false, includeIfNull: false)
  final num? targetWeightKg;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is GoalInput &&
            runtimeType == other.runtimeType &&
            equals(
              [goalType, targetWeightKg],
              [other.goalType, other.targetWeightKg],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([goalType, targetWeightKg]);

  factory GoalInput.fromJson(Map<String, dynamic> json) =>
      _$GoalInputFromJson(json);

  Map<String, dynamic> toJson() => _$GoalInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
