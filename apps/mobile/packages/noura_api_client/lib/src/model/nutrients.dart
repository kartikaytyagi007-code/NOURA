//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'nutrients.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Nutrients {
  /// Returns a new [Nutrients] instance.
  Nutrients({
    required this.energyKcal,

    required this.proteinG,

    required this.carbohydrateG,

    required this.fatG,

    required this.fibreG,
  });

  // minimum: 0
  @JsonKey(name: r'energy_kcal', required: true, includeIfNull: true)
  final num? energyKcal;

  // minimum: 0
  @JsonKey(name: r'protein_g', required: true, includeIfNull: true)
  final num? proteinG;

  // minimum: 0
  @JsonKey(name: r'carbohydrate_g', required: true, includeIfNull: true)
  final num? carbohydrateG;

  // minimum: 0
  @JsonKey(name: r'fat_g', required: true, includeIfNull: true)
  final num? fatG;

  // minimum: 0
  @JsonKey(name: r'fibre_g', required: true, includeIfNull: true)
  final num? fibreG;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Nutrients &&
            runtimeType == other.runtimeType &&
            equals(
              [energyKcal, proteinG, carbohydrateG, fatG, fibreG],
              [
                other.energyKcal,
                other.proteinG,
                other.carbohydrateG,
                other.fatG,
                other.fibreG,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([energyKcal, proteinG, carbohydrateG, fatG, fibreG]);

  factory Nutrients.fromJson(Map<String, dynamic> json) =>
      _$NutrientsFromJson(json);

  Map<String, dynamic> toJson() => _$NutrientsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
