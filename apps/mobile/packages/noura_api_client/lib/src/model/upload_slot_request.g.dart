// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_slot_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UploadSlotRequestCWProxy {
  UploadSlotRequest purpose(MediaPurpose purpose);

  UploadSlotRequest mime(ImageMime mime);

  UploadSlotRequest sizeBytes(int sizeBytes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadSlotRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadSlotRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadSlotRequest call({MediaPurpose purpose, ImageMime mime, int sizeBytes});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUploadSlotRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUploadSlotRequest.copyWith.fieldName(...)`
class _$UploadSlotRequestCWProxyImpl implements _$UploadSlotRequestCWProxy {
  const _$UploadSlotRequestCWProxyImpl(this._value);

  final UploadSlotRequest _value;

  @override
  UploadSlotRequest purpose(MediaPurpose purpose) => this(purpose: purpose);

  @override
  UploadSlotRequest mime(ImageMime mime) => this(mime: mime);

  @override
  UploadSlotRequest sizeBytes(int sizeBytes) => this(sizeBytes: sizeBytes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadSlotRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadSlotRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadSlotRequest call({
    Object? purpose = const $CopyWithPlaceholder(),
    Object? mime = const $CopyWithPlaceholder(),
    Object? sizeBytes = const $CopyWithPlaceholder(),
  }) {
    return UploadSlotRequest(
      purpose: purpose == const $CopyWithPlaceholder()
          ? _value.purpose
          // ignore: cast_nullable_to_non_nullable
          : purpose as MediaPurpose,
      mime: mime == const $CopyWithPlaceholder()
          ? _value.mime
          // ignore: cast_nullable_to_non_nullable
          : mime as ImageMime,
      sizeBytes: sizeBytes == const $CopyWithPlaceholder()
          ? _value.sizeBytes
          // ignore: cast_nullable_to_non_nullable
          : sizeBytes as int,
    );
  }
}

extension $UploadSlotRequestCopyWith on UploadSlotRequest {
  /// Returns a callable class that can be used as follows: `instanceOfUploadSlotRequest.copyWith(...)` or like so:`instanceOfUploadSlotRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UploadSlotRequestCWProxy get copyWith =>
      _$UploadSlotRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadSlotRequest _$UploadSlotRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UploadSlotRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['purpose', 'mime', 'size_bytes']);
      final val = UploadSlotRequest(
        purpose: $checkedConvert(
          'purpose',
          (v) => $enumDecode(_$MediaPurposeEnumMap, v),
        ),
        mime: $checkedConvert(
          'mime',
          (v) => $enumDecode(_$ImageMimeEnumMap, v),
        ),
        sizeBytes: $checkedConvert('size_bytes', (v) => (v as num).toInt()),
      );
      return val;
    }, fieldKeyMap: const {'sizeBytes': 'size_bytes'});

Map<String, dynamic> _$UploadSlotRequestToJson(UploadSlotRequest instance) =>
    <String, dynamic>{
      'purpose': _$MediaPurposeEnumMap[instance.purpose]!,
      'mime': _$ImageMimeEnumMap[instance.mime]!,
      'size_bytes': instance.sizeBytes,
    };

const _$MediaPurposeEnumMap = {
  MediaPurpose.meal: 'meal',
  MediaPurpose.progressPhoto: 'progress_photo',
};

const _$ImageMimeEnumMap = {
  ImageMime.imageSlashJpeg: 'image/jpeg',
  ImageMime.imageSlashPng: 'image/png',
  ImageMime.imageSlashWebp: 'image/webp',
};
