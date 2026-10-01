// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_download_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MediaDownloadResponseCWProxy {
  MediaDownloadResponse data(MediaDownload data);

  MediaDownloadResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaDownloadResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaDownloadResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaDownloadResponse call({MediaDownload data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMediaDownloadResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMediaDownloadResponse.copyWith.fieldName(...)`
class _$MediaDownloadResponseCWProxyImpl
    implements _$MediaDownloadResponseCWProxy {
  const _$MediaDownloadResponseCWProxyImpl(this._value);

  final MediaDownloadResponse _value;

  @override
  MediaDownloadResponse data(MediaDownload data) => this(data: data);

  @override
  MediaDownloadResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaDownloadResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaDownloadResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaDownloadResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return MediaDownloadResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as MediaDownload,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $MediaDownloadResponseCopyWith on MediaDownloadResponse {
  /// Returns a callable class that can be used as follows: `instanceOfMediaDownloadResponse.copyWith(...)` or like so:`instanceOfMediaDownloadResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MediaDownloadResponseCWProxy get copyWith =>
      _$MediaDownloadResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaDownloadResponse _$MediaDownloadResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MediaDownloadResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = MediaDownloadResponse(
    data: $checkedConvert(
      'data',
      (v) => MediaDownload.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => Meta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$MediaDownloadResponseToJson(
  MediaDownloadResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
