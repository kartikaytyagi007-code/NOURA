// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HomeCWProxy {
  Home date(DateTime date);

  Home nutrition(NutrientTotals nutrition);

  Home nextMeal(PlanMealPreview? nextMeal);

  Home todaysWorkout(WorkoutSessionPreview? todaysWorkout);

  Home insight(InsightSummary? insight);

  Home planGeneration(Job? planGeneration);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Home(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Home(...).copyWith(id: 12, name: "My name")
  /// ````
  Home call({
    DateTime date,
    NutrientTotals nutrition,
    PlanMealPreview? nextMeal,
    WorkoutSessionPreview? todaysWorkout,
    InsightSummary? insight,
    Job? planGeneration,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHome.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHome.copyWith.fieldName(...)`
class _$HomeCWProxyImpl implements _$HomeCWProxy {
  const _$HomeCWProxyImpl(this._value);

  final Home _value;

  @override
  Home date(DateTime date) => this(date: date);

  @override
  Home nutrition(NutrientTotals nutrition) => this(nutrition: nutrition);

  @override
  Home nextMeal(PlanMealPreview? nextMeal) => this(nextMeal: nextMeal);

  @override
  Home todaysWorkout(WorkoutSessionPreview? todaysWorkout) =>
      this(todaysWorkout: todaysWorkout);

  @override
  Home insight(InsightSummary? insight) => this(insight: insight);

  @override
  Home planGeneration(Job? planGeneration) =>
      this(planGeneration: planGeneration);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Home(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Home(...).copyWith(id: 12, name: "My name")
  /// ````
  Home call({
    Object? date = const $CopyWithPlaceholder(),
    Object? nutrition = const $CopyWithPlaceholder(),
    Object? nextMeal = const $CopyWithPlaceholder(),
    Object? todaysWorkout = const $CopyWithPlaceholder(),
    Object? insight = const $CopyWithPlaceholder(),
    Object? planGeneration = const $CopyWithPlaceholder(),
  }) {
    return Home(
      date: date == const $CopyWithPlaceholder()
          ? _value.date
          // ignore: cast_nullable_to_non_nullable
          : date as DateTime,
      nutrition: nutrition == const $CopyWithPlaceholder()
          ? _value.nutrition
          // ignore: cast_nullable_to_non_nullable
          : nutrition as NutrientTotals,
      nextMeal: nextMeal == const $CopyWithPlaceholder()
          ? _value.nextMeal
          // ignore: cast_nullable_to_non_nullable
          : nextMeal as PlanMealPreview?,
      todaysWorkout: todaysWorkout == const $CopyWithPlaceholder()
          ? _value.todaysWorkout
          // ignore: cast_nullable_to_non_nullable
          : todaysWorkout as WorkoutSessionPreview?,
      insight: insight == const $CopyWithPlaceholder()
          ? _value.insight
          // ignore: cast_nullable_to_non_nullable
          : insight as InsightSummary?,
      planGeneration: planGeneration == const $CopyWithPlaceholder()
          ? _value.planGeneration
          // ignore: cast_nullable_to_non_nullable
          : planGeneration as Job?,
    );
  }
}

extension $HomeCopyWith on Home {
  /// Returns a callable class that can be used as follows: `instanceOfHome.copyWith(...)` or like so:`instanceOfHome.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HomeCWProxy get copyWith => _$HomeCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Home _$HomeFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Home',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'date',
        'nutrition',
        'next_meal',
        'todays_workout',
        'insight',
        'plan_generation',
      ],
    );
    final val = Home(
      date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
      nutrition: $checkedConvert(
        'nutrition',
        (v) => NutrientTotals.fromJson(v as Map<String, dynamic>),
      ),
      nextMeal: $checkedConvert(
        'next_meal',
        (v) => v == null
            ? null
            : PlanMealPreview.fromJson(v as Map<String, dynamic>),
      ),
      todaysWorkout: $checkedConvert(
        'todays_workout',
        (v) => v == null
            ? null
            : WorkoutSessionPreview.fromJson(v as Map<String, dynamic>),
      ),
      insight: $checkedConvert(
        'insight',
        (v) => v == null
            ? null
            : InsightSummary.fromJson(v as Map<String, dynamic>),
      ),
      planGeneration: $checkedConvert(
        'plan_generation',
        (v) => v == null ? null : Job.fromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'nextMeal': 'next_meal',
    'todaysWorkout': 'todays_workout',
    'planGeneration': 'plan_generation',
  },
);

Map<String, dynamic> _$HomeToJson(Home instance) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'nutrition': instance.nutrition.toJson(),
  'next_meal': instance.nextMeal?.toJson(),
  'todays_workout': instance.todaysWorkout?.toJson(),
  'insight': instance.insight?.toJson(),
  'plan_generation': instance.planGeneration?.toJson(),
};
