//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'portion_ref.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PortionRef {
  /// Returns a new [PortionRef] instance.
  PortionRef({
    required this.foodId,

    required this.recipeId,

    required this.label,

    required this.gramsMin,

    required this.gramsMax,
  });

  @JsonKey(name: r'food_id', required: true, includeIfNull: true)
  final String? foodId;

  @JsonKey(name: r'recipe_id', required: true, includeIfNull: true)
  final String? recipeId;

  @JsonKey(name: r'label', required: true, includeIfNull: false)
  final String label;

  // minimum: 0
  @JsonKey(name: r'grams_min', required: true, includeIfNull: false)
  final num gramsMin;

  // minimum: 0
  @JsonKey(name: r'grams_max', required: true, includeIfNull: false)
  final num gramsMax;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PortionRef &&
            runtimeType == other.runtimeType &&
            equals(
              [foodId, recipeId, label, gramsMin, gramsMax],
              [
                other.foodId,
                other.recipeId,
                other.label,
                other.gramsMin,
                other.gramsMax,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([foodId, recipeId, label, gramsMin, gramsMax]);

  factory PortionRef.fromJson(Map<String, dynamic> json) =>
      _$PortionRefFromJson(json);

  Map<String, dynamic> toJson() => _$PortionRefToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
