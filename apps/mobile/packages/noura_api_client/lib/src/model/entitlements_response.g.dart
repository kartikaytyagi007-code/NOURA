// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlements_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EntitlementsResponseCWProxy {
  EntitlementsResponse data(Entitlements data);

  EntitlementsResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EntitlementsResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EntitlementsResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  EntitlementsResponse call({Entitlements data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEntitlementsResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEntitlementsResponse.copyWith.fieldName(...)`
class _$EntitlementsResponseCWProxyImpl
    implements _$EntitlementsResponseCWProxy {
  const _$EntitlementsResponseCWProxyImpl(this._value);

  final EntitlementsResponse _value;

  @override
  EntitlementsResponse data(Entitlements data) => this(data: data);

  @override
  EntitlementsResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EntitlementsResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EntitlementsResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  EntitlementsResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return EntitlementsResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as Entitlements,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $EntitlementsResponseCopyWith on EntitlementsResponse {
  /// Returns a callable class that can be used as follows: `instanceOfEntitlementsResponse.copyWith(...)` or like so:`instanceOfEntitlementsResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EntitlementsResponseCWProxy get copyWith =>
      _$EntitlementsResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntitlementsResponse _$EntitlementsResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('EntitlementsResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = EntitlementsResponse(
    data: $checkedConvert(
      'data',
      (v) => Entitlements.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => Meta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$EntitlementsResponseToJson(
  EntitlementsResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
