// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_meal_log_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateMealLogRequestCWProxy {
  CreateMealLogRequest clientId(String clientId);

  CreateMealLogRequest consumedAt(DateTime consumedAt);

  CreateMealLogRequest timezone(String timezone);

  CreateMealLogRequest slot(MealSlot slot);

  CreateMealLogRequest scanId(String? scanId);

  CreateMealLogRequest planMealId(String? planMealId);

  CreateMealLogRequest items(List<ConfirmedItemInput> items);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateMealLogRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateMealLogRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateMealLogRequest call({
    String clientId,
    DateTime consumedAt,
    String timezone,
    MealSlot slot,
    String? scanId,
    String? planMealId,
    List<ConfirmedItemInput> items,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateMealLogRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateMealLogRequest.copyWith.fieldName(...)`
class _$CreateMealLogRequestCWProxyImpl
    implements _$CreateMealLogRequestCWProxy {
  const _$CreateMealLogRequestCWProxyImpl(this._value);

  final CreateMealLogRequest _value;

  @override
  CreateMealLogRequest clientId(String clientId) => this(clientId: clientId);

  @override
  CreateMealLogRequest consumedAt(DateTime consumedAt) =>
      this(consumedAt: consumedAt);

  @override
  CreateMealLogRequest timezone(String timezone) => this(timezone: timezone);

  @override
  CreateMealLogRequest slot(MealSlot slot) => this(slot: slot);

  @override
  CreateMealLogRequest scanId(String? scanId) => this(scanId: scanId);

  @override
  CreateMealLogRequest planMealId(String? planMealId) =>
      this(planMealId: planMealId);

  @override
  CreateMealLogRequest items(List<ConfirmedItemInput> items) =>
      this(items: items);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateMealLogRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateMealLogRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateMealLogRequest call({
    Object? clientId = const $CopyWithPlaceholder(),
    Object? consumedAt = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
    Object? slot = const $CopyWithPlaceholder(),
    Object? scanId = const $CopyWithPlaceholder(),
    Object? planMealId = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return CreateMealLogRequest(
      clientId: clientId == const $CopyWithPlaceholder()
          ? _value.clientId
          // ignore: cast_nullable_to_non_nullable
          : clientId as String,
      consumedAt: consumedAt == const $CopyWithPlaceholder()
          ? _value.consumedAt
          // ignore: cast_nullable_to_non_nullable
          : consumedAt as DateTime,
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String,
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
          : items as List<ConfirmedItemInput>,
    );
  }
}

extension $CreateMealLogRequestCopyWith on CreateMealLogRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateMealLogRequest.copyWith(...)` or like so:`instanceOfCreateMealLogRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateMealLogRequestCWProxy get copyWith =>
      _$CreateMealLogRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateMealLogRequest _$CreateMealLogRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CreateMealLogRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'client_id',
        'consumed_at',
        'timezone',
        'slot',
        'items',
      ],
    );
    final val = CreateMealLogRequest(
      clientId: $checkedConvert('client_id', (v) => v as String),
      consumedAt: $checkedConvert(
        'consumed_at',
        (v) => DateTime.parse(v as String),
      ),
      timezone: $checkedConvert('timezone', (v) => v as String),
      slot: $checkedConvert('slot', (v) => $enumDecode(_$MealSlotEnumMap, v)),
      scanId: $checkedConvert('scan_id', (v) => v as String?),
      planMealId: $checkedConvert('plan_meal_id', (v) => v as String?),
      items: $checkedConvert(
        'items',
        (v) => (v as List<dynamic>)
            .map((e) => ConfirmedItemInput.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'clientId': 'client_id',
    'consumedAt': 'consumed_at',
    'scanId': 'scan_id',
    'planMealId': 'plan_meal_id',
  },
);

Map<String, dynamic> _$CreateMealLogRequestToJson(
  CreateMealLogRequest instance,
) => <String, dynamic>{
  'client_id': instance.clientId,
  'consumed_at': instance.consumedAt.toIso8601String(),
  'timezone': instance.timezone,
  'slot': _$MealSlotEnumMap[instance.slot]!,
  'scan_id': ?instance.scanId,
  'plan_meal_id': ?instance.planMealId,
  'items': instance.items.map((e) => e.toJson()).toList(),
};

const _$MealSlotEnumMap = {
  MealSlot.breakfast: 'breakfast',
  MealSlot.lunch: 'lunch',
  MealSlot.dinner: 'dinner',
  MealSlot.snack: 'snack',
};
