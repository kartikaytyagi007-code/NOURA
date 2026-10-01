import 'package:flutter/material.dart';

import '../tokens.dart';
import 'n_button.dart';

/// Shared loading / empty / error / offline states. Every data screen uses these (blueprint §4).
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.label = 'Loading'});
  final String label;

  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(label: label, liveRegion: true, child: const CircularProgressIndicator()),
  );
}

class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(NSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: NColors.secondary, semanticLabel: title),
            const SizedBox(height: NSpace.md),
            Text(title, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: NSpace.sm),
            Text(message, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              const SizedBox(height: NSpace.lg),
              NButton(label: actionLabel!, onPressed: onAction),
            ],
            if (secondaryLabel != null) ...[
              const SizedBox(height: NSpace.sm),
              NButton(label: secondaryLabel!, onPressed: onSecondary, variant: NButtonVariant.text),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.title, required this.message});
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => MessageView(icon: Icons.inbox_outlined, title: title, message: message);
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry, this.offline = false});
  final String message;
  final VoidCallback onRetry;
  final bool offline;

  @override
  Widget build(BuildContext context) => MessageView(
    icon: offline ? Icons.cloud_off_outlined : Icons.error_outline,
    title: offline ? "You're offline" : 'Something went wrong',
    message: message,
    actionLabel: 'Try again',
    onAction: onRetry,
  );
}
