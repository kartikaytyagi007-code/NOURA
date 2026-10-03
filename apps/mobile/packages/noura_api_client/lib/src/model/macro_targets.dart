//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'macro_targets.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MacroTargets {
  /// Returns a new [MacroTargets] instance.
  MacroTargets({
    required this.energyKcal,

    required this.proteinG,

    required this.fibreG,

    required this.carbohydrateG,

    required this.fatG,
  });

  // minimum: 0
  @JsonKey(name: r'energy_kcal', required: true, includeIfNull: true)
  final int? energyKcal;

  // minimum: 0
  @JsonKey(name: r'protein_g', required: true, includeIfNull: true)
  final num? proteinG;

  // minimum: 0
  @JsonKey(name: r'fibre_g', required: true, includeIfNull: true)
  final num? fibreG;

  // minimum: 0
  @JsonKey(name: r'carbohydrate_g', required: true, includeIfNull: true)
  final num? carbohydrateG;

  // minimum: 0
  @JsonKey(name: r'fat_g', required: true, includeIfNull: true)
  final num? fatG;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MacroTargets &&
            runtimeType == other.runtimeType &&
            equals(
              [energyKcal, proteinG, fibreG, carbohydrateG, fatG],
              [
                other.energyKcal,
                other.proteinG,
                other.fibreG,
                other.carbohydrateG,
                other.fatG,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([energyKcal, proteinG, fibreG, carbohydrateG, fatG]);

  factory MacroTargets.fromJson(Map<String, dynamic> json) =>
      _$MacroTargetsFromJson(json);

  Map<String, dynamic> toJson() => _$MacroTargetsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
