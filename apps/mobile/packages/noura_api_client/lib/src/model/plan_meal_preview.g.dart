// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_meal_preview.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PlanMealPreviewCWProxy {
  PlanMealPreview planMealId(String planMealId);

  PlanMealPreview slot(MealSlot slot);

  PlanMealPreview title(String title);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlanMealPreview(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlanMealPreview(...).copyWith(id: 12, name: "My name")
  /// ````
  PlanMealPreview call({String planMealId, MealSlot slot, String title});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPlanMealPreview.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPlanMealPreview.copyWith.fieldName(...)`
class _$PlanMealPreviewCWProxyImpl implements _$PlanMealPreviewCWProxy {
  const _$PlanMealPreviewCWProxyImpl(this._value);

  final PlanMealPreview _value;

  @override
  PlanMealPreview planMealId(String planMealId) => this(planMealId: planMealId);

  @override
  PlanMealPreview slot(MealSlot slot) => this(slot: slot);

  @override
  PlanMealPreview title(String title) => this(title: title);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlanMealPreview(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlanMealPreview(...).copyWith(id: 12, name: "My name")
  /// ````
  PlanMealPreview call({
    Object? planMealId = const $CopyWithPlaceholder(),
    Object? slot = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
  }) {
    return PlanMealPreview(
      planMealId: planMealId == const $CopyWithPlaceholder()
          ? _value.planMealId
          // ignore: cast_nullable_to_non_nullable
          : planMealId as String,
      slot: slot == const $CopyWithPlaceholder()
          ? _value.slot
          // ignore: cast_nullable_to_non_nullable
          : slot as MealSlot,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
    );
  }
}

extension $PlanMealPreviewCopyWith on PlanMealPreview {
  /// Returns a callable class that can be used as follows: `instanceOfPlanMealPreview.copyWith(...)` or like so:`instanceOfPlanMealPreview.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PlanMealPreviewCWProxy get copyWith => _$PlanMealPreviewCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlanMealPreview _$PlanMealPreviewFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PlanMealPreview', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['plan_meal_id', 'slot', 'title']);
      final val = PlanMealPreview(
        planMealId: $checkedConvert('plan_meal_id', (v) => v as String),
        slot: $checkedConvert('slot', (v) => $enumDecode(_$MealSlotEnumMap, v)),
        title: $checkedConvert('title', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'planMealId': 'plan_meal_id'});

Map<String, dynamic> _$PlanMealPreviewToJson(PlanMealPreview instance) =>
    <String, dynamic>{
      'plan_meal_id': instance.planMealId,
      'slot': _$MealSlotEnumMap[instance.slot]!,
      'title': instance.title,
    };

const _$MealSlotEnumMap = {
  MealSlot.breakfast: 'breakfast',
  MealSlot.lunch: 'lunch',
  MealSlot.dinner: 'dinner',
  MealSlot.snack: 'snack',
};
