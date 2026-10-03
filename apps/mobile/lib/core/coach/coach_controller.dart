import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../providers.dart' show coachRepositoryProvider;
import 'coach_repository.dart';

/// One open coach conversation: the thread id and its messages so far, oldest first (blueprint §16
/// "M9 Coach: ... grounded responses/cards"). A fresh thread is created the first time the coach tab
/// is opened in a session; the blueprint specifies no thread-list UI for V1.
class CoachChatState {
  const CoachChatState({required this.threadId, required this.messages, this.sending = false});
  final String threadId;
  final List<CoachMessage> messages;
  final bool sending;

  CoachChatState copyWith({List<CoachMessage>? messages, bool? sending}) =>
      CoachChatState(threadId: threadId, messages: messages ?? this.messages, sending: sending ?? this.sending);
}

/// Statuses that stop polling for a given assistant message (mirrors [MealScanController]'s
/// capture → processing → terminal convention for the same reason: the real reply is generated
/// asynchronously by the worker, blueprint §2).
const _terminalMessageStatuses = {CoachMessageStatusEnum.completed, CoachMessageStatusEnum.failed};

class CoachController extends AsyncNotifier<CoachChatState> {
  @override
  Future<CoachChatState> build() async {
    final repository = ref.watch(coachRepositoryProvider);
    final thread = await repository.createThread();
    final list = await repository.listMessages(thread.id);
    return CoachChatState(threadId: thread.id, messages: list.items);
  }

  CoachRepository get _repository => ref.read(coachRepositoryProvider);

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  /// Sends [text], then polls until the assistant's reply leaves `pending` (never fabricated client
  /// side: the displayed answer, cards and any proposal always come back from the server).
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final current = state.value;
    if (current == null || current.sending) return;
    state = AsyncData(current.copyWith(sending: true));
    try {
      final accepted = await _repository.sendMessage(current.threadId, trimmed);
      final optimistic = await _repository.listMessages(current.threadId);
      state = AsyncData((state.value ?? current).copyWith(messages: optimistic.items, sending: true));
      await _pollUntilTerminal(current.threadId, accepted.message.id);
    } finally {
      final latest = state.value;
      if (latest != null) state = AsyncData(latest.copyWith(sending: false));
    }
  }

  Future<void> _pollUntilTerminal(String threadId, String assistantMessageId) async {
    const maxAttempts = 15;
    const interval = Duration(seconds: 2);
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final list = await _repository.listMessages(threadId);
      final current = state.value;
      if (current != null) state = AsyncData(current.copyWith(messages: list.items, sending: true));
      final assistant = list.items.where((m) => m.id == assistantMessageId).firstOrNull;
      if (assistant == null || _terminalMessageStatuses.contains(assistant.status)) return;
      await Future<void>.delayed(interval);
    }
  }

  Future<void> applyProposal(ActionProposal proposal) async {
    await _repository.applyProposal(proposal.id, proposal.expectedRevision);
    await _refreshMessages();
  }

  Future<void> cancelProposal(ActionProposal proposal) async {
    await _repository.cancelProposal(proposal.id);
    await _refreshMessages();
  }

  Future<void> _refreshMessages() async {
    final current = state.value;
    if (current == null) return;
    final list = await _repository.listMessages(current.threadId);
    state = AsyncData(current.copyWith(messages: list.items));
  }
}

final coachControllerProvider = AsyncNotifierProvider<CoachController, CoachChatState>(CoachController.new);
