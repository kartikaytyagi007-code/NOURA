// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webhook_ack.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WebhookAckCWProxy {
  WebhookAck received(bool received);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WebhookAck(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WebhookAck(...).copyWith(id: 12, name: "My name")
  /// ````
  WebhookAck call({bool received});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWebhookAck.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWebhookAck.copyWith.fieldName(...)`
class _$WebhookAckCWProxyImpl implements _$WebhookAckCWProxy {
  const _$WebhookAckCWProxyImpl(this._value);

  final WebhookAck _value;

  @override
  WebhookAck received(bool received) => this(received: received);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WebhookAck(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WebhookAck(...).copyWith(id: 12, name: "My name")
  /// ````
  WebhookAck call({Object? received = const $CopyWithPlaceholder()}) {
    return WebhookAck(
      received: received == const $CopyWithPlaceholder()
          ? _value.received
          // ignore: cast_nullable_to_non_nullable
          : received as bool,
    );
  }
}

extension $WebhookAckCopyWith on WebhookAck {
  /// Returns a callable class that can be used as follows: `instanceOfWebhookAck.copyWith(...)` or like so:`instanceOfWebhookAck.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WebhookAckCWProxy get copyWith => _$WebhookAckCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WebhookAck _$WebhookAckFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WebhookAck', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['received']);
      final val = WebhookAck(
        received: $checkedConvert('received', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$WebhookAckToJson(WebhookAck instance) =>
    <String, dynamic>{'received': instance.received};
