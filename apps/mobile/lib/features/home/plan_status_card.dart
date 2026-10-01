import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../../app/routes.dart';
import '../../core/ui/components/n_button.dart';
import '../../core/ui/tokens.dart';

/// What the profile and eligibility mean for planning. This is real, server-derived state (the
/// plan itself arrives in M3), so the card states plainly what is and is not available. It shows no
/// calorie or nutrient numbers: the target policy in development builds is a placeholder.
class PlanStatusCard extends StatelessWidget {
  const PlanStatusCard({super.key, required this.planning});

  final Planning planning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (title, body, icon, action) = switch (planning.status) {
      PlanningStatus.requested => (
        'Plan requested',
        'Your details are saved and a meal plan request is queued. Plan generation is not available in this '
            'build yet (planned for M3).',
        Icons.schedule,
        null,
      ),
      PlanningStatus.unavailableTrackingOnly => (
        'Tracking only',
        'Based on your answers, NOURA will not create automated meal or workout plans for you. Tracking '
            'stays available.',
        Icons.insights_outlined,
        'Review your answers',
      ),
      PlanningStatus.unavailableNeedsReview => (
        'Plans are off for now',
        'You chose not to answer a screening question, so automated plans are off. You can update your answers '
            'any time.',
        Icons.help_outline,
        'Update your answers',
      ),
      PlanningStatus.unavailablePolicy => (
        'Plans are not available yet',
        'Automated plans are switched off in this environment until an approved nutrition policy is '
            'configured. Your profile is saved.',
        Icons.lock_outline,
        null,
      ),
    };
    return Card(
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
                  Text(body, style: theme.textTheme.bodyMedium?.copyWith(color: NColors.onSurfaceVariant)),
                  if (action != null) ...[
                    const SizedBox(height: NSpace.sm),
                    NButton(
                      label: action,
                      expand: false,
                      variant: NButtonVariant.secondary,
                      onPressed: () => context.push(Routes.settingsEligibility),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
