//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/number_range.dart';
import 'package:noura_api_client/src/model/source_ref.dart';
import 'package:noura_api_client/src/model/nutrients.dart';
import 'package:noura_api_client/src/model/uncertainty.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'analyzed_item.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnalyzedItem {
  /// Returns a new [AnalyzedItem] instance.
  AnalyzedItem({
    required this.itemId,

    required this.label,

    required this.foodId,

    required this.recipeId,

    required this.source_,

    required this.grams,

    required this.gramsRange,

    required this.nutrients,

    required this.uncertainty,
  });

  @JsonKey(name: r'item_id', required: true, includeIfNull: false)
  final String itemId;

  @JsonKey(name: r'label', required: true, includeIfNull: false)
  final String label;

  @JsonKey(name: r'food_id', required: true, includeIfNull: true)
  final String? foodId;

  @JsonKey(name: r'recipe_id', required: true, includeIfNull: true)
  final String? recipeId;

  @JsonKey(name: r'source', required: true, includeIfNull: true)
  final SourceRef? source_;

  @JsonKey(name: r'grams', required: true, includeIfNull: true)
  final num? grams;

  @JsonKey(name: r'grams_range', required: true, includeIfNull: true)
  final NumberRange? gramsRange;

  @JsonKey(name: r'nutrients', required: true, includeIfNull: true)
  final Nutrients? nutrients;

  @JsonKey(name: r'uncertainty', required: true, includeIfNull: true)
  final Uncertainty? uncertainty;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AnalyzedItem &&
            runtimeType == other.runtimeType &&
            equals(
              [
                itemId,
                label,
                foodId,
                recipeId,
                source_,
                grams,
                gramsRange,
                nutrients,
                uncertainty,
              ],
              [
                other.itemId,
                other.label,
                other.foodId,
                other.recipeId,
                other.source_,
                other.grams,
                other.gramsRange,
                other.nutrients,
                other.uncertainty,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        itemId,
        label,
        foodId,
        recipeId,
        source_,
        grams,
        gramsRange,
        nutrients,
        uncertainty,
      ]);

  factory AnalyzedItem.fromJson(Map<String, dynamic> json) =>
      _$AnalyzedItemFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyzedItemToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
