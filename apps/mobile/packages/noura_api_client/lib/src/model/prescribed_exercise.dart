//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/exercise_ref.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'prescribed_exercise.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PrescribedExercise {
  /// Returns a new [PrescribedExercise] instance.
  PrescribedExercise({
    required this.id,

    required this.exercise,

    required this.ordinal,

    required this.sets,

    required this.repsMin,

    required this.repsMax,

    required this.restSec,

    required this.effortCue,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'exercise', required: true, includeIfNull: false)
  final ExerciseRef exercise;

  // minimum: 1
  @JsonKey(name: r'ordinal', required: true, includeIfNull: false)
  final int ordinal;

  // minimum: 1
  // maximum: 20
  @JsonKey(name: r'sets', required: true, includeIfNull: false)
  final int sets;

  // minimum: 1
  // maximum: 100
  @JsonKey(name: r'reps_min', required: true, includeIfNull: false)
  final int repsMin;

  // minimum: 1
  // maximum: 100
  @JsonKey(name: r'reps_max', required: true, includeIfNull: false)
  final int repsMax;

  // minimum: 0
  // maximum: 900
  @JsonKey(name: r'rest_sec', required: true, includeIfNull: false)
  final int restSec;

  @JsonKey(name: r'effort_cue', required: true, includeIfNull: true)
  final String? effortCue;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PrescribedExercise &&
            runtimeType == other.runtimeType &&
            equals(
              [
                id,
                exercise,
                ordinal,
                sets,
                repsMin,
                repsMax,
                restSec,
                effortCue,
              ],
              [
                other.id,
                other.exercise,
                other.ordinal,
                other.sets,
                other.repsMin,
                other.repsMax,
                other.restSec,
                other.effortCue,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        id,
        exercise,
        ordinal,
        sets,
        repsMin,
        repsMax,
        restSec,
        effortCue,
      ]);

  factory PrescribedExercise.fromJson(Map<String, dynamic> json) =>
      _$PrescribedExerciseFromJson(json);

  Map<String, dynamic> toJson() => _$PrescribedExerciseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
