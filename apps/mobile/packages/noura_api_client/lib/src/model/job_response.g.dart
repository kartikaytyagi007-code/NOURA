// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$JobResponseCWProxy {
  JobResponse data(Job data);

  JobResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `JobResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// JobResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  JobResponse call({Job data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfJobResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfJobResponse.copyWith.fieldName(...)`
class _$JobResponseCWProxyImpl implements _$JobResponseCWProxy {
  const _$JobResponseCWProxyImpl(this._value);

  final JobResponse _value;

  @override
  JobResponse data(Job data) => this(data: data);

  @override
  JobResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `JobResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// JobResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  JobResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return JobResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as Job,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $JobResponseCopyWith on JobResponse {
  /// Returns a callable class that can be used as follows: `instanceOfJobResponse.copyWith(...)` or like so:`instanceOfJobResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$JobResponseCWProxy get copyWith => _$JobResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobResponse _$JobResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('JobResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = JobResponse(
        data: $checkedConvert(
          'data',
          (v) => Job.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => Meta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$JobResponseToJson(JobResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
