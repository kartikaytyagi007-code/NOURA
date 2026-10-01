// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_analysis.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MealAnalysisCWProxy {
  MealAnalysis scanId(String scanId);

  MealAnalysis revision(int revision);

  MealAnalysis items(List<AnalyzedItem> items);

  MealAnalysis totals(NutrientTotals totals);

  MealAnalysis mealBalance(MealBalance mealBalance);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealAnalysis(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealAnalysis(...).copyWith(id: 12, name: "My name")
  /// ````
  MealAnalysis call({
    String scanId,
    int revision,
    List<AnalyzedItem> items,
    NutrientTotals totals,
    MealBalance mealBalance,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMealAnalysis.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMealAnalysis.copyWith.fieldName(...)`
class _$MealAnalysisCWProxyImpl implements _$MealAnalysisCWProxy {
  const _$MealAnalysisCWProxyImpl(this._value);

  final MealAnalysis _value;

  @override
  MealAnalysis scanId(String scanId) => this(scanId: scanId);

  @override
  MealAnalysis revision(int revision) => this(revision: revision);

  @override
  MealAnalysis items(List<AnalyzedItem> items) => this(items: items);

  @override
  MealAnalysis totals(NutrientTotals totals) => this(totals: totals);

  @override
  MealAnalysis mealBalance(MealBalance mealBalance) =>
      this(mealBalance: mealBalance);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealAnalysis(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealAnalysis(...).copyWith(id: 12, name: "My name")
  /// ````
  MealAnalysis call({
    Object? scanId = const $CopyWithPlaceholder(),
    Object? revision = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
    Object? totals = const $CopyWithPlaceholder(),
    Object? mealBalance = const $CopyWithPlaceholder(),
  }) {
    return MealAnalysis(
      scanId: scanId == const $CopyWithPlaceholder()
          ? _value.scanId
          // ignore: cast_nullable_to_non_nullable
          : scanId as String,
      revision: revision == const $CopyWithPlaceholder()
          ? _value.revision
          // ignore: cast_nullable_to_non_nullable
          : revision as int,
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
          : mealBalance as MealBalance,
    );
  }
}

extension $MealAnalysisCopyWith on MealAnalysis {
  /// Returns a callable class that can be used as follows: `instanceOfMealAnalysis.copyWith(...)` or like so:`instanceOfMealAnalysis.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MealAnalysisCWProxy get copyWith => _$MealAnalysisCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealAnalysis _$MealAnalysisFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MealAnalysis', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'scan_id',
          'revision',
          'items',
          'totals',
          'meal_balance',
        ],
      );
      final val = MealAnalysis(
        scanId: $checkedConvert('scan_id', (v) => v as String),
        revision: $checkedConvert('revision', (v) => (v as num).toInt()),
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
          (v) => MealBalance.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    }, fieldKeyMap: const {'scanId': 'scan_id', 'mealBalance': 'meal_balance'});

Map<String, dynamic> _$MealAnalysisToJson(MealAnalysis instance) =>
    <String, dynamic>{
      'scan_id': instance.scanId,
      'revision': instance.revision,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'totals': instance.totals.toJson(),
      'meal_balance': instance.mealBalance.toJson(),
    };
