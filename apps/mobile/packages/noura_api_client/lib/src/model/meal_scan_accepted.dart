//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'meal_scan_accepted.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MealScanAccepted {
  /// Returns a new [MealScanAccepted] instance.
  MealScanAccepted({required this.jobId, required this.scanId});

  @JsonKey(name: r'job_id', required: true, includeIfNull: false)
  final String jobId;

  @JsonKey(name: r'scan_id', required: true, includeIfNull: false)
  final String scanId;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MealScanAccepted &&
            runtimeType == other.runtimeType &&
            equals([jobId, scanId], [other.jobId, other.scanId]);
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([jobId, scanId]);

  factory MealScanAccepted.fromJson(Map<String, dynamic> json) =>
      _$MealScanAcceptedFromJson(json);

  Map<String, dynamic> toJson() => _$MealScanAcceptedToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
