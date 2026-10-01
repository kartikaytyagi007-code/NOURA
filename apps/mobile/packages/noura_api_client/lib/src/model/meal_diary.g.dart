// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_diary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MealDiaryCWProxy {
  MealDiary date(DateTime date);

  MealDiary logs(List<MealLog> logs);

  MealDiary totals(NutrientTotals totals);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealDiary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealDiary(...).copyWith(id: 12, name: "My name")
  /// ````
  MealDiary call({DateTime date, List<MealLog> logs, NutrientTotals totals});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMealDiary.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMealDiary.copyWith.fieldName(...)`
class _$MealDiaryCWProxyImpl implements _$MealDiaryCWProxy {
  const _$MealDiaryCWProxyImpl(this._value);

  final MealDiary _value;

  @override
  MealDiary date(DateTime date) => this(date: date);

  @override
  MealDiary logs(List<MealLog> logs) => this(logs: logs);

  @override
  MealDiary totals(NutrientTotals totals) => this(totals: totals);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealDiary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealDiary(...).copyWith(id: 12, name: "My name")
  /// ````
  MealDiary call({
    Object? date = const $CopyWithPlaceholder(),
    Object? logs = const $CopyWithPlaceholder(),
    Object? totals = const $CopyWithPlaceholder(),
  }) {
    return MealDiary(
      date: date == const $CopyWithPlaceholder()
          ? _value.date
          // ignore: cast_nullable_to_non_nullable
          : date as DateTime,
      logs: logs == const $CopyWithPlaceholder()
          ? _value.logs
          // ignore: cast_nullable_to_non_nullable
          : logs as List<MealLog>,
      totals: totals == const $CopyWithPlaceholder()
          ? _value.totals
          // ignore: cast_nullable_to_non_nullable
          : totals as NutrientTotals,
    );
  }
}

extension $MealDiaryCopyWith on MealDiary {
  /// Returns a callable class that can be used as follows: `instanceOfMealDiary.copyWith(...)` or like so:`instanceOfMealDiary.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MealDiaryCWProxy get copyWith => _$MealDiaryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealDiary _$MealDiaryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MealDiary', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['date', 'logs', 'totals']);
      final val = MealDiary(
        date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
        logs: $checkedConvert(
          'logs',
          (v) => (v as List<dynamic>)
              .map((e) => MealLog.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        totals: $checkedConvert(
          'totals',
          (v) => NutrientTotals.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MealDiaryToJson(MealDiary instance) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'logs': instance.logs.map((e) => e.toJson()).toList(),
  'totals': instance.totals.toJson(),
};
