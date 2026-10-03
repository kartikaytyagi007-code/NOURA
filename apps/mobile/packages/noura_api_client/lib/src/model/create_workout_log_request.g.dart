// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_workout_log_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateWorkoutLogRequestCWProxy {
  CreateWorkoutLogRequest clientId(String clientId);

  CreateWorkoutLogRequest sessionId(String sessionId);

  CreateWorkoutLogRequest startedAt(DateTime? startedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateWorkoutLogRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateWorkoutLogRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateWorkoutLogRequest call({
    String clientId,
    String sessionId,
    DateTime? startedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateWorkoutLogRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateWorkoutLogRequest.copyWith.fieldName(...)`
class _$CreateWorkoutLogRequestCWProxyImpl
    implements _$CreateWorkoutLogRequestCWProxy {
  const _$CreateWorkoutLogRequestCWProxyImpl(this._value);

  final CreateWorkoutLogRequest _value;

  @override
  CreateWorkoutLogRequest clientId(String clientId) => this(clientId: clientId);

  @override
  CreateWorkoutLogRequest sessionId(String sessionId) =>
      this(sessionId: sessionId);

  @override
  CreateWorkoutLogRequest startedAt(DateTime? startedAt) =>
      this(startedAt: startedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateWorkoutLogRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateWorkoutLogRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateWorkoutLogRequest call({
    Object? clientId = const $CopyWithPlaceholder(),
    Object? sessionId = const $CopyWithPlaceholder(),
    Object? startedAt = const $CopyWithPlaceholder(),
  }) {
    return CreateWorkoutLogRequest(
      clientId: clientId == const $CopyWithPlaceholder()
          ? _value.clientId
          // ignore: cast_nullable_to_non_nullable
          : clientId as String,
      sessionId: sessionId == const $CopyWithPlaceholder()
          ? _value.sessionId
          // ignore: cast_nullable_to_non_nullable
          : sessionId as String,
      startedAt: startedAt == const $CopyWithPlaceholder()
          ? _value.startedAt
          // ignore: cast_nullable_to_non_nullable
          : startedAt as DateTime?,
    );
  }
}

extension $CreateWorkoutLogRequestCopyWith on CreateWorkoutLogRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateWorkoutLogRequest.copyWith(...)` or like so:`instanceOfCreateWorkoutLogRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateWorkoutLogRequestCWProxy get copyWith =>
      _$CreateWorkoutLogRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateWorkoutLogRequest _$CreateWorkoutLogRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CreateWorkoutLogRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['client_id', 'session_id']);
    final val = CreateWorkoutLogRequest(
      clientId: $checkedConvert('client_id', (v) => v as String),
      sessionId: $checkedConvert('session_id', (v) => v as String),
      startedAt: $checkedConvert(
        'started_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'clientId': 'client_id',
    'sessionId': 'session_id',
    'startedAt': 'started_at',
  },
);

Map<String, dynamic> _$CreateWorkoutLogRequestToJson(
  CreateWorkoutLogRequest instance,
) => <String, dynamic>{
  'client_id': instance.clientId,
  'session_id': instance.sessionId,
  'started_at': ?instance.startedAt?.toIso8601String(),
};
