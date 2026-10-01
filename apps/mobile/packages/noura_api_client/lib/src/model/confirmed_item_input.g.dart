// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirmed_item_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ConfirmedItemInputCWProxy {
  ConfirmedItemInput temporaryId(String? temporaryId);

  ConfirmedItemInput foodId(String? foodId);

  ConfirmedItemInput recipeId(String? recipeId);

  ConfirmedItemInput label(String label);

  ConfirmedItemInput grams(num? grams);

  ConfirmedItemInput serving(ServingInput? serving);

  ConfirmedItemInput preparation(PreparationInput? preparation);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConfirmedItemInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConfirmedItemInput(...).copyWith(id: 12, name: "My name")
  /// ````
  ConfirmedItemInput call({
    String? temporaryId,
    String? foodId,
    String? recipeId,
    String label,
    num? grams,
    ServingInput? serving,
    PreparationInput? preparation,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfConfirmedItemInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfConfirmedItemInput.copyWith.fieldName(...)`
class _$ConfirmedItemInputCWProxyImpl implements _$ConfirmedItemInputCWProxy {
  const _$ConfirmedItemInputCWProxyImpl(this._value);

  final ConfirmedItemInput _value;

  @override
  ConfirmedItemInput temporaryId(String? temporaryId) =>
      this(temporaryId: temporaryId);

  @override
  ConfirmedItemInput foodId(String? foodId) => this(foodId: foodId);

  @override
  ConfirmedItemInput recipeId(String? recipeId) => this(recipeId: recipeId);

  @override
  ConfirmedItemInput label(String label) => this(label: label);

  @override
  ConfirmedItemInput grams(num? grams) => this(grams: grams);

  @override
  ConfirmedItemInput serving(ServingInput? serving) => this(serving: serving);

  @override
  ConfirmedItemInput preparation(PreparationInput? preparation) =>
      this(preparation: preparation);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConfirmedItemInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConfirmedItemInput(...).copyWith(id: 12, name: "My name")
  /// ````
  ConfirmedItemInput call({
    Object? temporaryId = const $CopyWithPlaceholder(),
    Object? foodId = const $CopyWithPlaceholder(),
    Object? recipeId = const $CopyWithPlaceholder(),
    Object? label = const $CopyWithPlaceholder(),
    Object? grams = const $CopyWithPlaceholder(),
    Object? serving = const $CopyWithPlaceholder(),
    Object? preparation = const $CopyWithPlaceholder(),
  }) {
    return ConfirmedItemInput(
      temporaryId: temporaryId == const $CopyWithPlaceholder()
          ? _value.temporaryId
          // ignore: cast_nullable_to_non_nullable
          : temporaryId as String?,
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
      grams: grams == const $CopyWithPlaceholder()
          ? _value.grams
          // ignore: cast_nullable_to_non_nullable
          : grams as num?,
      serving: serving == const $CopyWithPlaceholder()
          ? _value.serving
          // ignore: cast_nullable_to_non_nullable
          : serving as ServingInput?,
      preparation: preparation == const $CopyWithPlaceholder()
          ? _value.preparation
          // ignore: cast_nullable_to_non_nullable
          : preparation as PreparationInput?,
    );
  }
}

extension $ConfirmedItemInputCopyWith on ConfirmedItemInput {
  /// Returns a callable class that can be used as follows: `instanceOfConfirmedItemInput.copyWith(...)` or like so:`instanceOfConfirmedItemInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ConfirmedItemInputCWProxy get copyWith =>
      _$ConfirmedItemInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfirmedItemInput _$ConfirmedItemInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ConfirmedItemInput',
      json,
      ($checkedConvert) {
        $checkKeys(json, requiredKeys: const ['label']);
        final val = ConfirmedItemInput(
          temporaryId: $checkedConvert('temporary_id', (v) => v as String?),
          foodId: $checkedConvert('food_id', (v) => v as String?),
          recipeId: $checkedConvert('recipe_id', (v) => v as String?),
          label: $checkedConvert('label', (v) => v as String),
          grams: $checkedConvert('grams', (v) => v as num?),
          serving: $checkedConvert(
            'serving',
            (v) => v == null
                ? null
                : ServingInput.fromJson(v as Map<String, dynamic>),
          ),
          preparation: $checkedConvert(
            'preparation',
            (v) => v == null
                ? null
                : PreparationInput.fromJson(v as Map<String, dynamic>),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'temporaryId': 'temporary_id',
        'foodId': 'food_id',
        'recipeId': 'recipe_id',
      },
    );

Map<String, dynamic> _$ConfirmedItemInputToJson(ConfirmedItemInput instance) =>
    <String, dynamic>{
      'temporary_id': ?instance.temporaryId,
      'food_id': ?instance.foodId,
      'recipe_id': ?instance.recipeId,
      'label': instance.label,
      'grams': ?instance.grams,
      'serving': ?instance.serving?.toJson(),
      'preparation': ?instance.preparation?.toJson(),
    };
