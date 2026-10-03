// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'next_meal_action_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NextMealActionRequestCWProxy {
  NextMealActionRequest date(DateTime date);

  NextMealActionRequest slot(MealSlot slot);

  NextMealActionRequest action(NextMealActionType action);

  NextMealActionRequest candidateId(String? candidateId);

  NextMealActionRequest targetPlanMealId(String? targetPlanMealId);

  NextMealActionRequest expectedRevision(int? expectedRevision);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NextMealActionRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NextMealActionRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  NextMealActionRequest call({
    DateTime date,
    MealSlot slot,
    NextMealActionType action,
    String? candidateId,
    String? targetPlanMealId,
    int? expectedRevision,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNextMealActionRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNextMealActionRequest.copyWith.fieldName(...)`
class _$NextMealActionRequestCWProxyImpl
    implements _$NextMealActionRequestCWProxy {
  const _$NextMealActionRequestCWProxyImpl(this._value);

  final NextMealActionRequest _value;

  @override
  NextMealActionRequest date(DateTime date) => this(date: date);

  @override
  NextMealActionRequest slot(MealSlot slot) => this(slot: slot);

  @override
  NextMealActionRequest action(NextMealActionType action) =>
      this(action: action);

  @override
  NextMealActionRequest candidateId(String? candidateId) =>
      this(candidateId: candidateId);

  @override
  NextMealActionRequest targetPlanMealId(String? targetPlanMealId) =>
      this(targetPlanMealId: targetPlanMealId);

  @override
  NextMealActionRequest expectedRevision(int? expectedRevision) =>
      this(expectedRevision: expectedRevision);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NextMealActionRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NextMealActionRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  NextMealActionRequest call({
    Object? date = const $CopyWithPlaceholder(),
    Object? slot = const $CopyWithPlaceholder(),
    Object? action = const $CopyWithPlaceholder(),
    Object? candidateId = const $CopyWithPlaceholder(),
    Object? targetPlanMealId = const $CopyWithPlaceholder(),
    Object? expectedRevision = const $CopyWithPlaceholder(),
  }) {
    return NextMealActionRequest(
      date: date == const $CopyWithPlaceholder()
          ? _value.date
          // ignore: cast_nullable_to_non_nullable
          : date as DateTime,
      slot: slot == const $CopyWithPlaceholder()
          ? _value.slot
          // ignore: cast_nullable_to_non_nullable
          : slot as MealSlot,
      action: action == const $CopyWithPlaceholder()
          ? _value.action
          // ignore: cast_nullable_to_non_nullable
          : action as NextMealActionType,
      candidateId: candidateId == const $CopyWithPlaceholder()
          ? _value.candidateId
          // ignore: cast_nullable_to_non_nullable
          : candidateId as String?,
      targetPlanMealId: targetPlanMealId == const $CopyWithPlaceholder()
          ? _value.targetPlanMealId
          // ignore: cast_nullable_to_non_nullable
          : targetPlanMealId as String?,
      expectedRevision: expectedRevision == const $CopyWithPlaceholder()
          ? _value.expectedRevision
          // ignore: cast_nullable_to_non_nullable
          : expectedRevision as int?,
    );
  }
}

extension $NextMealActionRequestCopyWith on NextMealActionRequest {
  /// Returns a callable class that can be used as follows: `instanceOfNextMealActionRequest.copyWith(...)` or like so:`instanceOfNextMealActionRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NextMealActionRequestCWProxy get copyWith =>
      _$NextMealActionRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NextMealActionRequest _$NextMealActionRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'NextMealActionRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['date', 'slot', 'action']);
    final val = NextMealActionRequest(
      date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
      slot: $checkedConvert('slot', (v) => $enumDecode(_$MealSlotEnumMap, v)),
      action: $checkedConvert(
        'action',
        (v) => $enumDecode(_$NextMealActionTypeEnumMap, v),
      ),
      candidateId: $checkedConvert('candidate_id', (v) => v as String?),
      targetPlanMealId: $checkedConvert(
        'target_plan_meal_id',
        (v) => v as String?,
      ),
      expectedRevision: $checkedConvert(
        'expected_revision',
        (v) => (v as num?)?.toInt(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'candidateId': 'candidate_id',
    'targetPlanMealId': 'target_plan_meal_id',
    'expectedRevision': 'expected_revision',
  },
);

Map<String, dynamic> _$NextMealActionRequestToJson(
  NextMealActionRequest instance,
) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'slot': _$MealSlotEnumMap[instance.slot]!,
  'action': _$NextMealActionTypeEnumMap[instance.action]!,
  'candidate_id': ?instance.candidateId,
  'target_plan_meal_id': ?instance.targetPlanMealId,
  'expected_revision': ?instance.expectedRevision,
};

const _$MealSlotEnumMap = {
  MealSlot.breakfast: 'breakfast',
  MealSlot.lunch: 'lunch',
  MealSlot.dinner: 'dinner',
  MealSlot.snack: 'snack',
};

const _$NextMealActionTypeEnumMap = {
  NextMealActionType.add: 'add',
  NextMealActionType.swap: 'swap',
  NextMealActionType.dismiss: 'dismiss',
};
