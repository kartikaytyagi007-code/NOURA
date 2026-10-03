// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session_preview.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkoutSessionPreviewCWProxy {
  WorkoutSessionPreview sessionId(String sessionId);

  WorkoutSessionPreview title(String title);

  WorkoutSessionPreview status(WorkoutSessionPreviewStatusEnum status);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutSessionPreview(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutSessionPreview(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutSessionPreview call({
    String sessionId,
    String title,
    WorkoutSessionPreviewStatusEnum status,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkoutSessionPreview.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkoutSessionPreview.copyWith.fieldName(...)`
class _$WorkoutSessionPreviewCWProxyImpl
    implements _$WorkoutSessionPreviewCWProxy {
  const _$WorkoutSessionPreviewCWProxyImpl(this._value);

  final WorkoutSessionPreview _value;

  @override
  WorkoutSessionPreview sessionId(String sessionId) =>
      this(sessionId: sessionId);

  @override
  WorkoutSessionPreview title(String title) => this(title: title);

  @override
  WorkoutSessionPreview status(WorkoutSessionPreviewStatusEnum status) =>
      this(status: status);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutSessionPreview(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutSessionPreview(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutSessionPreview call({
    Object? sessionId = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
  }) {
    return WorkoutSessionPreview(
      sessionId: sessionId == const $CopyWithPlaceholder()
          ? _value.sessionId
          // ignore: cast_nullable_to_non_nullable
          : sessionId as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as WorkoutSessionPreviewStatusEnum,
    );
  }
}

extension $WorkoutSessionPreviewCopyWith on WorkoutSessionPreview {
  /// Returns a callable class that can be used as follows: `instanceOfWorkoutSessionPreview.copyWith(...)` or like so:`instanceOfWorkoutSessionPreview.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkoutSessionPreviewCWProxy get copyWith =>
      _$WorkoutSessionPreviewCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutSessionPreview _$WorkoutSessionPreviewFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('WorkoutSessionPreview', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['session_id', 'title', 'status']);
  final val = WorkoutSessionPreview(
    sessionId: $checkedConvert('session_id', (v) => v as String),
    title: $checkedConvert('title', (v) => v as String),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$WorkoutSessionPreviewStatusEnumEnumMap, v),
    ),
  );
  return val;
}, fieldKeyMap: const {'sessionId': 'session_id'});

Map<String, dynamic> _$WorkoutSessionPreviewToJson(
  WorkoutSessionPreview instance,
) => <String, dynamic>{
  'session_id': instance.sessionId,
  'title': instance.title,
  'status': _$WorkoutSessionPreviewStatusEnumEnumMap[instance.status]!,
};

const _$WorkoutSessionPreviewStatusEnumEnumMap = {
  WorkoutSessionPreviewStatusEnum.scheduled: 'scheduled',
  WorkoutSessionPreviewStatusEnum.rescheduled: 'rescheduled',
  WorkoutSessionPreviewStatusEnum.cancelled: 'cancelled',
  WorkoutSessionPreviewStatusEnum.completed: 'completed',
  WorkoutSessionPreviewStatusEnum.skipped: 'skipped',
};
