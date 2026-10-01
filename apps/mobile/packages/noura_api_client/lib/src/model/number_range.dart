//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'number_range.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NumberRange {
  /// Returns a new [NumberRange] instance.
  NumberRange({required this.min, required this.max});

  @JsonKey(name: r'min', required: true, includeIfNull: false)
  final num min;

  @JsonKey(name: r'max', required: true, includeIfNull: false)
  final num max;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NumberRange &&
            runtimeType == other.runtimeType &&
            equals([min, max], [other.min, other.max]);
  }

  @override
  int get hashCode => runtimeType.hashCode ^ mapPropsToHashCode([min, max]);

  factory NumberRange.fromJson(Map<String, dynamic> json) =>
      _$NumberRangeFromJson(json);

  Map<String, dynamic> toJson() => _$NumberRangeToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
