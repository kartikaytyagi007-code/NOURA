// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'next_meal_action_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NextMealActionResponseCWProxy {
  NextMealActionResponse data(NextMealActionResult data);

  NextMealActionResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NextMealActionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NextMealActionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  NextMealActionResponse call({NextMealActionResult data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNextMealActionResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNextMealActionResponse.copyWith.fieldName(...)`
class _$NextMealActionResponseCWProxyImpl
    implements _$NextMealActionResponseCWProxy {
  const _$NextMealActionResponseCWProxyImpl(this._value);

  final NextMealActionResponse _value;

  @override
  NextMealActionResponse data(NextMealActionResult data) => this(data: data);

  @override
  NextMealActionResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NextMealActionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NextMealActionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  NextMealActionResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return NextMealActionResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as NextMealActionResult,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $NextMealActionResponseCopyWith on NextMealActionResponse {
  /// Returns a callable class that can be used as follows: `instanceOfNextMealActionResponse.copyWith(...)` or like so:`instanceOfNextMealActionResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NextMealActionResponseCWProxy get copyWith =>
      _$NextMealActionResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NextMealActionResponse _$NextMealActionResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('NextMealActionResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = NextMealActionResponse(
    data: $checkedConvert(
      'data',
      (v) => NextMealActionResult.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => Meta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$NextMealActionResponseToJson(
  NextMealActionResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
