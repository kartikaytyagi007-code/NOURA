// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analyzed_item.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AnalyzedItemCWProxy {
  AnalyzedItem itemId(String itemId);

  AnalyzedItem label(String label);

  AnalyzedItem foodId(String? foodId);

  AnalyzedItem recipeId(String? recipeId);

  AnalyzedItem source_(SourceRef? source_);

  AnalyzedItem grams(num? grams);

  AnalyzedItem gramsRange(NumberRange? gramsRange);

  AnalyzedItem nutrients(Nutrients? nutrients);

  AnalyzedItem uncertainty(Uncertainty? uncertainty);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnalyzedItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnalyzedItem(...).copyWith(id: 12, name: "My name")
  /// ````
  AnalyzedItem call({
    String itemId,
    String label,
    String? foodId,
    String? recipeId,
    SourceRef? source_,
    num? grams,
    NumberRange? gramsRange,
    Nutrients? nutrients,
    Uncertainty? uncertainty,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAnalyzedItem.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAnalyzedItem.copyWith.fieldName(...)`
class _$AnalyzedItemCWProxyImpl implements _$AnalyzedItemCWProxy {
  const _$AnalyzedItemCWProxyImpl(this._value);

  final AnalyzedItem _value;

  @override
  AnalyzedItem itemId(String itemId) => this(itemId: itemId);

  @override
  AnalyzedItem label(String label) => this(label: label);

  @override
  AnalyzedItem foodId(String? foodId) => this(foodId: foodId);

  @override
  AnalyzedItem recipeId(String? recipeId) => this(recipeId: recipeId);

  @override
  AnalyzedItem source_(SourceRef? source_) => this(source_: source_);

  @override
  AnalyzedItem grams(num? grams) => this(grams: grams);

  @override
  AnalyzedItem gramsRange(NumberRange? gramsRange) =>
      this(gramsRange: gramsRange);

  @override
  AnalyzedItem nutrients(Nutrients? nutrients) => this(nutrients: nutrients);

  @override
  AnalyzedItem uncertainty(Uncertainty? uncertainty) =>
      this(uncertainty: uncertainty);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnalyzedItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnalyzedItem(...).copyWith(id: 12, name: "My name")
  /// ````
  AnalyzedItem call({
    Object? itemId = const $CopyWithPlaceholder(),
    Object? label = const $CopyWithPlaceholder(),
    Object? foodId = const $CopyWithPlaceholder(),
    Object? recipeId = const $CopyWithPlaceholder(),
    Object? source_ = const $CopyWithPlaceholder(),
    Object? grams = const $CopyWithPlaceholder(),
    Object? gramsRange = const $CopyWithPlaceholder(),
    Object? nutrients = const $CopyWithPlaceholder(),
    Object? uncertainty = const $CopyWithPlaceholder(),
  }) {
    return AnalyzedItem(
      itemId: itemId == const $CopyWithPlaceholder()
          ? _value.itemId
          // ignore: cast_nullable_to_non_nullable
          : itemId as String,
      label: label == const $CopyWithPlaceholder()
          ? _value.label
          // ignore: cast_nullable_to_non_nullable
          : label as String,
      foodId: foodId == const $CopyWithPlaceholder()
          ? _value.foodId
          // ignore: cast_nullable_to_non_nullable
          : foodId as String?,
      recipeId: recipeId == const $CopyWithPlaceholder()
          ? _value.recipeId
          // ignore: cast_nullable_to_non_nullable
          : recipeId as String?,
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as SourceRef?,
      grams: grams == const $CopyWithPlaceholder()
          ? _value.grams
          // ignore: cast_nullable_to_non_nullable
          : grams as num?,
      gramsRange: gramsRange == const $CopyWithPlaceholder()
          ? _value.gramsRange
          // ignore: cast_nullable_to_non_nullable
          : gramsRange as NumberRange?,
      nutrients: nutrients == const $CopyWithPlaceholder()
          ? _value.nutrients
          // ignore: cast_nullable_to_non_nullable
          : nutrients as Nutrients?,
      uncertainty: uncertainty == const $CopyWithPlaceholder()
          ? _value.uncertainty
          // ignore: cast_nullable_to_non_nullable
          : uncertainty as Uncertainty?,
    );
  }
}

extension $AnalyzedItemCopyWith on AnalyzedItem {
  /// Returns a callable class that can be used as follows: `instanceOfAnalyzedItem.copyWith(...)` or like so:`instanceOfAnalyzedItem.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AnalyzedItemCWProxy get copyWith => _$AnalyzedItemCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyzedItem _$AnalyzedItemFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'AnalyzedItem',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'item_id',
        'label',
        'food_id',
        'recipe_id',
        'source',
        'grams',
        'grams_range',
        'nutrients',
        'uncertainty',
      ],
    );
    final val = AnalyzedItem(
      itemId: $checkedConvert('item_id', (v) => v as String),
      label: $checkedConvert('label', (v) => v as String),
      foodId: $checkedConvert('food_id', (v) => v as String?),
      recipeId: $checkedConvert('recipe_id', (v) => v as String?),
      source_: $checkedConvert(
        'source',
        (v) => v == null ? null : SourceRef.fromJson(v as Map<String, dynamic>),
      ),
      grams: $checkedConvert('grams', (v) => v as num?),
      gramsRange: $checkedConvert(
        'grams_range',
        (v) =>
            v == null ? null : NumberRange.fromJson(v as Map<String, dynamic>),
      ),
      nutrients: $checkedConvert(
        'nutrients',
        (v) => v == null ? null : Nutrients.fromJson(v as Map<String, dynamic>),
      ),
      uncertainty: $checkedConvert(
        'uncertainty',
        (v) => $enumDecodeNullable(_$UncertaintyEnumMap, v),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'itemId': 'item_id',
    'foodId': 'food_id',
    'recipeId': 'recipe_id',
    'source_': 'source',
    'gramsRange': 'grams_range',
  },
);

Map<String, dynamic> _$AnalyzedItemToJson(AnalyzedItem instance) =>
    <String, dynamic>{
      'item_id': instance.itemId,
      'label': instance.label,
      'food_id': instance.foodId,
      'recipe_id': instance.recipeId,
      'source': instance.source_?.toJson(),
      'grams': instance.grams,
      'grams_range': instance.gramsRange?.toJson(),
      'nutrients': instance.nutrients?.toJson(),
      'uncertainty': _$UncertaintyEnumMap[instance.uncertainty],
    };

const _$UncertaintyEnumMap = {
  Uncertainty.low: 'low',
  Uncertainty.medium: 'medium',
  Uncertainty.high: 'high',
};
