// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrient_totals.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NutrientTotalsCWProxy {
  NutrientTotals nutrients(Nutrients nutrients);

  NutrientTotals coverage(Coverage coverage);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NutrientTotals(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NutrientTotals(...).copyWith(id: 12, name: "My name")
  /// ````
  NutrientTotals call({Nutrients nutrients, Coverage coverage});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNutrientTotals.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNutrientTotals.copyWith.fieldName(...)`
class _$NutrientTotalsCWProxyImpl implements _$NutrientTotalsCWProxy {
  const _$NutrientTotalsCWProxyImpl(this._value);

  final NutrientTotals _value;

  @override
  NutrientTotals nutrients(Nutrients nutrients) => this(nutrients: nutrients);

  @override
  NutrientTotals coverage(Coverage coverage) => this(coverage: coverage);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NutrientTotals(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NutrientTotals(...).copyWith(id: 12, name: "My name")
  /// ````
  NutrientTotals call({
    Object? nutrients = const $CopyWithPlaceholder(),
    Object? coverage = const $CopyWithPlaceholder(),
  }) {
    return NutrientTotals(
      nutrients: nutrients == const $CopyWithPlaceholder()
          ? _value.nutrients
          // ignore: cast_nullable_to_non_nullable
          : nutrients as Nutrients,
      coverage: coverage == const $CopyWithPlaceholder()
          ? _value.coverage
          // ignore: cast_nullable_to_non_nullable
          : coverage as Coverage,
    );
  }
}

extension $NutrientTotalsCopyWith on NutrientTotals {
  /// Returns a callable class that can be used as follows: `instanceOfNutrientTotals.copyWith(...)` or like so:`instanceOfNutrientTotals.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NutrientTotalsCWProxy get copyWith => _$NutrientTotalsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NutrientTotals _$NutrientTotalsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('NutrientTotals', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['nutrients', 'coverage']);
      final val = NutrientTotals(
        nutrients: $checkedConvert(
          'nutrients',
          (v) => Nutrients.fromJson(v as Map<String, dynamic>),
        ),
        coverage: $checkedConvert(
          'coverage',
          (v) => Coverage.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$NutrientTotalsToJson(NutrientTotals instance) =>
    <String, dynamic>{
      'nutrients': instance.nutrients.toJson(),
      'coverage': instance.coverage.toJson(),
    };
