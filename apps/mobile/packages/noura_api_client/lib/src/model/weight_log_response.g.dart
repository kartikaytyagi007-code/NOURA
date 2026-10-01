// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_log_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeightLogResponseCWProxy {
  WeightLogResponse data(WeightLog data);

  WeightLogResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightLogResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightLogResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightLogResponse call({WeightLog data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeightLogResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeightLogResponse.copyWith.fieldName(...)`
class _$WeightLogResponseCWProxyImpl implements _$WeightLogResponseCWProxy {
  const _$WeightLogResponseCWProxyImpl(this._value);

  final WeightLogResponse _value;

  @override
  WeightLogResponse data(WeightLog data) => this(data: data);

  @override
  WeightLogResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightLogResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightLogResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightLogResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return WeightLogResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as WeightLog,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $WeightLogResponseCopyWith on WeightLogResponse {
  /// Returns a callable class that can be used as follows: `instanceOfWeightLogResponse.copyWith(...)` or like so:`instanceOfWeightLogResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeightLogResponseCWProxy get copyWith =>
      _$WeightLogResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightLogResponse _$WeightLogResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WeightLogResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = WeightLogResponse(
        data: $checkedConvert(
          'data',
          (v) => WeightLog.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => Meta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$WeightLogResponseToJson(WeightLogResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
