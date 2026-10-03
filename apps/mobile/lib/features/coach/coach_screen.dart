import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../../app/shell.dart';
import '../../core/api/api_failure.dart';
import '../../core/coach/coach_controller.dart';
import '../../core/ui/components/state_views.dart';
import '../../core/ui/tokens.dart';

const _suggestedPrompts = [
  'What should I eat next?',
  'How is my week looking?',
  "What's today's workout?",
  'Can you swap my lunch?',
];

/// Coach chat (blueprint §4 "Messages, contextual suggestion chips, proposal cards, confirm/cancel
/// plan change"; §16 "M9 Coach"). The coach only ever answers from the user's own real app data or
/// says plainly when that data is missing (blueprint §12) — nothing here is computed client side.
/// A proposed action (e.g. a meal swap) always needs an explicit confirm tap; it is never applied as
/// a side effect of sending a message (scope note 7, "no silent actions").
class CoachScreen extends ConsumerStatefulWidget {
  const CoachScreen({super.key});

  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _controller.clear();
    await ref.read(coachControllerProvider.notifier).sendMessage(trimmed);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coachControllerProvider);
    final controller = ref.read(coachControllerProvider.notifier);
    return TabPage(
      title: 'Coach',
      scrollable: false,
      children: [
        Expanded(
          child: state.when(
            loading: () => const LoadingView(label: 'Starting your coach chat'),
            error: (error, _) => ErrorView(
              message: error is ApiFailure ? error.message : 'Something went wrong.',
              offline: error is ApiFailure && error.isOffline,
              onRetry: controller.reload,
            ),
            data: (chat) => _ChatBody(
              chat: chat,
              scrollController: _scrollController,
              onPromptTap: _send,
              onApply: controller.applyProposal,
              onCancel: controller.cancelProposal,
            ),
          ),
        ),
        const Divider(height: 1),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(NSpace.sm, NSpace.sm, NSpace.sm, NSpace.sm),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _send,
                    decoration: const InputDecoration(
                      hintText: 'Ask your coach…',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: NSpace.sm, vertical: NSpace.sm),
                    ),
                  ),
                ),
                const SizedBox(width: NSpace.sm),
                IconButton.filled(
                  onPressed: state.value?.sending == true ? null : () => _send(_controller.text),
                  icon: const Icon(Icons.send),
                  tooltip: 'Send',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatBody extends StatelessWidget {
  const _ChatBody({
    required this.chat,
    required this.scrollController,
    required this.onPromptTap,
    required this.onApply,
    required this.onCancel,
  });

  final CoachChatState chat;
  final ScrollController scrollController;
  final Future<void> Function(String) onPromptTap;
  final Future<void> Function(ActionProposal) onApply;
  final Future<void> Function(ActionProposal) onCancel;

  @override
  Widget build(BuildContext context) {
    if (chat.messages.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(NSpace.md),
        children: [
          const Text('Ask about your plan, meals or workouts. I only use your real app data.'),
          const SizedBox(height: NSpace.md),
          Wrap(
            spacing: NSpace.sm,
            runSpacing: NSpace.sm,
            children: [
              for (final prompt in _suggestedPrompts)
                ActionChip(label: Text(prompt), onPressed: () => onPromptTap(prompt)),
            ],
          ),
        ],
      );
    }
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(NSpace.md),
      itemCount: chat.messages.length,
      itemBuilder: (context, index) =>
          _MessageBubble(message: chat.messages[index], onApply: onApply, onCancel: onCancel),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.onApply, required this.onCancel});
  final CoachMessage message;
  final Future<void> Function(ActionProposal) onApply;
  final Future<void> Function(ActionProposal) onCancel;

  bool get _isUser => message.role == CoachMessageRoleEnum.user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPending = message.status == CoachMessageStatusEnum.pending;
    final isFailed = message.status == CoachMessageStatusEnum.failed;
    return Align(
      alignment: _isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: NSpace.xs),
          child: Column(
            crossAxisAlignment: _isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: NSpace.md, vertical: NSpace.sm),
                decoration: BoxDecoration(
                  color: _isUser
                      ? NColors.primaryContainer
                      : (isFailed ? NColors.errorContainer : NColors.surfaceContainer),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: isPending
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox.square(dimension: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: NSpace.sm),
                          Text('Thinking…'),
                        ],
                      )
                    : Text(
                        message.content,
                        style: theme.textTheme.bodyMedium?.copyWith(color: isFailed ? NColors.onErrorContainer : null),
                      ),
              ),
              for (final card in message.cards) _CoachCardView(card: card),
              if (message.actionProposal != null)
                _ProposalCard(proposal: message.actionProposal!, onApply: onApply, onCancel: onCancel),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoachCardView extends StatelessWidget {
  const _CoachCardView({required this.card});
  final CoachCard card;

  @override
  Widget build(BuildContext context) {
    final icon = switch (card.type) {
      CoachCardTypeEnum.meal => Icons.restaurant_outlined,
      CoachCardTypeEnum.workout => Icons.fitness_center_outlined,
      CoachCardTypeEnum.insight => Icons.insights_outlined,
    };
    return Padding(
      padding: const EdgeInsets.only(top: NSpace.xs),
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(dense: true, leading: Icon(icon), title: Text(card.title)),
      ),
    );
  }
}

/// A proposed plan change (blueprint §12 "requires_confirmation=true"): shown with explicit
/// confirm/cancel actions, never applied automatically.
class _ProposalCard extends StatefulWidget {
  const _ProposalCard({required this.proposal, required this.onApply, required this.onCancel});
  final ActionProposal proposal;
  final Future<void> Function(ActionProposal) onApply;
  final Future<void> Function(ActionProposal) onCancel;

  @override
  State<_ProposalCard> createState() => _ProposalCardState();
}

class _ProposalCardState extends State<_ProposalCard> {
  bool _busy = false;
  String? _error;

  Future<void> _run(Future<void> Function(ActionProposal) action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action(widget.proposal);
    } on ApiFailure catch (error) {
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final proposal = widget.proposal;
    final pending = proposal.status == ActionProposalStatusEnum.pending;
    return Padding(
      padding: const EdgeInsets.only(top: NSpace.xs),
      child: Card(
        margin: EdgeInsets.zero,
        color: NColors.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(NSpace.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(proposal.summary),
              const SizedBox(height: NSpace.xs),
              Text(switch (proposal.status) {
                ActionProposalStatusEnum.pending => 'Awaiting your confirmation.',
                ActionProposalStatusEnum.applied => 'Applied.',
                ActionProposalStatusEnum.cancelled => 'Cancelled.',
                ActionProposalStatusEnum.expired => 'This suggestion expired.',
                ActionProposalStatusEnum.failed => 'This suggestion could not be applied.',
              }, style: Theme.of(context).textTheme.bodySmall),
              if (_error != null) ...[
                const SizedBox(height: NSpace.xs),
                Text(_error!, style: const TextStyle(color: NColors.error)),
              ],
              if (pending) ...[
                const SizedBox(height: NSpace.sm),
                Row(
                  children: [
                    TextButton(onPressed: _busy ? null : () => _run(widget.onCancel), child: const Text('Cancel')),
                    const SizedBox(width: NSpace.sm),
                    FilledButton(
                      onPressed: _busy ? null : () => _run(widget.onApply),
                      child: _busy
                          ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Confirm'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
