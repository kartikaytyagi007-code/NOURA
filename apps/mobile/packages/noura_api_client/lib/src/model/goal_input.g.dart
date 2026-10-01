// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GoalInputCWProxy {
  GoalInput goalType(GoalType goalType);

  GoalInput targetWeightKg(num? targetWeightKg);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GoalInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GoalInput(...).copyWith(id: 12, name: "My name")
  /// ````
  GoalInput call({GoalType goalType, num? targetWeightKg});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGoalInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGoalInput.copyWith.fieldName(...)`
class _$GoalInputCWProxyImpl implements _$GoalInputCWProxy {
  const _$GoalInputCWProxyImpl(this._value);

  final GoalInput _value;

  @override
  GoalInput goalType(GoalType goalType) => this(goalType: goalType);

  @override
  GoalInput targetWeightKg(num? targetWeightKg) =>
      this(targetWeightKg: targetWeightKg);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GoalInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GoalInput(...).copyWith(id: 12, name: "My name")
  /// ````
  GoalInput call({
    Object? goalType = const $CopyWithPlaceholder(),
    Object? targetWeightKg = const $CopyWithPlaceholder(),
  }) {
    return GoalInput(
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

extension $GoalInputCopyWith on GoalInput {
  /// Returns a callable class that can be used as follows: `instanceOfGoalInput.copyWith(...)` or like so:`instanceOfGoalInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GoalInputCWProxy get copyWith => _$GoalInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoalInput _$GoalInputFromJson(Map<String, dynamic> json) => $checkedCreate(
  'GoalInput',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['goal_type']);
    final val = GoalInput(
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

Map<String, dynamic> _$GoalInputToJson(GoalInput instance) => <String, dynamic>{
  'goal_type': _$GoalTypeEnumMap[instance.goalType]!,
  'target_weight_kg': ?instance.targetWeightKg,
};

const _$GoalTypeEnumMap = {
  GoalType.loseFat: 'lose_fat',
  GoalType.maintain: 'maintain',
  GoalType.gainMuscle: 'gain_muscle',
  GoalType.generalHealth: 'general_health',
};
