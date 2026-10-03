// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_asset_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MediaAssetResponseCWProxy {
  MediaAssetResponse data(MediaAsset data);

  MediaAssetResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaAssetResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaAssetResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaAssetResponse call({MediaAsset data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMediaAssetResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMediaAssetResponse.copyWith.fieldName(...)`
class _$MediaAssetResponseCWProxyImpl implements _$MediaAssetResponseCWProxy {
  const _$MediaAssetResponseCWProxyImpl(this._value);

  final MediaAssetResponse _value;

  @override
  MediaAssetResponse data(MediaAsset data) => this(data: data);

  @override
  MediaAssetResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaAssetResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaAssetResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaAssetResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return MediaAssetResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as MediaAsset,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $MediaAssetResponseCopyWith on MediaAssetResponse {
  /// Returns a callable class that can be used as follows: `instanceOfMediaAssetResponse.copyWith(...)` or like so:`instanceOfMediaAssetResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MediaAssetResponseCWProxy get copyWith =>
      _$MediaAssetResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaAssetResponse _$MediaAssetResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MediaAssetResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = MediaAssetResponse(
        data: $checkedConvert(
          'data',
          (v) => MediaAsset.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => Meta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MediaAssetResponseToJson(MediaAssetResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
