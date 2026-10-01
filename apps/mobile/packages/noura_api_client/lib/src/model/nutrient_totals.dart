//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/coverage.dart';
import 'package:noura_api_client/src/model/nutrients.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'nutrient_totals.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NutrientTotals {
  /// Returns a new [NutrientTotals] instance.
  NutrientTotals({required this.nutrients, required this.coverage});

  @JsonKey(name: r'nutrients', required: true, includeIfNull: false)
  final Nutrients nutrients;

  @JsonKey(name: r'coverage', required: true, includeIfNull: false)
  final Coverage coverage;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NutrientTotals &&
            runtimeType == other.runtimeType &&
            equals([nutrients, coverage], [other.nutrients, other.coverage]);
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([nutrients, coverage]);

  factory NutrientTotals.fromJson(Map<String, dynamic> json) =>
      _$NutrientTotalsFromJson(json);

  Map<String, dynamic> toJson() => _$NutrientTotalsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
