// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_slot_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UploadSlotResponseCWProxy {
  UploadSlotResponse data(UploadSlot data);

  UploadSlotResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadSlotResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadSlotResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadSlotResponse call({UploadSlot data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUploadSlotResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUploadSlotResponse.copyWith.fieldName(...)`
class _$UploadSlotResponseCWProxyImpl implements _$UploadSlotResponseCWProxy {
  const _$UploadSlotResponseCWProxyImpl(this._value);

  final UploadSlotResponse _value;

  @override
  UploadSlotResponse data(UploadSlot data) => this(data: data);

  @override
  UploadSlotResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadSlotResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadSlotResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadSlotResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return UploadSlotResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as UploadSlot,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $UploadSlotResponseCopyWith on UploadSlotResponse {
  /// Returns a callable class that can be used as follows: `instanceOfUploadSlotResponse.copyWith(...)` or like so:`instanceOfUploadSlotResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UploadSlotResponseCWProxy get copyWith =>
      _$UploadSlotResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadSlotResponse _$UploadSlotResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UploadSlotResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = UploadSlotResponse(
        data: $checkedConvert(
          'data',
          (v) => UploadSlot.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => Meta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$UploadSlotResponseToJson(UploadSlotResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
