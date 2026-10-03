//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/nutrient_totals.dart';
import 'package:noura_api_client/src/model/recipe_ingredient.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'recipe.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Recipe {
  /// Returns a new [Recipe] instance.
  Recipe({
    required this.id,

    required this.name,

    required this.cuisine,

    required this.tags,

    required this.dietTags,

    required this.ingredients,

    required this.instructions,

    required this.cookedYieldG,

    required this.servings,

    required this.cookingMinutes,

    required this.nutritionPerServing,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'cuisine', required: true, includeIfNull: true)
  final String? cuisine;

  @JsonKey(name: r'tags', required: true, includeIfNull: false)
  final List<String> tags;

  @JsonKey(name: r'diet_tags', required: true, includeIfNull: false)
  final List<String> dietTags;

  @JsonKey(name: r'ingredients', required: true, includeIfNull: false)
  final List<RecipeIngredient> ingredients;

  @JsonKey(name: r'instructions', required: true, includeIfNull: false)
  final List<String> instructions;

  @JsonKey(name: r'cooked_yield_g', required: true, includeIfNull: true)
  final num? cookedYieldG;

  @JsonKey(name: r'servings', required: true, includeIfNull: true)
  final int? servings;

  @JsonKey(name: r'cooking_minutes', required: true, includeIfNull: true)
  final int? cookingMinutes;

  @JsonKey(name: r'nutrition_per_serving', required: true, includeIfNull: true)
  final NutrientTotals? nutritionPerServing;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Recipe &&
            runtimeType == other.runtimeType &&
            equals(
              [
                id,
                name,
                cuisine,
                tags,
                dietTags,
                ingredients,
                instructions,
                cookedYieldG,
                servings,
                cookingMinutes,
                nutritionPerServing,
              ],
              [
                other.id,
                other.name,
                other.cuisine,
                other.tags,
                other.dietTags,
                other.ingredients,
                other.instructions,
                other.cookedYieldG,
                other.servings,
                other.cookingMinutes,
                other.nutritionPerServing,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        id,
        name,
        cuisine,
        tags,
        dietTags,
        ingredients,
        instructions,
        cookedYieldG,
        servings,
        cookingMinutes,
        nutritionPerServing,
      ]);

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
