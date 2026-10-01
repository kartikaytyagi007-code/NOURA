//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/portion_ref.dart';
import 'package:noura_api_client/src/model/nutrient_totals.dart';
import 'package:noura_api_client/src/model/recipe_ref.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'swap_candidate.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SwapCandidate {
  /// Returns a new [SwapCandidate] instance.
  SwapCandidate({
    required this.candidateId,

    required this.recipe,

    required this.portions,

    required this.nutrition,

    required this.dailyTotalsPreview,
  });

  @JsonKey(name: r'candidate_id', required: true, includeIfNull: false)
  final String candidateId;

  @JsonKey(name: r'recipe', required: true, includeIfNull: false)
  final RecipeRef recipe;

  @JsonKey(name: r'portions', required: true, includeIfNull: false)
  final List<PortionRef> portions;

  @JsonKey(name: r'nutrition', required: true, includeIfNull: false)
  final NutrientTotals nutrition;

  @JsonKey(name: r'daily_totals_preview', required: true, includeIfNull: false)
  final NutrientTotals dailyTotalsPreview;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SwapCandidate &&
            runtimeType == other.runtimeType &&
            equals(
              [candidateId, recipe, portions, nutrition, dailyTotalsPreview],
              [
                other.candidateId,
                other.recipe,
                other.portions,
                other.nutrition,
                other.dailyTotalsPreview,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        candidateId,
        recipe,
        portions,
        nutrition,
        dailyTotalsPreview,
      ]);

  factory SwapCandidate.fromJson(Map<String, dynamic> json) =>
      _$SwapCandidateFromJson(json);

  Map<String, dynamic> toJson() => _$SwapCandidateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
