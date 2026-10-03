// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RecipeCWProxy {
  Recipe id(String id);

  Recipe name(String name);

  Recipe cuisine(String? cuisine);

  Recipe tags(List<String> tags);

  Recipe dietTags(List<String> dietTags);

  Recipe ingredients(List<RecipeIngredient> ingredients);

  Recipe instructions(List<String> instructions);

  Recipe cookedYieldG(num? cookedYieldG);

  Recipe servings(int? servings);

  Recipe cookingMinutes(int? cookingMinutes);

  Recipe nutritionPerServing(NutrientTotals? nutritionPerServing);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Recipe(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Recipe(...).copyWith(id: 12, name: "My name")
  /// ````
  Recipe call({
    String id,
    String name,
    String? cuisine,
    List<String> tags,
    List<String> dietTags,
    List<RecipeIngredient> ingredients,
    List<String> instructions,
    num? cookedYieldG,
    int? servings,
    int? cookingMinutes,
    NutrientTotals? nutritionPerServing,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRecipe.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRecipe.copyWith.fieldName(...)`
class _$RecipeCWProxyImpl implements _$RecipeCWProxy {
  const _$RecipeCWProxyImpl(this._value);

  final Recipe _value;

  @override
  Recipe id(String id) => this(id: id);

  @override
  Recipe name(String name) => this(name: name);

  @override
  Recipe cuisine(String? cuisine) => this(cuisine: cuisine);

  @override
  Recipe tags(List<String> tags) => this(tags: tags);

  @override
  Recipe dietTags(List<String> dietTags) => this(dietTags: dietTags);

  @override
  Recipe ingredients(List<RecipeIngredient> ingredients) =>
      this(ingredients: ingredients);

  @override
  Recipe instructions(List<String> instructions) =>
      this(instructions: instructions);

  @override
  Recipe cookedYieldG(num? cookedYieldG) => this(cookedYieldG: cookedYieldG);

  @override
  Recipe servings(int? servings) => this(servings: servings);

  @override
  Recipe cookingMinutes(int? cookingMinutes) =>
      this(cookingMinutes: cookingMinutes);

  @override
  Recipe nutritionPerServing(NutrientTotals? nutritionPerServing) =>
      this(nutritionPerServing: nutritionPerServing);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Recipe(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Recipe(...).copyWith(id: 12, name: "My name")
  /// ````
  Recipe call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? cuisine = const $CopyWithPlaceholder(),
    Object? tags = const $CopyWithPlaceholder(),
    Object? dietTags = const $CopyWithPlaceholder(),
    Object? ingredients = const $CopyWithPlaceholder(),
    Object? instructions = const $CopyWithPlaceholder(),
    Object? cookedYieldG = const $CopyWithPlaceholder(),
    Object? servings = const $CopyWithPlaceholder(),
    Object? cookingMinutes = const $CopyWithPlaceholder(),
    Object? nutritionPerServing = const $CopyWithPlaceholder(),
  }) {
    return Recipe(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      cuisine: cuisine == const $CopyWithPlaceholder()
          ? _value.cuisine
          // ignore: cast_nullable_to_non_nullable
          : cuisine as String?,
      tags: tags == const $CopyWithPlaceholder()
          ? _value.tags
          // ignore: cast_nullable_to_non_nullable
          : tags as List<String>,
      dietTags: dietTags == const $CopyWithPlaceholder()
          ? _value.dietTags
          // ignore: cast_nullable_to_non_nullable
          : dietTags as List<String>,
      ingredients: ingredients == const $CopyWithPlaceholder()
          ? _value.ingredients
          // ignore: cast_nullable_to_non_nullable
          : ingredients as List<RecipeIngredient>,
      instructions: instructions == const $CopyWithPlaceholder()
          ? _value.instructions
          // ignore: cast_nullable_to_non_nullable
          : instructions as List<String>,
      cookedYieldG: cookedYieldG == const $CopyWithPlaceholder()
          ? _value.cookedYieldG
          // ignore: cast_nullable_to_non_nullable
          : cookedYieldG as num?,
      servings: servings == const $CopyWithPlaceholder()
          ? _value.servings
          // ignore: cast_nullable_to_non_nullable
          : servings as int?,
      cookingMinutes: cookingMinutes == const $CopyWithPlaceholder()
          ? _value.cookingMinutes
          // ignore: cast_nullable_to_non_nullable
          : cookingMinutes as int?,
      nutritionPerServing: nutritionPerServing == const $CopyWithPlaceholder()
          ? _value.nutritionPerServing
          // ignore: cast_nullable_to_non_nullable
          : nutritionPerServing as NutrientTotals?,
    );
  }
}

extension $RecipeCopyWith on Recipe {
  /// Returns a callable class that can be used as follows: `instanceOfRecipe.copyWith(...)` or like so:`instanceOfRecipe.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RecipeCWProxy get copyWith => _$RecipeCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recipe _$RecipeFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Recipe',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'name',
        'cuisine',
        'tags',
        'diet_tags',
        'ingredients',
        'instructions',
        'cooked_yield_g',
        'servings',
        'cooking_minutes',
        'nutrition_per_serving',
      ],
    );
    final val = Recipe(
      id: $checkedConvert('id', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      cuisine: $checkedConvert('cuisine', (v) => v as String?),
      tags: $checkedConvert(
        'tags',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      dietTags: $checkedConvert(
        'diet_tags',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      ingredients: $checkedConvert(
        'ingredients',
        (v) => (v as List<dynamic>)
            .map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      instructions: $checkedConvert(
        'instructions',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      cookedYieldG: $checkedConvert('cooked_yield_g', (v) => v as num?),
      servings: $checkedConvert('servings', (v) => (v as num?)?.toInt()),
      cookingMinutes: $checkedConvert(
        'cooking_minutes',
        (v) => (v as num?)?.toInt(),
      ),
      nutritionPerServing: $checkedConvert(
        'nutrition_per_serving',
        (v) => v == null
            ? null
            : NutrientTotals.fromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'dietTags': 'diet_tags',
    'cookedYieldG': 'cooked_yield_g',
    'cookingMinutes': 'cooking_minutes',
    'nutritionPerServing': 'nutrition_per_serving',
  },
);

Map<String, dynamic> _$RecipeToJson(Recipe instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'cuisine': instance.cuisine,
  'tags': instance.tags,
  'diet_tags': instance.dietTags,
  'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
  'instructions': instance.instructions,
  'cooked_yield_g': instance.cookedYieldG,
  'servings': instance.servings,
  'cooking_minutes': instance.cookingMinutes,
  'nutrition_per_serving': instance.nutritionPerServing?.toJson(),
};
