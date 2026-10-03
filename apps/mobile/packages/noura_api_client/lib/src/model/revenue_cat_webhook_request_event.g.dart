// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revenue_cat_webhook_request_event.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RevenueCatWebhookRequestEventCWProxy {
  RevenueCatWebhookRequestEvent id(String id);

  RevenueCatWebhookRequestEvent type(String type);

  RevenueCatWebhookRequestEvent appUserId(String? appUserId);

  RevenueCatWebhookRequestEvent environment(String? environment);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RevenueCatWebhookRequestEvent(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RevenueCatWebhookRequestEvent(...).copyWith(id: 12, name: "My name")
  /// ````
  RevenueCatWebhookRequestEvent call({
    String id,
    String type,
    String? appUserId,
    String? environment,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRevenueCatWebhookRequestEvent.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRevenueCatWebhookRequestEvent.copyWith.fieldName(...)`
class _$RevenueCatWebhookRequestEventCWProxyImpl
    implements _$RevenueCatWebhookRequestEventCWProxy {
  const _$RevenueCatWebhookRequestEventCWProxyImpl(this._value);

  final RevenueCatWebhookRequestEvent _value;

  @override
  RevenueCatWebhookRequestEvent id(String id) => this(id: id);

  @override
  RevenueCatWebhookRequestEvent type(String type) => this(type: type);

  @override
  RevenueCatWebhookRequestEvent appUserId(String? appUserId) =>
      this(appUserId: appUserId);

  @override
  RevenueCatWebhookRequestEvent environment(String? environment) =>
      this(environment: environment);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RevenueCatWebhookRequestEvent(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RevenueCatWebhookRequestEvent(...).copyWith(id: 12, name: "My name")
  /// ````
  RevenueCatWebhookRequestEvent call({
    Object? id = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? appUserId = const $CopyWithPlaceholder(),
    Object? environment = const $CopyWithPlaceholder(),
  }) {
    return RevenueCatWebhookRequestEvent(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as String,
      appUserId: appUserId == const $CopyWithPlaceholder()
          ? _value.appUserId
          // ignore: cast_nullable_to_non_nullable
          : appUserId as String?,
      environment: environment == const $CopyWithPlaceholder()
          ? _value.environment
          // ignore: cast_nullable_to_non_nullable
          : environment as String?,
    );
  }
}

extension $RevenueCatWebhookRequestEventCopyWith
    on RevenueCatWebhookRequestEvent {
  /// Returns a callable class that can be used as follows: `instanceOfRevenueCatWebhookRequestEvent.copyWith(...)` or like so:`instanceOfRevenueCatWebhookRequestEvent.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RevenueCatWebhookRequestEventCWProxy get copyWith =>
      _$RevenueCatWebhookRequestEventCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RevenueCatWebhookRequestEvent _$RevenueCatWebhookRequestEventFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('RevenueCatWebhookRequestEvent', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['id', 'type']);
  final val = RevenueCatWebhookRequestEvent(
    id: $checkedConvert('id', (v) => v as String),
    type: $checkedConvert('type', (v) => v as String),
    appUserId: $checkedConvert('app_user_id', (v) => v as String?),
    environment: $checkedConvert('environment', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {'appUserId': 'app_user_id'});

Map<String, dynamic> _$RevenueCatWebhookRequestEventToJson(
  RevenueCatWebhookRequestEvent instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'app_user_id': ?instance.appUserId,
  'environment': ?instance.environment,
};
