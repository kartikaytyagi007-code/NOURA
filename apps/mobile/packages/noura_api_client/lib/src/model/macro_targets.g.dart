// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'macro_targets.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MacroTargetsCWProxy {
  MacroTargets energyKcal(int? energyKcal);

  MacroTargets proteinG(num? proteinG);

  MacroTargets fibreG(num? fibreG);

  MacroTargets carbohydrateG(num? carbohydrateG);

  MacroTargets fatG(num? fatG);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MacroTargets(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MacroTargets(...).copyWith(id: 12, name: "My name")
  /// ````
  MacroTargets call({
    int? energyKcal,
    num? proteinG,
    num? fibreG,
    num? carbohydrateG,
    num? fatG,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMacroTargets.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMacroTargets.copyWith.fieldName(...)`
class _$MacroTargetsCWProxyImpl implements _$MacroTargetsCWProxy {
  const _$MacroTargetsCWProxyImpl(this._value);

  final MacroTargets _value;

  @override
  MacroTargets energyKcal(int? energyKcal) => this(energyKcal: energyKcal);

  @override
  MacroTargets proteinG(num? proteinG) => this(proteinG: proteinG);

  @override
  MacroTargets fibreG(num? fibreG) => this(fibreG: fibreG);

  @override
  MacroTargets carbohydrateG(num? carbohydrateG) =>
      this(carbohydrateG: carbohydrateG);

  @override
  MacroTargets fatG(num? fatG) => this(fatG: fatG);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MacroTargets(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MacroTargets(...).copyWith(id: 12, name: "My name")
  /// ````
  MacroTargets call({
    Object? energyKcal = const $CopyWithPlaceholder(),
    Object? proteinG = const $CopyWithPlaceholder(),
    Object? fibreG = const $CopyWithPlaceholder(),
    Object? carbohydrateG = const $CopyWithPlaceholder(),
    Object? fatG = const $CopyWithPlaceholder(),
  }) {
    return MacroTargets(
      energyKcal: energyKcal == const $CopyWithPlaceholder()
          ? _value.energyKcal
          // ignore: cast_nullable_to_non_nullable
          : energyKcal as int?,
      proteinG: proteinG == const $CopyWithPlaceholder()
          ? _value.proteinG
          // ignore: cast_nullable_to_non_nullable
          : proteinG as num?,
      fibreG: fibreG == const $CopyWithPlaceholder()
          ? _value.fibreG
          // ignore: cast_nullable_to_non_nullable
          : fibreG as num?,
      carbohydrateG: carbohydrateG == const $CopyWithPlaceholder()
          ? _value.carbohydrateG
          // ignore: cast_nullable_to_non_nullable
          : carbohydrateG as num?,
      fatG: fatG == const $CopyWithPlaceholder()
          ? _value.fatG
          // ignore: cast_nullable_to_non_nullable
          : fatG as num?,
    );
  }
}

extension $MacroTargetsCopyWith on MacroTargets {
  /// Returns a callable class that can be used as follows: `instanceOfMacroTargets.copyWith(...)` or like so:`instanceOfMacroTargets.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MacroTargetsCWProxy get copyWith => _$MacroTargetsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MacroTargets _$MacroTargetsFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'MacroTargets',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'energy_kcal',
            'protein_g',
            'fibre_g',
            'carbohydrate_g',
            'fat_g',
          ],
        );
        final val = MacroTargets(
          energyKcal: $checkedConvert(
            'energy_kcal',
            (v) => (v as num?)?.toInt(),
          ),
          proteinG: $checkedConvert('protein_g', (v) => v as num?),
          fibreG: $checkedConvert('fibre_g', (v) => v as num?),
          carbohydrateG: $checkedConvert('carbohydrate_g', (v) => v as num?),
          fatG: $checkedConvert('fat_g', (v) => v as num?),
        );
        return val;
      },
      fieldKeyMap: const {
        'energyKcal': 'energy_kcal',
        'proteinG': 'protein_g',
        'fibreG': 'fibre_g',
        'carbohydrateG': 'carbohydrate_g',
        'fatG': 'fat_g',
      },
    );

Map<String, dynamic> _$MacroTargetsToJson(MacroTargets instance) =>
    <String, dynamic>{
      'energy_kcal': instance.energyKcal,
      'protein_g': instance.proteinG,
      'fibre_g': instance.fibreG,
      'carbohydrate_g': instance.carbohydrateG,
      'fat_g': instance.fatG,
    };
