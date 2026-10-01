// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_scan_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MealScanResponseCWProxy {
  MealScanResponse data(MealScan data);

  MealScanResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealScanResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealScanResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MealScanResponse call({MealScan data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMealScanResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMealScanResponse.copyWith.fieldName(...)`
class _$MealScanResponseCWProxyImpl implements _$MealScanResponseCWProxy {
  const _$MealScanResponseCWProxyImpl(this._value);

  final MealScanResponse _value;

  @override
  MealScanResponse data(MealScan data) => this(data: data);

  @override
  MealScanResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealScanResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealScanResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MealScanResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return MealScanResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as MealScan,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $MealScanResponseCopyWith on MealScanResponse {
  /// Returns a callable class that can be used as follows: `instanceOfMealScanResponse.copyWith(...)` or like so:`instanceOfMealScanResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MealScanResponseCWProxy get copyWith => _$MealScanResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealScanResponse _$MealScanResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MealScanResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = MealScanResponse(
        data: $checkedConvert(
          'data',
          (v) => MealScan.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => Meta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MealScanResponseToJson(MealScanResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
