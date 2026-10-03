//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/next_meal_action_type.dart';
import 'package:noura_api_client/src/model/meal_slot.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'next_meal_action_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NextMealActionRequest {
  /// Returns a new [NextMealActionRequest] instance.
  NextMealActionRequest({
    required this.date,

    required this.slot,

    required this.action,

    this.candidateId,

    this.targetPlanMealId,

    this.expectedRevision,
  });

  @JsonKey(name: r'date', required: true, includeIfNull: false)
  final DateTime date;

  @JsonKey(name: r'slot', required: true, includeIfNull: false)
  final MealSlot slot;

  @JsonKey(name: r'action', required: true, includeIfNull: false)
  final NextMealActionType action;

  @JsonKey(name: r'candidate_id', required: false, includeIfNull: false)
  final String? candidateId;

  @JsonKey(name: r'target_plan_meal_id', required: false, includeIfNull: false)
  final String? targetPlanMealId;

  // minimum: 1
  @JsonKey(name: r'expected_revision', required: false, includeIfNull: false)
  final int? expectedRevision;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NextMealActionRequest &&
            runtimeType == other.runtimeType &&
            equals(
              [
                date,
                slot,
                action,
                candidateId,
                targetPlanMealId,
                expectedRevision,
              ],
              [
                other.date,
                other.slot,
                other.action,
                other.candidateId,
                other.targetPlanMealId,
                other.expectedRevision,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        date,
        slot,
        action,
        candidateId,
        targetPlanMealId,
        expectedRevision,
      ]);

  factory NextMealActionRequest.fromJson(Map<String, dynamic> json) =>
      _$NextMealActionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$NextMealActionRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
