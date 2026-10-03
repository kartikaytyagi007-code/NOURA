//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'feature_usage.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FeatureUsage {
  /// Returns a new [FeatureUsage] instance.
  FeatureUsage({
    required this.feature,

    required this.period,

    required this.limit,

    required this.used,

    required this.reserved,
  });

  @JsonKey(name: r'feature', required: true, includeIfNull: false)
  final FeatureUsageFeatureEnum feature;

  @JsonKey(name: r'period', required: true, includeIfNull: false)
  final String period;

  /// Finite configured limit; null only when not yet configured.
  // minimum: 0
  @JsonKey(name: r'limit', required: true, includeIfNull: true)
  final int? limit;

  // minimum: 0
  @JsonKey(name: r'used', required: true, includeIfNull: false)
  final int used;

  // minimum: 0
  @JsonKey(name: r'reserved', required: true, includeIfNull: false)
  final int reserved;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is FeatureUsage &&
            runtimeType == other.runtimeType &&
            equals(
              [feature, period, limit, used, reserved],
              [
                other.feature,
                other.period,
                other.limit,
                other.used,
                other.reserved,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([feature, period, limit, used, reserved]);

  factory FeatureUsage.fromJson(Map<String, dynamic> json) =>
      _$FeatureUsageFromJson(json);

  Map<String, dynamic> toJson() => _$FeatureUsageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum FeatureUsageFeatureEnum {
  @JsonValue(r'meal_scan')
  mealScan(r'meal_scan'),
  @JsonValue(r'coach_reply')
  coachReply(r'coach_reply'),
  @JsonValue(r'diet_plan')
  dietPlan(r'diet_plan'),
  @JsonValue(r'workout_plan')
  workoutPlan(r'workout_plan'),
  @JsonValue(r'plan_regeneration')
  planRegeneration(r'plan_regeneration');

  const FeatureUsageFeatureEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
