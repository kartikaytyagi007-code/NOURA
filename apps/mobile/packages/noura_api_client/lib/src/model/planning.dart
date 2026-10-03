//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/planning_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'planning.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Planning {
  /// Returns a new [Planning] instance.
  Planning({required this.status, required this.jobId});

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final PlanningStatus status;

  /// The initial diet-plan generation request, when status is requested.
  @JsonKey(name: r'job_id', required: true, includeIfNull: true)
  final String? jobId;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Planning &&
            runtimeType == other.runtimeType &&
            equals([status, jobId], [other.status, other.jobId]);
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([status, jobId]);

  factory Planning.fromJson(Map<String, dynamic> json) =>
      _$PlanningFromJson(json);

  Map<String, dynamic> toJson() => _$PlanningToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
