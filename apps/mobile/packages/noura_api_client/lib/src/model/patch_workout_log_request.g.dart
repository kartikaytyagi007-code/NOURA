// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_workout_log_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PatchWorkoutLogRequestCWProxy {
  PatchWorkoutLogRequest expectedRevision(int expectedRevision);

  PatchWorkoutLogRequest status(PatchWorkoutLogRequestStatusEnum status);

  PatchWorkoutLogRequest completedAt(DateTime? completedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PatchWorkoutLogRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PatchWorkoutLogRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PatchWorkoutLogRequest call({
    int expectedRevision,
    PatchWorkoutLogRequestStatusEnum status,
    DateTime? completedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPatchWorkoutLogRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPatchWorkoutLogRequest.copyWith.fieldName(...)`
class _$PatchWorkoutLogRequestCWProxyImpl
    implements _$PatchWorkoutLogRequestCWProxy {
  const _$PatchWorkoutLogRequestCWProxyImpl(this._value);

  final PatchWorkoutLogRequest _value;

  @override
  PatchWorkoutLogRequest expectedRevision(int expectedRevision) =>
      this(expectedRevision: expectedRevision);

  @override
  PatchWorkoutLogRequest status(PatchWorkoutLogRequestStatusEnum status) =>
      this(status: status);

  @override
  PatchWorkoutLogRequest completedAt(DateTime? completedAt) =>
      this(completedAt: completedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PatchWorkoutLogRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PatchWorkoutLogRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PatchWorkoutLogRequest call({
    Object? expectedRevision = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? completedAt = const $CopyWithPlaceholder(),
  }) {
    return PatchWorkoutLogRequest(
      expectedRevision: expectedRevision == const $CopyWithPlaceholder()
          ? _value.expectedRevision
          // ignore: cast_nullable_to_non_nullable
          : expectedRevision as int,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as PatchWorkoutLogRequestStatusEnum,
      completedAt: completedAt == const $CopyWithPlaceholder()
          ? _value.completedAt
          // ignore: cast_nullable_to_non_nullable
          : completedAt as DateTime?,
    );
  }
}

extension $PatchWorkoutLogRequestCopyWith on PatchWorkoutLogRequest {
  /// Returns a callable class that can be used as follows: `instanceOfPatchWorkoutLogRequest.copyWith(...)` or like so:`instanceOfPatchWorkoutLogRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PatchWorkoutLogRequestCWProxy get copyWith =>
      _$PatchWorkoutLogRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchWorkoutLogRequest _$PatchWorkoutLogRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PatchWorkoutLogRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['expected_revision', 'status']);
    final val = PatchWorkoutLogRequest(
      expectedRevision: $checkedConvert(
        'expected_revision',
        (v) => (v as num).toInt(),
      ),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$PatchWorkoutLogRequestStatusEnumEnumMap, v),
      ),
      completedAt: $checkedConvert(
        'completed_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'expectedRevision': 'expected_revision',
    'completedAt': 'completed_at',
  },
);

Map<String, dynamic> _$PatchWorkoutLogRequestToJson(
  PatchWorkoutLogRequest instance,
) => <String, dynamic>{
  'expected_revision': instance.expectedRevision,
  'status': _$PatchWorkoutLogRequestStatusEnumEnumMap[instance.status]!,
  'completed_at': ?instance.completedAt?.toIso8601String(),
};

const _$PatchWorkoutLogRequestStatusEnumEnumMap = {
  PatchWorkoutLogRequestStatusEnum.completed: 'completed',
  PatchWorkoutLogRequestStatusEnum.skipped: 'skipped',
  PatchWorkoutLogRequestStatusEnum.abandoned: 'abandoned',
};
