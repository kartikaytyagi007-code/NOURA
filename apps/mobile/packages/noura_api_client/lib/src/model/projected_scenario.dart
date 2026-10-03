//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/nutrient_totals.dart';
import 'package:noura_api_client/src/model/meal_balance.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'projected_scenario.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ProjectedScenario {
  /// Returns a new [ProjectedScenario] instance.
  ProjectedScenario({
    required this.label,

    required this.totals,

    required this.mealBalance,
  });

  @JsonKey(name: r'label', required: true, includeIfNull: false)
  final ProjectedScenarioLabelEnum label;

  @JsonKey(name: r'totals', required: true, includeIfNull: false)
  final NutrientTotals totals;

  @JsonKey(name: r'meal_balance', required: true, includeIfNull: false)
  final MealBalance mealBalance;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProjectedScenario &&
            runtimeType == other.runtimeType &&
            equals(
              [label, totals, mealBalance],
              [other.label, other.totals, other.mealBalance],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([label, totals, mealBalance]);

  factory ProjectedScenario.fromJson(Map<String, dynamic> json) =>
      _$ProjectedScenarioFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectedScenarioToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ProjectedScenarioLabelEnum {
  @JsonValue(r'projected')
  projected(r'projected');

  const ProjectedScenarioLabelEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
