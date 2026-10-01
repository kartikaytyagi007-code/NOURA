// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlements.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EntitlementsCWProxy {
  Entitlements entitlements(List<Entitlement> entitlements);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Entitlements(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Entitlements(...).copyWith(id: 12, name: "My name")
  /// ````
  Entitlements call({List<Entitlement> entitlements});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEntitlements.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEntitlements.copyWith.fieldName(...)`
class _$EntitlementsCWProxyImpl implements _$EntitlementsCWProxy {
  const _$EntitlementsCWProxyImpl(this._value);

  final Entitlements _value;

  @override
  Entitlements entitlements(List<Entitlement> entitlements) =>
      this(entitlements: entitlements);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Entitlements(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Entitlements(...).copyWith(id: 12, name: "My name")
  /// ````
  Entitlements call({Object? entitlements = const $CopyWithPlaceholder()}) {
    return Entitlements(
      entitlements: entitlements == const $CopyWithPlaceholder()
          ? _value.entitlements
          // ignore: cast_nullable_to_non_nullable
          : entitlements as List<Entitlement>,
    );
  }
}

extension $EntitlementsCopyWith on Entitlements {
  /// Returns a callable class that can be used as follows: `instanceOfEntitlements.copyWith(...)` or like so:`instanceOfEntitlements.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EntitlementsCWProxy get copyWith => _$EntitlementsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Entitlements _$EntitlementsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Entitlements', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['entitlements']);
      final val = Entitlements(
        entitlements: $checkedConvert(
          'entitlements',
          (v) => (v as List<dynamic>)
              .map((e) => Entitlement.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$EntitlementsToJson(Entitlements instance) =>
    <String, dynamic>{
      'entitlements': instance.entitlements.map((e) => e.toJson()).toList(),
    };
