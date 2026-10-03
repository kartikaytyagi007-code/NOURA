// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExportResponseCWProxy {
  ExportResponse data(AccountExport data);

  ExportResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExportResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExportResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ExportResponse call({AccountExport data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExportResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExportResponse.copyWith.fieldName(...)`
class _$ExportResponseCWProxyImpl implements _$ExportResponseCWProxy {
  const _$ExportResponseCWProxyImpl(this._value);

  final ExportResponse _value;

  @override
  ExportResponse data(AccountExport data) => this(data: data);

  @override
  ExportResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExportResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExportResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ExportResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return ExportResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as AccountExport,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $ExportResponseCopyWith on ExportResponse {
  /// Returns a callable class that can be used as follows: `instanceOfExportResponse.copyWith(...)` or like so:`instanceOfExportResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExportResponseCWProxy get copyWith => _$ExportResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExportResponse _$ExportResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ExportResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = ExportResponse(
        data: $checkedConvert(
          'data',
          (v) => AccountExport.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => Meta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ExportResponseToJson(ExportResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
