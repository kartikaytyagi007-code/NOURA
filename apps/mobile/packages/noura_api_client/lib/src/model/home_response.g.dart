// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HomeResponseCWProxy {
  HomeResponse data(Home data);

  HomeResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HomeResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HomeResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  HomeResponse call({Home data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHomeResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHomeResponse.copyWith.fieldName(...)`
class _$HomeResponseCWProxyImpl implements _$HomeResponseCWProxy {
  const _$HomeResponseCWProxyImpl(this._value);

  final HomeResponse _value;

  @override
  HomeResponse data(Home data) => this(data: data);

  @override
  HomeResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HomeResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HomeResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  HomeResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return HomeResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as Home,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $HomeResponseCopyWith on HomeResponse {
  /// Returns a callable class that can be used as follows: `instanceOfHomeResponse.copyWith(...)` or like so:`instanceOfHomeResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HomeResponseCWProxy get copyWith => _$HomeResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeResponse _$HomeResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('HomeResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = HomeResponse(
        data: $checkedConvert(
          'data',
          (v) => Home.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => Meta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$HomeResponseToJson(HomeResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
