// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_usage.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FeatureUsageCWProxy {
  FeatureUsage feature(FeatureUsageFeatureEnum feature);

  FeatureUsage period(String period);

  FeatureUsage limit(int? limit);

  FeatureUsage used(int used);

  FeatureUsage reserved(int reserved);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FeatureUsage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FeatureUsage(...).copyWith(id: 12, name: "My name")
  /// ````
  FeatureUsage call({
    FeatureUsageFeatureEnum feature,
    String period,
    int? limit,
    int used,
    int reserved,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFeatureUsage.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFeatureUsage.copyWith.fieldName(...)`
class _$FeatureUsageCWProxyImpl implements _$FeatureUsageCWProxy {
  const _$FeatureUsageCWProxyImpl(this._value);

  final FeatureUsage _value;

  @override
  FeatureUsage feature(FeatureUsageFeatureEnum feature) =>
      this(feature: feature);

  @override
  FeatureUsage period(String period) => this(period: period);

  @override
  FeatureUsage limit(int? limit) => this(limit: limit);

  @override
  FeatureUsage used(int used) => this(used: used);

  @override
  FeatureUsage reserved(int reserved) => this(reserved: reserved);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FeatureUsage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FeatureUsage(...).copyWith(id: 12, name: "My name")
  /// ````
  FeatureUsage call({
    Object? feature = const $CopyWithPlaceholder(),
    Object? period = const $CopyWithPlaceholder(),
    Object? limit = const $CopyWithPlaceholder(),
    Object? used = const $CopyWithPlaceholder(),
    Object? reserved = const $CopyWithPlaceholder(),
  }) {
    return FeatureUsage(
      feature: feature == const $CopyWithPlaceholder()
          ? _value.feature
          // ignore: cast_nullable_to_non_nullable
          : feature as FeatureUsageFeatureEnum,
      period: period == const $CopyWithPlaceholder()
          ? _value.period
          // ignore: cast_nullable_to_non_nullable
          : period as String,
      limit: limit == const $CopyWithPlaceholder()
          ? _value.limit
          // ignore: cast_nullable_to_non_nullable
          : limit as int?,
      used: used == const $CopyWithPlaceholder()
          ? _value.used
          // ignore: cast_nullable_to_non_nullable
          : used as int,
      reserved: reserved == const $CopyWithPlaceholder()
          ? _value.reserved
          // ignore: cast_nullable_to_non_nullable
          : reserved as int,
    );
  }
}

extension $FeatureUsageCopyWith on FeatureUsage {
  /// Returns a callable class that can be used as follows: `instanceOfFeatureUsage.copyWith(...)` or like so:`instanceOfFeatureUsage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FeatureUsageCWProxy get copyWith => _$FeatureUsageCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeatureUsage _$FeatureUsageFromJson(Map<String, dynamic> json) =>
    $checkedCreate('FeatureUsage', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['feature', 'period', 'limit', 'used', 'reserved'],
      );
      final val = FeatureUsage(
        feature: $checkedConvert(
          'feature',
          (v) => $enumDecode(_$FeatureUsageFeatureEnumEnumMap, v),
        ),
        period: $checkedConvert('period', (v) => v as String),
        limit: $checkedConvert('limit', (v) => (v as num?)?.toInt()),
        used: $checkedConvert('used', (v) => (v as num).toInt()),
        reserved: $checkedConvert('reserved', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$FeatureUsageToJson(FeatureUsage instance) =>
    <String, dynamic>{
      'feature': _$FeatureUsageFeatureEnumEnumMap[instance.feature]!,
      'period': instance.period,
      'limit': instance.limit,
      'used': instance.used,
      'reserved': instance.reserved,
    };

const _$FeatureUsageFeatureEnumEnumMap = {
  FeatureUsageFeatureEnum.mealScan: 'meal_scan',
  FeatureUsageFeatureEnum.coachReply: 'coach_reply',
  FeatureUsageFeatureEnum.dietPlan: 'diet_plan',
  FeatureUsageFeatureEnum.workoutPlan: 'workout_plan',
  FeatureUsageFeatureEnum.planRegeneration: 'plan_regeneration',
};
