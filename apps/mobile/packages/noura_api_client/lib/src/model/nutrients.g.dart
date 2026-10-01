// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrients.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NutrientsCWProxy {
  Nutrients energyKcal(num? energyKcal);

  Nutrients proteinG(num? proteinG);

  Nutrients carbohydrateG(num? carbohydrateG);

  Nutrients fatG(num? fatG);

  Nutrients fibreG(num? fibreG);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Nutrients(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Nutrients(...).copyWith(id: 12, name: "My name")
  /// ````
  Nutrients call({
    num? energyKcal,
    num? proteinG,
    num? carbohydrateG,
    num? fatG,
    num? fibreG,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNutrients.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNutrients.copyWith.fieldName(...)`
class _$NutrientsCWProxyImpl implements _$NutrientsCWProxy {
  const _$NutrientsCWProxyImpl(this._value);

  final Nutrients _value;

  @override
  Nutrients energyKcal(num? energyKcal) => this(energyKcal: energyKcal);

  @override
  Nutrients proteinG(num? proteinG) => this(proteinG: proteinG);

  @override
  Nutrients carbohydrateG(num? carbohydrateG) =>
      this(carbohydrateG: carbohydrateG);

  @override
  Nutrients fatG(num? fatG) => this(fatG: fatG);

  @override
  Nutrients fibreG(num? fibreG) => this(fibreG: fibreG);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Nutrients(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Nutrients(...).copyWith(id: 12, name: "My name")
  /// ````
  Nutrients call({
    Object? energyKcal = const $CopyWithPlaceholder(),
    Object? proteinG = const $CopyWithPlaceholder(),
    Object? carbohydrateG = const $CopyWithPlaceholder(),
    Object? fatG = const $CopyWithPlaceholder(),
    Object? fibreG = const $CopyWithPlaceholder(),
  }) {
    return Nutrients(
      energyKcal: energyKcal == const $CopyWithPlaceholder()
          ? _value.energyKcal
          // ignore: cast_nullable_to_non_nullable
          : energyKcal as num?,
      proteinG: proteinG == const $CopyWithPlaceholder()
          ? _value.proteinG
          // ignore: cast_nullable_to_non_nullable
          : proteinG as num?,
      carbohydrateG: carbohydrateG == const $CopyWithPlaceholder()
          ? _value.carbohydrateG
          // ignore: cast_nullable_to_non_nullable
          : carbohydrateG as num?,
      fatG: fatG == const $CopyWithPlaceholder()
          ? _value.fatG
          // ignore: cast_nullable_to_non_nullable
          : fatG as num?,
      fibreG: fibreG == const $CopyWithPlaceholder()
          ? _value.fibreG
          // ignore: cast_nullable_to_non_nullable
          : fibreG as num?,
    );
  }
}

extension $NutrientsCopyWith on Nutrients {
  /// Returns a callable class that can be used as follows: `instanceOfNutrients.copyWith(...)` or like so:`instanceOfNutrients.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NutrientsCWProxy get copyWith => _$NutrientsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Nutrients _$NutrientsFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Nutrients',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'energy_kcal',
        'protein_g',
        'carbohydrate_g',
        'fat_g',
        'fibre_g',
      ],
    );
    final val = Nutrients(
      energyKcal: $checkedConvert('energy_kcal', (v) => v as num?),
      proteinG: $checkedConvert('protein_g', (v) => v as num?),
      carbohydrateG: $checkedConvert('carbohydrate_g', (v) => v as num?),
      fatG: $checkedConvert('fat_g', (v) => v as num?),
      fibreG: $checkedConvert('fibre_g', (v) => v as num?),
    );
    return val;
  },
  fieldKeyMap: const {
    'energyKcal': 'energy_kcal',
    'proteinG': 'protein_g',
    'carbohydrateG': 'carbohydrate_g',
    'fatG': 'fat_g',
    'fibreG': 'fibre_g',
  },
);

Map<String, dynamic> _$NutrientsToJson(Nutrients instance) => <String, dynamic>{
  'energy_kcal': instance.energyKcal,
  'protein_g': instance.proteinG,
  'carbohydrate_g': instance.carbohydrateG,
  'fat_g': instance.fatG,
  'fibre_g': instance.fibreG,
};
