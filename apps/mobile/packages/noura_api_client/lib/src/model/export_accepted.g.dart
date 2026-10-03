// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_accepted.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExportAcceptedCWProxy {
  ExportAccepted exportId(String exportId);

  ExportAccepted jobId(String jobId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExportAccepted(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExportAccepted(...).copyWith(id: 12, name: "My name")
  /// ````
  ExportAccepted call({String exportId, String jobId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExportAccepted.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExportAccepted.copyWith.fieldName(...)`
class _$ExportAcceptedCWProxyImpl implements _$ExportAcceptedCWProxy {
  const _$ExportAcceptedCWProxyImpl(this._value);

  final ExportAccepted _value;

  @override
  ExportAccepted exportId(String exportId) => this(exportId: exportId);

  @override
  ExportAccepted jobId(String jobId) => this(jobId: jobId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExportAccepted(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExportAccepted(...).copyWith(id: 12, name: "My name")
  /// ````
  ExportAccepted call({
    Object? exportId = const $CopyWithPlaceholder(),
    Object? jobId = const $CopyWithPlaceholder(),
  }) {
    return ExportAccepted(
      exportId: exportId == const $CopyWithPlaceholder()
          ? _value.exportId
          // ignore: cast_nullable_to_non_nullable
          : exportId as String,
      jobId: jobId == const $CopyWithPlaceholder()
          ? _value.jobId
          // ignore: cast_nullable_to_non_nullable
          : jobId as String,
    );
  }
}

extension $ExportAcceptedCopyWith on ExportAccepted {
  /// Returns a callable class that can be used as follows: `instanceOfExportAccepted.copyWith(...)` or like so:`instanceOfExportAccepted.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExportAcceptedCWProxy get copyWith => _$ExportAcceptedCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExportAccepted _$ExportAcceptedFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ExportAccepted', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['export_id', 'job_id']);
      final val = ExportAccepted(
        exportId: $checkedConvert('export_id', (v) => v as String),
        jobId: $checkedConvert('job_id', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'exportId': 'export_id', 'jobId': 'job_id'});

Map<String, dynamic> _$ExportAcceptedToJson(ExportAccepted instance) =>
    <String, dynamic>{'export_id': instance.exportId, 'job_id': instance.jobId};
