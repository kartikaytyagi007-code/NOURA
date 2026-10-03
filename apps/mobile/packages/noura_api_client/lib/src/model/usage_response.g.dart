// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UsageResponseCWProxy {
  UsageResponse data(Usage data);

  UsageResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UsageResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UsageResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  UsageResponse call({Usage data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUsageResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUsageResponse.copyWith.fieldName(...)`
class _$UsageResponseCWProxyImpl implements _$UsageResponseCWProxy {
  const _$UsageResponseCWProxyImpl(this._value);

  final UsageResponse _value;

  @override
  UsageResponse data(Usage data) => this(data: data);

  @override
  UsageResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UsageResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UsageResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  UsageResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return UsageResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as Usage,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $UsageResponseCopyWith on UsageResponse {
  /// Returns a callable class that can be used as follows: `instanceOfUsageResponse.copyWith(...)` or like so:`instanceOfUsageResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UsageResponseCWProxy get copyWith => _$UsageResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsageResponse _$UsageResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UsageResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = UsageResponse(
        data: $checkedConvert(
          'data',
          (v) => Usage.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => Meta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$UsageResponseToJson(UsageResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
