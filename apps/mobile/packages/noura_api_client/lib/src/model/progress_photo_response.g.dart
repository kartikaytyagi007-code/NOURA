// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_photo_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ProgressPhotoResponseCWProxy {
  ProgressPhotoResponse data(ProgressPhoto data);

  ProgressPhotoResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ProgressPhotoResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ProgressPhotoResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ProgressPhotoResponse call({ProgressPhoto data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfProgressPhotoResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfProgressPhotoResponse.copyWith.fieldName(...)`
class _$ProgressPhotoResponseCWProxyImpl
    implements _$ProgressPhotoResponseCWProxy {
  const _$ProgressPhotoResponseCWProxyImpl(this._value);

  final ProgressPhotoResponse _value;

  @override
  ProgressPhotoResponse data(ProgressPhoto data) => this(data: data);

  @override
  ProgressPhotoResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ProgressPhotoResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ProgressPhotoResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ProgressPhotoResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return ProgressPhotoResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as ProgressPhoto,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $ProgressPhotoResponseCopyWith on ProgressPhotoResponse {
  /// Returns a callable class that can be used as follows: `instanceOfProgressPhotoResponse.copyWith(...)` or like so:`instanceOfProgressPhotoResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ProgressPhotoResponseCWProxy get copyWith =>
      _$ProgressPhotoResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgressPhotoResponse _$ProgressPhotoResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ProgressPhotoResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = ProgressPhotoResponse(
    data: $checkedConvert(
      'data',
      (v) => ProgressPhoto.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => Meta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ProgressPhotoResponseToJson(
  ProgressPhotoResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
