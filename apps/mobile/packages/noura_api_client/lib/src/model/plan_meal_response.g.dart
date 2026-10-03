// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_meal_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PlanMealResponseCWProxy {
  PlanMealResponse data(PlanMeal data);

  PlanMealResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlanMealResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlanMealResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PlanMealResponse call({PlanMeal data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPlanMealResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPlanMealResponse.copyWith.fieldName(...)`
class _$PlanMealResponseCWProxyImpl implements _$PlanMealResponseCWProxy {
  const _$PlanMealResponseCWProxyImpl(this._value);

  final PlanMealResponse _value;

  @override
  PlanMealResponse data(PlanMeal data) => this(data: data);

  @override
  PlanMealResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlanMealResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlanMealResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PlanMealResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return PlanMealResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as PlanMeal,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $PlanMealResponseCopyWith on PlanMealResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPlanMealResponse.copyWith(...)` or like so:`instanceOfPlanMealResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PlanMealResponseCWProxy get copyWith => _$PlanMealResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlanMealResponse _$PlanMealResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PlanMealResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = PlanMealResponse(
        data: $checkedConvert(
          'data',
          (v) => PlanMeal.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => Meta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PlanMealResponseToJson(PlanMealResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
