//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'serving_input.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ServingInput {
  /// Returns a new [ServingInput] instance.
  ServingInput({required this.unit, required this.quantity});

  @JsonKey(name: r'unit', required: true, includeIfNull: false)
  final String unit;

  // minimum: 0
  // maximum: 50
  @JsonKey(name: r'quantity', required: true, includeIfNull: false)
  final num quantity;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ServingInput &&
            runtimeType == other.runtimeType &&
            equals([unit, quantity], [other.unit, other.quantity]);
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([unit, quantity]);

  factory ServingInput.fromJson(Map<String, dynamic> json) =>
      _$ServingInputFromJson(json);

  Map<String, dynamic> toJson() => _$ServingInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
