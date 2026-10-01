// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_diary_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MealDiaryResponseCWProxy {
  MealDiaryResponse data(MealDiary data);

  MealDiaryResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealDiaryResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealDiaryResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MealDiaryResponse call({MealDiary data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMealDiaryResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMealDiaryResponse.copyWith.fieldName(...)`
class _$MealDiaryResponseCWProxyImpl implements _$MealDiaryResponseCWProxy {
  const _$MealDiaryResponseCWProxyImpl(this._value);

  final MealDiaryResponse _value;

  @override
  MealDiaryResponse data(MealDiary data) => this(data: data);

  @override
  MealDiaryResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealDiaryResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealDiaryResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MealDiaryResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return MealDiaryResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as MealDiary,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $MealDiaryResponseCopyWith on MealDiaryResponse {
  /// Returns a callable class that can be used as follows: `instanceOfMealDiaryResponse.copyWith(...)` or like so:`instanceOfMealDiaryResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MealDiaryResponseCWProxy get copyWith =>
      _$MealDiaryResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealDiaryResponse _$MealDiaryResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MealDiaryResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = MealDiaryResponse(
        data: $checkedConvert(
          'data',
          (v) => MealDiary.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => Meta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MealDiaryResponseToJson(MealDiaryResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
