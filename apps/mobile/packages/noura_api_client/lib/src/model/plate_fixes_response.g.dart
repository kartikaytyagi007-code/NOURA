// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plate_fixes_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PlateFixesResponseCWProxy {
  PlateFixesResponse data(PlateFixes data);

  PlateFixesResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlateFixesResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlateFixesResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PlateFixesResponse call({PlateFixes data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPlateFixesResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPlateFixesResponse.copyWith.fieldName(...)`
class _$PlateFixesResponseCWProxyImpl implements _$PlateFixesResponseCWProxy {
  const _$PlateFixesResponseCWProxyImpl(this._value);

  final PlateFixesResponse _value;

  @override
  PlateFixesResponse data(PlateFixes data) => this(data: data);

  @override
  PlateFixesResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlateFixesResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlateFixesResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PlateFixesResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return PlateFixesResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as PlateFixes,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $PlateFixesResponseCopyWith on PlateFixesResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPlateFixesResponse.copyWith(...)` or like so:`instanceOfPlateFixesResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PlateFixesResponseCWProxy get copyWith =>
      _$PlateFixesResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlateFixesResponse _$PlateFixesResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PlateFixesResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = PlateFixesResponse(
        data: $checkedConvert(
          'data',
          (v) => PlateFixes.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => Meta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PlateFixesResponseToJson(PlateFixesResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
