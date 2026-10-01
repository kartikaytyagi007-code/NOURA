// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_day.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PlanDayCWProxy {
  PlanDay date(DateTime date);

  PlanDay meals(List<PlanMeal> meals);

  PlanDay totals(NutrientTotals totals);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlanDay(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlanDay(...).copyWith(id: 12, name: "My name")
  /// ````
  PlanDay call({DateTime date, List<PlanMeal> meals, NutrientTotals totals});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPlanDay.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPlanDay.copyWith.fieldName(...)`
class _$PlanDayCWProxyImpl implements _$PlanDayCWProxy {
  const _$PlanDayCWProxyImpl(this._value);

  final PlanDay _value;

  @override
  PlanDay date(DateTime date) => this(date: date);

  @override
  PlanDay meals(List<PlanMeal> meals) => this(meals: meals);

  @override
  PlanDay totals(NutrientTotals totals) => this(totals: totals);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlanDay(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlanDay(...).copyWith(id: 12, name: "My name")
  /// ````
  PlanDay call({
    Object? date = const $CopyWithPlaceholder(),
    Object? meals = const $CopyWithPlaceholder(),
    Object? totals = const $CopyWithPlaceholder(),
  }) {
    return PlanDay(
      date: date == const $CopyWithPlaceholder()
          ? _value.date
          // ignore: cast_nullable_to_non_nullable
          : date as DateTime,
      meals: meals == const $CopyWithPlaceholder()
          ? _value.meals
          // ignore: cast_nullable_to_non_nullable
          : meals as List<PlanMeal>,
      totals: totals == const $CopyWithPlaceholder()
          ? _value.totals
          // ignore: cast_nullable_to_non_nullable
          : totals as NutrientTotals,
    );
  }
}

extension $PlanDayCopyWith on PlanDay {
  /// Returns a callable class that can be used as follows: `instanceOfPlanDay.copyWith(...)` or like so:`instanceOfPlanDay.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PlanDayCWProxy get copyWith => _$PlanDayCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlanDay _$PlanDayFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PlanDay', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['date', 'meals', 'totals']);
      final val = PlanDay(
        date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
        meals: $checkedConvert(
          'meals',
          (v) => (v as List<dynamic>)
              .map((e) => PlanMeal.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        totals: $checkedConvert(
          'totals',
          (v) => NutrientTotals.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PlanDayToJson(PlanDay instance) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'meals': instance.meals.map((e) => e.toJson()).toList(),
  'totals': instance.totals.toJson(),
};
