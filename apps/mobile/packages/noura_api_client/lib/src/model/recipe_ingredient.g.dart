// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_ingredient.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RecipeIngredientCWProxy {
  RecipeIngredient foodId(String foodId);

  RecipeIngredient name(String name);

  RecipeIngredient edibleGrams(num edibleGrams);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RecipeIngredient(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RecipeIngredient(...).copyWith(id: 12, name: "My name")
  /// ````
  RecipeIngredient call({String foodId, String name, num edibleGrams});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRecipeIngredient.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRecipeIngredient.copyWith.fieldName(...)`
class _$RecipeIngredientCWProxyImpl implements _$RecipeIngredientCWProxy {
  const _$RecipeIngredientCWProxyImpl(this._value);

  final RecipeIngredient _value;

  @override
  RecipeIngredient foodId(String foodId) => this(foodId: foodId);

  @override
  RecipeIngredient name(String name) => this(name: name);

  @override
  RecipeIngredient edibleGrams(num edibleGrams) =>
      this(edibleGrams: edibleGrams);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RecipeIngredient(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RecipeIngredient(...).copyWith(id: 12, name: "My name")
  /// ````
  RecipeIngredient call({
    Object? foodId = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? edibleGrams = const $CopyWithPlaceholder(),
  }) {
    return RecipeIngredient(
      foodId: foodId == const $CopyWithPlaceholder()
          ? _value.foodId
          // ignore: cast_nullable_to_non_nullable
          : foodId as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      edibleGrams: edibleGrams == const $CopyWithPlaceholder()
          ? _value.edibleGrams
          // ignore: cast_nullable_to_non_nullable
          : edibleGrams as num,
    );
  }
}

extension $RecipeIngredientCopyWith on RecipeIngredient {
  /// Returns a callable class that can be used as follows: `instanceOfRecipeIngredient.copyWith(...)` or like so:`instanceOfRecipeIngredient.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RecipeIngredientCWProxy get copyWith => _$RecipeIngredientCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeIngredient _$RecipeIngredientFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RecipeIngredient', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['food_id', 'name', 'edible_grams']);
      final val = RecipeIngredient(
        foodId: $checkedConvert('food_id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        edibleGrams: $checkedConvert('edible_grams', (v) => v as num),
      );
      return val;
    }, fieldKeyMap: const {'foodId': 'food_id', 'edibleGrams': 'edible_grams'});

Map<String, dynamic> _$RecipeIngredientToJson(RecipeIngredient instance) =>
    <String, dynamic>{
      'food_id': instance.foodId,
      'name': instance.name,
      'edible_grams': instance.edibleGrams,
    };
