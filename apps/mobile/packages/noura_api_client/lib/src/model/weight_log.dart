//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'weight_log.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WeightLog {
  /// Returns a new [WeightLog] instance.
  WeightLog({
    required this.id,

    required this.clientId,

    required this.measuredAt,

    required this.weightKg,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'client_id', required: true, includeIfNull: false)
  final String clientId;

  @JsonKey(name: r'measured_at', required: true, includeIfNull: false)
  final DateTime measuredAt;

  @JsonKey(name: r'weight_kg', required: true, includeIfNull: false)
  final num weightKg;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is WeightLog &&
            runtimeType == other.runtimeType &&
            equals(
              [id, clientId, measuredAt, weightKg],
              [other.id, other.clientId, other.measuredAt, other.weightKg],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([id, clientId, measuredAt, weightKg]);

  factory WeightLog.fromJson(Map<String, dynamic> json) =>
      _$WeightLogFromJson(json);

  Map<String, dynamic> toJson() => _$WeightLogToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
