// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_plan.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkoutPlanCWProxy {
  WorkoutPlan id(String id);

  WorkoutPlan version(int version);

  WorkoutPlan startsOn(DateTime startsOn);

  WorkoutPlan revision(int revision);

  WorkoutPlan sessions(List<WorkoutSession> sessions);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutPlan(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutPlan(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutPlan call({
    String id,
    int version,
    DateTime startsOn,
    int revision,
    List<WorkoutSession> sessions,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkoutPlan.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkoutPlan.copyWith.fieldName(...)`
class _$WorkoutPlanCWProxyImpl implements _$WorkoutPlanCWProxy {
  const _$WorkoutPlanCWProxyImpl(this._value);

  final WorkoutPlan _value;

  @override
  WorkoutPlan id(String id) => this(id: id);

  @override
  WorkoutPlan version(int version) => this(version: version);

  @override
  WorkoutPlan startsOn(DateTime startsOn) => this(startsOn: startsOn);

  @override
  WorkoutPlan revision(int revision) => this(revision: revision);

  @override
  WorkoutPlan sessions(List<WorkoutSession> sessions) =>
      this(sessions: sessions);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutPlan(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutPlan(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutPlan call({
    Object? id = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? startsOn = const $CopyWithPlaceholder(),
    Object? revision = const $CopyWithPlaceholder(),
    Object? sessions = const $CopyWithPlaceholder(),
  }) {
    return WorkoutPlan(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
      startsOn: startsOn == const $CopyWithPlaceholder()
          ? _value.startsOn
          // ignore: cast_nullable_to_non_nullable
          : startsOn as DateTime,
      revision: revision == const $CopyWithPlaceholder()
          ? _value.revision
          // ignore: cast_nullable_to_non_nullable
          : revision as int,
      sessions: sessions == const $CopyWithPlaceholder()
          ? _value.sessions
          // ignore: cast_nullable_to_non_nullable
          : sessions as List<WorkoutSession>,
    );
  }
}

extension $WorkoutPlanCopyWith on WorkoutPlan {
  /// Returns a callable class that can be used as follows: `instanceOfWorkoutPlan.copyWith(...)` or like so:`instanceOfWorkoutPlan.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkoutPlanCWProxy get copyWith => _$WorkoutPlanCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutPlan _$WorkoutPlanFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('WorkoutPlan', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'version', 'starts_on', 'revision', 'sessions'],
  );
  final val = WorkoutPlan(
    id: $checkedConvert('id', (v) => v as String),
    version: $checkedConvert('version', (v) => (v as num).toInt()),
    startsOn: $checkedConvert('starts_on', (v) => DateTime.parse(v as String)),
    revision: $checkedConvert('revision', (v) => (v as num).toInt()),
    sessions: $checkedConvert(
      'sessions',
      (v) => (v as List<dynamic>)
          .map((e) => WorkoutSession.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
}, fieldKeyMap: const {'startsOn': 'starts_on'});

Map<String, dynamic> _$WorkoutPlanToJson(WorkoutPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'version': instance.version,
      'starts_on': instance.startsOn.toIso8601String(),
      'revision': instance.revision,
      'sessions': instance.sessions.map((e) => e.toJson()).toList(),
    };
