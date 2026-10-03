//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'replace_plan_meal_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReplacePlanMealRequest {
  /// Returns a new [ReplacePlanMealRequest] instance.
  ReplacePlanMealRequest({
    required this.expectedRevision,

    required this.candidateId,
  });

  // minimum: 1
  @JsonKey(name: r'expected_revision', required: true, includeIfNull: false)
  final int expectedRevision;

  @JsonKey(name: r'candidate_id', required: true, includeIfNull: false)
  final String candidateId;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ReplacePlanMealRequest &&
            runtimeType == other.runtimeType &&
            equals(
              [expectedRevision, candidateId],
              [other.expectedRevision, other.candidateId],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([expectedRevision, candidateId]);

  factory ReplacePlanMealRequest.fromJson(Map<String, dynamic> json) =>
      _$ReplacePlanMealRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ReplacePlanMealRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
