// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_analysis_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MealAnalysisResponseCWProxy {
  MealAnalysisResponse data(MealAnalysis data);

  MealAnalysisResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealAnalysisResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealAnalysisResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MealAnalysisResponse call({MealAnalysis data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMealAnalysisResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMealAnalysisResponse.copyWith.fieldName(...)`
class _$MealAnalysisResponseCWProxyImpl
    implements _$MealAnalysisResponseCWProxy {
  const _$MealAnalysisResponseCWProxyImpl(this._value);

  final MealAnalysisResponse _value;

  @override
  MealAnalysisResponse data(MealAnalysis data) => this(data: data);

  @override
  MealAnalysisResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealAnalysisResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealAnalysisResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MealAnalysisResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return MealAnalysisResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as MealAnalysis,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $MealAnalysisResponseCopyWith on MealAnalysisResponse {
  /// Returns a callable class that can be used as follows: `instanceOfMealAnalysisResponse.copyWith(...)` or like so:`instanceOfMealAnalysisResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MealAnalysisResponseCWProxy get copyWith =>
      _$MealAnalysisResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealAnalysisResponse _$MealAnalysisResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MealAnalysisResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = MealAnalysisResponse(
    data: $checkedConvert(
      'data',
      (v) => MealAnalysis.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => Meta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$MealAnalysisResponseToJson(
  MealAnalysisResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
