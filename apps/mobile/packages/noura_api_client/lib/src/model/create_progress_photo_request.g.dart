// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_progress_photo_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateProgressPhotoRequestCWProxy {
  CreateProgressPhotoRequest mediaId(String mediaId);

  CreateProgressPhotoRequest capturedAt(DateTime capturedAt);

  CreateProgressPhotoRequest angle(PhotoAngle angle);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateProgressPhotoRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateProgressPhotoRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateProgressPhotoRequest call({
    String mediaId,
    DateTime capturedAt,
    PhotoAngle angle,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateProgressPhotoRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateProgressPhotoRequest.copyWith.fieldName(...)`
class _$CreateProgressPhotoRequestCWProxyImpl
    implements _$CreateProgressPhotoRequestCWProxy {
  const _$CreateProgressPhotoRequestCWProxyImpl(this._value);

  final CreateProgressPhotoRequest _value;

  @override
  CreateProgressPhotoRequest mediaId(String mediaId) => this(mediaId: mediaId);

  @override
  CreateProgressPhotoRequest capturedAt(DateTime capturedAt) =>
      this(capturedAt: capturedAt);

  @override
  CreateProgressPhotoRequest angle(PhotoAngle angle) => this(angle: angle);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateProgressPhotoRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateProgressPhotoRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateProgressPhotoRequest call({
    Object? mediaId = const $CopyWithPlaceholder(),
    Object? capturedAt = const $CopyWithPlaceholder(),
    Object? angle = const $CopyWithPlaceholder(),
  }) {
    return CreateProgressPhotoRequest(
      mediaId: mediaId == const $CopyWithPlaceholder()
          ? _value.mediaId
          // ignore: cast_nullable_to_non_nullable
          : mediaId as String,
      capturedAt: capturedAt == const $CopyWithPlaceholder()
          ? _value.capturedAt
          // ignore: cast_nullable_to_non_nullable
          : capturedAt as DateTime,
      angle: angle == const $CopyWithPlaceholder()
          ? _value.angle
          // ignore: cast_nullable_to_non_nullable
          : angle as PhotoAngle,
    );
  }
}

extension $CreateProgressPhotoRequestCopyWith on CreateProgressPhotoRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateProgressPhotoRequest.copyWith(...)` or like so:`instanceOfCreateProgressPhotoRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateProgressPhotoRequestCWProxy get copyWith =>
      _$CreateProgressPhotoRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateProgressPhotoRequest _$CreateProgressPhotoRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateProgressPhotoRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['media_id', 'captured_at', 'angle']);
  final val = CreateProgressPhotoRequest(
    mediaId: $checkedConvert('media_id', (v) => v as String),
    capturedAt: $checkedConvert(
      'captured_at',
      (v) => DateTime.parse(v as String),
    ),
    angle: $checkedConvert('angle', (v) => $enumDecode(_$PhotoAngleEnumMap, v)),
  );
  return val;
}, fieldKeyMap: const {'mediaId': 'media_id', 'capturedAt': 'captured_at'});

Map<String, dynamic> _$CreateProgressPhotoRequestToJson(
  CreateProgressPhotoRequest instance,
) => <String, dynamic>{
  'media_id': instance.mediaId,
  'captured_at': instance.capturedAt.toIso8601String(),
  'angle': _$PhotoAngleEnumMap[instance.angle]!,
};

const _$PhotoAngleEnumMap = {
  PhotoAngle.front: 'front',
  PhotoAngle.side: 'side',
  PhotoAngle.back: 'back',
};
