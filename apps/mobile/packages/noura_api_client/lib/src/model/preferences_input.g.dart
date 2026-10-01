// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PreferencesInputCWProxy {
  PreferencesInput expectedRevision(int expectedRevision);

  PreferencesInput dietType(DietType dietType);

  PreferencesInput allergyIds(Set<String> allergyIds);

  PreferencesInput exclusionIds(Set<String> exclusionIds);

  PreferencesInput dislikes(Set<String>? dislikes);

  PreferencesInput cuisines(Set<String> cuisines);

  PreferencesInput budgetBand(BudgetBand budgetBand);

  PreferencesInput cookingTime(CookingTime cookingTime);

  PreferencesInput mealsPerDay(int mealsPerDay);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PreferencesInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PreferencesInput(...).copyWith(id: 12, name: "My name")
  /// ````
  PreferencesInput call({
    int expectedRevision,
    DietType dietType,
    Set<String> allergyIds,
    Set<String> exclusionIds,
    Set<String>? dislikes,
    Set<String> cuisines,
    BudgetBand budgetBand,
    CookingTime cookingTime,
    int mealsPerDay,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPreferencesInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPreferencesInput.copyWith.fieldName(...)`
class _$PreferencesInputCWProxyImpl implements _$PreferencesInputCWProxy {
  const _$PreferencesInputCWProxyImpl(this._value);

  final PreferencesInput _value;

  @override
  PreferencesInput expectedRevision(int expectedRevision) =>
      this(expectedRevision: expectedRevision);

  @override
  PreferencesInput dietType(DietType dietType) => this(dietType: dietType);

  @override
  PreferencesInput allergyIds(Set<String> allergyIds) =>
      this(allergyIds: allergyIds);

  @override
  PreferencesInput exclusionIds(Set<String> exclusionIds) =>
      this(exclusionIds: exclusionIds);

  @override
  PreferencesInput dislikes(Set<String>? dislikes) => this(dislikes: dislikes);

  @override
  PreferencesInput cuisines(Set<String> cuisines) => this(cuisines: cuisines);

  @override
  PreferencesInput budgetBand(BudgetBand budgetBand) =>
      this(budgetBand: budgetBand);

  @override
  PreferencesInput cookingTime(CookingTime cookingTime) =>
      this(cookingTime: cookingTime);

  @override
  PreferencesInput mealsPerDay(int mealsPerDay) =>
      this(mealsPerDay: mealsPerDay);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PreferencesInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PreferencesInput(...).copyWith(id: 12, name: "My name")
  /// ````
  PreferencesInput call({
    Object? expectedRevision = const $CopyWithPlaceholder(),
    Object? dietType = const $CopyWithPlaceholder(),
    Object? allergyIds = const $CopyWithPlaceholder(),
    Object? exclusionIds = const $CopyWithPlaceholder(),
    Object? dislikes = const $CopyWithPlaceholder(),
    Object? cuisines = const $CopyWithPlaceholder(),
    Object? budgetBand = const $CopyWithPlaceholder(),
    Object? cookingTime = const $CopyWithPlaceholder(),
    Object? mealsPerDay = const $CopyWithPlaceholder(),
  }) {
    return PreferencesInput(
      expectedRevision: expectedRevision == const $CopyWithPlaceholder()
          ? _value.expectedRevision
          // ignore: cast_nullable_to_non_nullable
          : expectedRevision as int,
      dietType: dietType == const $CopyWithPlaceholder()
          ? _value.dietType
          // ignore: cast_nullable_to_non_nullable
          : dietType as DietType,
      allergyIds: allergyIds == const $CopyWithPlaceholder()
          ? _value.allergyIds
          // ignore: cast_nullable_to_non_nullable
          : allergyIds as Set<String>,
      exclusionIds: exclusionIds == const $CopyWithPlaceholder()
          ? _value.exclusionIds
          // ignore: cast_nullable_to_non_nullable
          : exclusionIds as Set<String>,
      dislikes: dislikes == const $CopyWithPlaceholder()
          ? _value.dislikes
          // ignore: cast_nullable_to_non_nullable
          : dislikes as Set<String>?,
      cuisines: cuisines == const $CopyWithPlaceholder()
          ? _value.cuisines
          // ignore: cast_nullable_to_non_nullable
          : cuisines as Set<String>,
      budgetBand: budgetBand == const $CopyWithPlaceholder()
          ? _value.budgetBand
          // ignore: cast_nullable_to_non_nullable
          : budgetBand as BudgetBand,
      cookingTime: cookingTime == const $CopyWithPlaceholder()
          ? _value.cookingTime
          // ignore: cast_nullable_to_non_nullable
          : cookingTime as CookingTime,
      mealsPerDay: mealsPerDay == const $CopyWithPlaceholder()
          ? _value.mealsPerDay
          // ignore: cast_nullable_to_non_nullable
          : mealsPerDay as int,
    );
  }
}

extension $PreferencesInputCopyWith on PreferencesInput {
  /// Returns a callable class that can be used as follows: `instanceOfPreferencesInput.copyWith(...)` or like so:`instanceOfPreferencesInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PreferencesInputCWProxy get copyWith => _$PreferencesInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreferencesInput _$PreferencesInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PreferencesInput',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'expected_revision',
            'diet_type',
            'allergy_ids',
            'exclusion_ids',
            'cuisines',
            'budget_band',
            'cooking_time',
            'meals_per_day',
          ],
        );
        final val = PreferencesInput(
          expectedRevision: $checkedConvert(
            'expected_revision',
            (v) => (v as num).toInt(),
          ),
          dietType: $checkedConvert(
            'diet_type',
            (v) => $enumDecode(_$DietTypeEnumMap, v),
          ),
          allergyIds: $checkedConvert(
            'allergy_ids',
            (v) => (v as List<dynamic>).map((e) => e as String).toSet(),
          ),
          exclusionIds: $checkedConvert(
            'exclusion_ids',
            (v) => (v as List<dynamic>).map((e) => e as String).toSet(),
          ),
          dislikes: $checkedConvert(
            'dislikes',
            (v) => (v as List<dynamic>?)?.map((e) => e as String).toSet(),
          ),
          cuisines: $checkedConvert(
            'cuisines',
            (v) => (v as List<dynamic>).map((e) => e as String).toSet(),
          ),
          budgetBand: $checkedConvert(
            'budget_band',
            (v) => $enumDecode(_$BudgetBandEnumMap, v),
          ),
          cookingTime: $checkedConvert(
            'cooking_time',
            (v) => $enumDecode(_$CookingTimeEnumMap, v),
          ),
          mealsPerDay: $checkedConvert(
            'meals_per_day',
            (v) => (v as num).toInt(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'expectedRevision': 'expected_revision',
        'dietType': 'diet_type',
        'allergyIds': 'allergy_ids',
        'exclusionIds': 'exclusion_ids',
        'budgetBand': 'budget_band',
        'cookingTime': 'cooking_time',
        'mealsPerDay': 'meals_per_day',
      },
    );

Map<String, dynamic> _$PreferencesInputToJson(PreferencesInput instance) =>
    <String, dynamic>{
      'expected_revision': instance.expectedRevision,
      'diet_type': _$DietTypeEnumMap[instance.dietType]!,
      'allergy_ids': instance.allergyIds.toList(),
      'exclusion_ids': instance.exclusionIds.toList(),
      'dislikes': ?instance.dislikes?.toList(),
      'cuisines': instance.cuisines.toList(),
      'budget_band': _$BudgetBandEnumMap[instance.budgetBand]!,
      'cooking_time': _$CookingTimeEnumMap[instance.cookingTime]!,
      'meals_per_day': instance.mealsPerDay,
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
