// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revenue_cat_webhook_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RevenueCatWebhookRequestCWProxy {
  RevenueCatWebhookRequest apiVersion(String? apiVersion);

  RevenueCatWebhookRequest event(RevenueCatWebhookRequestEvent event);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RevenueCatWebhookRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RevenueCatWebhookRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RevenueCatWebhookRequest call({
    String? apiVersion,
    RevenueCatWebhookRequestEvent event,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRevenueCatWebhookRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRevenueCatWebhookRequest.copyWith.fieldName(...)`
class _$RevenueCatWebhookRequestCWProxyImpl
    implements _$RevenueCatWebhookRequestCWProxy {
  const _$RevenueCatWebhookRequestCWProxyImpl(this._value);

  final RevenueCatWebhookRequest _value;

  @override
  RevenueCatWebhookRequest apiVersion(String? apiVersion) =>
      this(apiVersion: apiVersion);

  @override
  RevenueCatWebhookRequest event(RevenueCatWebhookRequestEvent event) =>
      this(event: event);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RevenueCatWebhookRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RevenueCatWebhookRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RevenueCatWebhookRequest call({
    Object? apiVersion = const $CopyWithPlaceholder(),
    Object? event = const $CopyWithPlaceholder(),
  }) {
    return RevenueCatWebhookRequest(
      apiVersion: apiVersion == const $CopyWithPlaceholder()
          ? _value.apiVersion
          // ignore: cast_nullable_to_non_nullable
          : apiVersion as String?,
      event: event == const $CopyWithPlaceholder()
          ? _value.event
          // ignore: cast_nullable_to_non_nullable
          : event as RevenueCatWebhookRequestEvent,
    );
  }
}

extension $RevenueCatWebhookRequestCopyWith on RevenueCatWebhookRequest {
  /// Returns a callable class that can be used as follows: `instanceOfRevenueCatWebhookRequest.copyWith(...)` or like so:`instanceOfRevenueCatWebhookRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RevenueCatWebhookRequestCWProxy get copyWith =>
      _$RevenueCatWebhookRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RevenueCatWebhookRequest _$RevenueCatWebhookRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('RevenueCatWebhookRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['event']);
  final val = RevenueCatWebhookRequest(
    apiVersion: $checkedConvert('api_version', (v) => v as String?),
    event: $checkedConvert(
      'event',
      (v) => RevenueCatWebhookRequestEvent.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
}, fieldKeyMap: const {'apiVersion': 'api_version'});

Map<String, dynamic> _$RevenueCatWebhookRequestToJson(
  RevenueCatWebhookRequest instance,
) => <String, dynamic>{
  'api_version': ?instance.apiVersion,
  'event': instance.event.toJson(),
};
