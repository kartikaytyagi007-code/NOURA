// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_scan_accepted.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MealScanAcceptedCWProxy {
  MealScanAccepted jobId(String jobId);

  MealScanAccepted scanId(String scanId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealScanAccepted(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealScanAccepted(...).copyWith(id: 12, name: "My name")
  /// ````
  MealScanAccepted call({String jobId, String scanId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMealScanAccepted.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMealScanAccepted.copyWith.fieldName(...)`
class _$MealScanAcceptedCWProxyImpl implements _$MealScanAcceptedCWProxy {
  const _$MealScanAcceptedCWProxyImpl(this._value);

  final MealScanAccepted _value;

  @override
  MealScanAccepted jobId(String jobId) => this(jobId: jobId);

  @override
  MealScanAccepted scanId(String scanId) => this(scanId: scanId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealScanAccepted(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealScanAccepted(...).copyWith(id: 12, name: "My name")
  /// ````
  MealScanAccepted call({
    Object? jobId = const $CopyWithPlaceholder(),
    Object? scanId = const $CopyWithPlaceholder(),
  }) {
    return MealScanAccepted(
      jobId: jobId == const $CopyWithPlaceholder()
          ? _value.jobId
          // ignore: cast_nullable_to_non_nullable
          : jobId as String,
      scanId: scanId == const $CopyWithPlaceholder()
          ? _value.scanId
          // ignore: cast_nullable_to_non_nullable
          : scanId as String,
    );
  }
}

extension $MealScanAcceptedCopyWith on MealScanAccepted {
  /// Returns a callable class that can be used as follows: `instanceOfMealScanAccepted.copyWith(...)` or like so:`instanceOfMealScanAccepted.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MealScanAcceptedCWProxy get copyWith => _$MealScanAcceptedCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealScanAccepted _$MealScanAcceptedFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MealScanAccepted', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['job_id', 'scan_id']);
      final val = MealScanAccepted(
        jobId: $checkedConvert('job_id', (v) => v as String),
        scanId: $checkedConvert('scan_id', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'jobId': 'job_id', 'scanId': 'scan_id'});

Map<String, dynamic> _$MealScanAcceptedToJson(MealScanAccepted instance) =>
    <String, dynamic>{'job_id': instance.jobId, 'scan_id': instance.scanId};
