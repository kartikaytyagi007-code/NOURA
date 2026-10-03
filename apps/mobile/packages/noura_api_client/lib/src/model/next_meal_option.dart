//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/portion_ref.dart';
import 'package:noura_api_client/src/model/nutrient_totals.dart';
import 'package:noura_api_client/src/model/next_meal_source.dart';
import 'package:noura_api_client/src/model/recipe_ref.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'next_meal_option.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NextMealOption {
  /// Returns a new [NextMealOption] instance.
  NextMealOption({
    required this.source_,

    required this.planMealId,

    required this.planMealRevision,

    required this.candidateId,

    required this.recipe,

    required this.portions,

    required this.nutrition,

    required this.reason,
  });

  @JsonKey(name: r'source', required: true, includeIfNull: false)
  final NextMealSource source_;

  /// Non-null means this option can be swapped into that plan slot (send it back as target_plan_meal_id). An alternative to an already-planned slot carries the SAME plan_meal_id as the plan option, since swapping it in targets that slot. Null means there is no plan slot to swap into; use the add action instead.
  @JsonKey(name: r'plan_meal_id', required: true, includeIfNull: true)
  final String? planMealId;

  /// expected_revision to send with a swap action targeting plan_meal_id. Null iff plan_meal_id is null.
  // minimum: 1
  @JsonKey(name: r'plan_meal_revision', required: true, includeIfNull: true)
  final int? planMealRevision;

  /// Echo this back as nextMealAction's candidate_id to add/swap this option.
  @JsonKey(name: r'candidate_id', required: true, includeIfNull: false)
  final String candidateId;

  @JsonKey(name: r'recipe', required: true, includeIfNull: false)
  final RecipeRef recipe;

  @JsonKey(name: r'portions', required: true, includeIfNull: false)
  final List<PortionRef> portions;

  @JsonKey(name: r'nutrition', required: true, includeIfNull: false)
  final NutrientTotals nutrition;

  @JsonKey(name: r'reason', required: true, includeIfNull: false)
  final String reason;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NextMealOption &&
            runtimeType == other.runtimeType &&
            equals(
              [
                source_,
                planMealId,
                planMealRevision,
                candidateId,
                recipe,
                portions,
                nutrition,
                reason,
              ],
              [
                other.source_,
                other.planMealId,
                other.planMealRevision,
                other.candidateId,
                other.recipe,
                other.portions,
                other.nutrition,
                other.reason,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        source_,
        planMealId,
        planMealRevision,
        candidateId,
        recipe,
        portions,
        nutrition,
        reason,
      ]);

  factory NextMealOption.fromJson(Map<String, dynamic> json) =>
      _$NextMealOptionFromJson(json);

  Map<String, dynamic> toJson() => _$NextMealOptionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
