//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'recipe_ingredient.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RecipeIngredient {
  /// Returns a new [RecipeIngredient] instance.
  RecipeIngredient({
    required this.foodId,

    required this.name,

    required this.edibleGrams,
  });

  @JsonKey(name: r'food_id', required: true, includeIfNull: false)
  final String foodId;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  // minimum: 0
  @JsonKey(name: r'edible_grams', required: true, includeIfNull: false)
  final num edibleGrams;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is RecipeIngredient &&
            runtimeType == other.runtimeType &&
            equals(
              [foodId, name, edibleGrams],
              [other.foodId, other.name, other.edibleGrams],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([foodId, name, edibleGrams]);

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) =>
      _$RecipeIngredientFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeIngredientToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
