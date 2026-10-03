//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/prescribed_exercise.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'workout_session.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkoutSession {
  /// Returns a new [WorkoutSession] instance.
  WorkoutSession({
    required this.id,

    required this.date,

    required this.order,

    required this.title,

    required this.status,

    required this.exercises,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'date', required: true, includeIfNull: false)
  final DateTime date;

  // minimum: 1
  @JsonKey(name: r'order', required: true, includeIfNull: false)
  final int order;

  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final WorkoutSessionStatusEnum status;

  @JsonKey(name: r'exercises', required: true, includeIfNull: false)
  final List<PrescribedExercise> exercises;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is WorkoutSession &&
            runtimeType == other.runtimeType &&
            equals(
              [id, date, order, title, status, exercises],
              [
                other.id,
                other.date,
                other.order,
                other.title,
                other.status,
                other.exercises,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([id, date, order, title, status, exercises]);

  factory WorkoutSession.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutSessionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum WorkoutSessionStatusEnum {
  @JsonValue(r'scheduled')
  scheduled(r'scheduled'),
  @JsonValue(r'rescheduled')
  rescheduled(r'rescheduled'),
  @JsonValue(r'cancelled')
  cancelled(r'cancelled');

  const WorkoutSessionStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
