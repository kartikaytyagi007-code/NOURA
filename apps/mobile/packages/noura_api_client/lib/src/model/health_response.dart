//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/health_check.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'health_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthResponse {
  /// Returns a new [HealthResponse] instance.
  HealthResponse({
    required this.status,

    required this.service,

    required this.version,

    required this.checks,
  });

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final HealthResponseStatusEnum status;

  @JsonKey(name: r'service', required: true, includeIfNull: false)
  final HealthResponseServiceEnum service;

  @JsonKey(name: r'version', required: true, includeIfNull: false)
  final String version;

  @JsonKey(name: r'checks', required: true, includeIfNull: false)
  final List<HealthCheck> checks;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is HealthResponse &&
            runtimeType == other.runtimeType &&
            equals(
              [status, service, version, checks],
              [other.status, other.service, other.version, other.checks],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([status, service, version, checks]);

  factory HealthResponse.fromJson(Map<String, dynamic> json) =>
      _$HealthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HealthResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum HealthResponseStatusEnum {
  @JsonValue(r'ok')
  ok(r'ok'),
  @JsonValue(r'unavailable')
  unavailable(r'unavailable');

  const HealthResponseStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum HealthResponseServiceEnum {
  @JsonValue(r'api')
  api(r'api'),
  @JsonValue(r'worker')
  worker(r'worker');

  const HealthResponseServiceEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
