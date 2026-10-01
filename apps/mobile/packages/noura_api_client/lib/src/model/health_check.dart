//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'health_check.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthCheck {
  /// Returns a new [HealthCheck] instance.
  HealthCheck({required this.name, required this.ok});

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'ok', required: true, includeIfNull: false)
  final bool ok;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is HealthCheck &&
            runtimeType == other.runtimeType &&
            equals([name, ok], [other.name, other.ok]);
  }

  @override
  int get hashCode => runtimeType.hashCode ^ mapPropsToHashCode([name, ok]);

  factory HealthCheck.fromJson(Map<String, dynamic> json) =>
      _$HealthCheckFromJson(json);

  Map<String, dynamic> toJson() => _$HealthCheckToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
