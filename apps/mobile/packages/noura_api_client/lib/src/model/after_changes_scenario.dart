//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/nutrient_totals.dart';
import 'package:noura_api_client/src/model/meal_balance.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'after_changes_scenario.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AfterChangesScenario {
  /// Returns a new [AfterChangesScenario] instance.
  AfterChangesScenario({
    required this.totals,

    required this.mealBalance,

    required this.assumptions,
  });

  @JsonKey(name: r'totals', required: true, includeIfNull: false)
  final NutrientTotals totals;

  @JsonKey(name: r'meal_balance', required: true, includeIfNull: false)
  final MealBalance mealBalance;

  @JsonKey(name: r'assumptions', required: true, includeIfNull: false)
  final List<String> assumptions;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AfterChangesScenario &&
            runtimeType == other.runtimeType &&
            equals(
              [totals, mealBalance, assumptions],
              [other.totals, other.mealBalance, other.assumptions],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([totals, mealBalance, assumptions]);

  factory AfterChangesScenario.fromJson(Map<String, dynamic> json) =>
      _$AfterChangesScenarioFromJson(json);

  Map<String, dynamic> toJson() => _$AfterChangesScenarioToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
