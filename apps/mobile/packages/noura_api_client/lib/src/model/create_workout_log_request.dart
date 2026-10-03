//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'create_workout_log_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateWorkoutLogRequest {
  /// Returns a new [CreateWorkoutLogRequest] instance.
  CreateWorkoutLogRequest({
    required this.clientId,

    required this.sessionId,

    this.startedAt,
  });

  @JsonKey(name: r'client_id', required: true, includeIfNull: false)
  final String clientId;

  @JsonKey(name: r'session_id', required: true, includeIfNull: false)
  final String sessionId;

  @JsonKey(name: r'started_at', required: false, includeIfNull: false)
  final DateTime? startedAt;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CreateWorkoutLogRequest &&
            runtimeType == other.runtimeType &&
            equals(
              [clientId, sessionId, startedAt],
              [other.clientId, other.sessionId, other.startedAt],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([clientId, sessionId, startedAt]);

  factory CreateWorkoutLogRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateWorkoutLogRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateWorkoutLogRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
