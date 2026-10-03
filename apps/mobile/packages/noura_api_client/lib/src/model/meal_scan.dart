//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/meal_scan_status.dart';
import 'package:noura_api_client/src/model/recognition.dart';
import 'package:noura_api_client/src/model/safe_error.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'meal_scan.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MealScan {
  /// Returns a new [MealScan] instance.
  MealScan({
    required this.id,

    required this.status,

    required this.recognition,

    required this.revision,

    required this.error,

    required this.createdAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final MealScanStatus status;

  @JsonKey(name: r'recognition', required: true, includeIfNull: true)
  final Recognition? recognition;

  // minimum: 1
  @JsonKey(name: r'revision', required: true, includeIfNull: false)
  final int revision;

  @JsonKey(name: r'error', required: true, includeIfNull: true)
  final SafeError? error;

  @JsonKey(name: r'created_at', required: true, includeIfNull: false)
  final DateTime createdAt;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MealScan &&
            runtimeType == other.runtimeType &&
            equals(
              [id, status, recognition, revision, error, createdAt],
              [
                other.id,
                other.status,
                other.recognition,
                other.revision,
                other.error,
                other.createdAt,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([id, status, recognition, revision, error, createdAt]);

  factory MealScan.fromJson(Map<String, dynamic> json) =>
      _$MealScanFromJson(json);

  Map<String, dynamic> toJson() => _$MealScanToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
