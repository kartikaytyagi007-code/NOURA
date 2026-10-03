// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FoodListResponseCWProxy {
  FoodListResponse data(FoodList data);

  FoodListResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FoodListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FoodListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  FoodListResponse call({FoodList data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFoodListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFoodListResponse.copyWith.fieldName(...)`
class _$FoodListResponseCWProxyImpl implements _$FoodListResponseCWProxy {
  const _$FoodListResponseCWProxyImpl(this._value);

  final FoodListResponse _value;

  @override
  FoodListResponse data(FoodList data) => this(data: data);

  @override
  FoodListResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FoodListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FoodListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  FoodListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return FoodListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as FoodList,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $FoodListResponseCopyWith on FoodListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfFoodListResponse.copyWith(...)` or like so:`instanceOfFoodListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FoodListResponseCWProxy get copyWith => _$FoodListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodListResponse _$FoodListResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('FoodListResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = FoodListResponse(
        data: $checkedConvert(
          'data',
          (v) => FoodList.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => Meta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$FoodListResponseToJson(FoodListResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
