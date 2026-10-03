// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_photo.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ProgressPhotoCWProxy {
  ProgressPhoto id(String id);

  ProgressPhoto mediaId(String mediaId);

  ProgressPhoto capturedAt(DateTime capturedAt);

  ProgressPhoto angle(PhotoAngle angle);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ProgressPhoto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ProgressPhoto(...).copyWith(id: 12, name: "My name")
  /// ````
  ProgressPhoto call({
    String id,
    String mediaId,
    DateTime capturedAt,
    PhotoAngle angle,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfProgressPhoto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfProgressPhoto.copyWith.fieldName(...)`
class _$ProgressPhotoCWProxyImpl implements _$ProgressPhotoCWProxy {
  const _$ProgressPhotoCWProxyImpl(this._value);

  final ProgressPhoto _value;

  @override
  ProgressPhoto id(String id) => this(id: id);

  @override
  ProgressPhoto mediaId(String mediaId) => this(mediaId: mediaId);

  @override
  ProgressPhoto capturedAt(DateTime capturedAt) => this(capturedAt: capturedAt);

  @override
  ProgressPhoto angle(PhotoAngle angle) => this(angle: angle);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ProgressPhoto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ProgressPhoto(...).copyWith(id: 12, name: "My name")
  /// ````
  ProgressPhoto call({
    Object? id = const $CopyWithPlaceholder(),
    Object? mediaId = const $CopyWithPlaceholder(),
    Object? capturedAt = const $CopyWithPlaceholder(),
    Object? angle = const $CopyWithPlaceholder(),
  }) {
    return ProgressPhoto(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
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

extension $ProgressPhotoCopyWith on ProgressPhoto {
  /// Returns a callable class that can be used as follows: `instanceOfProgressPhoto.copyWith(...)` or like so:`instanceOfProgressPhoto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ProgressPhotoCWProxy get copyWith => _$ProgressPhotoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgressPhoto _$ProgressPhotoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ProgressPhoto', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['id', 'media_id', 'captured_at', 'angle'],
      );
      final val = ProgressPhoto(
        id: $checkedConvert('id', (v) => v as String),
        mediaId: $checkedConvert('media_id', (v) => v as String),
        capturedAt: $checkedConvert(
          'captured_at',
          (v) => DateTime.parse(v as String),
        ),
        angle: $checkedConvert(
          'angle',
          (v) => $enumDecode(_$PhotoAngleEnumMap, v),
        ),
      );
      return val;
    }, fieldKeyMap: const {'mediaId': 'media_id', 'capturedAt': 'captured_at'});

Map<String, dynamic> _$ProgressPhotoToJson(ProgressPhoto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'media_id': instance.mediaId,
      'captured_at': instance.capturedAt.toIso8601String(),
      'angle': _$PhotoAngleEnumMap[instance.angle]!,
    };

const _$PhotoAngleEnumMap = {
  PhotoAngle.front: 'front',
  PhotoAngle.side: 'side',
  PhotoAngle.back: 'back',
};
