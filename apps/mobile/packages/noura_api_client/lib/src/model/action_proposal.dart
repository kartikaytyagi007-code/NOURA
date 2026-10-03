//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'action_proposal.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ActionProposal {
  /// Returns a new [ActionProposal] instance.
  ActionProposal({
    required this.id,

    required this.type,

    required this.status,

    required this.expectedRevision,

    required this.expiresAt,

    required this.appliedAt,

    required this.summary,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'type', required: true, includeIfNull: false)
  final ActionProposalTypeEnum type;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final ActionProposalStatusEnum status;

  // minimum: 1
  @JsonKey(name: r'expected_revision', required: true, includeIfNull: false)
  final int expectedRevision;

  @JsonKey(name: r'expires_at', required: true, includeIfNull: false)
  final DateTime expiresAt;

  @JsonKey(name: r'applied_at', required: true, includeIfNull: true)
  final DateTime? appliedAt;

  @JsonKey(name: r'summary', required: true, includeIfNull: false)
  final String summary;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ActionProposal &&
            runtimeType == other.runtimeType &&
            equals(
              [
                id,
                type,
                status,
                expectedRevision,
                expiresAt,
                appliedAt,
                summary,
              ],
              [
                other.id,
                other.type,
                other.status,
                other.expectedRevision,
                other.expiresAt,
                other.appliedAt,
                other.summary,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        id,
        type,
        status,
        expectedRevision,
        expiresAt,
        appliedAt,
        summary,
      ]);

  factory ActionProposal.fromJson(Map<String, dynamic> json) =>
      _$ActionProposalFromJson(json);

  Map<String, dynamic> toJson() => _$ActionProposalToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ActionProposalTypeEnum {
  @JsonValue(r'swap_meal')
  swapMeal(r'swap_meal'),
  @JsonValue(r'regenerate_day')
  regenerateDay(r'regenerate_day'),
  @JsonValue(r'reschedule_workout')
  rescheduleWorkout(r'reschedule_workout');

  const ActionProposalTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum ActionProposalStatusEnum {
  @JsonValue(r'pending')
  pending(r'pending'),
  @JsonValue(r'applied')
  applied(r'applied'),
  @JsonValue(r'cancelled')
  cancelled(r'cancelled'),
  @JsonValue(r'expired')
  expired(r'expired'),
  @JsonValue(r'failed')
  failed(r'failed');

  const ActionProposalStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
