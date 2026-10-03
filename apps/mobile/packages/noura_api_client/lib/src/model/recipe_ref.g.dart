// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_ref.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RecipeRefCWProxy {
  RecipeRef id(String id);

  RecipeRef name(String name);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RecipeRef(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RecipeRef(...).copyWith(id: 12, name: "My name")
  /// ````
  RecipeRef call({String id, String name});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRecipeRef.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRecipeRef.copyWith.fieldName(...)`
class _$RecipeRefCWProxyImpl implements _$RecipeRefCWProxy {
  const _$RecipeRefCWProxyImpl(this._value);

  final RecipeRef _value;

  @override
  RecipeRef id(String id) => this(id: id);

  @override
  RecipeRef name(String name) => this(name: name);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RecipeRef(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RecipeRef(...).copyWith(id: 12, name: "My name")
  /// ````
  RecipeRef call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
  }) {
    return RecipeRef(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
    );
  }
}

extension $RecipeRefCopyWith on RecipeRef {
  /// Returns a callable class that can be used as follows: `instanceOfRecipeRef.copyWith(...)` or like so:`instanceOfRecipeRef.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RecipeRefCWProxy get copyWith => _$RecipeRefCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeRef _$RecipeRefFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RecipeRef', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id', 'name']);
      final val = RecipeRef(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$RecipeRefToJson(RecipeRef instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};
