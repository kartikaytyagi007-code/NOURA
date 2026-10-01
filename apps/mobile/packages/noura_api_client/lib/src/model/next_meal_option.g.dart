// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'next_meal_option.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NextMealOptionCWProxy {
  NextMealOption recipe(RecipeRef recipe);

  NextMealOption portions(List<PortionRef> portions);

  NextMealOption nutrition(NutrientTotals nutrition);

  NextMealOption reason(String reason);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NextMealOption(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NextMealOption(...).copyWith(id: 12, name: "My name")
  /// ````
  NextMealOption call({
    RecipeRef recipe,
    List<PortionRef> portions,
    NutrientTotals nutrition,
    String reason,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNextMealOption.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNextMealOption.copyWith.fieldName(...)`
class _$NextMealOptionCWProxyImpl implements _$NextMealOptionCWProxy {
  const _$NextMealOptionCWProxyImpl(this._value);

  final NextMealOption _value;

  @override
  NextMealOption recipe(RecipeRef recipe) => this(recipe: recipe);

  @override
  NextMealOption portions(List<PortionRef> portions) =>
      this(portions: portions);

  @override
  NextMealOption nutrition(NutrientTotals nutrition) =>
      this(nutrition: nutrition);

  @override
  NextMealOption reason(String reason) => this(reason: reason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NextMealOption(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NextMealOption(...).copyWith(id: 12, name: "My name")
  /// ````
  NextMealOption call({
    Object? recipe = const $CopyWithPlaceholder(),
    Object? portions = const $CopyWithPlaceholder(),
    Object? nutrition = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
  }) {
    return NextMealOption(
      recipe: recipe == const $CopyWithPlaceholder()
          ? _value.recipe
          // ignore: cast_nullable_to_non_nullable
          : recipe as RecipeRef,
      portions: portions == const $CopyWithPlaceholder()
          ? _value.portions
          // ignore: cast_nullable_to_non_nullable
          : portions as List<PortionRef>,
      nutrition: nutrition == const $CopyWithPlaceholder()
          ? _value.nutrition
          // ignore: cast_nullable_to_non_nullable
          : nutrition as NutrientTotals,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String,
    );
  }
}

extension $NextMealOptionCopyWith on NextMealOption {
  /// Returns a callable class that can be used as follows: `instanceOfNextMealOption.copyWith(...)` or like so:`instanceOfNextMealOption.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NextMealOptionCWProxy get copyWith => _$NextMealOptionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NextMealOption _$NextMealOptionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('NextMealOption', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['recipe', 'portions', 'nutrition', 'reason'],
      );
      final val = NextMealOption(
        recipe: $checkedConvert(
          'recipe',
          (v) => RecipeRef.fromJson(v as Map<String, dynamic>),
        ),
        portions: $checkedConvert(
          'portions',
          (v) => (v as List<dynamic>)
              .map((e) => PortionRef.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        nutrition: $checkedConvert(
          'nutrition',
          (v) => NutrientTotals.fromJson(v as Map<String, dynamic>),
        ),
        reason: $checkedConvert('reason', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$NextMealOptionToJson(NextMealOption instance) =>
    <String, dynamic>{
      'recipe': instance.recipe.toJson(),
      'portions': instance.portions.map((e) => e.toJson()).toList(),
      'nutrition': instance.nutrition.toJson(),
      'reason': instance.reason,
    };
