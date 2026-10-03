// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ProgressResponseCWProxy {
  ProgressResponse data(Progress data);

  ProgressResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ProgressResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ProgressResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ProgressResponse call({Progress data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfProgressResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfProgressResponse.copyWith.fieldName(...)`
class _$ProgressResponseCWProxyImpl implements _$ProgressResponseCWProxy {
  const _$ProgressResponseCWProxyImpl(this._value);

  final ProgressResponse _value;

  @override
  ProgressResponse data(Progress data) => this(data: data);

  @override
  ProgressResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ProgressResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ProgressResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ProgressResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return ProgressResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as Progress,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $ProgressResponseCopyWith on ProgressResponse {
  /// Returns a callable class that can be used as follows: `instanceOfProgressResponse.copyWith(...)` or like so:`instanceOfProgressResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ProgressResponseCWProxy get copyWith => _$ProgressResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgressResponse _$ProgressResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ProgressResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = ProgressResponse(
        data: $checkedConvert(
          'data',
          (v) => Progress.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => Meta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ProgressResponseToJson(ProgressResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
