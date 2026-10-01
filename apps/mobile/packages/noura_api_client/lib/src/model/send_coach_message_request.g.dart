// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_coach_message_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SendCoachMessageRequestCWProxy {
  SendCoachMessageRequest clientId(String clientId);

  SendCoachMessageRequest message(String message);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SendCoachMessageRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SendCoachMessageRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SendCoachMessageRequest call({String clientId, String message});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSendCoachMessageRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSendCoachMessageRequest.copyWith.fieldName(...)`
class _$SendCoachMessageRequestCWProxyImpl
    implements _$SendCoachMessageRequestCWProxy {
  const _$SendCoachMessageRequestCWProxyImpl(this._value);

  final SendCoachMessageRequest _value;

  @override
  SendCoachMessageRequest clientId(String clientId) => this(clientId: clientId);

  @override
  SendCoachMessageRequest message(String message) => this(message: message);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SendCoachMessageRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SendCoachMessageRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SendCoachMessageRequest call({
    Object? clientId = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
  }) {
    return SendCoachMessageRequest(
      clientId: clientId == const $CopyWithPlaceholder()
          ? _value.clientId
          // ignore: cast_nullable_to_non_nullable
          : clientId as String,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
    );
  }
}

extension $SendCoachMessageRequestCopyWith on SendCoachMessageRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSendCoachMessageRequest.copyWith(...)` or like so:`instanceOfSendCoachMessageRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SendCoachMessageRequestCWProxy get copyWith =>
      _$SendCoachMessageRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendCoachMessageRequest _$SendCoachMessageRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SendCoachMessageRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['client_id', 'message']);
  final val = SendCoachMessageRequest(
    clientId: $checkedConvert('client_id', (v) => v as String),
    message: $checkedConvert('message', (v) => v as String),
  );
  return val;
}, fieldKeyMap: const {'clientId': 'client_id'});

Map<String, dynamic> _$SendCoachMessageRequestToJson(
  SendCoachMessageRequest instance,
) => <String, dynamic>{
  'client_id': instance.clientId,
  'message': instance.message,
};
