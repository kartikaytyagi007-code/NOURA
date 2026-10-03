// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkoutSessionCWProxy {
  WorkoutSession id(String id);

  WorkoutSession date(DateTime date);

  WorkoutSession order(int order);

  WorkoutSession title(String title);

  WorkoutSession status(WorkoutSessionStatusEnum status);

  WorkoutSession exercises(List<PrescribedExercise> exercises);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutSession(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutSession(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutSession call({
    String id,
    DateTime date,
    int order,
    String title,
    WorkoutSessionStatusEnum status,
    List<PrescribedExercise> exercises,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkoutSession.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkoutSession.copyWith.fieldName(...)`
class _$WorkoutSessionCWProxyImpl implements _$WorkoutSessionCWProxy {
  const _$WorkoutSessionCWProxyImpl(this._value);

  final WorkoutSession _value;

  @override
  WorkoutSession id(String id) => this(id: id);

  @override
  WorkoutSession date(DateTime date) => this(date: date);

  @override
  WorkoutSession order(int order) => this(order: order);

  @override
  WorkoutSession title(String title) => this(title: title);

  @override
  WorkoutSession status(WorkoutSessionStatusEnum status) =>
      this(status: status);

  @override
  WorkoutSession exercises(List<PrescribedExercise> exercises) =>
      this(exercises: exercises);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutSession(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutSession(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutSession call({
    Object? id = const $CopyWithPlaceholder(),
    Object? date = const $CopyWithPlaceholder(),
    Object? order = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? exercises = const $CopyWithPlaceholder(),
  }) {
    return WorkoutSession(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      date: date == const $CopyWithPlaceholder()
          ? _value.date
          // ignore: cast_nullable_to_non_nullable
          : date as DateTime,
      order: order == const $CopyWithPlaceholder()
          ? _value.order
          // ignore: cast_nullable_to_non_nullable
          : order as int,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as WorkoutSessionStatusEnum,
      exercises: exercises == const $CopyWithPlaceholder()
          ? _value.exercises
          // ignore: cast_nullable_to_non_nullable
          : exercises as List<PrescribedExercise>,
    );
  }
}

extension $WorkoutSessionCopyWith on WorkoutSession {
  /// Returns a callable class that can be used as follows: `instanceOfWorkoutSession.copyWith(...)` or like so:`instanceOfWorkoutSession.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkoutSessionCWProxy get copyWith => _$WorkoutSessionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutSession _$WorkoutSessionFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('WorkoutSession', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'date', 'order', 'title', 'status', 'exercises'],
  );
  final val = WorkoutSession(
    id: $checkedConvert('id', (v) => v as String),
    date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
    order: $checkedConvert('order', (v) => (v as num).toInt()),
    title: $checkedConvert('title', (v) => v as String),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$WorkoutSessionStatusEnumEnumMap, v),
    ),
    exercises: $checkedConvert(
      'exercises',
      (v) => (v as List<dynamic>)
          .map((e) => PrescribedExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$WorkoutSessionToJson(WorkoutSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'order': instance.order,
      'title': instance.title,
      'status': _$WorkoutSessionStatusEnumEnumMap[instance.status]!,
      'exercises': instance.exercises.map((e) => e.toJson()).toList(),
    };

const _$WorkoutSessionStatusEnumEnumMap = {
  WorkoutSessionStatusEnum.scheduled: 'scheduled',
  WorkoutSessionStatusEnum.rescheduled: 'rescheduled',
  WorkoutSessionStatusEnum.cancelled: 'cancelled',
};
