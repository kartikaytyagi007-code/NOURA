//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/nutrient_totals.dart';
import 'package:noura_api_client/src/model/meal_balance.dart';
import 'package:noura_api_client/src/model/analyzed_item.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'meal_analysis.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MealAnalysis {
  /// Returns a new [MealAnalysis] instance.
  MealAnalysis({
    required this.scanId,

    required this.revision,

    required this.items,

    required this.totals,

    required this.mealBalance,
  });

  @JsonKey(name: r'scan_id', required: true, includeIfNull: false)
  final String scanId;

  // minimum: 1
  @JsonKey(name: r'revision', required: true, includeIfNull: false)
  final int revision;

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<AnalyzedItem> items;

  @JsonKey(name: r'totals', required: true, includeIfNull: false)
  final NutrientTotals totals;

  @JsonKey(name: r'meal_balance', required: true, includeIfNull: false)
  final MealBalance mealBalance;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MealAnalysis &&
            runtimeType == other.runtimeType &&
            equals(
              [scanId, revision, items, totals, mealBalance],
              [
                other.scanId,
                other.revision,
                other.items,
                other.totals,
                other.mealBalance,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([scanId, revision, items, totals, mealBalance]);

  factory MealAnalysis.fromJson(Map<String, dynamic> json) =>
      _$MealAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$MealAnalysisToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
