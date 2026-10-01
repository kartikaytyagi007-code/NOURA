// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DeletedResponseCWProxy {
  DeletedResponse data(Deleted data);

  DeletedResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeletedResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeletedResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  DeletedResponse call({Deleted data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDeletedResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDeletedResponse.copyWith.fieldName(...)`
class _$DeletedResponseCWProxyImpl implements _$DeletedResponseCWProxy {
  const _$DeletedResponseCWProxyImpl(this._value);

  final DeletedResponse _value;

  @override
  DeletedResponse data(Deleted data) => this(data: data);

  @override
  DeletedResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeletedResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeletedResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  DeletedResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return DeletedResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as Deleted,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $DeletedResponseCopyWith on DeletedResponse {
  /// Returns a callable class that can be used as follows: `instanceOfDeletedResponse.copyWith(...)` or like so:`instanceOfDeletedResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DeletedResponseCWProxy get copyWith => _$DeletedResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeletedResponse _$DeletedResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DeletedResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = DeletedResponse(
        data: $checkedConvert(
          'data',
          (v) => Deleted.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => Meta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$DeletedResponseToJson(DeletedResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
