// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_accepted_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExportAcceptedResponseCWProxy {
  ExportAcceptedResponse data(ExportAccepted data);

  ExportAcceptedResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExportAcceptedResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExportAcceptedResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ExportAcceptedResponse call({ExportAccepted data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExportAcceptedResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExportAcceptedResponse.copyWith.fieldName(...)`
class _$ExportAcceptedResponseCWProxyImpl
    implements _$ExportAcceptedResponseCWProxy {
  const _$ExportAcceptedResponseCWProxyImpl(this._value);

  final ExportAcceptedResponse _value;

  @override
  ExportAcceptedResponse data(ExportAccepted data) => this(data: data);

  @override
  ExportAcceptedResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExportAcceptedResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExportAcceptedResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ExportAcceptedResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return ExportAcceptedResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as ExportAccepted,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $ExportAcceptedResponseCopyWith on ExportAcceptedResponse {
  /// Returns a callable class that can be used as follows: `instanceOfExportAcceptedResponse.copyWith(...)` or like so:`instanceOfExportAcceptedResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExportAcceptedResponseCWProxy get copyWith =>
      _$ExportAcceptedResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExportAcceptedResponse _$ExportAcceptedResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ExportAcceptedResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = ExportAcceptedResponse(
    data: $checkedConvert(
      'data',
      (v) => ExportAccepted.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => Meta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ExportAcceptedResponseToJson(
  ExportAcceptedResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
