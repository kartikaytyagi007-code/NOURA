// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_plan_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkoutPlanResponseCWProxy {
  WorkoutPlanResponse data(WorkoutPlan data);

  WorkoutPlanResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutPlanResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutPlanResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutPlanResponse call({WorkoutPlan data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkoutPlanResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkoutPlanResponse.copyWith.fieldName(...)`
class _$WorkoutPlanResponseCWProxyImpl implements _$WorkoutPlanResponseCWProxy {
  const _$WorkoutPlanResponseCWProxyImpl(this._value);

  final WorkoutPlanResponse _value;

  @override
  WorkoutPlanResponse data(WorkoutPlan data) => this(data: data);

  @override
  WorkoutPlanResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutPlanResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutPlanResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutPlanResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return WorkoutPlanResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as WorkoutPlan,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $WorkoutPlanResponseCopyWith on WorkoutPlanResponse {
  /// Returns a callable class that can be used as follows: `instanceOfWorkoutPlanResponse.copyWith(...)` or like so:`instanceOfWorkoutPlanResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkoutPlanResponseCWProxy get copyWith =>
      _$WorkoutPlanResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutPlanResponse _$WorkoutPlanResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WorkoutPlanResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = WorkoutPlanResponse(
        data: $checkedConvert(
          'data',
          (v) => WorkoutPlan.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => Meta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$WorkoutPlanResponseToJson(
  WorkoutPlanResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
