// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_log_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MealLogResponseCWProxy {
  MealLogResponse data(MealLog data);

  MealLogResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealLogResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealLogResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MealLogResponse call({MealLog data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMealLogResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMealLogResponse.copyWith.fieldName(...)`
class _$MealLogResponseCWProxyImpl implements _$MealLogResponseCWProxy {
  const _$MealLogResponseCWProxyImpl(this._value);

  final MealLogResponse _value;

  @override
  MealLogResponse data(MealLog data) => this(data: data);

  @override
  MealLogResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealLogResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealLogResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MealLogResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return MealLogResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as MealLog,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $MealLogResponseCopyWith on MealLogResponse {
  /// Returns a callable class that can be used as follows: `instanceOfMealLogResponse.copyWith(...)` or like so:`instanceOfMealLogResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MealLogResponseCWProxy get copyWith => _$MealLogResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealLogResponse _$MealLogResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MealLogResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = MealLogResponse(
        data: $checkedConvert(
          'data',
          (v) => MealLog.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => Meta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MealLogResponseToJson(MealLogResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
