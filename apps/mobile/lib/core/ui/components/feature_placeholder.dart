import 'package:flutter/material.dart';

import '../tokens.dart';

/// Explicitly labelled placeholder for a future milestone. It is deliberately non-interactive so
/// unfinished features never appear functional (M1 boundary). Shows no sample numbers.
class FeaturePlaceholder extends StatelessWidget {
  const FeaturePlaceholder({
    super.key,
    required this.title,
    required this.milestone,
    required this.description,
    this.icon = Icons.hourglass_empty_rounded,
  });

  final String title;
  final String milestone;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      label: '$title. Not available yet. Planned for $milestone.',
      excludeSemantics: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(NSpace.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: NColors.secondary),
              const SizedBox(width: NSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: NSpace.xs),
                    Text(description, style: theme.textTheme.bodyMedium?.copyWith(color: NColors.onSurfaceVariant)),
                    const SizedBox(height: NSpace.sm),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: NColors.tonalInset,
                        borderRadius: BorderRadius.circular(NRadius.md),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: NSpace.sm, vertical: NSpace.xs),
                        child: Text('Not available yet · $milestone', style: theme.textTheme.labelMedium),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
