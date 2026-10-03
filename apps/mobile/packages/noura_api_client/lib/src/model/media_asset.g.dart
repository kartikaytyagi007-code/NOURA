// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_asset.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MediaAssetCWProxy {
  MediaAsset id(String id);

  MediaAsset purpose(MediaAssetPurposeEnum purpose);

  MediaAsset status(MediaAssetStatusEnum status);

  MediaAsset verifiedMime(String? verifiedMime);

  MediaAsset byteSize(int? byteSize);

  MediaAsset createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaAsset(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaAsset(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaAsset call({
    String id,
    MediaAssetPurposeEnum purpose,
    MediaAssetStatusEnum status,
    String? verifiedMime,
    int? byteSize,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMediaAsset.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMediaAsset.copyWith.fieldName(...)`
class _$MediaAssetCWProxyImpl implements _$MediaAssetCWProxy {
  const _$MediaAssetCWProxyImpl(this._value);

  final MediaAsset _value;

  @override
  MediaAsset id(String id) => this(id: id);

  @override
  MediaAsset purpose(MediaAssetPurposeEnum purpose) => this(purpose: purpose);

  @override
  MediaAsset status(MediaAssetStatusEnum status) => this(status: status);

  @override
  MediaAsset verifiedMime(String? verifiedMime) =>
      this(verifiedMime: verifiedMime);

  @override
  MediaAsset byteSize(int? byteSize) => this(byteSize: byteSize);

  @override
  MediaAsset createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaAsset(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaAsset(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaAsset call({
    Object? id = const $CopyWithPlaceholder(),
    Object? purpose = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? verifiedMime = const $CopyWithPlaceholder(),
    Object? byteSize = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return MediaAsset(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      purpose: purpose == const $CopyWithPlaceholder()
          ? _value.purpose
          // ignore: cast_nullable_to_non_nullable
          : purpose as MediaAssetPurposeEnum,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as MediaAssetStatusEnum,
      verifiedMime: verifiedMime == const $CopyWithPlaceholder()
          ? _value.verifiedMime
          // ignore: cast_nullable_to_non_nullable
          : verifiedMime as String?,
      byteSize: byteSize == const $CopyWithPlaceholder()
          ? _value.byteSize
          // ignore: cast_nullable_to_non_nullable
          : byteSize as int?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $MediaAssetCopyWith on MediaAsset {
  /// Returns a callable class that can be used as follows: `instanceOfMediaAsset.copyWith(...)` or like so:`instanceOfMediaAsset.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MediaAssetCWProxy get copyWith => _$MediaAssetCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaAsset _$MediaAssetFromJson(Map<String, dynamic> json) => $checkedCreate(
  'MediaAsset',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'purpose',
        'status',
        'verified_mime',
        'byte_size',
        'created_at',
      ],
    );
    final val = MediaAsset(
      id: $checkedConvert('id', (v) => v as String),
      purpose: $checkedConvert(
        'purpose',
        (v) => $enumDecode(_$MediaAssetPurposeEnumEnumMap, v),
      ),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$MediaAssetStatusEnumEnumMap, v),
      ),
      verifiedMime: $checkedConvert('verified_mime', (v) => v as String?),
      byteSize: $checkedConvert('byte_size', (v) => (v as num?)?.toInt()),
      createdAt: $checkedConvert(
        'created_at',
        (v) => DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'verifiedMime': 'verified_mime',
    'byteSize': 'byte_size',
    'createdAt': 'created_at',
  },
);

Map<String, dynamic> _$MediaAssetToJson(MediaAsset instance) =>
    <String, dynamic>{
      'id': instance.id,
      'purpose': _$MediaAssetPurposeEnumEnumMap[instance.purpose]!,
      'status': _$MediaAssetStatusEnumEnumMap[instance.status]!,
      'verified_mime': instance.verifiedMime,
      'byte_size': instance.byteSize,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$MediaAssetPurposeEnumEnumMap = {
  MediaAssetPurposeEnum.meal: 'meal',
  MediaAssetPurposeEnum.progressPhoto: 'progress_photo',
  MediaAssetPurposeEnum.export_: 'export',
};

const _$MediaAssetStatusEnumEnumMap = {
  MediaAssetStatusEnum.awaitingUpload: 'awaiting_upload',
  MediaAssetStatusEnum.uploaded: 'uploaded',
  MediaAssetStatusEnum.verified: 'verified',
  MediaAssetStatusEnum.rejected: 'rejected',
  MediaAssetStatusEnum.deleted: 'deleted',
};
