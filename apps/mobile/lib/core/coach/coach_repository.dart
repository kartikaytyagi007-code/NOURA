import 'dart:math';

import 'package:dio/dio.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../api/api_failure.dart';
import '../profile/profile_repository.dart' show newIdempotencyKey;

/// Server-owned coach chat (M9: context-aware chat, honest gap-handling, confirm-before-apply
/// suggestions, blueprint §12, §16 "M9 Coach"). Widgets use this through [CoachController]; they
/// never call the generated client directly (same convention as [ProgressRepository]).
abstract interface class CoachRepository {
  Future<CoachThread> createThread();

  Future<void> deleteThread(String threadId);

  Future<CoachMessageList> listMessages(String threadId);

  /// Sends a message and returns the accepted job plus the pending assistant placeholder. The real
  /// reply arrives asynchronously; callers poll [listMessages] until that message leaves `pending`
  /// (same convention as [MealScanController]'s capture → processing → terminal flow).
  Future<CoachMessageAccepted> sendMessage(String threadId, String message);

  /// Applies a proposed action (e.g. a meal swap) through the normal confirmed-action path — this
  /// never happens silently as a side effect of a chat message (blueprint §12 "requires_confirmation").
  Future<ActionProposal> applyProposal(String proposalId, int expectedRevision);

  Future<ActionProposal> cancelProposal(String proposalId);
}

final _random = Random.secure();
String _newClientId() => 'coach-${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(1 << 32)}';

class ApiCoachRepository implements CoachRepository {
  ApiCoachRepository(this._client);

  final NouraApiClient _client;

  CoachApi get _coach => _client.getCoachApi();

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<CoachThread> createThread() =>
      _guard(() async => (await _coach.createCoachThread(idempotencyKey: newIdempotencyKey())).data!.data);

  @override
  Future<void> deleteThread(String threadId) =>
      _guard(() async => _coach.deleteCoachThread(id: threadId, idempotencyKey: newIdempotencyKey()));

  @override
  Future<CoachMessageList> listMessages(String threadId) =>
      _guard(() async => (await _coach.listCoachMessages(id: threadId)).data!.data);

  @override
  Future<CoachMessageAccepted> sendMessage(String threadId, String message) => _guard(
    () async => (await _coach.sendCoachMessage(
      id: threadId,
      idempotencyKey: newIdempotencyKey(),
      sendCoachMessageRequest: SendCoachMessageRequest(clientId: _newClientId(), message: message),
    )).data!.data,
  );

  @override
  Future<ActionProposal> applyProposal(String proposalId, int expectedRevision) => _guard(
    () async => (await _coach.applyActionProposal(
      id: proposalId,
      idempotencyKey: newIdempotencyKey(),
      revisionRequest: RevisionRequest(expectedRevision: expectedRevision),
    )).data!.data,
  );

  @override
  Future<ActionProposal> cancelProposal(String proposalId) => _guard(
    () async => (await _coach.cancelActionProposal(id: proposalId, idempotencyKey: newIdempotencyKey())).data!.data,
  );
}

/// DEVELOPMENT-ONLY coach used with mock auth (same convention as [MockProgressRepository]). It
/// never calls a real AI provider; it answers deterministically and always labels itself `(mock)`
/// in its replies, mirroring the server's own mock-provider labelling (D-010, D-031).
class MockCoachRepository implements CoachRepository {
  final Map<String, List<CoachMessage>> _messagesByThread = {};
  int _counter = 0;

  String _id(String prefix) {
    _counter += 1;
    return 'mock-$prefix-$_counter';
  }

  @override
  Future<CoachThread> createThread() async {
    final id = _id('thread');
    _messagesByThread[id] = [];
    return CoachThread(id: id, createdAt: DateTime.now());
  }

  @override
  Future<void> deleteThread(String threadId) async {
    _messagesByThread.remove(threadId);
  }

