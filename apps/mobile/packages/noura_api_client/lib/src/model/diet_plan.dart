//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/plan_day.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'diet_plan.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DietPlan {
  /// Returns a new [DietPlan] instance.
  DietPlan({
    required this.id,

    required this.version,

    required this.startsOn,

    required this.status,

    required this.targetSnapshotId,

    required this.days,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  // minimum: 1
  @JsonKey(name: r'version', required: true, includeIfNull: false)
  final int version;

  @JsonKey(name: r'starts_on', required: true, includeIfNull: false)
  final DateTime startsOn;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final DietPlanStatusEnum status;

  @JsonKey(name: r'target_snapshot_id', required: true, includeIfNull: false)
  final String targetSnapshotId;

  @JsonKey(name: r'days', required: true, includeIfNull: false)
  final List<PlanDay> days;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DietPlan &&
            runtimeType == other.runtimeType &&
            equals(
              [id, version, startsOn, status, targetSnapshotId, days],
              [
                other.id,
                other.version,
                other.startsOn,
                other.status,
                other.targetSnapshotId,
                other.days,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        id,
        version,
        startsOn,
        status,
        targetSnapshotId,
        days,
      ]);

  factory DietPlan.fromJson(Map<String, dynamic> json) =>
      _$DietPlanFromJson(json);

  Map<String, dynamic> toJson() => _$DietPlanToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum DietPlanStatusEnum {
  @JsonValue(r'active')
  active(r'active'),
  @JsonValue(r'superseded')
  superseded(r'superseded');

  const DietPlanStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
