// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diet_plan.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DietPlanCWProxy {
  DietPlan id(String id);

  DietPlan version(int version);

  DietPlan startsOn(DateTime startsOn);

  DietPlan status(DietPlanStatusEnum status);

  DietPlan targetSnapshotId(String targetSnapshotId);

  DietPlan days(List<PlanDay> days);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DietPlan(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DietPlan(...).copyWith(id: 12, name: "My name")
  /// ````
  DietPlan call({
    String id,
    int version,
    DateTime startsOn,
    DietPlanStatusEnum status,
    String targetSnapshotId,
    List<PlanDay> days,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDietPlan.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDietPlan.copyWith.fieldName(...)`
class _$DietPlanCWProxyImpl implements _$DietPlanCWProxy {
  const _$DietPlanCWProxyImpl(this._value);

  final DietPlan _value;

  @override
  DietPlan id(String id) => this(id: id);

  @override
  DietPlan version(int version) => this(version: version);

  @override
  DietPlan startsOn(DateTime startsOn) => this(startsOn: startsOn);

  @override
  DietPlan status(DietPlanStatusEnum status) => this(status: status);

  @override
  DietPlan targetSnapshotId(String targetSnapshotId) =>
      this(targetSnapshotId: targetSnapshotId);

  @override
  DietPlan days(List<PlanDay> days) => this(days: days);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DietPlan(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DietPlan(...).copyWith(id: 12, name: "My name")
  /// ````
  DietPlan call({
    Object? id = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? startsOn = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? targetSnapshotId = const $CopyWithPlaceholder(),
    Object? days = const $CopyWithPlaceholder(),
  }) {
    return DietPlan(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
      startsOn: startsOn == const $CopyWithPlaceholder()
          ? _value.startsOn
          // ignore: cast_nullable_to_non_nullable
          : startsOn as DateTime,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as DietPlanStatusEnum,
      targetSnapshotId: targetSnapshotId == const $CopyWithPlaceholder()
          ? _value.targetSnapshotId
          // ignore: cast_nullable_to_non_nullable
          : targetSnapshotId as String,
      days: days == const $CopyWithPlaceholder()
          ? _value.days
          // ignore: cast_nullable_to_non_nullable
          : days as List<PlanDay>,
    );
  }
}

extension $DietPlanCopyWith on DietPlan {
  /// Returns a callable class that can be used as follows: `instanceOfDietPlan.copyWith(...)` or like so:`instanceOfDietPlan.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DietPlanCWProxy get copyWith => _$DietPlanCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DietPlan _$DietPlanFromJson(Map<String, dynamic> json) => $checkedCreate(
  'DietPlan',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'version',
        'starts_on',
        'status',
        'target_snapshot_id',
        'days',
      ],
    );
    final val = DietPlan(
      id: $checkedConvert('id', (v) => v as String),
      version: $checkedConvert('version', (v) => (v as num).toInt()),
      startsOn: $checkedConvert(
        'starts_on',
        (v) => DateTime.parse(v as String),
      ),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$DietPlanStatusEnumEnumMap, v),
      ),
      targetSnapshotId: $checkedConvert(
        'target_snapshot_id',
        (v) => v as String,
      ),
      days: $checkedConvert(
        'days',
        (v) => (v as List<dynamic>)
            .map((e) => PlanDay.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'startsOn': 'starts_on',
    'targetSnapshotId': 'target_snapshot_id',
  },
);

Map<String, dynamic> _$DietPlanToJson(DietPlan instance) => <String, dynamic>{
  'id': instance.id,
  'version': instance.version,
  'starts_on': instance.startsOn.toIso8601String(),
  'status': _$DietPlanStatusEnumEnumMap[instance.status]!,
  'target_snapshot_id': instance.targetSnapshotId,
  'days': instance.days.map((e) => e.toJson()).toList(),
};

const _$DietPlanStatusEnumEnumMap = {
  DietPlanStatusEnum.active: 'active',
  DietPlanStatusEnum.superseded: 'superseded',
};
