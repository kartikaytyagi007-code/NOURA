// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'after_changes_scenario.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AfterChangesScenarioCWProxy {
  AfterChangesScenario totals(NutrientTotals totals);

  AfterChangesScenario mealBalance(MealBalance mealBalance);

  AfterChangesScenario assumptions(List<String> assumptions);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AfterChangesScenario(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AfterChangesScenario(...).copyWith(id: 12, name: "My name")
  /// ````
  AfterChangesScenario call({
    NutrientTotals totals,
    MealBalance mealBalance,
    List<String> assumptions,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAfterChangesScenario.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAfterChangesScenario.copyWith.fieldName(...)`
class _$AfterChangesScenarioCWProxyImpl
    implements _$AfterChangesScenarioCWProxy {
  const _$AfterChangesScenarioCWProxyImpl(this._value);

  final AfterChangesScenario _value;

  @override
  AfterChangesScenario totals(NutrientTotals totals) => this(totals: totals);

  @override
  AfterChangesScenario mealBalance(MealBalance mealBalance) =>
      this(mealBalance: mealBalance);

  @override
  AfterChangesScenario assumptions(List<String> assumptions) =>
      this(assumptions: assumptions);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AfterChangesScenario(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AfterChangesScenario(...).copyWith(id: 12, name: "My name")
  /// ````
  AfterChangesScenario call({
    Object? totals = const $CopyWithPlaceholder(),
    Object? mealBalance = const $CopyWithPlaceholder(),
    Object? assumptions = const $CopyWithPlaceholder(),
  }) {
    return AfterChangesScenario(
      totals: totals == const $CopyWithPlaceholder()
          ? _value.totals
          // ignore: cast_nullable_to_non_nullable
          : totals as NutrientTotals,
      mealBalance: mealBalance == const $CopyWithPlaceholder()
          ? _value.mealBalance
          // ignore: cast_nullable_to_non_nullable
          : mealBalance as MealBalance,
      assumptions: assumptions == const $CopyWithPlaceholder()
          ? _value.assumptions
          // ignore: cast_nullable_to_non_nullable
          : assumptions as List<String>,
    );
  }
}

extension $AfterChangesScenarioCopyWith on AfterChangesScenario {
  /// Returns a callable class that can be used as follows: `instanceOfAfterChangesScenario.copyWith(...)` or like so:`instanceOfAfterChangesScenario.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AfterChangesScenarioCWProxy get copyWith =>
      _$AfterChangesScenarioCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AfterChangesScenario _$AfterChangesScenarioFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AfterChangesScenario', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['totals', 'meal_balance', 'assumptions'],
  );
  final val = AfterChangesScenario(
    totals: $checkedConvert(
      'totals',
      (v) => NutrientTotals.fromJson(v as Map<String, dynamic>),
    ),
    mealBalance: $checkedConvert(
      'meal_balance',
      (v) => MealBalance.fromJson(v as Map<String, dynamic>),
    ),
    assumptions: $checkedConvert(
      'assumptions',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
  );
  return val;
}, fieldKeyMap: const {'mealBalance': 'meal_balance'});

Map<String, dynamic> _$AfterChangesScenarioToJson(
  AfterChangesScenario instance,
) => <String, dynamic>{
  'totals': instance.totals.toJson(),
  'meal_balance': instance.mealBalance.toJson(),
  'assumptions': instance.assumptions,
};
