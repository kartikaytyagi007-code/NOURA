// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_message_accepted.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CoachMessageAcceptedCWProxy {
  CoachMessageAccepted jobId(String jobId);

  CoachMessageAccepted message(CoachMessage message);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CoachMessageAccepted(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CoachMessageAccepted(...).copyWith(id: 12, name: "My name")
  /// ````
  CoachMessageAccepted call({String jobId, CoachMessage message});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCoachMessageAccepted.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCoachMessageAccepted.copyWith.fieldName(...)`
class _$CoachMessageAcceptedCWProxyImpl
    implements _$CoachMessageAcceptedCWProxy {
  const _$CoachMessageAcceptedCWProxyImpl(this._value);

  final CoachMessageAccepted _value;

  @override
  CoachMessageAccepted jobId(String jobId) => this(jobId: jobId);

  @override
  CoachMessageAccepted message(CoachMessage message) => this(message: message);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CoachMessageAccepted(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CoachMessageAccepted(...).copyWith(id: 12, name: "My name")
  /// ````
  CoachMessageAccepted call({
    Object? jobId = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
  }) {
    return CoachMessageAccepted(
      jobId: jobId == const $CopyWithPlaceholder()
          ? _value.jobId
          // ignore: cast_nullable_to_non_nullable
          : jobId as String,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as CoachMessage,
    );
  }
}

extension $CoachMessageAcceptedCopyWith on CoachMessageAccepted {
  /// Returns a callable class that can be used as follows: `instanceOfCoachMessageAccepted.copyWith(...)` or like so:`instanceOfCoachMessageAccepted.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CoachMessageAcceptedCWProxy get copyWith =>
      _$CoachMessageAcceptedCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoachMessageAccepted _$CoachMessageAcceptedFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CoachMessageAccepted', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['job_id', 'message']);
  final val = CoachMessageAccepted(
    jobId: $checkedConvert('job_id', (v) => v as String),
    message: $checkedConvert(
      'message',
      (v) => CoachMessage.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
}, fieldKeyMap: const {'jobId': 'job_id'});

Map<String, dynamic> _$CoachMessageAcceptedToJson(
  CoachMessageAccepted instance,
) => <String, dynamic>{
  'job_id': instance.jobId,
  'message': instance.message.toJson(),
};
