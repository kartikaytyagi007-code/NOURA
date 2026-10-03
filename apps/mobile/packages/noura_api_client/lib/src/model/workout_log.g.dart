// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_log.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkoutLogCWProxy {
  WorkoutLog id(String id);

  WorkoutLog clientId(String clientId);

  WorkoutLog sessionId(String sessionId);

  WorkoutLog status(WorkoutLogStatusEnum status);

  WorkoutLog startedAt(DateTime? startedAt);

  WorkoutLog completedAt(DateTime? completedAt);

  WorkoutLog sets(List<SetLogInput> sets);

  WorkoutLog revision(int revision);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutLog(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutLog(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutLog call({
    String id,
    String clientId,
    String sessionId,
    WorkoutLogStatusEnum status,
    DateTime? startedAt,
    DateTime? completedAt,
    List<SetLogInput> sets,
    int revision,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkoutLog.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkoutLog.copyWith.fieldName(...)`
class _$WorkoutLogCWProxyImpl implements _$WorkoutLogCWProxy {
  const _$WorkoutLogCWProxyImpl(this._value);

  final WorkoutLog _value;

  @override
  WorkoutLog id(String id) => this(id: id);

  @override
  WorkoutLog clientId(String clientId) => this(clientId: clientId);

  @override
  WorkoutLog sessionId(String sessionId) => this(sessionId: sessionId);

  @override
  WorkoutLog status(WorkoutLogStatusEnum status) => this(status: status);

  @override
  WorkoutLog startedAt(DateTime? startedAt) => this(startedAt: startedAt);

  @override
  WorkoutLog completedAt(DateTime? completedAt) =>
      this(completedAt: completedAt);

  @override
  WorkoutLog sets(List<SetLogInput> sets) => this(sets: sets);

  @override
  WorkoutLog revision(int revision) => this(revision: revision);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutLog(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutLog(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutLog call({
    Object? id = const $CopyWithPlaceholder(),
    Object? clientId = const $CopyWithPlaceholder(),
    Object? sessionId = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? startedAt = const $CopyWithPlaceholder(),
    Object? completedAt = const $CopyWithPlaceholder(),
    Object? sets = const $CopyWithPlaceholder(),
    Object? revision = const $CopyWithPlaceholder(),
  }) {
    return WorkoutLog(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      clientId: clientId == const $CopyWithPlaceholder()
          ? _value.clientId
          // ignore: cast_nullable_to_non_nullable
          : clientId as String,
      sessionId: sessionId == const $CopyWithPlaceholder()
          ? _value.sessionId
          // ignore: cast_nullable_to_non_nullable
          : sessionId as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as WorkoutLogStatusEnum,
      startedAt: startedAt == const $CopyWithPlaceholder()
          ? _value.startedAt
          // ignore: cast_nullable_to_non_nullable
          : startedAt as DateTime?,
      completedAt: completedAt == const $CopyWithPlaceholder()
          ? _value.completedAt
          // ignore: cast_nullable_to_non_nullable
          : completedAt as DateTime?,
      sets: sets == const $CopyWithPlaceholder()
          ? _value.sets
          // ignore: cast_nullable_to_non_nullable
          : sets as List<SetLogInput>,
      revision: revision == const $CopyWithPlaceholder()
          ? _value.revision
          // ignore: cast_nullable_to_non_nullable
          : revision as int,
    );
  }
}

extension $WorkoutLogCopyWith on WorkoutLog {
  /// Returns a callable class that can be used as follows: `instanceOfWorkoutLog.copyWith(...)` or like so:`instanceOfWorkoutLog.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkoutLogCWProxy get copyWith => _$WorkoutLogCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutLog _$WorkoutLogFromJson(Map<String, dynamic> json) => $checkedCreate(
  'WorkoutLog',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'client_id',
        'session_id',
        'status',
        'started_at',
        'completed_at',
        'sets',
        'revision',
      ],
    );
    final val = WorkoutLog(
      id: $checkedConvert('id', (v) => v as String),
      clientId: $checkedConvert('client_id', (v) => v as String),
      sessionId: $checkedConvert('session_id', (v) => v as String),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$WorkoutLogStatusEnumEnumMap, v),
      ),
      startedAt: $checkedConvert(
        'started_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      completedAt: $checkedConvert(
        'completed_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      sets: $checkedConvert(
        'sets',
        (v) => (v as List<dynamic>)
            .map((e) => SetLogInput.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      revision: $checkedConvert('revision', (v) => (v as num).toInt()),
    );
    return val;
  },
  fieldKeyMap: const {
    'clientId': 'client_id',
    'sessionId': 'session_id',
    'startedAt': 'started_at',
    'completedAt': 'completed_at',
  },
);

Map<String, dynamic> _$WorkoutLogToJson(WorkoutLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'client_id': instance.clientId,
      'session_id': instance.sessionId,
      'status': _$WorkoutLogStatusEnumEnumMap[instance.status]!,
      'started_at': instance.startedAt?.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
      'sets': instance.sets.map((e) => e.toJson()).toList(),
      'revision': instance.revision,
    };

const _$WorkoutLogStatusEnumEnumMap = {
  WorkoutLogStatusEnum.inProgress: 'in_progress',
  WorkoutLogStatusEnum.completed: 'completed',
  WorkoutLogStatusEnum.skipped: 'skipped',
  WorkoutLogStatusEnum.abandoned: 'abandoned',
};
