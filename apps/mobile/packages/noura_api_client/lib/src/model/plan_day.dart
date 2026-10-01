//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/nutrient_totals.dart';
import 'package:noura_api_client/src/model/plan_meal.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'plan_day.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PlanDay {
  /// Returns a new [PlanDay] instance.
  PlanDay({required this.date, required this.meals, required this.totals});

  @JsonKey(name: r'date', required: true, includeIfNull: false)
  final DateTime date;

  @JsonKey(name: r'meals', required: true, includeIfNull: false)
  final List<PlanMeal> meals;

  @JsonKey(name: r'totals', required: true, includeIfNull: false)
  final NutrientTotals totals;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PlanDay &&
            runtimeType == other.runtimeType &&
            equals(
              [date, meals, totals],
              [other.date, other.meals, other.totals],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([date, meals, totals]);

  factory PlanDay.fromJson(Map<String, dynamic> json) =>
      _$PlanDayFromJson(json);

  Map<String, dynamic> toJson() => _$PlanDayToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
