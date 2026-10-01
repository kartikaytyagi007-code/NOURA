// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PreferencesResponseCWProxy {
  PreferencesResponse data(Preferences data);

  PreferencesResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PreferencesResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PreferencesResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PreferencesResponse call({Preferences data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPreferencesResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPreferencesResponse.copyWith.fieldName(...)`
class _$PreferencesResponseCWProxyImpl implements _$PreferencesResponseCWProxy {
  const _$PreferencesResponseCWProxyImpl(this._value);

  final PreferencesResponse _value;

  @override
  PreferencesResponse data(Preferences data) => this(data: data);

  @override
  PreferencesResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PreferencesResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PreferencesResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PreferencesResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return PreferencesResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as Preferences,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $PreferencesResponseCopyWith on PreferencesResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPreferencesResponse.copyWith(...)` or like so:`instanceOfPreferencesResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PreferencesResponseCWProxy get copyWith =>
      _$PreferencesResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreferencesResponse _$PreferencesResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PreferencesResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = PreferencesResponse(
        data: $checkedConvert(
          'data',
          (v) => Preferences.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => Meta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PreferencesResponseToJson(
  PreferencesResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
