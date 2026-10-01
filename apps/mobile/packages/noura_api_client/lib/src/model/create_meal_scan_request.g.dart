// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_meal_scan_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateMealScanRequestCWProxy {
  CreateMealScanRequest mediaId(String mediaId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateMealScanRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateMealScanRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateMealScanRequest call({String mediaId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateMealScanRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateMealScanRequest.copyWith.fieldName(...)`
class _$CreateMealScanRequestCWProxyImpl
    implements _$CreateMealScanRequestCWProxy {
  const _$CreateMealScanRequestCWProxyImpl(this._value);

  final CreateMealScanRequest _value;

  @override
  CreateMealScanRequest mediaId(String mediaId) => this(mediaId: mediaId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateMealScanRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateMealScanRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateMealScanRequest call({Object? mediaId = const $CopyWithPlaceholder()}) {
    return CreateMealScanRequest(
      mediaId: mediaId == const $CopyWithPlaceholder()
          ? _value.mediaId
          // ignore: cast_nullable_to_non_nullable
          : mediaId as String,
    );
  }
}

extension $CreateMealScanRequestCopyWith on CreateMealScanRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateMealScanRequest.copyWith(...)` or like so:`instanceOfCreateMealScanRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateMealScanRequestCWProxy get copyWith =>
      _$CreateMealScanRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateMealScanRequest _$CreateMealScanRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateMealScanRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['media_id']);
  final val = CreateMealScanRequest(
    mediaId: $checkedConvert('media_id', (v) => v as String),
  );
  return val;
}, fieldKeyMap: const {'mediaId': 'media_id'});

Map<String, dynamic> _$CreateMealScanRequestToJson(
  CreateMealScanRequest instance,
) => <String, dynamic>{'media_id': instance.mediaId};
