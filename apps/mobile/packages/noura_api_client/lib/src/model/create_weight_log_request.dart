//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'create_weight_log_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateWeightLogRequest {
  /// Returns a new [CreateWeightLogRequest] instance.
  CreateWeightLogRequest({
    required this.clientId,

    required this.measuredAt,

    required this.weightKg,
  });

  @JsonKey(name: r'client_id', required: true, includeIfNull: false)
  final String clientId;

  @JsonKey(name: r'measured_at', required: true, includeIfNull: false)
  final DateTime measuredAt;

  // minimum: 20
  // maximum: 400
  @JsonKey(name: r'weight_kg', required: true, includeIfNull: false)
  final num weightKg;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CreateWeightLogRequest &&
            runtimeType == other.runtimeType &&
            equals(
              [clientId, measuredAt, weightKg],
              [other.clientId, other.measuredAt, other.weightKg],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([clientId, measuredAt, weightKg]);

  factory CreateWeightLogRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateWeightLogRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateWeightLogRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
