// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_message.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CoachMessageCWProxy {
  CoachMessage id(String id);

  CoachMessage role(CoachMessageRoleEnum role);

  CoachMessage content(String content);

  CoachMessage status(CoachMessageStatusEnum status);

  CoachMessage error(SafeError? error);

  CoachMessage cards(List<CoachCard> cards);

  CoachMessage actionProposal(ActionProposal? actionProposal);

  CoachMessage createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CoachMessage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CoachMessage(...).copyWith(id: 12, name: "My name")
  /// ````
  CoachMessage call({
    String id,
    CoachMessageRoleEnum role,
    String content,
    CoachMessageStatusEnum status,
    SafeError? error,
    List<CoachCard> cards,
    ActionProposal? actionProposal,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCoachMessage.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCoachMessage.copyWith.fieldName(...)`
class _$CoachMessageCWProxyImpl implements _$CoachMessageCWProxy {
  const _$CoachMessageCWProxyImpl(this._value);

  final CoachMessage _value;

  @override
  CoachMessage id(String id) => this(id: id);

  @override
  CoachMessage role(CoachMessageRoleEnum role) => this(role: role);

  @override
  CoachMessage content(String content) => this(content: content);

  @override
  CoachMessage status(CoachMessageStatusEnum status) => this(status: status);

  @override
  CoachMessage error(SafeError? error) => this(error: error);

  @override
  CoachMessage cards(List<CoachCard> cards) => this(cards: cards);

  @override
  CoachMessage actionProposal(ActionProposal? actionProposal) =>
      this(actionProposal: actionProposal);

  @override
  CoachMessage createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CoachMessage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CoachMessage(...).copyWith(id: 12, name: "My name")
  /// ````
  CoachMessage call({
    Object? id = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? content = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
    Object? cards = const $CopyWithPlaceholder(),
    Object? actionProposal = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return CoachMessage(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as CoachMessageRoleEnum,
      content: content == const $CopyWithPlaceholder()
          ? _value.content
          // ignore: cast_nullable_to_non_nullable
          : content as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as CoachMessageStatusEnum,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as SafeError?,
      cards: cards == const $CopyWithPlaceholder()
          ? _value.cards
          // ignore: cast_nullable_to_non_nullable
          : cards as List<CoachCard>,
      actionProposal: actionProposal == const $CopyWithPlaceholder()
          ? _value.actionProposal
          // ignore: cast_nullable_to_non_nullable
          : actionProposal as ActionProposal?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $CoachMessageCopyWith on CoachMessage {
  /// Returns a callable class that can be used as follows: `instanceOfCoachMessage.copyWith(...)` or like so:`instanceOfCoachMessage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CoachMessageCWProxy get copyWith => _$CoachMessageCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoachMessage _$CoachMessageFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CoachMessage',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'role',
            'content',
            'status',
            'error',
            'cards',
            'action_proposal',
            'created_at',
          ],
        );
        final val = CoachMessage(
          id: $checkedConvert('id', (v) => v as String),
          role: $checkedConvert(
            'role',
            (v) => $enumDecode(_$CoachMessageRoleEnumEnumMap, v),
          ),
          content: $checkedConvert('content', (v) => v as String),
          status: $checkedConvert(
            'status',
            (v) => $enumDecode(_$CoachMessageStatusEnumEnumMap, v),
          ),
          error: $checkedConvert(
            'error',
            (v) => v == null
                ? null
                : SafeError.fromJson(v as Map<String, dynamic>),
          ),
          cards: $checkedConvert(
            'cards',
            (v) => (v as List<dynamic>)
                .map((e) => CoachCard.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
          actionProposal: $checkedConvert(
            'action_proposal',
            (v) => v == null
                ? null
                : ActionProposal.fromJson(v as Map<String, dynamic>),
          ),
          createdAt: $checkedConvert(
            'created_at',
            (v) => DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'actionProposal': 'action_proposal',
        'createdAt': 'created_at',
      },
    );

Map<String, dynamic> _$CoachMessageToJson(CoachMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': _$CoachMessageRoleEnumEnumMap[instance.role]!,
      'content': instance.content,
      'status': _$CoachMessageStatusEnumEnumMap[instance.status]!,
      'error': instance.error?.toJson(),
      'cards': instance.cards.map((e) => e.toJson()).toList(),
      'action_proposal': instance.actionProposal?.toJson(),
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$CoachMessageRoleEnumEnumMap = {
  CoachMessageRoleEnum.user: 'user',
  CoachMessageRoleEnum.assistant: 'assistant',
};

const _$CoachMessageStatusEnumEnumMap = {
  CoachMessageStatusEnum.pending: 'pending',
  CoachMessageStatusEnum.completed: 'completed',
  CoachMessageStatusEnum.failed: 'failed',
};
