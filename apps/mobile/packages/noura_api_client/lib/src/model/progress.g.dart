// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ProgressCWProxy {
  Progress periodStart(DateTime periodStart);

  Progress periodEnd(DateTime periodEnd);

  Progress weightPoints(List<WeightPoint> weightPoints);

  Progress mealLoggedDays(int mealLoggedDays);

  Progress workoutsCompleted(int workoutsCompleted);

  Progress workoutsScheduledElapsed(int workoutsScheduledElapsed);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Progress(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Progress(...).copyWith(id: 12, name: "My name")
  /// ````
  Progress call({
    DateTime periodStart,
    DateTime periodEnd,
    List<WeightPoint> weightPoints,
    int mealLoggedDays,
    int workoutsCompleted,
    int workoutsScheduledElapsed,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfProgress.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfProgress.copyWith.fieldName(...)`
class _$ProgressCWProxyImpl implements _$ProgressCWProxy {
  const _$ProgressCWProxyImpl(this._value);

  final Progress _value;

  @override
  Progress periodStart(DateTime periodStart) => this(periodStart: periodStart);

  @override
  Progress periodEnd(DateTime periodEnd) => this(periodEnd: periodEnd);

  @override
  Progress weightPoints(List<WeightPoint> weightPoints) =>
      this(weightPoints: weightPoints);

  @override
  Progress mealLoggedDays(int mealLoggedDays) =>
      this(mealLoggedDays: mealLoggedDays);

  @override
  Progress workoutsCompleted(int workoutsCompleted) =>
      this(workoutsCompleted: workoutsCompleted);

  @override
  Progress workoutsScheduledElapsed(int workoutsScheduledElapsed) =>
      this(workoutsScheduledElapsed: workoutsScheduledElapsed);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Progress(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Progress(...).copyWith(id: 12, name: "My name")
  /// ````
  Progress call({
    Object? periodStart = const $CopyWithPlaceholder(),
    Object? periodEnd = const $CopyWithPlaceholder(),
    Object? weightPoints = const $CopyWithPlaceholder(),
    Object? mealLoggedDays = const $CopyWithPlaceholder(),
    Object? workoutsCompleted = const $CopyWithPlaceholder(),
    Object? workoutsScheduledElapsed = const $CopyWithPlaceholder(),
  }) {
    return Progress(
      periodStart: periodStart == const $CopyWithPlaceholder()
          ? _value.periodStart
          // ignore: cast_nullable_to_non_nullable
          : periodStart as DateTime,
      periodEnd: periodEnd == const $CopyWithPlaceholder()
          ? _value.periodEnd
          // ignore: cast_nullable_to_non_nullable
          : periodEnd as DateTime,
      weightPoints: weightPoints == const $CopyWithPlaceholder()
          ? _value.weightPoints
          // ignore: cast_nullable_to_non_nullable
          : weightPoints as List<WeightPoint>,
      mealLoggedDays: mealLoggedDays == const $CopyWithPlaceholder()
          ? _value.mealLoggedDays
          // ignore: cast_nullable_to_non_nullable
          : mealLoggedDays as int,
      workoutsCompleted: workoutsCompleted == const $CopyWithPlaceholder()
          ? _value.workoutsCompleted
          // ignore: cast_nullable_to_non_nullable
          : workoutsCompleted as int,
      workoutsScheduledElapsed:
          workoutsScheduledElapsed == const $CopyWithPlaceholder()
          ? _value.workoutsScheduledElapsed
          // ignore: cast_nullable_to_non_nullable
          : workoutsScheduledElapsed as int,
    );
  }
}

extension $ProgressCopyWith on Progress {
  /// Returns a callable class that can be used as follows: `instanceOfProgress.copyWith(...)` or like so:`instanceOfProgress.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ProgressCWProxy get copyWith => _$ProgressCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Progress _$ProgressFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Progress',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'period_start',
        'period_end',
        'weight_points',
        'meal_logged_days',
        'workouts_completed',
        'workouts_scheduled_elapsed',
      ],
    );
    final val = Progress(
      periodStart: $checkedConvert(
        'period_start',
        (v) => DateTime.parse(v as String),
      ),
      periodEnd: $checkedConvert(
        'period_end',
        (v) => DateTime.parse(v as String),
      ),
      weightPoints: $checkedConvert(
        'weight_points',
        (v) => (v as List<dynamic>)
            .map((e) => WeightPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      mealLoggedDays: $checkedConvert(
        'meal_logged_days',
        (v) => (v as num).toInt(),
      ),
      workoutsCompleted: $checkedConvert(
        'workouts_completed',
        (v) => (v as num).toInt(),
      ),
      workoutsScheduledElapsed: $checkedConvert(
        'workouts_scheduled_elapsed',
        (v) => (v as num).toInt(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'periodStart': 'period_start',
    'periodEnd': 'period_end',
    'weightPoints': 'weight_points',
    'mealLoggedDays': 'meal_logged_days',
    'workoutsCompleted': 'workouts_completed',
    'workoutsScheduledElapsed': 'workouts_scheduled_elapsed',
  },
);

Map<String, dynamic> _$ProgressToJson(Progress instance) => <String, dynamic>{
  'period_start': instance.periodStart.toIso8601String(),
  'period_end': instance.periodEnd.toIso8601String(),
  'weight_points': instance.weightPoints.map((e) => e.toJson()).toList(),
  'meal_logged_days': instance.mealLoggedDays,
  'workouts_completed': instance.workoutsCompleted,
  'workouts_scheduled_elapsed': instance.workoutsScheduledElapsed,
};
