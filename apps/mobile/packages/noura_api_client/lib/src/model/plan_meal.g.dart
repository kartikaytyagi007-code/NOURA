// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_meal.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PlanMealCWProxy {
  PlanMeal id(String id);

  PlanMeal date(DateTime date);

  PlanMeal slot(MealSlot slot);

  PlanMeal slotOrdinal(int slotOrdinal);

  PlanMeal recipe(RecipeRef? recipe);

  PlanMeal portions(List<PortionRef> portions);

  PlanMeal nutrition(NutrientTotals nutrition);

  PlanMeal revision(int revision);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlanMeal(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlanMeal(...).copyWith(id: 12, name: "My name")
  /// ````
  PlanMeal call({
    String id,
    DateTime date,
    MealSlot slot,
    int slotOrdinal,
    RecipeRef? recipe,
    List<PortionRef> portions,
    NutrientTotals nutrition,
    int revision,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPlanMeal.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPlanMeal.copyWith.fieldName(...)`
class _$PlanMealCWProxyImpl implements _$PlanMealCWProxy {
  const _$PlanMealCWProxyImpl(this._value);

  final PlanMeal _value;

  @override
  PlanMeal id(String id) => this(id: id);

  @override
  PlanMeal date(DateTime date) => this(date: date);

  @override
  PlanMeal slot(MealSlot slot) => this(slot: slot);

  @override
  PlanMeal slotOrdinal(int slotOrdinal) => this(slotOrdinal: slotOrdinal);

  @override
  PlanMeal recipe(RecipeRef? recipe) => this(recipe: recipe);

  @override
  PlanMeal portions(List<PortionRef> portions) => this(portions: portions);

  @override
  PlanMeal nutrition(NutrientTotals nutrition) => this(nutrition: nutrition);

  @override
  PlanMeal revision(int revision) => this(revision: revision);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlanMeal(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlanMeal(...).copyWith(id: 12, name: "My name")
  /// ````
  PlanMeal call({
    Object? id = const $CopyWithPlaceholder(),
    Object? date = const $CopyWithPlaceholder(),
    Object? slot = const $CopyWithPlaceholder(),
    Object? slotOrdinal = const $CopyWithPlaceholder(),
    Object? recipe = const $CopyWithPlaceholder(),
    Object? portions = const $CopyWithPlaceholder(),
    Object? nutrition = const $CopyWithPlaceholder(),
    Object? revision = const $CopyWithPlaceholder(),
  }) {
    return PlanMeal(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      date: date == const $CopyWithPlaceholder()
          ? _value.date
          // ignore: cast_nullable_to_non_nullable
          : date as DateTime,
      slot: slot == const $CopyWithPlaceholder()
          ? _value.slot
          // ignore: cast_nullable_to_non_nullable
          : slot as MealSlot,
      slotOrdinal: slotOrdinal == const $CopyWithPlaceholder()
          ? _value.slotOrdinal
          // ignore: cast_nullable_to_non_nullable
          : slotOrdinal as int,
      recipe: recipe == const $CopyWithPlaceholder()
          ? _value.recipe
          // ignore: cast_nullable_to_non_nullable
          : recipe as RecipeRef?,
      portions: portions == const $CopyWithPlaceholder()
          ? _value.portions
          // ignore: cast_nullable_to_non_nullable
          : portions as List<PortionRef>,
      nutrition: nutrition == const $CopyWithPlaceholder()
          ? _value.nutrition
          // ignore: cast_nullable_to_non_nullable
          : nutrition as NutrientTotals,
      revision: revision == const $CopyWithPlaceholder()
          ? _value.revision
          // ignore: cast_nullable_to_non_nullable
          : revision as int,
    );
  }
}

extension $PlanMealCopyWith on PlanMeal {
  /// Returns a callable class that can be used as follows: `instanceOfPlanMeal.copyWith(...)` or like so:`instanceOfPlanMeal.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PlanMealCWProxy get copyWith => _$PlanMealCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlanMeal _$PlanMealFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PlanMeal', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'date',
          'slot',
          'slot_ordinal',
          'recipe',
          'portions',
          'nutrition',
          'revision',
        ],
      );
      final val = PlanMeal(
        id: $checkedConvert('id', (v) => v as String),
        date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
        slot: $checkedConvert('slot', (v) => $enumDecode(_$MealSlotEnumMap, v)),
        slotOrdinal: $checkedConvert('slot_ordinal', (v) => (v as num).toInt()),
        recipe: $checkedConvert(
          'recipe',
          (v) =>
              v == null ? null : RecipeRef.fromJson(v as Map<String, dynamic>),
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
        revision: $checkedConvert('revision', (v) => (v as num).toInt()),
      );
      return val;
    }, fieldKeyMap: const {'slotOrdinal': 'slot_ordinal'});

Map<String, dynamic> _$PlanMealToJson(PlanMeal instance) => <String, dynamic>{
  'id': instance.id,
  'date': instance.date.toIso8601String(),
  'slot': _$MealSlotEnumMap[instance.slot]!,
  'slot_ordinal': instance.slotOrdinal,
  'recipe': instance.recipe?.toJson(),
  'portions': instance.portions.map((e) => e.toJson()).toList(),
  'nutrition': instance.nutrition.toJson(),
  'revision': instance.revision,
};

const _$MealSlotEnumMap = {
  MealSlot.breakfast: 'breakfast',
  MealSlot.lunch: 'lunch',
  MealSlot.dinner: 'dinner',
  MealSlot.snack: 'snack',
};
