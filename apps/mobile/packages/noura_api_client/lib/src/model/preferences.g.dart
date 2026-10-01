// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PreferencesCWProxy {
  Preferences dietType(DietType? dietType);

  Preferences allergyIds(List<String> allergyIds);

  Preferences exclusionIds(List<String> exclusionIds);

  Preferences dislikes(List<String> dislikes);

  Preferences cuisines(List<String> cuisines);

  Preferences budgetBand(BudgetBand? budgetBand);

  Preferences cookingTime(CookingTime? cookingTime);

  Preferences mealsPerDay(int? mealsPerDay);

  Preferences revision(int revision);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Preferences(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Preferences(...).copyWith(id: 12, name: "My name")
  /// ````
  Preferences call({
    DietType? dietType,
    List<String> allergyIds,
    List<String> exclusionIds,
    List<String> dislikes,
    List<String> cuisines,
    BudgetBand? budgetBand,
    CookingTime? cookingTime,
    int? mealsPerDay,
    int revision,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPreferences.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPreferences.copyWith.fieldName(...)`
class _$PreferencesCWProxyImpl implements _$PreferencesCWProxy {
  const _$PreferencesCWProxyImpl(this._value);

  final Preferences _value;

  @override
  Preferences dietType(DietType? dietType) => this(dietType: dietType);

  @override
  Preferences allergyIds(List<String> allergyIds) =>
      this(allergyIds: allergyIds);

  @override
  Preferences exclusionIds(List<String> exclusionIds) =>
      this(exclusionIds: exclusionIds);

  @override
  Preferences dislikes(List<String> dislikes) => this(dislikes: dislikes);

  @override
  Preferences cuisines(List<String> cuisines) => this(cuisines: cuisines);

  @override
  Preferences budgetBand(BudgetBand? budgetBand) =>
      this(budgetBand: budgetBand);

  @override
  Preferences cookingTime(CookingTime? cookingTime) =>
      this(cookingTime: cookingTime);

  @override
  Preferences mealsPerDay(int? mealsPerDay) => this(mealsPerDay: mealsPerDay);

  @override
  Preferences revision(int revision) => this(revision: revision);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Preferences(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Preferences(...).copyWith(id: 12, name: "My name")
  /// ````
  Preferences call({
    Object? dietType = const $CopyWithPlaceholder(),
    Object? allergyIds = const $CopyWithPlaceholder(),
    Object? exclusionIds = const $CopyWithPlaceholder(),
    Object? dislikes = const $CopyWithPlaceholder(),
    Object? cuisines = const $CopyWithPlaceholder(),
    Object? budgetBand = const $CopyWithPlaceholder(),
    Object? cookingTime = const $CopyWithPlaceholder(),
    Object? mealsPerDay = const $CopyWithPlaceholder(),
    Object? revision = const $CopyWithPlaceholder(),
  }) {
    return Preferences(
      dietType: dietType == const $CopyWithPlaceholder()
          ? _value.dietType
          // ignore: cast_nullable_to_non_nullable
          : dietType as DietType?,
      allergyIds: allergyIds == const $CopyWithPlaceholder()
          ? _value.allergyIds
          // ignore: cast_nullable_to_non_nullable
          : allergyIds as List<String>,
      exclusionIds: exclusionIds == const $CopyWithPlaceholder()
          ? _value.exclusionIds
          // ignore: cast_nullable_to_non_nullable
          : exclusionIds as List<String>,
      dislikes: dislikes == const $CopyWithPlaceholder()
          ? _value.dislikes
          // ignore: cast_nullable_to_non_nullable
          : dislikes as List<String>,
      cuisines: cuisines == const $CopyWithPlaceholder()
          ? _value.cuisines
          // ignore: cast_nullable_to_non_nullable
          : cuisines as List<String>,
      budgetBand: budgetBand == const $CopyWithPlaceholder()
          ? _value.budgetBand
          // ignore: cast_nullable_to_non_nullable
          : budgetBand as BudgetBand?,
      cookingTime: cookingTime == const $CopyWithPlaceholder()
          ? _value.cookingTime
          // ignore: cast_nullable_to_non_nullable
          : cookingTime as CookingTime?,
      mealsPerDay: mealsPerDay == const $CopyWithPlaceholder()
          ? _value.mealsPerDay
          // ignore: cast_nullable_to_non_nullable
          : mealsPerDay as int?,
      revision: revision == const $CopyWithPlaceholder()
          ? _value.revision
          // ignore: cast_nullable_to_non_nullable
          : revision as int,
    );
  }
}

extension $PreferencesCopyWith on Preferences {
  /// Returns a callable class that can be used as follows: `instanceOfPreferences.copyWith(...)` or like so:`instanceOfPreferences.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PreferencesCWProxy get copyWith => _$PreferencesCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Preferences _$PreferencesFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Preferences',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'diet_type',
        'allergy_ids',
        'exclusion_ids',
        'dislikes',
        'cuisines',
        'budget_band',
        'cooking_time',
        'meals_per_day',
        'revision',
      ],
    );
    final val = Preferences(
      dietType: $checkedConvert(
        'diet_type',
        (v) => $enumDecodeNullable(_$DietTypeEnumMap, v),
      ),
      allergyIds: $checkedConvert(
        'allergy_ids',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      exclusionIds: $checkedConvert(
        'exclusion_ids',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      dislikes: $checkedConvert(
        'dislikes',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      cuisines: $checkedConvert(
        'cuisines',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      budgetBand: $checkedConvert(
        'budget_band',
        (v) => $enumDecodeNullable(_$BudgetBandEnumMap, v),
      ),
      cookingTime: $checkedConvert(
        'cooking_time',
        (v) => $enumDecodeNullable(_$CookingTimeEnumMap, v),
      ),
      mealsPerDay: $checkedConvert(
        'meals_per_day',
        (v) => (v as num?)?.toInt(),
      ),
      revision: $checkedConvert('revision', (v) => (v as num).toInt()),
    );
    return val;
  },
  fieldKeyMap: const {
    'dietType': 'diet_type',
    'allergyIds': 'allergy_ids',
    'exclusionIds': 'exclusion_ids',
    'budgetBand': 'budget_band',
    'cookingTime': 'cooking_time',
    'mealsPerDay': 'meals_per_day',
  },
);

Map<String, dynamic> _$PreferencesToJson(Preferences instance) =>
    <String, dynamic>{
      'diet_type': _$DietTypeEnumMap[instance.dietType],
      'allergy_ids': instance.allergyIds,
      'exclusion_ids': instance.exclusionIds,
      'dislikes': instance.dislikes,
      'cuisines': instance.cuisines,
      'budget_band': _$BudgetBandEnumMap[instance.budgetBand],
      'cooking_time': _$CookingTimeEnumMap[instance.cookingTime],
      'meals_per_day': instance.mealsPerDay,
      'revision': instance.revision,
    };

const _$DietTypeEnumMap = {
  DietType.vegetarian: 'vegetarian',
  DietType.eggatarian: 'eggatarian',
  DietType.vegan: 'vegan',
  DietType.nonVegetarian: 'non_vegetarian',
};

const _$BudgetBandEnumMap = {
  BudgetBand.low: 'low',
  BudgetBand.medium: 'medium',
  BudgetBand.high: 'high',
};

const _$CookingTimeEnumMap = {
  CookingTime.minimal: 'minimal',
  CookingTime.moderate: 'moderate',
  CookingTime.flexible: 'flexible',
};
