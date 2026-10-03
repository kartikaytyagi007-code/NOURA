// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EntitlementCWProxy {
  Entitlement key(String key);

  Entitlement isActive(bool isActive);

  Entitlement providerStatus(String providerStatus);

  Entitlement expiresAt(DateTime? expiresAt);

  Entitlement lastVerifiedAt(DateTime lastVerifiedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Entitlement(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Entitlement(...).copyWith(id: 12, name: "My name")
  /// ````
  Entitlement call({
    String key,
    bool isActive,
    String providerStatus,
    DateTime? expiresAt,
    DateTime lastVerifiedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEntitlement.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEntitlement.copyWith.fieldName(...)`
class _$EntitlementCWProxyImpl implements _$EntitlementCWProxy {
  const _$EntitlementCWProxyImpl(this._value);

  final Entitlement _value;

  @override
  Entitlement key(String key) => this(key: key);

  @override
  Entitlement isActive(bool isActive) => this(isActive: isActive);

  @override
  Entitlement providerStatus(String providerStatus) =>
      this(providerStatus: providerStatus);

  @override
  Entitlement expiresAt(DateTime? expiresAt) => this(expiresAt: expiresAt);

  @override
  Entitlement lastVerifiedAt(DateTime lastVerifiedAt) =>
      this(lastVerifiedAt: lastVerifiedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Entitlement(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Entitlement(...).copyWith(id: 12, name: "My name")
  /// ````
  Entitlement call({
    Object? key = const $CopyWithPlaceholder(),
    Object? isActive = const $CopyWithPlaceholder(),
    Object? providerStatus = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
    Object? lastVerifiedAt = const $CopyWithPlaceholder(),
  }) {
    return Entitlement(
      key: key == const $CopyWithPlaceholder()
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as String,
      isActive: isActive == const $CopyWithPlaceholder()
          ? _value.isActive
          // ignore: cast_nullable_to_non_nullable
          : isActive as bool,
      providerStatus: providerStatus == const $CopyWithPlaceholder()
          ? _value.providerStatus
          // ignore: cast_nullable_to_non_nullable
          : providerStatus as String,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime?,
      lastVerifiedAt: lastVerifiedAt == const $CopyWithPlaceholder()
          ? _value.lastVerifiedAt
          // ignore: cast_nullable_to_non_nullable
          : lastVerifiedAt as DateTime,
    );
  }
}

extension $EntitlementCopyWith on Entitlement {
  /// Returns a callable class that can be used as follows: `instanceOfEntitlement.copyWith(...)` or like so:`instanceOfEntitlement.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EntitlementCWProxy get copyWith => _$EntitlementCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Entitlement _$EntitlementFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Entitlement',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'key',
        'is_active',
        'provider_status',
        'expires_at',
        'last_verified_at',
      ],
    );
    final val = Entitlement(
      key: $checkedConvert('key', (v) => v as String),
      isActive: $checkedConvert('is_active', (v) => v as bool),
      providerStatus: $checkedConvert('provider_status', (v) => v as String),
      expiresAt: $checkedConvert(
        'expires_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      lastVerifiedAt: $checkedConvert(
        'last_verified_at',
        (v) => DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'isActive': 'is_active',
    'providerStatus': 'provider_status',
    'expiresAt': 'expires_at',
    'lastVerifiedAt': 'last_verified_at',
  },
);

Map<String, dynamic> _$EntitlementToJson(Entitlement instance) =>
    <String, dynamic>{
      'key': instance.key,
      'is_active': instance.isActive,
      'provider_status': instance.providerStatus,
      'expires_at': instance.expiresAt?.toIso8601String(),
      'last_verified_at': instance.lastVerifiedAt.toIso8601String(),
    };
