// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'next_meal_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NextMealResponseCWProxy {
  NextMealResponse data(NextMeal data);

  NextMealResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NextMealResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NextMealResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  NextMealResponse call({NextMeal data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNextMealResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNextMealResponse.copyWith.fieldName(...)`
class _$NextMealResponseCWProxyImpl implements _$NextMealResponseCWProxy {
  const _$NextMealResponseCWProxyImpl(this._value);

  final NextMealResponse _value;

  @override
  NextMealResponse data(NextMeal data) => this(data: data);

  @override
  NextMealResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NextMealResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NextMealResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  NextMealResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return NextMealResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as NextMeal,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $NextMealResponseCopyWith on NextMealResponse {
  /// Returns a callable class that can be used as follows: `instanceOfNextMealResponse.copyWith(...)` or like so:`instanceOfNextMealResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NextMealResponseCWProxy get copyWith => _$NextMealResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NextMealResponse _$NextMealResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('NextMealResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = NextMealResponse(
        data: $checkedConvert(
          'data',
          (v) => NextMeal.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => Meta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$NextMealResponseToJson(NextMealResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
