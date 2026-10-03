// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portion_ref.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PortionRefCWProxy {
  PortionRef foodId(String? foodId);

  PortionRef recipeId(String? recipeId);

  PortionRef label(String label);

  PortionRef gramsMin(num gramsMin);

  PortionRef gramsMax(num gramsMax);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PortionRef(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PortionRef(...).copyWith(id: 12, name: "My name")
  /// ````
  PortionRef call({
    String? foodId,
    String? recipeId,
    String label,
    num gramsMin,
    num gramsMax,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPortionRef.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPortionRef.copyWith.fieldName(...)`
class _$PortionRefCWProxyImpl implements _$PortionRefCWProxy {
  const _$PortionRefCWProxyImpl(this._value);

  final PortionRef _value;

  @override
  PortionRef foodId(String? foodId) => this(foodId: foodId);

  @override
  PortionRef recipeId(String? recipeId) => this(recipeId: recipeId);

  @override
  PortionRef label(String label) => this(label: label);

  @override
  PortionRef gramsMin(num gramsMin) => this(gramsMin: gramsMin);

  @override
  PortionRef gramsMax(num gramsMax) => this(gramsMax: gramsMax);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PortionRef(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PortionRef(...).copyWith(id: 12, name: "My name")
  /// ````
  PortionRef call({
    Object? foodId = const $CopyWithPlaceholder(),
    Object? recipeId = const $CopyWithPlaceholder(),
    Object? label = const $CopyWithPlaceholder(),
    Object? gramsMin = const $CopyWithPlaceholder(),
    Object? gramsMax = const $CopyWithPlaceholder(),
  }) {
    return PortionRef(
      foodId: foodId == const $CopyWithPlaceholder()
          ? _value.foodId
          // ignore: cast_nullable_to_non_nullable
          : foodId as String?,
      recipeId: recipeId == const $CopyWithPlaceholder()
          ? _value.recipeId
          // ignore: cast_nullable_to_non_nullable
          : recipeId as String?,
      label: label == const $CopyWithPlaceholder()
          ? _value.label
          // ignore: cast_nullable_to_non_nullable
          : label as String,
      gramsMin: gramsMin == const $CopyWithPlaceholder()
          ? _value.gramsMin
          // ignore: cast_nullable_to_non_nullable
          : gramsMin as num,
      gramsMax: gramsMax == const $CopyWithPlaceholder()
          ? _value.gramsMax
          // ignore: cast_nullable_to_non_nullable
          : gramsMax as num,
    );
  }
}

extension $PortionRefCopyWith on PortionRef {
  /// Returns a callable class that can be used as follows: `instanceOfPortionRef.copyWith(...)` or like so:`instanceOfPortionRef.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PortionRefCWProxy get copyWith => _$PortionRefCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PortionRef _$PortionRefFromJson(Map<String, dynamic> json) => $checkedCreate(
  'PortionRef',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'food_id',
        'recipe_id',
        'label',
        'grams_min',
        'grams_max',
      ],
    );
    final val = PortionRef(
      foodId: $checkedConvert('food_id', (v) => v as String?),
      recipeId: $checkedConvert('recipe_id', (v) => v as String?),
      label: $checkedConvert('label', (v) => v as String),
      gramsMin: $checkedConvert('grams_min', (v) => v as num),
      gramsMax: $checkedConvert('grams_max', (v) => v as num),
    );
    return val;
  },
  fieldKeyMap: const {
    'foodId': 'food_id',
    'recipeId': 'recipe_id',
    'gramsMin': 'grams_min',
    'gramsMax': 'grams_max',
  },
);

Map<String, dynamic> _$PortionRefToJson(PortionRef instance) =>
    <String, dynamic>{
      'food_id': instance.foodId,
      'recipe_id': instance.recipeId,
      'label': instance.label,
      'grams_min': instance.gramsMin,
      'grams_max': instance.gramsMax,
    };
