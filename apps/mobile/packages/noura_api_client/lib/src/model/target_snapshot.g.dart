// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'target_snapshot.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TargetSnapshotCWProxy {
  TargetSnapshot id(String id);

  TargetSnapshot profileRevision(int profileRevision);

  TargetSnapshot policyVersion(String policyVersion);

  TargetSnapshot policyStatus(TargetSnapshotPolicyStatusEnum policyStatus);

  TargetSnapshot method(TargetSnapshotMethodEnum method);

  TargetSnapshot methodReference(String? methodReference);

  TargetSnapshot eligibility(EligibilityStatus eligibility);

  TargetSnapshot basis(TargetSnapshotBasisEnum basis);

  TargetSnapshot estimatedEnergyKcal(IntRange? estimatedEnergyKcal);

  TargetSnapshot targets(MacroTargets targets);

  TargetSnapshot warnings(List<TargetSnapshotWarningsEnum> warnings);

  TargetSnapshot validFrom(DateTime validFrom);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TargetSnapshot(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TargetSnapshot(...).copyWith(id: 12, name: "My name")
  /// ````
  TargetSnapshot call({
    String id,
    int profileRevision,
    String policyVersion,
    TargetSnapshotPolicyStatusEnum policyStatus,
    TargetSnapshotMethodEnum method,
    String? methodReference,
    EligibilityStatus eligibility,
    TargetSnapshotBasisEnum basis,
    IntRange? estimatedEnergyKcal,
    MacroTargets targets,
    List<TargetSnapshotWarningsEnum> warnings,
    DateTime validFrom,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTargetSnapshot.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTargetSnapshot.copyWith.fieldName(...)`
class _$TargetSnapshotCWProxyImpl implements _$TargetSnapshotCWProxy {
  const _$TargetSnapshotCWProxyImpl(this._value);

  final TargetSnapshot _value;

  @override
  TargetSnapshot id(String id) => this(id: id);

  @override
  TargetSnapshot profileRevision(int profileRevision) =>
      this(profileRevision: profileRevision);

  @override
  TargetSnapshot policyVersion(String policyVersion) =>
      this(policyVersion: policyVersion);

  @override
  TargetSnapshot policyStatus(TargetSnapshotPolicyStatusEnum policyStatus) =>
      this(policyStatus: policyStatus);

  @override
  TargetSnapshot method(TargetSnapshotMethodEnum method) =>
      this(method: method);

  @override
  TargetSnapshot methodReference(String? methodReference) =>
      this(methodReference: methodReference);

  @override
  TargetSnapshot eligibility(EligibilityStatus eligibility) =>
      this(eligibility: eligibility);

  @override
  TargetSnapshot basis(TargetSnapshotBasisEnum basis) => this(basis: basis);

  @override
  TargetSnapshot estimatedEnergyKcal(IntRange? estimatedEnergyKcal) =>
      this(estimatedEnergyKcal: estimatedEnergyKcal);

  @override
  TargetSnapshot targets(MacroTargets targets) => this(targets: targets);

  @override
  TargetSnapshot warnings(List<TargetSnapshotWarningsEnum> warnings) =>
      this(warnings: warnings);

  @override
  TargetSnapshot validFrom(DateTime validFrom) => this(validFrom: validFrom);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TargetSnapshot(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TargetSnapshot(...).copyWith(id: 12, name: "My name")
  /// ````
  TargetSnapshot call({
    Object? id = const $CopyWithPlaceholder(),
    Object? profileRevision = const $CopyWithPlaceholder(),
    Object? policyVersion = const $CopyWithPlaceholder(),
    Object? policyStatus = const $CopyWithPlaceholder(),
    Object? method = const $CopyWithPlaceholder(),
    Object? methodReference = const $CopyWithPlaceholder(),
    Object? eligibility = const $CopyWithPlaceholder(),
    Object? basis = const $CopyWithPlaceholder(),
    Object? estimatedEnergyKcal = const $CopyWithPlaceholder(),
    Object? targets = const $CopyWithPlaceholder(),
    Object? warnings = const $CopyWithPlaceholder(),
    Object? validFrom = const $CopyWithPlaceholder(),
  }) {
    return TargetSnapshot(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      profileRevision: profileRevision == const $CopyWithPlaceholder()
          ? _value.profileRevision
          // ignore: cast_nullable_to_non_nullable
          : profileRevision as int,
      policyVersion: policyVersion == const $CopyWithPlaceholder()
          ? _value.policyVersion
          // ignore: cast_nullable_to_non_nullable
          : policyVersion as String,
      policyStatus: policyStatus == const $CopyWithPlaceholder()
          ? _value.policyStatus
          // ignore: cast_nullable_to_non_nullable
          : policyStatus as TargetSnapshotPolicyStatusEnum,
      method: method == const $CopyWithPlaceholder()
          ? _value.method
          // ignore: cast_nullable_to_non_nullable
          : method as TargetSnapshotMethodEnum,
      methodReference: methodReference == const $CopyWithPlaceholder()
          ? _value.methodReference
          // ignore: cast_nullable_to_non_nullable
          : methodReference as String?,
      eligibility: eligibility == const $CopyWithPlaceholder()
          ? _value.eligibility
          // ignore: cast_nullable_to_non_nullable
          : eligibility as EligibilityStatus,
      basis: basis == const $CopyWithPlaceholder()
          ? _value.basis
          // ignore: cast_nullable_to_non_nullable
          : basis as TargetSnapshotBasisEnum,
      estimatedEnergyKcal: estimatedEnergyKcal == const $CopyWithPlaceholder()
          ? _value.estimatedEnergyKcal
          // ignore: cast_nullable_to_non_nullable
          : estimatedEnergyKcal as IntRange?,
      targets: targets == const $CopyWithPlaceholder()
          ? _value.targets
          // ignore: cast_nullable_to_non_nullable
          : targets as MacroTargets,
      warnings: warnings == const $CopyWithPlaceholder()
          ? _value.warnings
          // ignore: cast_nullable_to_non_nullable
          : warnings as List<TargetSnapshotWarningsEnum>,
      validFrom: validFrom == const $CopyWithPlaceholder()
          ? _value.validFrom
          // ignore: cast_nullable_to_non_nullable
          : validFrom as DateTime,
    );
  }
}

extension $TargetSnapshotCopyWith on TargetSnapshot {
  /// Returns a callable class that can be used as follows: `instanceOfTargetSnapshot.copyWith(...)` or like so:`instanceOfTargetSnapshot.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TargetSnapshotCWProxy get copyWith => _$TargetSnapshotCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TargetSnapshot _$TargetSnapshotFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'TargetSnapshot',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'profile_revision',
            'policy_version',
            'policy_status',
            'method',
            'method_reference',
            'eligibility',
            'basis',
            'estimated_energy_kcal',
            'targets',
            'warnings',
            'valid_from',
          ],
        );
        final val = TargetSnapshot(
          id: $checkedConvert('id', (v) => v as String),
          profileRevision: $checkedConvert(
            'profile_revision',
            (v) => (v as num).toInt(),
          ),
          policyVersion: $checkedConvert('policy_version', (v) => v as String),
          policyStatus: $checkedConvert(
            'policy_status',
            (v) => $enumDecode(_$TargetSnapshotPolicyStatusEnumEnumMap, v),
          ),
          method: $checkedConvert(
            'method',
            (v) => $enumDecode(_$TargetSnapshotMethodEnumEnumMap, v),
          ),
          methodReference: $checkedConvert(
            'method_reference',
            (v) => v as String?,
          ),
          eligibility: $checkedConvert(
            'eligibility',
            (v) => $enumDecode(_$EligibilityStatusEnumMap, v),
          ),
          basis: $checkedConvert(
            'basis',
            (v) => $enumDecode(_$TargetSnapshotBasisEnumEnumMap, v),
          ),
          estimatedEnergyKcal: $checkedConvert(
            'estimated_energy_kcal',
            (v) =>
                v == null ? null : IntRange.fromJson(v as Map<String, dynamic>),
          ),
          targets: $checkedConvert(
            'targets',
            (v) => MacroTargets.fromJson(v as Map<String, dynamic>),
          ),
          warnings: $checkedConvert(
            'warnings',
            (v) => (v as List<dynamic>)
                .map((e) => $enumDecode(_$TargetSnapshotWarningsEnumEnumMap, e))
                .toList(),
          ),
          validFrom: $checkedConvert(
            'valid_from',
            (v) => DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'profileRevision': 'profile_revision',
        'policyVersion': 'policy_version',
        'policyStatus': 'policy_status',
        'methodReference': 'method_reference',
        'estimatedEnergyKcal': 'estimated_energy_kcal',
        'validFrom': 'valid_from',
      },
    );

Map<String, dynamic> _$TargetSnapshotToJson(TargetSnapshot instance) =>
    <String, dynamic>{
      'id': instance.id,
      'profile_revision': instance.profileRevision,
      'policy_version': instance.policyVersion,
      'policy_status':
          _$TargetSnapshotPolicyStatusEnumEnumMap[instance.policyStatus]!,
      'method': _$TargetSnapshotMethodEnumEnumMap[instance.method]!,
      'method_reference': instance.methodReference,
      'eligibility': _$EligibilityStatusEnumMap[instance.eligibility]!,
      'basis': _$TargetSnapshotBasisEnumEnumMap[instance.basis]!,
      'estimated_energy_kcal': instance.estimatedEnergyKcal?.toJson(),
      'targets': instance.targets.toJson(),
      'warnings': instance.warnings
          .map((e) => _$TargetSnapshotWarningsEnumEnumMap[e]!)
          .toList(),
      'valid_from': instance.validFrom.toIso8601String(),
    };

const _$TargetSnapshotPolicyStatusEnumEnumMap = {
  TargetSnapshotPolicyStatusEnum.test: 'test',
  TargetSnapshotPolicyStatusEnum.approved: 'approved',
};

const _$TargetSnapshotMethodEnumEnumMap = {
  TargetSnapshotMethodEnum.policy: 'policy',
  TargetSnapshotMethodEnum.userOverride: 'user_override',
};

const _$EligibilityStatusEnumMap = {
  EligibilityStatus.eligible: 'eligible',
  EligibilityStatus.trackingOnly: 'tracking_only',
  EligibilityStatus.needsReview: 'needs_review',
};

const _$TargetSnapshotBasisEnumEnumMap = {
  TargetSnapshotBasisEnum.point: 'point',
  TargetSnapshotBasisEnum.range: 'range',
  TargetSnapshotBasisEnum.notCalculated: 'not_calculated',
};

const _$TargetSnapshotWarningsEnumEnumMap = {
  TargetSnapshotWarningsEnum.energyFloorApplied: 'energy_floor_applied',
  TargetSnapshotWarningsEnum.macroBudgetConflict: 'macro_budget_conflict',
};
