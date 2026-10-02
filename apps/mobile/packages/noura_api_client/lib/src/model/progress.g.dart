// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ProgressCWProxy {
  Progress periodStart(DateTime periodStart);

  Progress periodEnd(DateTime periodEnd);

  Progress weightPoints(List<WeightPoint> weightPoints);

  Progress startingWeightKg(num? startingWeightKg);

  Progress currentWeightKg(num? currentWeightKg);

  Progress goalWeightKg(num? goalWeightKg);

  Progress mealLoggedDays(int mealLoggedDays);

  Progress dietAdherence(AdherenceSummary dietAdherence);

  Progress workoutsCompleted(int workoutsCompleted);

  Progress workoutsScheduledElapsed(int workoutsScheduledElapsed);

  Progress workoutAdherence(AdherenceSummary workoutAdherence);

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
    num? startingWeightKg,
    num? currentWeightKg,
    num? goalWeightKg,
    int mealLoggedDays,
    AdherenceSummary dietAdherence,
    int workoutsCompleted,
    int workoutsScheduledElapsed,
    AdherenceSummary workoutAdherence,
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
  Progress startingWeightKg(num? startingWeightKg) =>
      this(startingWeightKg: startingWeightKg);

  @override
  Progress currentWeightKg(num? currentWeightKg) =>
      this(currentWeightKg: currentWeightKg);

  @override
  Progress goalWeightKg(num? goalWeightKg) => this(goalWeightKg: goalWeightKg);

  @override
  Progress mealLoggedDays(int mealLoggedDays) =>
      this(mealLoggedDays: mealLoggedDays);

  @override
  Progress dietAdherence(AdherenceSummary dietAdherence) =>
      this(dietAdherence: dietAdherence);

  @override
  Progress workoutsCompleted(int workoutsCompleted) =>
      this(workoutsCompleted: workoutsCompleted);

  @override
  Progress workoutsScheduledElapsed(int workoutsScheduledElapsed) =>
      this(workoutsScheduledElapsed: workoutsScheduledElapsed);

  @override
  Progress workoutAdherence(AdherenceSummary workoutAdherence) =>
      this(workoutAdherence: workoutAdherence);

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
    Object? startingWeightKg = const $CopyWithPlaceholder(),
    Object? currentWeightKg = const $CopyWithPlaceholder(),
    Object? goalWeightKg = const $CopyWithPlaceholder(),
    Object? mealLoggedDays = const $CopyWithPlaceholder(),
    Object? dietAdherence = const $CopyWithPlaceholder(),
    Object? workoutsCompleted = const $CopyWithPlaceholder(),
    Object? workoutsScheduledElapsed = const $CopyWithPlaceholder(),
    Object? workoutAdherence = const $CopyWithPlaceholder(),
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
      startingWeightKg: startingWeightKg == const $CopyWithPlaceholder()
          ? _value.startingWeightKg
          // ignore: cast_nullable_to_non_nullable
          : startingWeightKg as num?,
      currentWeightKg: currentWeightKg == const $CopyWithPlaceholder()
          ? _value.currentWeightKg
          // ignore: cast_nullable_to_non_nullable
          : currentWeightKg as num?,
      goalWeightKg: goalWeightKg == const $CopyWithPlaceholder()
          ? _value.goalWeightKg
          // ignore: cast_nullable_to_non_nullable
          : goalWeightKg as num?,
      mealLoggedDays: mealLoggedDays == const $CopyWithPlaceholder()
          ? _value.mealLoggedDays
          // ignore: cast_nullable_to_non_nullable
          : mealLoggedDays as int,
      dietAdherence: dietAdherence == const $CopyWithPlaceholder()
          ? _value.dietAdherence
          // ignore: cast_nullable_to_non_nullable
          : dietAdherence as AdherenceSummary,
      workoutsCompleted: workoutsCompleted == const $CopyWithPlaceholder()
          ? _value.workoutsCompleted
          // ignore: cast_nullable_to_non_nullable
          : workoutsCompleted as int,
      workoutsScheduledElapsed:
          workoutsScheduledElapsed == const $CopyWithPlaceholder()
          ? _value.workoutsScheduledElapsed
          // ignore: cast_nullable_to_non_nullable
          : workoutsScheduledElapsed as int,
      workoutAdherence: workoutAdherence == const $CopyWithPlaceholder()
          ? _value.workoutAdherence
          // ignore: cast_nullable_to_non_nullable
          : workoutAdherence as AdherenceSummary,
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
        'starting_weight_kg',
        'current_weight_kg',
        'goal_weight_kg',
        'meal_logged_days',
        'diet_adherence',
        'workouts_completed',
        'workouts_scheduled_elapsed',
        'workout_adherence',
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
      startingWeightKg: $checkedConvert('starting_weight_kg', (v) => v as num?),
      currentWeightKg: $checkedConvert('current_weight_kg', (v) => v as num?),
      goalWeightKg: $checkedConvert('goal_weight_kg', (v) => v as num?),
      mealLoggedDays: $checkedConvert(
        'meal_logged_days',
        (v) => (v as num).toInt(),
      ),
      dietAdherence: $checkedConvert(
        'diet_adherence',
        (v) => AdherenceSummary.fromJson(v as Map<String, dynamic>),
      ),
      workoutsCompleted: $checkedConvert(
        'workouts_completed',
        (v) => (v as num).toInt(),
      ),
      workoutsScheduledElapsed: $checkedConvert(
        'workouts_scheduled_elapsed',
        (v) => (v as num).toInt(),
      ),
      workoutAdherence: $checkedConvert(
        'workout_adherence',
        (v) => AdherenceSummary.fromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'periodStart': 'period_start',
    'periodEnd': 'period_end',
    'weightPoints': 'weight_points',
    'startingWeightKg': 'starting_weight_kg',
    'currentWeightKg': 'current_weight_kg',
    'goalWeightKg': 'goal_weight_kg',
    'mealLoggedDays': 'meal_logged_days',
    'dietAdherence': 'diet_adherence',
    'workoutsCompleted': 'workouts_completed',
    'workoutsScheduledElapsed': 'workouts_scheduled_elapsed',
    'workoutAdherence': 'workout_adherence',
  },
);

Map<String, dynamic> _$ProgressToJson(Progress instance) => <String, dynamic>{
  'period_start': instance.periodStart.toIso8601String(),
  'period_end': instance.periodEnd.toIso8601String(),
  'weight_points': instance.weightPoints.map((e) => e.toJson()).toList(),
  'starting_weight_kg': instance.startingWeightKg,
  'current_weight_kg': instance.currentWeightKg,
  'goal_weight_kg': instance.goalWeightKg,
  'meal_logged_days': instance.mealLoggedDays,
  'diet_adherence': instance.dietAdherence.toJson(),
  'workouts_completed': instance.workoutsCompleted,
  'workouts_scheduled_elapsed': instance.workoutsScheduledElapsed,
  'workout_adherence': instance.workoutAdherence.toJson(),
};
