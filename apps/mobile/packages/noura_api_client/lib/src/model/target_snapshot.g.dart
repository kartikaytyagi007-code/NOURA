// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'target_snapshot.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TargetSnapshotCWProxy {
  TargetSnapshot id(String id);

  TargetSnapshot profileRevision(int profileRevision);

  TargetSnapshot policyVersion(String policyVersion);

  TargetSnapshot method(TargetSnapshotMethodEnum method);

  TargetSnapshot methodReference(String? methodReference);

  TargetSnapshot eligibility(EligibilityStatus eligibility);

  TargetSnapshot estimatedEnergyKcal(IntRange? estimatedEnergyKcal);

  TargetSnapshot targets(MacroTargets targets);

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
    TargetSnapshotMethodEnum method,
    String? methodReference,
    EligibilityStatus eligibility,
    IntRange? estimatedEnergyKcal,
    MacroTargets targets,
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
  TargetSnapshot method(TargetSnapshotMethodEnum method) =>
      this(method: method);

  @override
  TargetSnapshot methodReference(String? methodReference) =>
      this(methodReference: methodReference);

  @override
  TargetSnapshot eligibility(EligibilityStatus eligibility) =>
      this(eligibility: eligibility);

  @override
  TargetSnapshot estimatedEnergyKcal(IntRange? estimatedEnergyKcal) =>
      this(estimatedEnergyKcal: estimatedEnergyKcal);

  @override
  TargetSnapshot targets(MacroTargets targets) => this(targets: targets);

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
    Object? method = const $CopyWithPlaceholder(),
    Object? methodReference = const $CopyWithPlaceholder(),
    Object? eligibility = const $CopyWithPlaceholder(),
    Object? estimatedEnergyKcal = const $CopyWithPlaceholder(),
    Object? targets = const $CopyWithPlaceholder(),
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
      estimatedEnergyKcal: estimatedEnergyKcal == const $CopyWithPlaceholder()
          ? _value.estimatedEnergyKcal
          // ignore: cast_nullable_to_non_nullable
          : estimatedEnergyKcal as IntRange?,
      targets: targets == const $CopyWithPlaceholder()
          ? _value.targets
          // ignore: cast_nullable_to_non_nullable
          : targets as MacroTargets,
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
            'method',
            'method_reference',
            'eligibility',
            'estimated_energy_kcal',
            'targets',
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
          estimatedEnergyKcal: $checkedConvert(
            'estimated_energy_kcal',
            (v) =>
                v == null ? null : IntRange.fromJson(v as Map<String, dynamic>),
          ),
          targets: $checkedConvert(
            'targets',
            (v) => MacroTargets.fromJson(v as Map<String, dynamic>),
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
      'method': _$TargetSnapshotMethodEnumEnumMap[instance.method]!,
      'method_reference': instance.methodReference,
      'eligibility': _$EligibilityStatusEnumMap[instance.eligibility]!,
      'estimated_energy_kcal': instance.estimatedEnergyKcal?.toJson(),
      'targets': instance.targets.toJson(),
      'valid_from': instance.validFrom.toIso8601String(),
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