  @override
  Future<CoachMessageList> listMessages(String threadId) async {
    return CoachMessageList(items: List.of(_messagesByThread[threadId] ?? const []), nextCursor: null);
  }

  @override
  Future<CoachMessageAccepted> sendMessage(String threadId, String message) async {
    final thread = _messagesByThread.putIfAbsent(threadId, () => []);
    final userMessage = CoachMessage(
      id: _id('msg'),
      role: CoachMessageRoleEnum.user,
      content: message,
      status: CoachMessageStatusEnum.completed,
      error: null,
      cards: const [],
      actionProposal: null,
      createdAt: DateTime.now(),
    );
    thread.add(userMessage);

    final lower = message.toLowerCase();
    final isOutOfScope =
        lower.contains('diagnos') || lower.contains('dosage') || lower.contains('dose') || lower.contains('insulin');
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final CoachMessage assistantMessage;
    if (isOutOfScope) {
      assistantMessage = CoachMessage(
        id: _id('msg'),
        role: CoachMessageRoleEnum.assistant,
        content:
            "I can't help with diagnoses or medication dosing (mock) — please contact a doctor. "
            'I can help with your meals and workouts instead.',
        status: CoachMessageStatusEnum.completed,
        error: null,
        cards: const [],
        actionProposal: null,
        createdAt: DateTime.now(),
      );
    } else if (lower.contains('swap')) {
      final proposal = ActionProposal(
        id: _id('proposal'),
        type: ActionProposalTypeEnum.swapMeal,
        status: ActionProposalStatusEnum.pending,
        expectedRevision: 1,
        expiresAt: DateTime.now().add(const Duration(minutes: 15)),
        appliedAt: null,
        summary: "Swap today's lunch for a mock alternative.",
      );
      assistantMessage = CoachMessage(
        id: _id('msg'),
        role: CoachMessageRoleEnum.assistant,
        content: "Development mock provider (mock): I can swap today's lunch — just confirm below.",
        status: CoachMessageStatusEnum.completed,
        error: null,
        cards: const [],
        actionProposal: proposal,
        createdAt: DateTime.now(),
      );
    } else {
      assistantMessage = CoachMessage(
        id: _id('msg'),
        role: CoachMessageRoleEnum.assistant,
        content:
            "Development mock provider (mock): you don't have a real active plan in this mock build, "
            'so I have no real meal or workout data to ground an answer in.',
        status: CoachMessageStatusEnum.completed,
        error: null,
        cards: const [],
        actionProposal: null,
        createdAt: DateTime.now(),
      );
    }
    thread.add(assistantMessage);
    return CoachMessageAccepted(jobId: _id('job'), message: assistantMessage);
  }

  @override
  Future<ActionProposal> applyProposal(String proposalId, int expectedRevision) async {
    for (final messages in _messagesByThread.values) {
      for (var i = 0; i < messages.length; i++) {
        final proposal = messages[i].actionProposal;
        if (proposal?.id == proposalId) {
          final applied = proposal!.copyWith(status: ActionProposalStatusEnum.applied, appliedAt: DateTime.now());
          messages[i] = messages[i].copyWith(actionProposal: applied);
          return applied;
        }
      }
    }
    throw const ApiFailure(kind: ApiFailureKind.notFound, message: 'Proposal not found.', retryable: false);
  }

  @override
  Future<ActionProposal> cancelProposal(String proposalId) async {
    for (final messages in _messagesByThread.values) {
      for (var i = 0; i < messages.length; i++) {
        final proposal = messages[i].actionProposal;
        if (proposal?.id == proposalId) {
          final cancelled = proposal!.copyWith(status: ActionProposalStatusEnum.cancelled);
          messages[i] = messages[i].copyWith(actionProposal: cancelled);
          return cancelled;
        }
      }
    }
    throw const ApiFailure(kind: ApiFailureKind.notFound, message: 'Proposal not found.', retryable: false);
  }
}
