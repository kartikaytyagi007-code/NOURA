// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_accepted.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$JobAcceptedCWProxy {
  JobAccepted jobId(String jobId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `JobAccepted(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// JobAccepted(...).copyWith(id: 12, name: "My name")
  /// ````
  JobAccepted call({String jobId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfJobAccepted.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfJobAccepted.copyWith.fieldName(...)`
class _$JobAcceptedCWProxyImpl implements _$JobAcceptedCWProxy {
  const _$JobAcceptedCWProxyImpl(this._value);

  final JobAccepted _value;

  @override
  JobAccepted jobId(String jobId) => this(jobId: jobId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `JobAccepted(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// JobAccepted(...).copyWith(id: 12, name: "My name")
  /// ````
  JobAccepted call({Object? jobId = const $CopyWithPlaceholder()}) {
    return JobAccepted(
      jobId: jobId == const $CopyWithPlaceholder()
          ? _value.jobId
          // ignore: cast_nullable_to_non_nullable
          : jobId as String,
    );
  }
}

extension $JobAcceptedCopyWith on JobAccepted {
  /// Returns a callable class that can be used as follows: `instanceOfJobAccepted.copyWith(...)` or like so:`instanceOfJobAccepted.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$JobAcceptedCWProxy get copyWith => _$JobAcceptedCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobAccepted _$JobAcceptedFromJson(Map<String, dynamic> json) =>
    $checkedCreate('JobAccepted', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['job_id']);
      final val = JobAccepted(
        jobId: $checkedConvert('job_id', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'jobId': 'job_id'});

Map<String, dynamic> _$JobAcceptedToJson(JobAccepted instance) =>
    <String, dynamic>{'job_id': instance.jobId};
