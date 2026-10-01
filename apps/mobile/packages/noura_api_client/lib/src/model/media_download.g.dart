// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_download.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MediaDownloadCWProxy {
  MediaDownload url(String url);

  MediaDownload expiresAt(DateTime expiresAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaDownload(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaDownload(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaDownload call({String url, DateTime expiresAt});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMediaDownload.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMediaDownload.copyWith.fieldName(...)`
class _$MediaDownloadCWProxyImpl implements _$MediaDownloadCWProxy {
  const _$MediaDownloadCWProxyImpl(this._value);

  final MediaDownload _value;

  @override
  MediaDownload url(String url) => this(url: url);

  @override
  MediaDownload expiresAt(DateTime expiresAt) => this(expiresAt: expiresAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaDownload(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaDownload(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaDownload call({
    Object? url = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
  }) {
    return MediaDownload(
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime,
    );
  }
}

extension $MediaDownloadCopyWith on MediaDownload {
  /// Returns a callable class that can be used as follows: `instanceOfMediaDownload.copyWith(...)` or like so:`instanceOfMediaDownload.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MediaDownloadCWProxy get copyWith => _$MediaDownloadCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaDownload _$MediaDownloadFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MediaDownload', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['url', 'expires_at']);
      final val = MediaDownload(
        url: $checkedConvert('url', (v) => v as String),
        expiresAt: $checkedConvert(
          'expires_at',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    }, fieldKeyMap: const {'expiresAt': 'expires_at'});

Map<String, dynamic> _$MediaDownloadToJson(MediaDownload instance) =>
    <String, dynamic>{
      'url': instance.url,
      'expires_at': instance.expiresAt.toIso8601String(),
    };
