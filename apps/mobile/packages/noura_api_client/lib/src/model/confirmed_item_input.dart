//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/preparation_input.dart';
import 'package:noura_api_client/src/model/serving_input.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'confirmed_item_input.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ConfirmedItemInput {
  /// Returns a new [ConfirmedItemInput] instance.
  ConfirmedItemInput({
    this.temporaryId,

    this.foodId,

    this.recipeId,

    required this.label,

    this.grams,

    this.serving,

    this.preparation,
  });

  @JsonKey(name: r'temporary_id', required: false, includeIfNull: false)
  final String? temporaryId;

  @JsonKey(name: r'food_id', required: false, includeIfNull: false)
  final String? foodId;

  @JsonKey(name: r'recipe_id', required: false, includeIfNull: false)
  final String? recipeId;

  @JsonKey(name: r'label', required: true, includeIfNull: false)
  final String label;

  // minimum: 0
  // maximum: 3000
  @JsonKey(name: r'grams', required: false, includeIfNull: false)
  final num? grams;

  @JsonKey(name: r'serving', required: false, includeIfNull: false)
  final ServingInput? serving;

  @JsonKey(name: r'preparation', required: false, includeIfNull: false)
  final PreparationInput? preparation;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ConfirmedItemInput &&
            runtimeType == other.runtimeType &&
            equals(
              [
                temporaryId,
                foodId,
                recipeId,
                label,
                grams,
                serving,
                preparation,
              ],
              [
                other.temporaryId,
                other.foodId,
                other.recipeId,
                other.label,
                other.grams,
                other.serving,
                other.preparation,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        temporaryId,
        foodId,
        recipeId,
        label,
        grams,
        serving,
        preparation,
      ]);

  factory ConfirmedItemInput.fromJson(Map<String, dynamic> json) =>
      _$ConfirmedItemInputFromJson(json);

  Map<String, dynamic> toJson() => _$ConfirmedItemInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
