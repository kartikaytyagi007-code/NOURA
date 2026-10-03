// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projected_scenario.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ProjectedScenarioCWProxy {
  ProjectedScenario label(ProjectedScenarioLabelEnum label);

  ProjectedScenario totals(NutrientTotals totals);

  ProjectedScenario mealBalance(MealBalance mealBalance);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ProjectedScenario(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ProjectedScenario(...).copyWith(id: 12, name: "My name")
  /// ````
  ProjectedScenario call({
    ProjectedScenarioLabelEnum label,
    NutrientTotals totals,
    MealBalance mealBalance,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfProjectedScenario.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfProjectedScenario.copyWith.fieldName(...)`
class _$ProjectedScenarioCWProxyImpl implements _$ProjectedScenarioCWProxy {
  const _$ProjectedScenarioCWProxyImpl(this._value);

  final ProjectedScenario _value;

  @override
  ProjectedScenario label(ProjectedScenarioLabelEnum label) =>
      this(label: label);

  @override
  ProjectedScenario totals(NutrientTotals totals) => this(totals: totals);

  @override
  ProjectedScenario mealBalance(MealBalance mealBalance) =>
      this(mealBalance: mealBalance);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ProjectedScenario(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ProjectedScenario(...).copyWith(id: 12, name: "My name")
  /// ````
  ProjectedScenario call({
    Object? label = const $CopyWithPlaceholder(),
    Object? totals = const $CopyWithPlaceholder(),
    Object? mealBalance = const $CopyWithPlaceholder(),
  }) {
    return ProjectedScenario(
      label: label == const $CopyWithPlaceholder()
          ? _value.label
          // ignore: cast_nullable_to_non_nullable
          : label as ProjectedScenarioLabelEnum,
      totals: totals == const $CopyWithPlaceholder()
          ? _value.totals
          // ignore: cast_nullable_to_non_nullable
          : totals as NutrientTotals,
      mealBalance: mealBalance == const $CopyWithPlaceholder()
          ? _value.mealBalance
          // ignore: cast_nullable_to_non_nullable
          : mealBalance as MealBalance,
    );
  }
}

extension $ProjectedScenarioCopyWith on ProjectedScenario {
  /// Returns a callable class that can be used as follows: `instanceOfProjectedScenario.copyWith(...)` or like so:`instanceOfProjectedScenario.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ProjectedScenarioCWProxy get copyWith =>
      _$ProjectedScenarioCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectedScenario _$ProjectedScenarioFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ProjectedScenario', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['label', 'totals', 'meal_balance']);
      final val = ProjectedScenario(
        label: $checkedConvert(
          'label',
          (v) => $enumDecode(_$ProjectedScenarioLabelEnumEnumMap, v),
        ),
        totals: $checkedConvert(
          'totals',
          (v) => NutrientTotals.fromJson(v as Map<String, dynamic>),
        ),
        mealBalance: $checkedConvert(
          'meal_balance',
          (v) => MealBalance.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    }, fieldKeyMap: const {'mealBalance': 'meal_balance'});

Map<String, dynamic> _$ProjectedScenarioToJson(ProjectedScenario instance) =>
    <String, dynamic>{
      'label': _$ProjectedScenarioLabelEnumEnumMap[instance.label]!,
      'totals': instance.totals.toJson(),
      'meal_balance': instance.mealBalance.toJson(),
    };

const _$ProjectedScenarioLabelEnumEnumMap = {
  ProjectedScenarioLabelEnum.projected: 'projected',
};
