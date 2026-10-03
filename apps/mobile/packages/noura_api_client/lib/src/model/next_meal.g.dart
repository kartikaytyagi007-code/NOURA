// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'next_meal.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NextMealCWProxy {
  NextMeal date(DateTime date);

  NextMeal slot(MealSlot slot);

  NextMeal loggedMeals(int loggedMeals);

  NextMeal limitedContext(bool limitedContext);

  NextMeal explanation(String? explanation);

  NextMeal options(List<NextMealOption> options);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NextMeal(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NextMeal(...).copyWith(id: 12, name: "My name")
  /// ````
  NextMeal call({
    DateTime date,
    MealSlot slot,
    int loggedMeals,
    bool limitedContext,
    String? explanation,
    List<NextMealOption> options,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNextMeal.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNextMeal.copyWith.fieldName(...)`
class _$NextMealCWProxyImpl implements _$NextMealCWProxy {
  const _$NextMealCWProxyImpl(this._value);

  final NextMeal _value;

  @override
  NextMeal date(DateTime date) => this(date: date);

  @override
  NextMeal slot(MealSlot slot) => this(slot: slot);

  @override
  NextMeal loggedMeals(int loggedMeals) => this(loggedMeals: loggedMeals);

  @override
  NextMeal limitedContext(bool limitedContext) =>
      this(limitedContext: limitedContext);

  @override
  NextMeal explanation(String? explanation) => this(explanation: explanation);

  @override
  NextMeal options(List<NextMealOption> options) => this(options: options);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NextMeal(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NextMeal(...).copyWith(id: 12, name: "My name")
  /// ````
  NextMeal call({
    Object? date = const $CopyWithPlaceholder(),
    Object? slot = const $CopyWithPlaceholder(),
    Object? loggedMeals = const $CopyWithPlaceholder(),
    Object? limitedContext = const $CopyWithPlaceholder(),
    Object? explanation = const $CopyWithPlaceholder(),
    Object? options = const $CopyWithPlaceholder(),
  }) {
    return NextMeal(
      date: date == const $CopyWithPlaceholder()
          ? _value.date
          // ignore: cast_nullable_to_non_nullable
          : date as DateTime,
      slot: slot == const $CopyWithPlaceholder()
          ? _value.slot
          // ignore: cast_nullable_to_non_nullable
          : slot as MealSlot,
      loggedMeals: loggedMeals == const $CopyWithPlaceholder()
          ? _value.loggedMeals
          // ignore: cast_nullable_to_non_nullable
          : loggedMeals as int,
      limitedContext: limitedContext == const $CopyWithPlaceholder()
          ? _value.limitedContext
          // ignore: cast_nullable_to_non_nullable
          : limitedContext as bool,
      explanation: explanation == const $CopyWithPlaceholder()
          ? _value.explanation
          // ignore: cast_nullable_to_non_nullable
          : explanation as String?,
      options: options == const $CopyWithPlaceholder()
          ? _value.options
          // ignore: cast_nullable_to_non_nullable
          : options as List<NextMealOption>,
    );
  }
}

extension $NextMealCopyWith on NextMeal {
  /// Returns a callable class that can be used as follows: `instanceOfNextMeal.copyWith(...)` or like so:`instanceOfNextMeal.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NextMealCWProxy get copyWith => _$NextMealCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NextMeal _$NextMealFromJson(Map<String, dynamic> json) => $checkedCreate(
  'NextMeal',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'date',
        'slot',
        'logged_meals',
        'limited_context',
        'explanation',
        'options',
      ],
    );
    final val = NextMeal(
      date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
      slot: $checkedConvert('slot', (v) => $enumDecode(_$MealSlotEnumMap, v)),
      loggedMeals: $checkedConvert('logged_meals', (v) => (v as num).toInt()),
      limitedContext: $checkedConvert('limited_context', (v) => v as bool),
      explanation: $checkedConvert('explanation', (v) => v as String?),
      options: $checkedConvert(
        'options',
        (v) => (v as List<dynamic>)
            .map((e) => NextMealOption.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'loggedMeals': 'logged_meals',
    'limitedContext': 'limited_context',
  },
);

Map<String, dynamic> _$NextMealToJson(NextMeal instance) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'slot': _$MealSlotEnumMap[instance.slot]!,
  'logged_meals': instance.loggedMeals,
  'limited_context': instance.limitedContext,
  'explanation': instance.explanation,
  'options': instance.options.map((e) => e.toJson()).toList(),
};

const _$MealSlotEnumMap = {
  MealSlot.breakfast: 'breakfast',
  MealSlot.lunch: 'lunch',
  MealSlot.dinner: 'dinner',
  MealSlot.snack: 'snack',
};
