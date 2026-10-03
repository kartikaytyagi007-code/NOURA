// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GoalCWProxy {
  Goal goalType(GoalType goalType);

  Goal targetWeightKg(num? targetWeightKg);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Goal(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Goal(...).copyWith(id: 12, name: "My name")
  /// ````
  Goal call({GoalType goalType, num? targetWeightKg});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGoal.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGoal.copyWith.fieldName(...)`
class _$GoalCWProxyImpl implements _$GoalCWProxy {
  const _$GoalCWProxyImpl(this._value);

  final Goal _value;

  @override
  Goal goalType(GoalType goalType) => this(goalType: goalType);

  @override
  Goal targetWeightKg(num? targetWeightKg) =>
      this(targetWeightKg: targetWeightKg);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Goal(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Goal(...).copyWith(id: 12, name: "My name")
  /// ````
  Goal call({
    Object? goalType = const $CopyWithPlaceholder(),
    Object? targetWeightKg = const $CopyWithPlaceholder(),
  }) {
    return Goal(
      goalType: goalType == const $CopyWithPlaceholder()
          ? _value.goalType
          // ignore: cast_nullable_to_non_nullable
          : goalType as GoalType,
      targetWeightKg: targetWeightKg == const $CopyWithPlaceholder()
          ? _value.targetWeightKg
          // ignore: cast_nullable_to_non_nullable
          : targetWeightKg as num?,
    );
  }
}

extension $GoalCopyWith on Goal {
  /// Returns a callable class that can be used as follows: `instanceOfGoal.copyWith(...)` or like so:`instanceOfGoal.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GoalCWProxy get copyWith => _$GoalCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Goal _$GoalFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Goal',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['goal_type', 'target_weight_kg']);
    final val = Goal(
      goalType: $checkedConvert(
        'goal_type',
        (v) => $enumDecode(_$GoalTypeEnumMap, v),
      ),
      targetWeightKg: $checkedConvert('target_weight_kg', (v) => v as num?),
    );
    return val;
  },
  fieldKeyMap: const {
    'goalType': 'goal_type',
    'targetWeightKg': 'target_weight_kg',
  },
);

Map<String, dynamic> _$GoalToJson(Goal instance) => <String, dynamic>{
  'goal_type': _$GoalTypeEnumMap[instance.goalType]!,
  'target_weight_kg': instance.targetWeightKg,
};

const _$GoalTypeEnumMap = {
  GoalType.loseFat: 'lose_fat',
  GoalType.maintain: 'maintain',
  GoalType.gainMuscle: 'gain_muscle',
  GoalType.generalHealth: 'general_health',
};
