//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/workout_session.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'workout_plan.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkoutPlan {
  /// Returns a new [WorkoutPlan] instance.
  WorkoutPlan({
    required this.id,

    required this.version,

    required this.startsOn,

    required this.revision,

    required this.sessions,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  // minimum: 1
  @JsonKey(name: r'version', required: true, includeIfNull: false)
  final int version;

  @JsonKey(name: r'starts_on', required: true, includeIfNull: false)
  final DateTime startsOn;

  // minimum: 1
  @JsonKey(name: r'revision', required: true, includeIfNull: false)
  final int revision;

  @JsonKey(name: r'sessions', required: true, includeIfNull: false)
  final List<WorkoutSession> sessions;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is WorkoutPlan &&
            runtimeType == other.runtimeType &&
            equals(
              [id, version, startsOn, revision, sessions],
              [
                other.id,
                other.version,
                other.startsOn,
                other.revision,
                other.sessions,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([id, version, startsOn, revision, sessions]);

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) =>
      _$WorkoutPlanFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutPlanToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
