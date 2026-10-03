// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diet_plan_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DietPlanResponseCWProxy {
  DietPlanResponse data(DietPlan data);

  DietPlanResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DietPlanResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DietPlanResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  DietPlanResponse call({DietPlan data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDietPlanResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDietPlanResponse.copyWith.fieldName(...)`
class _$DietPlanResponseCWProxyImpl implements _$DietPlanResponseCWProxy {
  const _$DietPlanResponseCWProxyImpl(this._value);

  final DietPlanResponse _value;

  @override
  DietPlanResponse data(DietPlan data) => this(data: data);

  @override
  DietPlanResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DietPlanResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DietPlanResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  DietPlanResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return DietPlanResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as DietPlan,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $DietPlanResponseCopyWith on DietPlanResponse {
  /// Returns a callable class that can be used as follows: `instanceOfDietPlanResponse.copyWith(...)` or like so:`instanceOfDietPlanResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DietPlanResponseCWProxy get copyWith => _$DietPlanResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DietPlanResponse _$DietPlanResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DietPlanResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = DietPlanResponse(
        data: $checkedConvert(
          'data',
          (v) => DietPlan.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => Meta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$DietPlanResponseToJson(DietPlanResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
