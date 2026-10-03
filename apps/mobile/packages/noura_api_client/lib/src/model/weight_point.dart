//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'weight_point.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WeightPoint {
  /// Returns a new [WeightPoint] instance.
  WeightPoint({required this.date, required this.weightKg});

  @JsonKey(name: r'date', required: true, includeIfNull: false)
  final DateTime date;

  @JsonKey(name: r'weight_kg', required: true, includeIfNull: false)
  final num weightKg;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is WeightPoint &&
            runtimeType == other.runtimeType &&
            equals([date, weightKg], [other.date, other.weightKg]);
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([date, weightKg]);

  factory WeightPoint.fromJson(Map<String, dynamic> json) =>
      _$WeightPointFromJson(json);

  Map<String, dynamic> toJson() => _$WeightPointToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
