import 'package:flutter/material.dart';

import '../../../core/ui/tokens.dart';

/// Common scrollable layout for auth screens; works with large text scales and the keyboard.
class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.title, this.subtitle, required this.children, this.showBack = true});

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: showBack ? AppBar() : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: NSpace.pageMargin, vertical: NSpace.lg),
              children: [
                Semantics(header: true, child: Text(title, style: theme.textTheme.headlineLarge)),
                if (subtitle != null) ...[
                  const SizedBox(height: NSpace.sm),
                  Text(subtitle!, style: theme.textTheme.bodyLarge?.copyWith(color: NColors.onSurfaceVariant)),
                ],
                const SizedBox(height: NSpace.lg),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FormErrorText extends StatelessWidget {
  const FormErrorText(this.message, {super.key});
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: NSpace.md),
      child: Semantics(
        liveRegion: true,
        child: Text(message!, style: const TextStyle(color: NColors.error)),
      ),
    );
  }
}
