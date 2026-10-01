//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/set_log_input.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'workout_log.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkoutLog {
  /// Returns a new [WorkoutLog] instance.
  WorkoutLog({
    required this.id,

    required this.clientId,

    required this.sessionId,

    required this.status,

    required this.startedAt,

    required this.completedAt,

    required this.sets,

    required this.revision,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'client_id', required: true, includeIfNull: false)
  final String clientId;

  @JsonKey(name: r'session_id', required: true, includeIfNull: false)
  final String sessionId;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final WorkoutLogStatusEnum status;

  @JsonKey(name: r'started_at', required: true, includeIfNull: true)
  final DateTime? startedAt;

  @JsonKey(name: r'completed_at', required: true, includeIfNull: true)
  final DateTime? completedAt;

  @JsonKey(name: r'sets', required: true, includeIfNull: false)
  final List<SetLogInput> sets;

  // minimum: 1
  @JsonKey(name: r'revision', required: true, includeIfNull: false)
  final int revision;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is WorkoutLog &&
            runtimeType == other.runtimeType &&
            equals(
              [
                id,
                clientId,
                sessionId,
                status,
                startedAt,
                completedAt,
                sets,
                revision,
              ],
              [
                other.id,
                other.clientId,
                other.sessionId,
                other.status,
                other.startedAt,
                other.completedAt,
                other.sets,
                other.revision,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        id,
        clientId,
        sessionId,
        status,
        startedAt,
        completedAt,
        sets,
        revision,
      ]);

  factory WorkoutLog.fromJson(Map<String, dynamic> json) =>
      _$WorkoutLogFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutLogToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum WorkoutLogStatusEnum {
  @JsonValue(r'in_progress')
  inProgress(r'in_progress'),
  @JsonValue(r'completed')
  completed(r'completed'),
  @JsonValue(r'skipped')
  skipped(r'skipped'),
  @JsonValue(r'abandoned')
  abandoned(r'abandoned');

  const WorkoutLogStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
