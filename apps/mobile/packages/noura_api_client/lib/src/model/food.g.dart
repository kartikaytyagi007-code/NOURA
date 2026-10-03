// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FoodCWProxy {
  Food id(String id);

  Food name(String name);

  Food aliases(List<String> aliases);

  Food nutrientBasis(FoodNutrientBasisEnum nutrientBasis);

  Food per100g(Nutrients per100g);

  Food servingConversions(List<ServingConversion> servingConversions);

  Food dietTags(List<String> dietTags);

  Food allergenTags(List<String> allergenTags);

  Food allergenCoverage(FoodAllergenCoverageEnum allergenCoverage);

  Food source_(SourceRef source_);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Food(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Food(...).copyWith(id: 12, name: "My name")
  /// ````
  Food call({
    String id,
    String name,
    List<String> aliases,
    FoodNutrientBasisEnum nutrientBasis,
    Nutrients per100g,
    List<ServingConversion> servingConversions,
    List<String> dietTags,
    List<String> allergenTags,
    FoodAllergenCoverageEnum allergenCoverage,
    SourceRef source_,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFood.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFood.copyWith.fieldName(...)`
class _$FoodCWProxyImpl implements _$FoodCWProxy {
  const _$FoodCWProxyImpl(this._value);

  final Food _value;

  @override
  Food id(String id) => this(id: id);

  @override
  Food name(String name) => this(name: name);

  @override
  Food aliases(List<String> aliases) => this(aliases: aliases);

  @override
  Food nutrientBasis(FoodNutrientBasisEnum nutrientBasis) =>
      this(nutrientBasis: nutrientBasis);

  @override
  Food per100g(Nutrients per100g) => this(per100g: per100g);

  @override
  Food servingConversions(List<ServingConversion> servingConversions) =>
      this(servingConversions: servingConversions);

  @override
  Food dietTags(List<String> dietTags) => this(dietTags: dietTags);

  @override
  Food allergenTags(List<String> allergenTags) =>
      this(allergenTags: allergenTags);

  @override
  Food allergenCoverage(FoodAllergenCoverageEnum allergenCoverage) =>
      this(allergenCoverage: allergenCoverage);

  @override
  Food source_(SourceRef source_) => this(source_: source_);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Food(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Food(...).copyWith(id: 12, name: "My name")
  /// ````
  Food call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? aliases = const $CopyWithPlaceholder(),
    Object? nutrientBasis = const $CopyWithPlaceholder(),
    Object? per100g = const $CopyWithPlaceholder(),
    Object? servingConversions = const $CopyWithPlaceholder(),
    Object? dietTags = const $CopyWithPlaceholder(),
    Object? allergenTags = const $CopyWithPlaceholder(),
    Object? allergenCoverage = const $CopyWithPlaceholder(),
    Object? source_ = const $CopyWithPlaceholder(),
  }) {
    return Food(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      aliases: aliases == const $CopyWithPlaceholder()
          ? _value.aliases
          // ignore: cast_nullable_to_non_nullable
          : aliases as List<String>,
      nutrientBasis: nutrientBasis == const $CopyWithPlaceholder()
          ? _value.nutrientBasis
          // ignore: cast_nullable_to_non_nullable
          : nutrientBasis as FoodNutrientBasisEnum,
      per100g: per100g == const $CopyWithPlaceholder()
          ? _value.per100g
          // ignore: cast_nullable_to_non_nullable
          : per100g as Nutrients,
      servingConversions: servingConversions == const $CopyWithPlaceholder()
          ? _value.servingConversions
          // ignore: cast_nullable_to_non_nullable
          : servingConversions as List<ServingConversion>,
      dietTags: dietTags == const $CopyWithPlaceholder()
          ? _value.dietTags
          // ignore: cast_nullable_to_non_nullable
          : dietTags as List<String>,
      allergenTags: allergenTags == const $CopyWithPlaceholder()
          ? _value.allergenTags
          // ignore: cast_nullable_to_non_nullable
          : allergenTags as List<String>,
      allergenCoverage: allergenCoverage == const $CopyWithPlaceholder()
          ? _value.allergenCoverage
          // ignore: cast_nullable_to_non_nullable
          : allergenCoverage as FoodAllergenCoverageEnum,
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as SourceRef,
    );
  }
}

extension $FoodCopyWith on Food {
  /// Returns a callable class that can be used as follows: `instanceOfFood.copyWith(...)` or like so:`instanceOfFood.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FoodCWProxy get copyWith => _$FoodCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Food _$FoodFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Food',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'name',
        'aliases',
        'nutrient_basis',
        'per_100g',
        'serving_conversions',
        'diet_tags',
        'allergen_tags',
        'allergen_coverage',
        'source',
      ],
    );
    final val = Food(
      id: $checkedConvert('id', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      aliases: $checkedConvert(
        'aliases',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      nutrientBasis: $checkedConvert(
        'nutrient_basis',
        (v) => $enumDecode(_$FoodNutrientBasisEnumEnumMap, v),
      ),
      per100g: $checkedConvert(
        'per_100g',
        (v) => Nutrients.fromJson(v as Map<String, dynamic>),
      ),
      servingConversions: $checkedConvert(
        'serving_conversions',
        (v) => (v as List<dynamic>)
            .map((e) => ServingConversion.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      dietTags: $checkedConvert(
        'diet_tags',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      allergenTags: $checkedConvert(
        'allergen_tags',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      allergenCoverage: $checkedConvert(
        'allergen_coverage',
        (v) => $enumDecode(_$FoodAllergenCoverageEnumEnumMap, v),
      ),
      source_: $checkedConvert(
        'source',
        (v) => SourceRef.fromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'nutrientBasis': 'nutrient_basis',
    'per100g': 'per_100g',
    'servingConversions': 'serving_conversions',
    'dietTags': 'diet_tags',
    'allergenTags': 'allergen_tags',
    'allergenCoverage': 'allergen_coverage',
    'source_': 'source',
  },
);

Map<String, dynamic> _$FoodToJson(Food instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'aliases': instance.aliases,
  'nutrient_basis': _$FoodNutrientBasisEnumEnumMap[instance.nutrientBasis]!,
  'per_100g': instance.per100g.toJson(),
  'serving_conversions': instance.servingConversions
      .map((e) => e.toJson())
      .toList(),
  'diet_tags': instance.dietTags,
  'allergen_tags': instance.allergenTags,
  'allergen_coverage':
      _$FoodAllergenCoverageEnumEnumMap[instance.allergenCoverage]!,
  'source': instance.source_.toJson(),
};

const _$FoodNutrientBasisEnumEnumMap = {
  FoodNutrientBasisEnum.raw: 'raw',
  FoodNutrientBasisEnum.cooked: 'cooked',
  FoodNutrientBasisEnum.asSold: 'as_sold',
};

const _$FoodAllergenCoverageEnumEnumMap = {
  FoodAllergenCoverageEnum.complete: 'complete',
  FoodAllergenCoverageEnum.partial: 'partial',
  FoodAllergenCoverageEnum.unknown: 'unknown',
};
