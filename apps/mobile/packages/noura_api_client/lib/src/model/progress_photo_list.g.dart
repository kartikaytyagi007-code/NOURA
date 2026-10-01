// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_photo_list.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ProgressPhotoListCWProxy {
  ProgressPhotoList items(List<ProgressPhoto> items);

  ProgressPhotoList nextCursor(String? nextCursor);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ProgressPhotoList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ProgressPhotoList(...).copyWith(id: 12, name: "My name")
  /// ````
  ProgressPhotoList call({List<ProgressPhoto> items, String? nextCursor});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfProgressPhotoList.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfProgressPhotoList.copyWith.fieldName(...)`
class _$ProgressPhotoListCWProxyImpl implements _$ProgressPhotoListCWProxy {
  const _$ProgressPhotoListCWProxyImpl(this._value);

  final ProgressPhotoList _value;

  @override
  ProgressPhotoList items(List<ProgressPhoto> items) => this(items: items);

  @override
  ProgressPhotoList nextCursor(String? nextCursor) =>
      this(nextCursor: nextCursor);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ProgressPhotoList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ProgressPhotoList(...).copyWith(id: 12, name: "My name")
  /// ````
  ProgressPhotoList call({
    Object? items = const $CopyWithPlaceholder(),
    Object? nextCursor = const $CopyWithPlaceholder(),
  }) {
    return ProgressPhotoList(
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<ProgressPhoto>,
      nextCursor: nextCursor == const $CopyWithPlaceholder()
          ? _value.nextCursor
          // ignore: cast_nullable_to_non_nullable
          : nextCursor as String?,
    );
  }
}

extension $ProgressPhotoListCopyWith on ProgressPhotoList {
  /// Returns a callable class that can be used as follows: `instanceOfProgressPhotoList.copyWith(...)` or like so:`instanceOfProgressPhotoList.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ProgressPhotoListCWProxy get copyWith =>
      _$ProgressPhotoListCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgressPhotoList _$ProgressPhotoListFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ProgressPhotoList', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['items', 'next_cursor']);
      final val = ProgressPhotoList(
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map((e) => ProgressPhoto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        nextCursor: $checkedConvert('next_cursor', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'nextCursor': 'next_cursor'});

Map<String, dynamic> _$ProgressPhotoListToJson(ProgressPhotoList instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'next_cursor': instance.nextCursor,
    };
