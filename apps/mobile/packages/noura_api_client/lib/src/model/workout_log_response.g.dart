// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_log_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkoutLogResponseCWProxy {
  WorkoutLogResponse data(WorkoutLog data);

  WorkoutLogResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutLogResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutLogResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutLogResponse call({WorkoutLog data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkoutLogResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkoutLogResponse.copyWith.fieldName(...)`
class _$WorkoutLogResponseCWProxyImpl implements _$WorkoutLogResponseCWProxy {
  const _$WorkoutLogResponseCWProxyImpl(this._value);

  final WorkoutLogResponse _value;

  @override
  WorkoutLogResponse data(WorkoutLog data) => this(data: data);

  @override
  WorkoutLogResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutLogResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutLogResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutLogResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return WorkoutLogResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as WorkoutLog,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $WorkoutLogResponseCopyWith on WorkoutLogResponse {
  /// Returns a callable class that can be used as follows: `instanceOfWorkoutLogResponse.copyWith(...)` or like so:`instanceOfWorkoutLogResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkoutLogResponseCWProxy get copyWith =>
      _$WorkoutLogResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutLogResponse _$WorkoutLogResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WorkoutLogResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = WorkoutLogResponse(
        data: $checkedConvert(
          'data',
          (v) => WorkoutLog.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => Meta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$WorkoutLogResponseToJson(WorkoutLogResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
