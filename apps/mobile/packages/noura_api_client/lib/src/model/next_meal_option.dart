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
    required this.recipe,

    required this.portions,

    required this.nutrition,

    required this.reason,
  });

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
              [recipe, portions, nutrition, reason],
              [other.recipe, other.portions, other.nutrition, other.reason],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([recipe, portions, nutrition, reason]);

  factory NextMealOption.fromJson(Map<String, dynamic> json) =>
      _$NextMealOptionFromJson(json);

  Map<String, dynamic> toJson() => _$NextMealOptionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
