// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PreferencesInputCWProxy {
  PreferencesInput expectedRevision(int expectedRevision);

  PreferencesInput dietType(DietType dietType);

  PreferencesInput allergyIds(Set<AllergyTag> allergyIds);

  PreferencesInput exclusionIds(Set<ExclusionTag> exclusionIds);

  PreferencesInput dislikes(Set<String>? dislikes);

  PreferencesInput cuisines(Set<CuisineTag> cuisines);

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
    Set<AllergyTag> allergyIds,
    Set<ExclusionTag> exclusionIds,
    Set<String>? dislikes,
    Set<CuisineTag> cuisines,
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
  PreferencesInput allergyIds(Set<AllergyTag> allergyIds) =>
      this(allergyIds: allergyIds);

  @override
  PreferencesInput exclusionIds(Set<ExclusionTag> exclusionIds) =>
      this(exclusionIds: exclusionIds);

  @override
  PreferencesInput dislikes(Set<String>? dislikes) => this(dislikes: dislikes);

  @override
  PreferencesInput cuisines(Set<CuisineTag> cuisines) =>
      this(cuisines: cuisines);

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
          : allergyIds as Set<AllergyTag>,
      exclusionIds: exclusionIds == const $CopyWithPlaceholder()
          ? _value.exclusionIds
          // ignore: cast_nullable_to_non_nullable
          : exclusionIds as Set<ExclusionTag>,
      dislikes: dislikes == const $CopyWithPlaceholder()
          ? _value.dislikes
          // ignore: cast_nullable_to_non_nullable
          : dislikes as Set<String>?,
      cuisines: cuisines == const $CopyWithPlaceholder()
          ? _value.cuisines
          // ignore: cast_nullable_to_non_nullable
          : cuisines as Set<CuisineTag>,
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
            (v) => (v as List<dynamic>)
                .map((e) => $enumDecode(_$AllergyTagEnumMap, e))
                .toSet(),
          ),
          exclusionIds: $checkedConvert(
            'exclusion_ids',
            (v) => (v as List<dynamic>)
                .map((e) => $enumDecode(_$ExclusionTagEnumMap, e))
                .toSet(),
          ),
          dislikes: $checkedConvert(
            'dislikes',
            (v) => (v as List<dynamic>?)?.map((e) => e as String).toSet(),
          ),
          cuisines: $checkedConvert(
            'cuisines',
            (v) => (v as List<dynamic>)
                .map((e) => $enumDecode(_$CuisineTagEnumMap, e))
                .toSet(),
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

Map<String, dynamic> _$PreferencesInputToJson(
  PreferencesInput instance,
) => <String, dynamic>{
  'expected_revision': instance.expectedRevision,
  'diet_type': _$DietTypeEnumMap[instance.dietType]!,
  'allergy_ids': instance.allergyIds
      .map((e) => _$AllergyTagEnumMap[e]!)
      .toList(),
  'exclusion_ids': instance.exclusionIds
      .map((e) => _$ExclusionTagEnumMap[e]!)
      .toList(),
  'dislikes': ?instance.dislikes?.toList(),
  'cuisines': instance.cuisines.map((e) => _$CuisineTagEnumMap[e]!).toList(),
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

const _$AllergyTagEnumMap = {
  AllergyTag.gluten: 'gluten',
  AllergyTag.crustacean: 'crustacean',
  AllergyTag.milk: 'milk',
  AllergyTag.egg: 'egg',
  AllergyTag.fish: 'fish',
  AllergyTag.peanut: 'peanut',
  AllergyTag.treeNut: 'tree_nut',
  AllergyTag.soy: 'soy',
  AllergyTag.sesame: 'sesame',
};

const _$ExclusionTagEnumMap = {
  ExclusionTag.beef: 'beef',
  ExclusionTag.pork: 'pork',
  ExclusionTag.mutton: 'mutton',
  ExclusionTag.chicken: 'chicken',
  ExclusionTag.seafood: 'seafood',
  ExclusionTag.onionGarlic: 'onion_garlic',
  ExclusionTag.rootVegetables: 'root_vegetables',
  ExclusionTag.mushroom: 'mushroom',
  ExclusionTag.alcohol: 'alcohol',
};

const _$CuisineTagEnumMap = {
  CuisineTag.northIndian: 'north_indian',
  CuisineTag.southIndian: 'south_indian',
  CuisineTag.eastIndian: 'east_indian',
  CuisineTag.westIndian: 'west_indian',
  CuisineTag.indoChinese: 'indo_chinese',
  CuisineTag.continental: 'continental',
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
