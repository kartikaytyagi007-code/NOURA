// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_log.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MealLogCWProxy {
  MealLog id(String id);

  MealLog clientId(String clientId);

  MealLog consumedAt(DateTime consumedAt);

  MealLog localDate(DateTime localDate);

  MealLog slot(MealSlot slot);

  MealLog scanId(String? scanId);

  MealLog planMealId(String? planMealId);

  MealLog items(List<AnalyzedItem> items);

  MealLog totals(NutrientTotals totals);

  MealLog mealBalance(MealBalance? mealBalance);

  MealLog revision(int revision);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealLog(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealLog(...).copyWith(id: 12, name: "My name")
  /// ````
  MealLog call({
    String id,
    String clientId,
    DateTime consumedAt,
    DateTime localDate,
    MealSlot slot,
    String? scanId,
    String? planMealId,
    List<AnalyzedItem> items,
    NutrientTotals totals,
    MealBalance? mealBalance,
    int revision,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMealLog.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMealLog.copyWith.fieldName(...)`
class _$MealLogCWProxyImpl implements _$MealLogCWProxy {
  const _$MealLogCWProxyImpl(this._value);

  final MealLog _value;

  @override
  MealLog id(String id) => this(id: id);

  @override
  MealLog clientId(String clientId) => this(clientId: clientId);

  @override
  MealLog consumedAt(DateTime consumedAt) => this(consumedAt: consumedAt);

  @override
  MealLog localDate(DateTime localDate) => this(localDate: localDate);

  @override
  MealLog slot(MealSlot slot) => this(slot: slot);

  @override
  MealLog scanId(String? scanId) => this(scanId: scanId);

  @override
  MealLog planMealId(String? planMealId) => this(planMealId: planMealId);

  @override
  MealLog items(List<AnalyzedItem> items) => this(items: items);

  @override
  MealLog totals(NutrientTotals totals) => this(totals: totals);

  @override
  MealLog mealBalance(MealBalance? mealBalance) =>
      this(mealBalance: mealBalance);

  @override
  MealLog revision(int revision) => this(revision: revision);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealLog(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealLog(...).copyWith(id: 12, name: "My name")
  /// ````
  MealLog call({
    Object? id = const $CopyWithPlaceholder(),
    Object? clientId = const $CopyWithPlaceholder(),
    Object? consumedAt = const $CopyWithPlaceholder(),
    Object? localDate = const $CopyWithPlaceholder(),
    Object? slot = const $CopyWithPlaceholder(),
    Object? scanId = const $CopyWithPlaceholder(),
    Object? planMealId = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
    Object? totals = const $CopyWithPlaceholder(),
    Object? mealBalance = const $CopyWithPlaceholder(),
    Object? revision = const $CopyWithPlaceholder(),
  }) {
    return MealLog(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      clientId: clientId == const $CopyWithPlaceholder()
          ? _value.clientId
          // ignore: cast_nullable_to_non_nullable
          : clientId as String,
      consumedAt: consumedAt == const $CopyWithPlaceholder()
          ? _value.consumedAt
          // ignore: cast_nullable_to_non_nullable
          : consumedAt as DateTime,
      localDate: localDate == const $CopyWithPlaceholder()
          ? _value.localDate
          // ignore: cast_nullable_to_non_nullable
          : localDate as DateTime,
      slot: slot == const $CopyWithPlaceholder()
          ? _value.slot
          // ignore: cast_nullable_to_non_nullable
          : slot as MealSlot,
      scanId: scanId == const $CopyWithPlaceholder()
          ? _value.scanId
          // ignore: cast_nullable_to_non_nullable
          : scanId as String?,
      planMealId: planMealId == const $CopyWithPlaceholder()
          ? _value.planMealId
          // ignore: cast_nullable_to_non_nullable
          : planMealId as String?,
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<AnalyzedItem>,
      totals: totals == const $CopyWithPlaceholder()
          ? _value.totals
          // ignore: cast_nullable_to_non_nullable
          : totals as NutrientTotals,
      mealBalance: mealBalance == const $CopyWithPlaceholder()
          ? _value.mealBalance
          // ignore: cast_nullable_to_non_nullable
          : mealBalance as MealBalance?,
      revision: revision == const $CopyWithPlaceholder()
          ? _value.revision
          // ignore: cast_nullable_to_non_nullable
          : revision as int,
    );
  }
}

extension $MealLogCopyWith on MealLog {
  /// Returns a callable class that can be used as follows: `instanceOfMealLog.copyWith(...)` or like so:`instanceOfMealLog.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MealLogCWProxy get copyWith => _$MealLogCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealLog _$MealLogFromJson(Map<String, dynamic> json) => $checkedCreate(
  'MealLog',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'client_id',
        'consumed_at',
        'local_date',
        'slot',
        'scan_id',
        'plan_meal_id',
        'items',
        'totals',
        'meal_balance',
        'revision',
      ],
    );
    final val = MealLog(
      id: $checkedConvert('id', (v) => v as String),
      clientId: $checkedConvert('client_id', (v) => v as String),
      consumedAt: $checkedConvert(
        'consumed_at',
        (v) => DateTime.parse(v as String),
      ),
      localDate: $checkedConvert(
        'local_date',
        (v) => DateTime.parse(v as String),
      ),
      slot: $checkedConvert('slot', (v) => $enumDecode(_$MealSlotEnumMap, v)),
      scanId: $checkedConvert('scan_id', (v) => v as String?),
      planMealId: $checkedConvert('plan_meal_id', (v) => v as String?),
      items: $checkedConvert(
        'items',
        (v) => (v as List<dynamic>)
            .map((e) => AnalyzedItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      totals: $checkedConvert(
        'totals',
        (v) => NutrientTotals.fromJson(v as Map<String, dynamic>),
      ),
      mealBalance: $checkedConvert(
        'meal_balance',
        (v) =>
            v == null ? null : MealBalance.fromJson(v as Map<String, dynamic>),
      ),
      revision: $checkedConvert('revision', (v) => (v as num).toInt()),
    );
    return val;
  },
  fieldKeyMap: const {
    'clientId': 'client_id',
    'consumedAt': 'consumed_at',
    'localDate': 'local_date',
    'scanId': 'scan_id',
    'planMealId': 'plan_meal_id',
    'mealBalance': 'meal_balance',
  },
);

Map<String, dynamic> _$MealLogToJson(MealLog instance) => <String, dynamic>{
  'id': instance.id,
  'client_id': instance.clientId,
  'consumed_at': instance.consumedAt.toIso8601String(),
  'local_date': instance.localDate.toIso8601String(),
  'slot': _$MealSlotEnumMap[instance.slot]!,
  'scan_id': instance.scanId,
  'plan_meal_id': instance.planMealId,
  'items': instance.items.map((e) => e.toJson()).toList(),
  'totals': instance.totals.toJson(),
  'meal_balance': instance.mealBalance?.toJson(),
  'revision': instance.revision,
};

const _$MealSlotEnumMap = {
  MealSlot.breakfast: 'breakfast',
  MealSlot.lunch: 'lunch',
  MealSlot.dinner: 'dinner',
  MealSlot.snack: 'snack',
};
