// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RecipeResponseCWProxy {
  RecipeResponse data(Recipe data);

  RecipeResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RecipeResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RecipeResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  RecipeResponse call({Recipe data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRecipeResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRecipeResponse.copyWith.fieldName(...)`
class _$RecipeResponseCWProxyImpl implements _$RecipeResponseCWProxy {
  const _$RecipeResponseCWProxyImpl(this._value);

  final RecipeResponse _value;

  @override
  RecipeResponse data(Recipe data) => this(data: data);

  @override
  RecipeResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RecipeResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RecipeResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  RecipeResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return RecipeResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as Recipe,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $RecipeResponseCopyWith on RecipeResponse {
  /// Returns a callable class that can be used as follows: `instanceOfRecipeResponse.copyWith(...)` or like so:`instanceOfRecipeResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RecipeResponseCWProxy get copyWith => _$RecipeResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeResponse _$RecipeResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RecipeResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = RecipeResponse(
        data: $checkedConvert(
          'data',
          (v) => Recipe.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => Meta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$RecipeResponseToJson(RecipeResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
