// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'next_meal_action_result.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NextMealActionResultCWProxy {
  NextMealActionResult action(NextMealActionType action);

  NextMealActionResult planMeal(PlanMeal? planMeal);

  NextMealActionResult dismissed(bool dismissed);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NextMealActionResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NextMealActionResult(...).copyWith(id: 12, name: "My name")
  /// ````
  NextMealActionResult call({
    NextMealActionType action,
    PlanMeal? planMeal,
    bool dismissed,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNextMealActionResult.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNextMealActionResult.copyWith.fieldName(...)`
class _$NextMealActionResultCWProxyImpl
    implements _$NextMealActionResultCWProxy {
  const _$NextMealActionResultCWProxyImpl(this._value);

  final NextMealActionResult _value;

  @override
  NextMealActionResult action(NextMealActionType action) =>
      this(action: action);

  @override
  NextMealActionResult planMeal(PlanMeal? planMeal) => this(planMeal: planMeal);

  @override
  NextMealActionResult dismissed(bool dismissed) => this(dismissed: dismissed);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NextMealActionResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NextMealActionResult(...).copyWith(id: 12, name: "My name")
  /// ````
  NextMealActionResult call({
    Object? action = const $CopyWithPlaceholder(),
    Object? planMeal = const $CopyWithPlaceholder(),
    Object? dismissed = const $CopyWithPlaceholder(),
  }) {
    return NextMealActionResult(
      action: action == const $CopyWithPlaceholder()
          ? _value.action
          // ignore: cast_nullable_to_non_nullable
          : action as NextMealActionType,
      planMeal: planMeal == const $CopyWithPlaceholder()
          ? _value.planMeal
          // ignore: cast_nullable_to_non_nullable
          : planMeal as PlanMeal?,
      dismissed: dismissed == const $CopyWithPlaceholder()
          ? _value.dismissed
          // ignore: cast_nullable_to_non_nullable
          : dismissed as bool,
    );
  }
}

extension $NextMealActionResultCopyWith on NextMealActionResult {
  /// Returns a callable class that can be used as follows: `instanceOfNextMealActionResult.copyWith(...)` or like so:`instanceOfNextMealActionResult.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NextMealActionResultCWProxy get copyWith =>
      _$NextMealActionResultCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NextMealActionResult _$NextMealActionResultFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('NextMealActionResult', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['action', 'plan_meal', 'dismissed']);
  final val = NextMealActionResult(
    action: $checkedConvert(
      'action',
      (v) => $enumDecode(_$NextMealActionTypeEnumMap, v),
    ),
    planMeal: $checkedConvert(
      'plan_meal',
      (v) => v == null ? null : PlanMeal.fromJson(v as Map<String, dynamic>),
    ),
    dismissed: $checkedConvert('dismissed', (v) => v as bool),
  );
  return val;
}, fieldKeyMap: const {'planMeal': 'plan_meal'});

Map<String, dynamic> _$NextMealActionResultToJson(
  NextMealActionResult instance,
) => <String, dynamic>{
  'action': _$NextMealActionTypeEnumMap[instance.action]!,
  'plan_meal': instance.planMeal?.toJson(),
  'dismissed': instance.dismissed,
};

const _$NextMealActionTypeEnumMap = {
  NextMealActionType.add: 'add',
  NextMealActionType.swap: 'swap',
  NextMealActionType.dismiss: 'dismiss',
};
