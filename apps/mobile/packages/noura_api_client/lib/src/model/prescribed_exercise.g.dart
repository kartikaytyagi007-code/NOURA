// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prescribed_exercise.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PrescribedExerciseCWProxy {
  PrescribedExercise id(String id);

  PrescribedExercise exercise(ExerciseRef exercise);

  PrescribedExercise ordinal(int ordinal);

  PrescribedExercise sets(int sets);

  PrescribedExercise repsMin(int repsMin);

  PrescribedExercise repsMax(int repsMax);

  PrescribedExercise restSec(int restSec);

  PrescribedExercise effortCue(String? effortCue);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PrescribedExercise(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PrescribedExercise(...).copyWith(id: 12, name: "My name")
  /// ````
  PrescribedExercise call({
    String id,
    ExerciseRef exercise,
    int ordinal,
    int sets,
    int repsMin,
    int repsMax,
    int restSec,
    String? effortCue,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPrescribedExercise.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPrescribedExercise.copyWith.fieldName(...)`
class _$PrescribedExerciseCWProxyImpl implements _$PrescribedExerciseCWProxy {
  const _$PrescribedExerciseCWProxyImpl(this._value);

  final PrescribedExercise _value;

  @override
  PrescribedExercise id(String id) => this(id: id);

  @override
  PrescribedExercise exercise(ExerciseRef exercise) => this(exercise: exercise);

  @override
  PrescribedExercise ordinal(int ordinal) => this(ordinal: ordinal);

  @override
  PrescribedExercise sets(int sets) => this(sets: sets);

  @override
  PrescribedExercise repsMin(int repsMin) => this(repsMin: repsMin);

  @override
  PrescribedExercise repsMax(int repsMax) => this(repsMax: repsMax);

  @override
  PrescribedExercise restSec(int restSec) => this(restSec: restSec);

  @override
  PrescribedExercise effortCue(String? effortCue) => this(effortCue: effortCue);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PrescribedExercise(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PrescribedExercise(...).copyWith(id: 12, name: "My name")
  /// ````
  PrescribedExercise call({
    Object? id = const $CopyWithPlaceholder(),
    Object? exercise = const $CopyWithPlaceholder(),
    Object? ordinal = const $CopyWithPlaceholder(),
    Object? sets = const $CopyWithPlaceholder(),
    Object? repsMin = const $CopyWithPlaceholder(),
    Object? repsMax = const $CopyWithPlaceholder(),
    Object? restSec = const $CopyWithPlaceholder(),
    Object? effortCue = const $CopyWithPlaceholder(),
  }) {
    return PrescribedExercise(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      exercise: exercise == const $CopyWithPlaceholder()
          ? _value.exercise
          // ignore: cast_nullable_to_non_nullable
          : exercise as ExerciseRef,
      ordinal: ordinal == const $CopyWithPlaceholder()
          ? _value.ordinal
          // ignore: cast_nullable_to_non_nullable
          : ordinal as int,
      sets: sets == const $CopyWithPlaceholder()
          ? _value.sets
          // ignore: cast_nullable_to_non_nullable
          : sets as int,
      repsMin: repsMin == const $CopyWithPlaceholder()
          ? _value.repsMin
          // ignore: cast_nullable_to_non_nullable
          : repsMin as int,
      repsMax: repsMax == const $CopyWithPlaceholder()
          ? _value.repsMax
          // ignore: cast_nullable_to_non_nullable
          : repsMax as int,
      restSec: restSec == const $CopyWithPlaceholder()
          ? _value.restSec
          // ignore: cast_nullable_to_non_nullable
          : restSec as int,
      effortCue: effortCue == const $CopyWithPlaceholder()
          ? _value.effortCue
          // ignore: cast_nullable_to_non_nullable
          : effortCue as String?,
    );
  }
}

extension $PrescribedExerciseCopyWith on PrescribedExercise {
  /// Returns a callable class that can be used as follows: `instanceOfPrescribedExercise.copyWith(...)` or like so:`instanceOfPrescribedExercise.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PrescribedExerciseCWProxy get copyWith =>
      _$PrescribedExerciseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrescribedExercise _$PrescribedExerciseFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PrescribedExercise',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'exercise',
            'ordinal',
            'sets',
            'reps_min',
            'reps_max',
            'rest_sec',
            'effort_cue',
          ],
        );
        final val = PrescribedExercise(
          id: $checkedConvert('id', (v) => v as String),
          exercise: $checkedConvert(
            'exercise',
            (v) => ExerciseRef.fromJson(v as Map<String, dynamic>),
          ),
          ordinal: $checkedConvert('ordinal', (v) => (v as num).toInt()),
          sets: $checkedConvert('sets', (v) => (v as num).toInt()),
          repsMin: $checkedConvert('reps_min', (v) => (v as num).toInt()),
          repsMax: $checkedConvert('reps_max', (v) => (v as num).toInt()),
          restSec: $checkedConvert('rest_sec', (v) => (v as num).toInt()),
          effortCue: $checkedConvert('effort_cue', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'repsMin': 'reps_min',
        'repsMax': 'reps_max',
        'restSec': 'rest_sec',
        'effortCue': 'effort_cue',
      },
    );

Map<String, dynamic> _$PrescribedExerciseToJson(PrescribedExercise instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exercise': instance.exercise.toJson(),
      'ordinal': instance.ordinal,
      'sets': instance.sets,
      'reps_min': instance.repsMin,
      'reps_max': instance.repsMax,
      'rest_sec': instance.restSec,
      'effort_cue': instance.effortCue,
    };
