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

    required this.policyStatus,

    required this.method,

    required this.methodReference,

    required this.eligibility,

    required this.basis,

    required this.estimatedEnergyKcal,

    required this.targets,

    required this.warnings,

    required this.validFrom,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  // minimum: 1
  @JsonKey(name: r'profile_revision', required: true, includeIfNull: false)
  final int profileRevision;

  @JsonKey(name: r'policy_version', required: true, includeIfNull: false)
  final String policyVersion;

  /// `test` means a development placeholder policy: the numbers are not reviewed and must never be presented as medical advice. Only `approved` policies may drive production planning.
  @JsonKey(name: r'policy_status', required: true, includeIfNull: false)
  final TargetSnapshotPolicyStatusEnum policyStatus;

  @JsonKey(name: r'method', required: true, includeIfNull: false)
  final TargetSnapshotMethodEnum method;

  @JsonKey(name: r'method_reference', required: true, includeIfNull: true)
  final String? methodReference;

  @JsonKey(name: r'eligibility', required: true, includeIfNull: false)
  final EligibilityStatus eligibility;

  /// point: one energy target. range: the calculation sex was declined, so only an energy range is offered and energy-dependent targets are null. not_calculated: eligibility excludes automated planning, so no targets exist.
  @JsonKey(name: r'basis', required: true, includeIfNull: false)
  final TargetSnapshotBasisEnum basis;

  @JsonKey(name: r'estimated_energy_kcal', required: true, includeIfNull: true)
  final IntRange? estimatedEnergyKcal;

  @JsonKey(name: r'targets', required: true, includeIfNull: false)
  final MacroTargets targets;

  @JsonKey(name: r'warnings', required: true, includeIfNull: false)
  final List<TargetSnapshotWarningsEnum> warnings;

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
                policyStatus,
                method,
                methodReference,
                eligibility,
                basis,
                estimatedEnergyKcal,
                targets,
                warnings,
                validFrom,
              ],
              [
                other.id,
                other.profileRevision,
                other.policyVersion,
                other.policyStatus,
                other.method,
                other.methodReference,
                other.eligibility,
                other.basis,
                other.estimatedEnergyKcal,
                other.targets,
                other.warnings,
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
        policyStatus,
        method,
        methodReference,
        eligibility,
        basis,
        estimatedEnergyKcal,
        targets,
        warnings,
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

/// `test` means a development placeholder policy: the numbers are not reviewed and must never be presented as medical advice. Only `approved` policies may drive production planning.
enum TargetSnapshotPolicyStatusEnum {
  @JsonValue(r'test')
  test(r'test'),
  @JsonValue(r'approved')
  approved(r'approved');

  const TargetSnapshotPolicyStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
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

/// point: one energy target. range: the calculation sex was declined, so only an energy range is offered and energy-dependent targets are null. not_calculated: eligibility excludes automated planning, so no targets exist.
enum TargetSnapshotBasisEnum {
  @JsonValue(r'point')
  point(r'point'),
  @JsonValue(r'range')
  range(r'range'),
  @JsonValue(r'not_calculated')
  notCalculated(r'not_calculated');

  const TargetSnapshotBasisEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum TargetSnapshotWarningsEnum {
  @JsonValue(r'energy_floor_applied')
  energyFloorApplied(r'energy_floor_applied'),
  @JsonValue(r'macro_budget_conflict')
  macroBudgetConflict(r'macro_budget_conflict');

  const TargetSnapshotWarningsEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
