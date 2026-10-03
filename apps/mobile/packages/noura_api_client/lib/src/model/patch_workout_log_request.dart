//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'patch_workout_log_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PatchWorkoutLogRequest {
  /// Returns a new [PatchWorkoutLogRequest] instance.
  PatchWorkoutLogRequest({
    required this.expectedRevision,

    required this.status,

    this.completedAt,
  });

  // minimum: 1
  @JsonKey(name: r'expected_revision', required: true, includeIfNull: false)
  final int expectedRevision;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final PatchWorkoutLogRequestStatusEnum status;

  @JsonKey(name: r'completed_at', required: false, includeIfNull: false)
  final DateTime? completedAt;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PatchWorkoutLogRequest &&
            runtimeType == other.runtimeType &&
            equals(
              [expectedRevision, status, completedAt],
              [other.expectedRevision, other.status, other.completedAt],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([expectedRevision, status, completedAt]);

  factory PatchWorkoutLogRequest.fromJson(Map<String, dynamic> json) =>
      _$PatchWorkoutLogRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PatchWorkoutLogRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum PatchWorkoutLogRequestStatusEnum {
  @JsonValue(r'completed')
  completed(r'completed'),
  @JsonValue(r'skipped')
  skipped(r'skipped'),
  @JsonValue(r'abandoned')
  abandoned(r'abandoned');

  const PatchWorkoutLogRequestStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
