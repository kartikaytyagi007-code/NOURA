import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../../app/routes.dart';
import '../../app/shell.dart';
import '../../core/api/api_failure.dart';
import '../../core/progress/progress_controller.dart';
import '../../core/ui/components/state_views.dart';
import '../../core/ui/tokens.dart';

/// Weight trend, starting/current/goal weight at a glance, and honest meal-plan/workout adherence
/// summaries (blueprint §6, §16 "M8 Progress"). Never infers progress from missing data and never
/// claims causation between weight change and adherence (M8 ticket).
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(progressControllerProvider);
    final controller = ref.read(progressControllerProvider.notifier);
    return TabPage(
      title: 'Progress',
      children: [
        state.when(
          loading: () => const SizedBox(height: 240, child: LoadingView(label: 'Loading your progress')),
          error: (error, _) => SizedBox(
            height: 240,
            child: ErrorView(
              message: error is ApiFailure ? error.message : 'Something went wrong.',
              offline: error is ApiFailure && error.isOffline,
              onRetry: controller.reload,
            ),
          ),
          data: (progress) => _ProgressBody(progress: progress),
        ),
      ],
    );
  }
}

class _ProgressBody extends StatelessWidget {
  const _ProgressBody({required this.progress});
  final Progress progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WeightCard(progress: progress),
        const SizedBox(height: NSpace.md),
        _AdherenceCard(
          title: 'Meal-plan adherence',
          icon: Icons.restaurant_outlined,
          adherence: progress.dietAdherence,
          unit: 'planned meals',
          noPlanMessage: 'No diet plan is active, so there is nothing to measure adherence against.',
        ),
        const SizedBox(height: NSpace.sm),
        _AdherenceCard(
          title: 'Workout consistency',
          icon: Icons.fitness_center_outlined,
          adherence: progress.workoutAdherence,
          unit: 'scheduled sessions',
          noPlanMessage: 'No workout plan is active, so there is nothing to measure consistency against.',
        ),
        const SizedBox(height: NSpace.md),
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(NSpace.sm),
            leading: const Icon(Icons.show_chart),
            title: const Text('Weight history'),
            subtitle: const Text('View and record individual weight entries.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.weightHistory),
          ),
        ),
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(NSpace.sm),
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Progress photos'),
            subtitle: const Text('Private front, side and back photos. Never analyzed.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.progressPhotos),
          ),
        ),
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(NSpace.sm),
            leading: const Icon(Icons.compare_outlined),
            title: const Text('Compare photos'),
            subtitle: const Text('Pick two dates and view the photos side by side.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.progressCompare),
          ),
        ),
      ],
    );
  }
}

class _WeightCard extends StatelessWidget {
  const _WeightCard({required this.progress});
  final Progress progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(NSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weight', style: theme.textTheme.titleMedium),
            const SizedBox(height: NSpace.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _WeightStat(label: 'Starting', value: progress.startingWeightKg),
                _WeightStat(label: 'Current', value: progress.currentWeightKg),
                _WeightStat(label: 'Goal', value: progress.goalWeightKg),
              ],
            ),
            if (progress.weightPoints.isEmpty) ...[
              const SizedBox(height: NSpace.md),
              const Text('No weight entries yet. Add one from Weight history.'),
            ] else ...[
              const SizedBox(height: NSpace.md),
              Text(
                '${progress.weightPoints.length} entr${progress.weightPoints.length == 1 ? 'y' : 'ies'} '
                'in the last 30 days.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WeightStat extends StatelessWidget {
  const _WeightStat({required this.label, required this.value});
  final String label;
  final num? value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value == null ? '—' : '${value!.toStringAsFixed(1)} kg', style: theme.textTheme.titleLarge),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _AdherenceCard extends StatelessWidget {
  const _AdherenceCard({
    required this.title,
    required this.icon,
    required this.adherence,
    required this.unit,
    required this.noPlanMessage,
  });

  final String title;
  final IconData icon;
  final AdherenceSummary adherence;
  final String unit;
  final String noPlanMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(NSpace.md),
        child: Row(
          children: [
            Icon(icon, color: NColors.secondary),
            const SizedBox(width: NSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: NSpace.xs),
                  if (!adherence.planActive)
                    Text(noPlanMessage, style: theme.textTheme.bodySmall)
                  else
                    Text('${adherence.logged} of ${adherence.planned} $unit so far.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
