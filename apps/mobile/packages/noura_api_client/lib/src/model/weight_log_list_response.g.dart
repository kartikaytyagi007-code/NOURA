// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_log_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeightLogListResponseCWProxy {
  WeightLogListResponse data(WeightLogList data);

  WeightLogListResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightLogListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightLogListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightLogListResponse call({WeightLogList data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeightLogListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeightLogListResponse.copyWith.fieldName(...)`
class _$WeightLogListResponseCWProxyImpl
    implements _$WeightLogListResponseCWProxy {
  const _$WeightLogListResponseCWProxyImpl(this._value);

  final WeightLogListResponse _value;

  @override
  WeightLogListResponse data(WeightLogList data) => this(data: data);

  @override
  WeightLogListResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightLogListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightLogListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightLogListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return WeightLogListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as WeightLogList,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $WeightLogListResponseCopyWith on WeightLogListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfWeightLogListResponse.copyWith(...)` or like so:`instanceOfWeightLogListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeightLogListResponseCWProxy get copyWith =>
      _$WeightLogListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightLogListResponse _$WeightLogListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('WeightLogListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = WeightLogListResponse(
    data: $checkedConvert(
      'data',
      (v) => WeightLogList.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => Meta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$WeightLogListResponseToJson(
  WeightLogListResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
