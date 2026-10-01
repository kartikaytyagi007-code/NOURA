// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DeletedCWProxy {
  Deleted id(String id);

  Deleted deleted(bool deleted);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Deleted(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Deleted(...).copyWith(id: 12, name: "My name")
  /// ````
  Deleted call({String id, bool deleted});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDeleted.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDeleted.copyWith.fieldName(...)`
class _$DeletedCWProxyImpl implements _$DeletedCWProxy {
  const _$DeletedCWProxyImpl(this._value);

  final Deleted _value;

  @override
  Deleted id(String id) => this(id: id);

  @override
  Deleted deleted(bool deleted) => this(deleted: deleted);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Deleted(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Deleted(...).copyWith(id: 12, name: "My name")
  /// ````
  Deleted call({
    Object? id = const $CopyWithPlaceholder(),
    Object? deleted = const $CopyWithPlaceholder(),
  }) {
    return Deleted(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      deleted: deleted == const $CopyWithPlaceholder()
          ? _value.deleted
          // ignore: cast_nullable_to_non_nullable
          : deleted as bool,
    );
  }
}

extension $DeletedCopyWith on Deleted {
  /// Returns a callable class that can be used as follows: `instanceOfDeleted.copyWith(...)` or like so:`instanceOfDeleted.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DeletedCWProxy get copyWith => _$DeletedCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Deleted _$DeletedFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Deleted', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id', 'deleted']);
      final val = Deleted(
        id: $checkedConvert('id', (v) => v as String),
        deleted: $checkedConvert('deleted', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$DeletedToJson(Deleted instance) => <String, dynamic>{
  'id': instance.id,
  'deleted': instance.deleted,
};
