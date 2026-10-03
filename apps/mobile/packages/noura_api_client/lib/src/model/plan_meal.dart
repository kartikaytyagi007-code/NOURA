//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/portion_ref.dart';
import 'package:noura_api_client/src/model/nutrient_totals.dart';
import 'package:noura_api_client/src/model/meal_slot.dart';
import 'package:noura_api_client/src/model/recipe_ref.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'plan_meal.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PlanMeal {
  /// Returns a new [PlanMeal] instance.
  PlanMeal({
    required this.id,

    required this.date,

    required this.slot,

    required this.slotOrdinal,

    required this.recipe,

    required this.portions,

    required this.nutrition,

    required this.revision,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'date', required: true, includeIfNull: false)
  final DateTime date;

  @JsonKey(name: r'slot', required: true, includeIfNull: false)
  final MealSlot slot;

  // minimum: 1
  // maximum: 4
  @JsonKey(name: r'slot_ordinal', required: true, includeIfNull: false)
  final int slotOrdinal;

  @JsonKey(name: r'recipe', required: true, includeIfNull: true)
  final RecipeRef? recipe;

  @JsonKey(name: r'portions', required: true, includeIfNull: false)
  final List<PortionRef> portions;

  @JsonKey(name: r'nutrition', required: true, includeIfNull: false)
  final NutrientTotals nutrition;

  // minimum: 1
  @JsonKey(name: r'revision', required: true, includeIfNull: false)
  final int revision;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PlanMeal &&
            runtimeType == other.runtimeType &&
            equals(
              [
                id,
                date,
                slot,
                slotOrdinal,
                recipe,
                portions,
                nutrition,
                revision,
              ],
              [
                other.id,
                other.date,
                other.slot,
                other.slotOrdinal,
                other.recipe,
                other.portions,
                other.nutrition,
                other.revision,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        id,
        date,
        slot,
        slotOrdinal,
        recipe,
        portions,
        nutrition,
        revision,
      ]);

  factory PlanMeal.fromJson(Map<String, dynamic> json) =>
      _$PlanMealFromJson(json);

  Map<String, dynamic> toJson() => _$PlanMealToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
