//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'serving_conversion.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ServingConversion {
  /// Returns a new [ServingConversion] instance.
  ServingConversion({
    required this.unit,

    required this.gramsMin,

    required this.gramsMax,
  });

  @JsonKey(name: r'unit', required: true, includeIfNull: false)
  final String unit;

  // minimum: 0
  @JsonKey(name: r'grams_min', required: true, includeIfNull: false)
  final num gramsMin;

  // minimum: 0
  @JsonKey(name: r'grams_max', required: true, includeIfNull: false)
  final num gramsMax;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ServingConversion &&
            runtimeType == other.runtimeType &&
            equals(
              [unit, gramsMin, gramsMax],
              [other.unit, other.gramsMin, other.gramsMax],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([unit, gramsMin, gramsMax]);

  factory ServingConversion.fromJson(Map<String, dynamic> json) =>
      _$ServingConversionFromJson(json);

  Map<String, dynamic> toJson() => _$ServingConversionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
