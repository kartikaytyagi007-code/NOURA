//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'meal_balance_component.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MealBalanceComponent {
  /// Returns a new [MealBalanceComponent] instance.
  MealBalanceComponent({
    required this.key,

    required this.score,

    required this.maxScore,

    required this.band,

    required this.evidence,
  });

  @JsonKey(name: r'key', required: true, includeIfNull: false)
  final MealBalanceComponentKeyEnum key;

  // minimum: 0
  // maximum: 25
  @JsonKey(name: r'score', required: true, includeIfNull: true)
  final num? score;

  /// Each component is capped at 25 in policy v1.
  // minimum: 25
  // maximum: 25
  @JsonKey(name: r'max_score', required: true, includeIfNull: false)
  final int maxScore;

  /// Qualitative read of this component (M5 per-nutrient indicator), null only when score is null.
  @JsonKey(name: r'band', required: true, includeIfNull: true)
  final MealBalanceComponentBandEnum? band;

  @JsonKey(name: r'evidence', required: true, includeIfNull: false)
  final Map<String, Object> evidence;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MealBalanceComponent &&
            runtimeType == other.runtimeType &&
            equals(
              [key, score, maxScore, band, evidence],
              [
                other.key,
                other.score,
                other.maxScore,
                other.band,
                other.evidence,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([key, score, maxScore, band, evidence]);

  factory MealBalanceComponent.fromJson(Map<String, dynamic> json) =>
      _$MealBalanceComponentFromJson(json);

  Map<String, dynamic> toJson() => _$MealBalanceComponentToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum MealBalanceComponentKeyEnum {
  @JsonValue(r'protein')
  protein(r'protein'),
  @JsonValue(r'fibre')
  fibre(r'fibre'),
  @JsonValue(r'vegetable_fruit')
  vegetableFruit(r'vegetable_fruit'),
  @JsonValue(r'variety')
  variety(r'variety');

  const MealBalanceComponentKeyEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Qualitative read of this component (M5 per-nutrient indicator), null only when score is null.
enum MealBalanceComponentBandEnum {
  @JsonValue(r'low')
  low(r'low'),
  @JsonValue(r'adequate')
  adequate(r'adequate'),
  @JsonValue(r'good')
  good(r'good');

  const MealBalanceComponentBandEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
