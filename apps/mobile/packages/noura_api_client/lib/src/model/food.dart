//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/source_ref.dart';
import 'package:noura_api_client/src/model/nutrients.dart';
import 'package:noura_api_client/src/model/serving_conversion.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'food.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Food {
  /// Returns a new [Food] instance.
  Food({
    required this.id,

    required this.name,

    required this.aliases,

    required this.nutrientBasis,

    required this.per100g,

    required this.servingConversions,

    required this.dietTags,

    required this.allergenTags,

    required this.allergenCoverage,

    required this.source_,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'aliases', required: true, includeIfNull: false)
  final List<String> aliases;

  @JsonKey(name: r'nutrient_basis', required: true, includeIfNull: false)
  final FoodNutrientBasisEnum nutrientBasis;

  @JsonKey(name: r'per_100g', required: true, includeIfNull: false)
  final Nutrients per100g;

  @JsonKey(name: r'serving_conversions', required: true, includeIfNull: false)
  final List<ServingConversion> servingConversions;

  @JsonKey(name: r'diet_tags', required: true, includeIfNull: false)
  final List<String> dietTags;

  @JsonKey(name: r'allergen_tags', required: true, includeIfNull: false)
  final List<String> allergenTags;

  @JsonKey(name: r'allergen_coverage', required: true, includeIfNull: false)
  final FoodAllergenCoverageEnum allergenCoverage;

  @JsonKey(name: r'source', required: true, includeIfNull: false)
  final SourceRef source_;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Food &&
            runtimeType == other.runtimeType &&
            equals(
              [
                id,
                name,
                aliases,
                nutrientBasis,
                per100g,
                servingConversions,
                dietTags,
                allergenTags,
                allergenCoverage,
                source_,
              ],
              [
                other.id,
                other.name,
                other.aliases,
                other.nutrientBasis,
                other.per100g,
                other.servingConversions,
                other.dietTags,
                other.allergenTags,
                other.allergenCoverage,
                other.source_,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        id,
        name,
        aliases,
        nutrientBasis,
        per100g,
        servingConversions,
        dietTags,
        allergenTags,
        allergenCoverage,
        source_,
      ]);

  factory Food.fromJson(Map<String, dynamic> json) => _$FoodFromJson(json);

  Map<String, dynamic> toJson() => _$FoodToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum FoodNutrientBasisEnum {
  @JsonValue(r'raw')
  raw(r'raw'),
  @JsonValue(r'cooked')
  cooked(r'cooked'),
  @JsonValue(r'as_sold')
  asSold(r'as_sold');

  const FoodNutrientBasisEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum FoodAllergenCoverageEnum {
  @JsonValue(r'complete')
  complete(r'complete'),
  @JsonValue(r'partial')
  partial(r'partial'),
  @JsonValue(r'unknown')
  unknown(r'unknown');

  const FoodAllergenCoverageEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
