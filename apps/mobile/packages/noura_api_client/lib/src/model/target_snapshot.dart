//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/eligibility_status.dart';
import 'package:noura_api_client/src/model/int_range.dart';
import 'package:noura_api_client/src/model/macro_targets.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'target_snapshot.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TargetSnapshot {
  /// Returns a new [TargetSnapshot] instance.
  TargetSnapshot({
    required this.id,

    required this.profileRevision,

    required this.policyVersion,

    required this.method,

    required this.methodReference,

    required this.eligibility,

    required this.estimatedEnergyKcal,

    required this.targets,

    required this.validFrom,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  // minimum: 1
  @JsonKey(name: r'profile_revision', required: true, includeIfNull: false)
  final int profileRevision;

  @JsonKey(name: r'policy_version', required: true, includeIfNull: false)
  final String policyVersion;

  @JsonKey(name: r'method', required: true, includeIfNull: false)
  final TargetSnapshotMethodEnum method;

  @JsonKey(name: r'method_reference', required: true, includeIfNull: true)
  final String? methodReference;

  @JsonKey(name: r'eligibility', required: true, includeIfNull: false)
  final EligibilityStatus eligibility;

  @JsonKey(name: r'estimated_energy_kcal', required: true, includeIfNull: true)
  final IntRange? estimatedEnergyKcal;

  @JsonKey(name: r'targets', required: true, includeIfNull: false)
  final MacroTargets targets;

  @JsonKey(name: r'valid_from', required: true, includeIfNull: false)
  final DateTime validFrom;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TargetSnapshot &&
            runtimeType == other.runtimeType &&
            equals(
              [
                id,
                profileRevision,
                policyVersion,
                method,
                methodReference,
                eligibility,
                estimatedEnergyKcal,
                targets,
                validFrom,
              ],
              [
                other.id,
                other.profileRevision,
                other.policyVersion,
                other.method,
                other.methodReference,
                other.eligibility,
                other.estimatedEnergyKcal,
                other.targets,
                other.validFrom,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        id,
        profileRevision,
        policyVersion,
        method,
        methodReference,
        eligibility,
        estimatedEnergyKcal,
        targets,
        validFrom,
      ]);

  factory TargetSnapshot.fromJson(Map<String, dynamic> json) =>
      _$TargetSnapshotFromJson(json);

  Map<String, dynamic> toJson() => _$TargetSnapshotToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum TargetSnapshotMethodEnum {
  @JsonValue(r'policy')
  policy(r'policy'),
  @JsonValue(r'user_override')
  userOverride(r'user_override');

  const TargetSnapshotMethodEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
