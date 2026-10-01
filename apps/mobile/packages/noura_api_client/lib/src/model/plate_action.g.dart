// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plate_action.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PlateActionCWProxy {
  PlateAction type(PlateActionTypeEnum type);

  PlateAction itemId(String? itemId);

  PlateAction catalogFoodId(String? catalogFoodId);

  PlateAction proposedGrams(num? proposedGrams);

  PlateAction reason(String reason);

  PlateAction projected(ProjectedScenario projected);

  PlateAction requiresConfirmation(bool requiresConfirmation);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlateAction(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlateAction(...).copyWith(id: 12, name: "My name")
  /// ````
  PlateAction call({
    PlateActionTypeEnum type,
    String? itemId,
    String? catalogFoodId,
    num? proposedGrams,
    String reason,
    ProjectedScenario projected,
    bool requiresConfirmation,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPlateAction.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPlateAction.copyWith.fieldName(...)`
class _$PlateActionCWProxyImpl implements _$PlateActionCWProxy {
  const _$PlateActionCWProxyImpl(this._value);

  final PlateAction _value;

  @override
  PlateAction type(PlateActionTypeEnum type) => this(type: type);

  @override
  PlateAction itemId(String? itemId) => this(itemId: itemId);

  @override
  PlateAction catalogFoodId(String? catalogFoodId) =>
      this(catalogFoodId: catalogFoodId);

  @override
  PlateAction proposedGrams(num? proposedGrams) =>
      this(proposedGrams: proposedGrams);

  @override
  PlateAction reason(String reason) => this(reason: reason);

  @override
  PlateAction projected(ProjectedScenario projected) =>
      this(projected: projected);

  @override
  PlateAction requiresConfirmation(bool requiresConfirmation) =>
      this(requiresConfirmation: requiresConfirmation);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlateAction(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlateAction(...).copyWith(id: 12, name: "My name")
  /// ````
  PlateAction call({
    Object? type = const $CopyWithPlaceholder(),
    Object? itemId = const $CopyWithPlaceholder(),
    Object? catalogFoodId = const $CopyWithPlaceholder(),
    Object? proposedGrams = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
    Object? projected = const $CopyWithPlaceholder(),
    Object? requiresConfirmation = const $CopyWithPlaceholder(),
  }) {
    return PlateAction(
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as PlateActionTypeEnum,
      itemId: itemId == const $CopyWithPlaceholder()
          ? _value.itemId
          // ignore: cast_nullable_to_non_nullable
          : itemId as String?,
      catalogFoodId: catalogFoodId == const $CopyWithPlaceholder()
          ? _value.catalogFoodId
          // ignore: cast_nullable_to_non_nullable
          : catalogFoodId as String?,
      proposedGrams: proposedGrams == const $CopyWithPlaceholder()
          ? _value.proposedGrams
          // ignore: cast_nullable_to_non_nullable
          : proposedGrams as num?,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String,
      projected: projected == const $CopyWithPlaceholder()
          ? _value.projected
          // ignore: cast_nullable_to_non_nullable
          : projected as ProjectedScenario,
      requiresConfirmation: requiresConfirmation == const $CopyWithPlaceholder()
          ? _value.requiresConfirmation
          // ignore: cast_nullable_to_non_nullable
          : requiresConfirmation as bool,
    );
  }
}

extension $PlateActionCopyWith on PlateAction {
  /// Returns a callable class that can be used as follows: `instanceOfPlateAction.copyWith(...)` or like so:`instanceOfPlateAction.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PlateActionCWProxy get copyWith => _$PlateActionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlateAction _$PlateActionFromJson(Map<String, dynamic> json) => $checkedCreate(
  'PlateAction',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'type',
        'item_id',
        'catalog_food_id',
        'proposed_grams',
        'reason',
        'projected',
        'requires_confirmation',
      ],
    );
    final val = PlateAction(
      type: $checkedConvert(
        'type',
        (v) => $enumDecode(_$PlateActionTypeEnumEnumMap, v),
      ),
      itemId: $checkedConvert('item_id', (v) => v as String?),
      catalogFoodId: $checkedConvert('catalog_food_id', (v) => v as String?),
      proposedGrams: $checkedConvert('proposed_grams', (v) => v as num?),
      reason: $checkedConvert('reason', (v) => v as String),
      projected: $checkedConvert(
        'projected',
        (v) => ProjectedScenario.fromJson(v as Map<String, dynamic>),
      ),
      requiresConfirmation: $checkedConvert(
        'requires_confirmation',
        (v) => v as bool,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'itemId': 'item_id',
    'catalogFoodId': 'catalog_food_id',
    'proposedGrams': 'proposed_grams',
    'requiresConfirmation': 'requires_confirmation',
  },
);

Map<String, dynamic> _$PlateActionToJson(PlateAction instance) =>
    <String, dynamic>{
      'type': _$PlateActionTypeEnumEnumMap[instance.type]!,
      'item_id': instance.itemId,
      'catalog_food_id': instance.catalogFoodId,
      'proposed_grams': instance.proposedGrams,
      'reason': instance.reason,
      'projected': instance.projected.toJson(),
      'requires_confirmation': instance.requiresConfirmation,
    };

const _$PlateActionTypeEnumEnumMap = {
  PlateActionTypeEnum.keep: 'keep',
  PlateActionTypeEnum.reduce: 'reduce',
  PlateActionTypeEnum.add: 'add',
  PlateActionTypeEnum.replace: 'replace',
};
