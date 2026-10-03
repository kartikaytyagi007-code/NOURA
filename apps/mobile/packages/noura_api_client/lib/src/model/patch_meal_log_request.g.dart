// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_meal_log_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PatchMealLogRequestCWProxy {
  PatchMealLogRequest expectedRevision(int expectedRevision);

  PatchMealLogRequest consumedAt(DateTime? consumedAt);

  PatchMealLogRequest slot(MealSlot? slot);

  PatchMealLogRequest items(List<ConfirmedItemInput>? items);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PatchMealLogRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PatchMealLogRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PatchMealLogRequest call({
    int expectedRevision,
    DateTime? consumedAt,
    MealSlot? slot,
    List<ConfirmedItemInput>? items,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPatchMealLogRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPatchMealLogRequest.copyWith.fieldName(...)`
class _$PatchMealLogRequestCWProxyImpl implements _$PatchMealLogRequestCWProxy {
  const _$PatchMealLogRequestCWProxyImpl(this._value);

  final PatchMealLogRequest _value;

  @override
  PatchMealLogRequest expectedRevision(int expectedRevision) =>
      this(expectedRevision: expectedRevision);

  @override
  PatchMealLogRequest consumedAt(DateTime? consumedAt) =>
      this(consumedAt: consumedAt);

  @override
  PatchMealLogRequest slot(MealSlot? slot) => this(slot: slot);

  @override
  PatchMealLogRequest items(List<ConfirmedItemInput>? items) =>
      this(items: items);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PatchMealLogRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PatchMealLogRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PatchMealLogRequest call({
    Object? expectedRevision = const $CopyWithPlaceholder(),
    Object? consumedAt = const $CopyWithPlaceholder(),
    Object? slot = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return PatchMealLogRequest(
      expectedRevision: expectedRevision == const $CopyWithPlaceholder()
          ? _value.expectedRevision
          // ignore: cast_nullable_to_non_nullable
          : expectedRevision as int,
      consumedAt: consumedAt == const $CopyWithPlaceholder()
          ? _value.consumedAt
          // ignore: cast_nullable_to_non_nullable
          : consumedAt as DateTime?,
      slot: slot == const $CopyWithPlaceholder()
          ? _value.slot
          // ignore: cast_nullable_to_non_nullable
          : slot as MealSlot?,
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<ConfirmedItemInput>?,
    );
  }
}

extension $PatchMealLogRequestCopyWith on PatchMealLogRequest {
  /// Returns a callable class that can be used as follows: `instanceOfPatchMealLogRequest.copyWith(...)` or like so:`instanceOfPatchMealLogRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PatchMealLogRequestCWProxy get copyWith =>
      _$PatchMealLogRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchMealLogRequest _$PatchMealLogRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PatchMealLogRequest',
      json,
      ($checkedConvert) {
        $checkKeys(json, requiredKeys: const ['expected_revision']);
        final val = PatchMealLogRequest(
          expectedRevision: $checkedConvert(
            'expected_revision',
            (v) => (v as num).toInt(),
          ),
          consumedAt: $checkedConvert(
            'consumed_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          slot: $checkedConvert(
            'slot',
            (v) => $enumDecodeNullable(_$MealSlotEnumMap, v),
          ),
          items: $checkedConvert(
            'items',
            (v) => (v as List<dynamic>?)
                ?.map(
                  (e) => ConfirmedItemInput.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'expectedRevision': 'expected_revision',
        'consumedAt': 'consumed_at',
      },
    );

Map<String, dynamic> _$PatchMealLogRequestToJson(
  PatchMealLogRequest instance,
) => <String, dynamic>{
  'expected_revision': instance.expectedRevision,
  'consumed_at': ?instance.consumedAt?.toIso8601String(),
  'slot': ?_$MealSlotEnumMap[instance.slot],
  'items': ?instance.items?.map((e) => e.toJson()).toList(),
};

const _$MealSlotEnumMap = {
  MealSlot.breakfast: 'breakfast',
  MealSlot.lunch: 'lunch',
  MealSlot.dinner: 'dinner',
  MealSlot.snack: 'snack',
};
