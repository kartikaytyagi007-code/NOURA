//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/coach_card.dart';
import 'package:noura_api_client/src/model/action_proposal.dart';
import 'package:noura_api_client/src/model/safe_error.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'coach_message.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CoachMessage {
  /// Returns a new [CoachMessage] instance.
  CoachMessage({
    required this.id,

    required this.role,

    required this.content,

    required this.status,

    required this.error,

    required this.cards,

    required this.actionProposal,

    required this.createdAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'role', required: true, includeIfNull: false)
  final CoachMessageRoleEnum role;

  @JsonKey(name: r'content', required: true, includeIfNull: false)
  final String content;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final CoachMessageStatusEnum status;

  @JsonKey(name: r'error', required: true, includeIfNull: true)
  final SafeError? error;

  @JsonKey(name: r'cards', required: true, includeIfNull: false)
  final List<CoachCard> cards;

  @JsonKey(name: r'action_proposal', required: true, includeIfNull: true)
  final ActionProposal? actionProposal;

  @JsonKey(name: r'created_at', required: true, includeIfNull: false)
  final DateTime createdAt;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CoachMessage &&
            runtimeType == other.runtimeType &&
            equals(
              [
                id,
                role,
                content,
                status,
                error,
                cards,
                actionProposal,
                createdAt,
              ],
              [
                other.id,
                other.role,
                other.content,
                other.status,
                other.error,
                other.cards,
                other.actionProposal,
                other.createdAt,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        id,
        role,
        content,
        status,
        error,
        cards,
        actionProposal,
        createdAt,
      ]);

  factory CoachMessage.fromJson(Map<String, dynamic> json) =>
      _$CoachMessageFromJson(json);

  Map<String, dynamic> toJson() => _$CoachMessageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum CoachMessageRoleEnum {
  @JsonValue(r'user')
  user(r'user'),
  @JsonValue(r'assistant')
  assistant(r'assistant');

  const CoachMessageRoleEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum CoachMessageStatusEnum {
  @JsonValue(r'pending')
  pending(r'pending'),
  @JsonValue(r'completed')
  completed(r'completed'),
  @JsonValue(r'failed')
  failed(r'failed');

  const CoachMessageStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
