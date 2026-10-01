// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$JobCWProxy {
  Job id(String id);

  Job type(JobType type);

  Job status(JobStatus status);

  Job resultIds(Map<String, String> resultIds);

  Job error(SafeError? error);

  Job pollAfterMs(int? pollAfterMs);

  Job createdAt(DateTime createdAt);

  Job updatedAt(DateTime updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Job(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Job(...).copyWith(id: 12, name: "My name")
  /// ````
  Job call({
    String id,
    JobType type,
    JobStatus status,
    Map<String, String> resultIds,
    SafeError? error,
    int? pollAfterMs,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfJob.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfJob.copyWith.fieldName(...)`
class _$JobCWProxyImpl implements _$JobCWProxy {
  const _$JobCWProxyImpl(this._value);

  final Job _value;

  @override
  Job id(String id) => this(id: id);

  @override
  Job type(JobType type) => this(type: type);

  @override
  Job status(JobStatus status) => this(status: status);

  @override
  Job resultIds(Map<String, String> resultIds) => this(resultIds: resultIds);

  @override
  Job error(SafeError? error) => this(error: error);

  @override
  Job pollAfterMs(int? pollAfterMs) => this(pollAfterMs: pollAfterMs);

  @override
  Job createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  Job updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Job(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Job(...).copyWith(id: 12, name: "My name")
  /// ````
  Job call({
    Object? id = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? resultIds = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
    Object? pollAfterMs = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return Job(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as JobType,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as JobStatus,
      resultIds: resultIds == const $CopyWithPlaceholder()
          ? _value.resultIds
          // ignore: cast_nullable_to_non_nullable
          : resultIds as Map<String, String>,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as SafeError?,
      pollAfterMs: pollAfterMs == const $CopyWithPlaceholder()
          ? _value.pollAfterMs
          // ignore: cast_nullable_to_non_nullable
          : pollAfterMs as int?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
    );
  }
}

extension $JobCopyWith on Job {
  /// Returns a callable class that can be used as follows: `instanceOfJob.copyWith(...)` or like so:`instanceOfJob.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$JobCWProxy get copyWith => _$JobCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Job _$JobFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Job',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'type',
        'status',
        'result_ids',
        'error',
        'poll_after_ms',
        'created_at',
        'updated_at',
      ],
    );
    final val = Job(
      id: $checkedConvert('id', (v) => v as String),
      type: $checkedConvert('type', (v) => $enumDecode(_$JobTypeEnumMap, v)),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$JobStatusEnumMap, v),
      ),
      resultIds: $checkedConvert(
        'result_ids',
        (v) => Map<String, String>.from(v as Map),
      ),
      error: $checkedConvert(
        'error',
        (v) => v == null ? null : SafeError.fromJson(v as Map<String, dynamic>),
      ),
      pollAfterMs: $checkedConvert(
        'poll_after_ms',
        (v) => (v as num?)?.toInt(),
      ),
      createdAt: $checkedConvert(
        'created_at',
        (v) => DateTime.parse(v as String),
      ),
      updatedAt: $checkedConvert(
        'updated_at',
        (v) => DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'resultIds': 'result_ids',
    'pollAfterMs': 'poll_after_ms',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
  },
);

Map<String, dynamic> _$JobToJson(Job instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$JobTypeEnumMap[instance.type]!,
  'status': _$JobStatusEnumMap[instance.status]!,
  'result_ids': instance.resultIds,
  'error': instance.error?.toJson(),
  'poll_after_ms': instance.pollAfterMs,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$JobTypeEnumMap = {
  JobType.dietPlan: 'diet_plan',
  JobType.workoutPlan: 'workout_plan',
  JobType.planRegeneration: 'plan_regeneration',
  JobType.mealScan: 'meal_scan',
  JobType.coachReply: 'coach_reply',
  JobType.weeklyInsight: 'weekly_insight',
};

const _$JobStatusEnumMap = {
  JobStatus.queued: 'queued',
  JobStatus.running: 'running',
  JobStatus.completed: 'completed',
  JobStatus.failed: 'failed',
  JobStatus.cancelled: 'cancelled',
};
