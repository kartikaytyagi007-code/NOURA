// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_photo_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ProgressPhotoListResponseCWProxy {
  ProgressPhotoListResponse data(ProgressPhotoList data);

  ProgressPhotoListResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ProgressPhotoListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ProgressPhotoListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ProgressPhotoListResponse call({ProgressPhotoList data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfProgressPhotoListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfProgressPhotoListResponse.copyWith.fieldName(...)`
class _$ProgressPhotoListResponseCWProxyImpl
    implements _$ProgressPhotoListResponseCWProxy {
  const _$ProgressPhotoListResponseCWProxyImpl(this._value);

  final ProgressPhotoListResponse _value;

  @override
  ProgressPhotoListResponse data(ProgressPhotoList data) => this(data: data);

  @override
  ProgressPhotoListResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ProgressPhotoListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ProgressPhotoListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ProgressPhotoListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return ProgressPhotoListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as ProgressPhotoList,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $ProgressPhotoListResponseCopyWith on ProgressPhotoListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfProgressPhotoListResponse.copyWith(...)` or like so:`instanceOfProgressPhotoListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ProgressPhotoListResponseCWProxy get copyWith =>
      _$ProgressPhotoListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgressPhotoListResponse _$ProgressPhotoListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ProgressPhotoListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = ProgressPhotoListResponse(
    data: $checkedConvert(
      'data',
      (v) => ProgressPhotoList.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => Meta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ProgressPhotoListResponseToJson(
  ProgressPhotoListResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
