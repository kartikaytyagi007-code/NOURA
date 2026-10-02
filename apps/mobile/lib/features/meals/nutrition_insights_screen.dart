import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../../core/api/api_failure.dart';
import '../../core/recommendations/insights_controller.dart';
import '../../core/ui/components/state_views.dart';
import '../../core/ui/tokens.dart';

/// Seven-day nutrition patterns (blueprint §4 "Meals: seven-day patterns", §10, §16 M6). Shows
/// coverage honestly: excluded days and an explicit uncertainty notice are always visible, never
/// just a clean-looking average.
class NutritionInsightsScreen extends ConsumerWidget {
  const NutritionInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(insightsControllerProvider);
    final controller = ref.read(insightsControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition patterns')),
      body: state.when(
        loading: () => const LoadingView(label: 'Loading your patterns'),
        error: (error, _) => ErrorView(
          message: error is ApiFailure ? error.message : 'Something went wrong.',
          offline: error is ApiFailure && error.isOffline,
          onRetry: controller.reload,
        ),
        data: (insights) => _InsightsBody(insights: insights),
      ),
    );
  }
}

class _InsightsBody extends StatelessWidget {
  const _InsightsBody({required this.insights});
  final Insights insights;

  @override
  Widget build(BuildContext context) {
    if (insights.loggedMeals == 0) {
      return const MessageView(
        icon: Icons.insights_outlined,
        title: 'No meals logged yet',
        message: 'Log a few meals this week to see your nutrition patterns.',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(NSpace.pageMargin),
      children: [
        Text(
          'Based on ${insights.loggedMeals} logged meal(s) across ${insights.daysWithLogs} of 7 days.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: NSpace.sm),
        if (insights.coverageUncertain)
          Card(
            color: NColors.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(NSpace.sm),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 20, color: NColors.outline),
                  const SizedBox(width: NSpace.sm),
                  Expanded(
                    child: Text(
                      insights.usableDays == 0
                          ? "We don't have enough complete data this week to show a pattern yet."
                          : 'Based on ${insights.usableDays} of 7 days with complete nutrition data. '
                                '${insights.excludedDays.length} day(s) were excluded: '
                                '${insights.excludedDays.map(_shortDate).join(', ')}.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: NSpace.md),
        if (insights.insights.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: NSpace.md),
            child: Text('No notable patterns in your logged meals this week.'),
          )
        else
          for (final insight in insights.insights)
            _InsightCard(insight: insight, isFocus: insight.key == insights.focus?.key),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight, required this.isFocus});
  final Insight insight;
  final bool isFocus;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: NSpace.sm),
      color: isFocus ? NColors.secondaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(NSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_titleFor(insight.key), style: Theme.of(context).textTheme.titleMedium),
            if (insight.explanation != null) ...[const SizedBox(height: NSpace.xs), Text(insight.explanation!)],
          ],
        ),
      ),
    );
  }
}

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _shortDate(DateTime date) => '${_months[date.month - 1]} ${date.day}';

String _titleFor(String key) => switch (key) {
  'protein_gap' => 'Protein gap',
  'fibre_gap' => 'Fibre gap',
  'coverage' => 'Data coverage',
  _ => key,
};
