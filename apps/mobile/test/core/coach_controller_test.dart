import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noura/core/coach/coach_controller.dart';
import 'package:noura/core/coach/coach_repository.dart';
import 'package:noura/core/providers.dart';
import 'package:noura_api_client/noura_api_client.dart';

/// A fake [CoachRepository] whose behaviour the test controls directly (same convention as
/// progress_controller_test.dart's `_FakeRepo`).
class _FakeCoachRepo implements CoachRepository {
  final Map<String, List<CoachMessage>> byThread = {};
  int _counter = 0;
  bool deleted = false;
  List<Future<CoachMessageList> Function()>? replyScript;

  @override
  Future<CoachThread> createThread() async {
    _counter += 1;
    final id = 'thread-$_counter';
    byThread[id] = [];
    return CoachThread(id: id, createdAt: DateTime.now());
  }

  @override
  Future<void> deleteThread(String threadId) async {
    deleted = true;
    byThread.remove(threadId);
  }

  @override
  Future<CoachMessageList> listMessages(String threadId) async =>
      CoachMessageList(items: List.of(byThread[threadId] ?? const []), nextCursor: null);

  @override
  Future<CoachMessageAccepted> sendMessage(String threadId, String message) async {
    _counter += 1;
    final userMsg = CoachMessage(
      id: 'u-$_counter',
      role: CoachMessageRoleEnum.user,
      content: message,
      status: CoachMessageStatusEnum.completed,
      error: null,
      cards: const [],
      actionProposal: null,
      createdAt: DateTime.now(),
    );
    _counter += 1;
    final assistantMsg = CoachMessage(
      id: 'a-$_counter',
      role: CoachMessageRoleEnum.assistant,
      content: 'Thinking…',
      status: CoachMessageStatusEnum.pending,
      error: null,
      cards: const [],
      actionProposal: null,
      createdAt: DateTime.now(),
    );
    final thread = byThread.putIfAbsent(threadId, () => []);
    thread.add(userMsg);
    thread.add(assistantMsg);

    // Simulate the real async reply landing a moment later (same pattern as the worker job).
    Future<void>.delayed(const Duration(milliseconds: 10), () {
      final list = byThread[threadId]!;
      final index = list.indexWhere((m) => m.id == assistantMsg.id);
      if (index != -1) {
        list[index] = list[index].copyWith(
          status: CoachMessageStatusEnum.completed,
          content: 'Here is a grounded answer.',
        );
      }
    });

    return CoachMessageAccepted(jobId: 'job-$_counter', message: assistantMsg);
  }

  @override
  Future<ActionProposal> applyProposal(String proposalId, int expectedRevision) => throw UnimplementedError();

  @override
  Future<ActionProposal> cancelProposal(String proposalId) => throw UnimplementedError();
}

ProviderContainer _container(CoachRepository repo) {
  final container = ProviderContainer(overrides: [coachRepositoryProvider.overrideWithValue(repo)]);
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('build creates a fresh thread with an empty message list', () async {
    final repo = _FakeCoachRepo();
    final container = _container(repo);
    final chat = await container.read(coachControllerProvider.future);
    expect(chat.threadId, isNotEmpty);
    expect(chat.messages, isEmpty);
  });

  test('sendMessage appends the user message immediately and resolves to the real completed reply', () async {
    final repo = _FakeCoachRepo();
    final container = _container(repo);
    await container.read(coachControllerProvider.future);

    await container.read(coachControllerProvider.notifier).sendMessage('What should I eat?');

    final state = container.read(coachControllerProvider).value!;
    expect(state.sending, isFalse);
    expect(state.messages, hasLength(2));
    expect(state.messages[0].role, CoachMessageRoleEnum.user);
    expect(state.messages[0].content, 'What should I eat?');
    expect(state.messages[1].role, CoachMessageRoleEnum.assistant);
    expect(state.messages[1].status, CoachMessageStatusEnum.completed);
    expect(state.messages[1].content, 'Here is a grounded answer.');
  });

  test('a blank message is never sent', () async {
    final repo = _FakeCoachRepo();
    final container = _container(repo);
    await container.read(coachControllerProvider.future);

    await container.read(coachControllerProvider.notifier).sendMessage('   ');

    final state = container.read(coachControllerProvider).value!;
    expect(state.messages, isEmpty);
  });
}
