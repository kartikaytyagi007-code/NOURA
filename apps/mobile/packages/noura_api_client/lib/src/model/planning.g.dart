// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planning.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PlanningCWProxy {
  Planning status(PlanningStatus status);

  Planning jobId(String? jobId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Planning(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Planning(...).copyWith(id: 12, name: "My name")
  /// ````
  Planning call({PlanningStatus status, String? jobId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPlanning.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPlanning.copyWith.fieldName(...)`
class _$PlanningCWProxyImpl implements _$PlanningCWProxy {
  const _$PlanningCWProxyImpl(this._value);

  final Planning _value;

  @override
  Planning status(PlanningStatus status) => this(status: status);

  @override
  Planning jobId(String? jobId) => this(jobId: jobId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Planning(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Planning(...).copyWith(id: 12, name: "My name")
  /// ````
  Planning call({
    Object? status = const $CopyWithPlaceholder(),
    Object? jobId = const $CopyWithPlaceholder(),
  }) {
    return Planning(
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as PlanningStatus,
      jobId: jobId == const $CopyWithPlaceholder()
          ? _value.jobId
          // ignore: cast_nullable_to_non_nullable
          : jobId as String?,
    );
  }
}

extension $PlanningCopyWith on Planning {
  /// Returns a callable class that can be used as follows: `instanceOfPlanning.copyWith(...)` or like so:`instanceOfPlanning.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PlanningCWProxy get copyWith => _$PlanningCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Planning _$PlanningFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Planning', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['status', 'job_id']);
      final val = Planning(
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$PlanningStatusEnumMap, v),
        ),
        jobId: $checkedConvert('job_id', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'jobId': 'job_id'});

Map<String, dynamic> _$PlanningToJson(Planning instance) => <String, dynamic>{
  'status': _$PlanningStatusEnumMap[instance.status]!,
  'job_id': instance.jobId,
};

const _$PlanningStatusEnumMap = {
  PlanningStatus.requested: 'requested',
  PlanningStatus.unavailableTrackingOnly: 'unavailable_tracking_only',
  PlanningStatus.unavailableNeedsReview: 'unavailable_needs_review',
  PlanningStatus.unavailablePolicy: 'unavailable_policy',
};
