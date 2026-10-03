//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'coverage.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Coverage {
  /// Returns a new [Coverage] instance.
  Coverage({
    required this.itemsTotal,

    required this.itemsWithNutrition,

    required this.complete,
  });

  // minimum: 0
  @JsonKey(name: r'items_total', required: true, includeIfNull: false)
  final int itemsTotal;

  // minimum: 0
  @JsonKey(name: r'items_with_nutrition', required: true, includeIfNull: false)
  final int itemsWithNutrition;

  @JsonKey(name: r'complete', required: true, includeIfNull: false)
  final bool complete;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Coverage &&
            runtimeType == other.runtimeType &&
            equals(
              [itemsTotal, itemsWithNutrition, complete],
              [other.itemsTotal, other.itemsWithNutrition, other.complete],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([itemsTotal, itemsWithNutrition, complete]);

  factory Coverage.fromJson(Map<String, dynamic> json) =>
      _$CoverageFromJson(json);

  Map<String, dynamic> toJson() => _$CoverageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
