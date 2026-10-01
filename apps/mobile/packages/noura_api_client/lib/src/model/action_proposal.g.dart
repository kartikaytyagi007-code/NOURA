// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_proposal.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ActionProposalCWProxy {
  ActionProposal id(String id);

  ActionProposal type(ActionProposalTypeEnum type);

  ActionProposal status(ActionProposalStatusEnum status);

  ActionProposal expectedRevision(int expectedRevision);

  ActionProposal expiresAt(DateTime expiresAt);

  ActionProposal appliedAt(DateTime? appliedAt);

  ActionProposal summary(String summary);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActionProposal(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActionProposal(...).copyWith(id: 12, name: "My name")
  /// ````
  ActionProposal call({
    String id,
    ActionProposalTypeEnum type,
    ActionProposalStatusEnum status,
    int expectedRevision,
    DateTime expiresAt,
    DateTime? appliedAt,
    String summary,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfActionProposal.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfActionProposal.copyWith.fieldName(...)`
class _$ActionProposalCWProxyImpl implements _$ActionProposalCWProxy {
  const _$ActionProposalCWProxyImpl(this._value);

  final ActionProposal _value;

  @override
  ActionProposal id(String id) => this(id: id);

  @override
  ActionProposal type(ActionProposalTypeEnum type) => this(type: type);

  @override
  ActionProposal status(ActionProposalStatusEnum status) =>
      this(status: status);

  @override
  ActionProposal expectedRevision(int expectedRevision) =>
      this(expectedRevision: expectedRevision);

  @override
  ActionProposal expiresAt(DateTime expiresAt) => this(expiresAt: expiresAt);

  @override
  ActionProposal appliedAt(DateTime? appliedAt) => this(appliedAt: appliedAt);

  @override
  ActionProposal summary(String summary) => this(summary: summary);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActionProposal(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActionProposal(...).copyWith(id: 12, name: "My name")
  /// ````
  ActionProposal call({
    Object? id = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? expectedRevision = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
    Object? appliedAt = const $CopyWithPlaceholder(),
    Object? summary = const $CopyWithPlaceholder(),
  }) {
    return ActionProposal(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as ActionProposalTypeEnum,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as ActionProposalStatusEnum,
      expectedRevision: expectedRevision == const $CopyWithPlaceholder()
          ? _value.expectedRevision
          // ignore: cast_nullable_to_non_nullable
          : expectedRevision as int,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime,
      appliedAt: appliedAt == const $CopyWithPlaceholder()
          ? _value.appliedAt
          // ignore: cast_nullable_to_non_nullable
          : appliedAt as DateTime?,
      summary: summary == const $CopyWithPlaceholder()
          ? _value.summary
          // ignore: cast_nullable_to_non_nullable
          : summary as String,
    );
  }
}

extension $ActionProposalCopyWith on ActionProposal {
  /// Returns a callable class that can be used as follows: `instanceOfActionProposal.copyWith(...)` or like so:`instanceOfActionProposal.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ActionProposalCWProxy get copyWith => _$ActionProposalCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActionProposal _$ActionProposalFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ActionProposal',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'type',
            'status',
            'expected_revision',
            'expires_at',
            'applied_at',
            'summary',
          ],
        );
        final val = ActionProposal(
          id: $checkedConvert('id', (v) => v as String),
          type: $checkedConvert(
            'type',
            (v) => $enumDecode(_$ActionProposalTypeEnumEnumMap, v),
          ),
          status: $checkedConvert(
            'status',
            (v) => $enumDecode(_$ActionProposalStatusEnumEnumMap, v),
          ),
          expectedRevision: $checkedConvert(
            'expected_revision',
            (v) => (v as num).toInt(),
          ),
          expiresAt: $checkedConvert(
            'expires_at',
            (v) => DateTime.parse(v as String),
          ),
          appliedAt: $checkedConvert(
            'applied_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          summary: $checkedConvert('summary', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {
        'expectedRevision': 'expected_revision',
        'expiresAt': 'expires_at',
        'appliedAt': 'applied_at',
      },
    );

Map<String, dynamic> _$ActionProposalToJson(ActionProposal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ActionProposalTypeEnumEnumMap[instance.type]!,
      'status': _$ActionProposalStatusEnumEnumMap[instance.status]!,
      'expected_revision': instance.expectedRevision,
      'expires_at': instance.expiresAt.toIso8601String(),
      'applied_at': instance.appliedAt?.toIso8601String(),
      'summary': instance.summary,
    };

const _$ActionProposalTypeEnumEnumMap = {
  ActionProposalTypeEnum.swapMeal: 'swap_meal',
  ActionProposalTypeEnum.regenerateDay: 'regenerate_day',
  ActionProposalTypeEnum.rescheduleWorkout: 'reschedule_workout',
};

const _$ActionProposalStatusEnumEnumMap = {
  ActionProposalStatusEnum.pending: 'pending',
  ActionProposalStatusEnum.applied: 'applied',
  ActionProposalStatusEnum.cancelled: 'cancelled',
  ActionProposalStatusEnum.expired: 'expired',
  ActionProposalStatusEnum.failed: 'failed',
};
