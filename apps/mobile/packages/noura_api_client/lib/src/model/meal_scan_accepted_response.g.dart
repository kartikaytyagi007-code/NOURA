// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_scan_accepted_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MealScanAcceptedResponseCWProxy {
  MealScanAcceptedResponse data(MealScanAccepted data);

  MealScanAcceptedResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealScanAcceptedResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealScanAcceptedResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MealScanAcceptedResponse call({MealScanAccepted data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMealScanAcceptedResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMealScanAcceptedResponse.copyWith.fieldName(...)`
class _$MealScanAcceptedResponseCWProxyImpl
    implements _$MealScanAcceptedResponseCWProxy {
  const _$MealScanAcceptedResponseCWProxyImpl(this._value);

  final MealScanAcceptedResponse _value;

  @override
  MealScanAcceptedResponse data(MealScanAccepted data) => this(data: data);

  @override
  MealScanAcceptedResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealScanAcceptedResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealScanAcceptedResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MealScanAcceptedResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return MealScanAcceptedResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as MealScanAccepted,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $MealScanAcceptedResponseCopyWith on MealScanAcceptedResponse {
  /// Returns a callable class that can be used as follows: `instanceOfMealScanAcceptedResponse.copyWith(...)` or like so:`instanceOfMealScanAcceptedResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MealScanAcceptedResponseCWProxy get copyWith =>
      _$MealScanAcceptedResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealScanAcceptedResponse _$MealScanAcceptedResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MealScanAcceptedResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = MealScanAcceptedResponse(
    data: $checkedConvert(
      'data',
      (v) => MealScanAccepted.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => Meta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$MealScanAcceptedResponseToJson(
  MealScanAcceptedResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
