// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swap_options_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SwapOptionsResponseCWProxy {
  SwapOptionsResponse data(SwapOptions data);

  SwapOptionsResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwapOptionsResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwapOptionsResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SwapOptionsResponse call({SwapOptions data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSwapOptionsResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSwapOptionsResponse.copyWith.fieldName(...)`
class _$SwapOptionsResponseCWProxyImpl implements _$SwapOptionsResponseCWProxy {
  const _$SwapOptionsResponseCWProxyImpl(this._value);

  final SwapOptionsResponse _value;

  @override
  SwapOptionsResponse data(SwapOptions data) => this(data: data);

  @override
  SwapOptionsResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwapOptionsResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwapOptionsResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SwapOptionsResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return SwapOptionsResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as SwapOptions,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $SwapOptionsResponseCopyWith on SwapOptionsResponse {
  /// Returns a callable class that can be used as follows: `instanceOfSwapOptionsResponse.copyWith(...)` or like so:`instanceOfSwapOptionsResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SwapOptionsResponseCWProxy get copyWith =>
      _$SwapOptionsResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwapOptionsResponse _$SwapOptionsResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SwapOptionsResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = SwapOptionsResponse(
        data: $checkedConvert(
          'data',
          (v) => SwapOptions.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => Meta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SwapOptionsResponseToJson(
  SwapOptionsResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
