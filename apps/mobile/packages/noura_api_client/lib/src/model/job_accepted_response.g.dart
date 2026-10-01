// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_accepted_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$JobAcceptedResponseCWProxy {
  JobAcceptedResponse data(JobAccepted data);

  JobAcceptedResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `JobAcceptedResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// JobAcceptedResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  JobAcceptedResponse call({JobAccepted data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfJobAcceptedResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfJobAcceptedResponse.copyWith.fieldName(...)`
class _$JobAcceptedResponseCWProxyImpl implements _$JobAcceptedResponseCWProxy {
  const _$JobAcceptedResponseCWProxyImpl(this._value);

  final JobAcceptedResponse _value;

  @override
  JobAcceptedResponse data(JobAccepted data) => this(data: data);

  @override
  JobAcceptedResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `JobAcceptedResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// JobAcceptedResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  JobAcceptedResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return JobAcceptedResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as JobAccepted,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $JobAcceptedResponseCopyWith on JobAcceptedResponse {
  /// Returns a callable class that can be used as follows: `instanceOfJobAcceptedResponse.copyWith(...)` or like so:`instanceOfJobAcceptedResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$JobAcceptedResponseCWProxy get copyWith =>
      _$JobAcceptedResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobAcceptedResponse _$JobAcceptedResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('JobAcceptedResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = JobAcceptedResponse(
        data: $checkedConvert(
          'data',
          (v) => JobAccepted.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => Meta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$JobAcceptedResponseToJson(
  JobAcceptedResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
