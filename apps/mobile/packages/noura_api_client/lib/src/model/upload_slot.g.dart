// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_slot.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UploadSlotCWProxy {
  UploadSlot mediaId(String mediaId);

  UploadSlot uploadUrl(String uploadUrl);

  UploadSlot expiresAt(DateTime expiresAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadSlot(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadSlot(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadSlot call({String mediaId, String uploadUrl, DateTime expiresAt});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUploadSlot.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUploadSlot.copyWith.fieldName(...)`
class _$UploadSlotCWProxyImpl implements _$UploadSlotCWProxy {
  const _$UploadSlotCWProxyImpl(this._value);

  final UploadSlot _value;

  @override
  UploadSlot mediaId(String mediaId) => this(mediaId: mediaId);

  @override
  UploadSlot uploadUrl(String uploadUrl) => this(uploadUrl: uploadUrl);

  @override
  UploadSlot expiresAt(DateTime expiresAt) => this(expiresAt: expiresAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadSlot(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadSlot(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadSlot call({
    Object? mediaId = const $CopyWithPlaceholder(),
    Object? uploadUrl = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
  }) {
    return UploadSlot(
      mediaId: mediaId == const $CopyWithPlaceholder()
          ? _value.mediaId
          // ignore: cast_nullable_to_non_nullable
          : mediaId as String,
      uploadUrl: uploadUrl == const $CopyWithPlaceholder()
          ? _value.uploadUrl
          // ignore: cast_nullable_to_non_nullable
          : uploadUrl as String,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime,
    );
  }
}

extension $UploadSlotCopyWith on UploadSlot {
  /// Returns a callable class that can be used as follows: `instanceOfUploadSlot.copyWith(...)` or like so:`instanceOfUploadSlot.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UploadSlotCWProxy get copyWith => _$UploadSlotCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadSlot _$UploadSlotFromJson(Map<String, dynamic> json) => $checkedCreate(
  'UploadSlot',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['media_id', 'upload_url', 'expires_at'],
    );
    final val = UploadSlot(
      mediaId: $checkedConvert('media_id', (v) => v as String),
      uploadUrl: $checkedConvert('upload_url', (v) => v as String),
      expiresAt: $checkedConvert(
        'expires_at',
        (v) => DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'mediaId': 'media_id',
    'uploadUrl': 'upload_url',
    'expiresAt': 'expires_at',
  },
);

Map<String, dynamic> _$UploadSlotToJson(UploadSlot instance) =>
    <String, dynamic>{
      'media_id': instance.mediaId,
      'upload_url': instance.uploadUrl,
      'expires_at': instance.expiresAt.toIso8601String(),
    };
