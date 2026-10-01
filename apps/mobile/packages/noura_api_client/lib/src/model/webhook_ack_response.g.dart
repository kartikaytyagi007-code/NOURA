// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webhook_ack_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WebhookAckResponseCWProxy {
  WebhookAckResponse data(WebhookAck data);

  WebhookAckResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WebhookAckResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WebhookAckResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WebhookAckResponse call({WebhookAck data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWebhookAckResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWebhookAckResponse.copyWith.fieldName(...)`
class _$WebhookAckResponseCWProxyImpl implements _$WebhookAckResponseCWProxy {
  const _$WebhookAckResponseCWProxyImpl(this._value);

  final WebhookAckResponse _value;

  @override
  WebhookAckResponse data(WebhookAck data) => this(data: data);

  @override
  WebhookAckResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WebhookAckResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WebhookAckResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WebhookAckResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return WebhookAckResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as WebhookAck,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $WebhookAckResponseCopyWith on WebhookAckResponse {
  /// Returns a callable class that can be used as follows: `instanceOfWebhookAckResponse.copyWith(...)` or like so:`instanceOfWebhookAckResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WebhookAckResponseCWProxy get copyWith =>
      _$WebhookAckResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WebhookAckResponse _$WebhookAckResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WebhookAckResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = WebhookAckResponse(
        data: $checkedConvert(
          'data',
          (v) => WebhookAck.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => Meta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$WebhookAckResponseToJson(WebhookAckResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
