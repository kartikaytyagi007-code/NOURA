import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../../core/meals/plate_fixes_controller.dart';
import '../../core/meals/plate_fixes_state.dart';
import '../../core/ui/components/state_views.dart';
import '../../core/ui/tokens.dart';

/// "Fix My Plate" (blueprint §8 step 7, §16 M5): up to three keep/reduce/add suggestions for the
/// just-confirmed meal, each with a real projected scenario, plus a combined after-changes scenario.
/// Suggestions are proposals only — accepting one means going back to correct items (M4's flow), not
/// an automatic edit (blueprint §9's "proposals, never automatic").
class FixMyPlateScreen extends ConsumerStatefulWidget {
  const FixMyPlateScreen({super.key, required this.scanId, required this.expectedRevision});
  final String scanId;
  final int expectedRevision;

  @override
  ConsumerState<FixMyPlateScreen> createState() => _FixMyPlateScreenState();
}

class _FixMyPlateScreenState extends ConsumerState<FixMyPlateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    ref
        .read(plateFixesControllerProvider.notifier)
        .load(scanId: widget.scanId, expectedRevision: widget.expectedRevision);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(plateFixesControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Fix My Plate')),
      body: switch (state) {
        PlateFixesIdle() || PlateFixesLoading() => const LoadingView(label: 'Finding plate improvements'),
        PlateFixesError(message: final message, retryable: final retryable) => MessageView(
          icon: Icons.error_outline,
          title: 'Could not load suggestions',
          message: message,
          actionLabel: retryable ? 'Try again' : null,
          onAction: retryable ? _load : null,
        ),
        PlateFixesLoaded(fixes: final fixes) => _FixesView(fixes: fixes),
      },
    );
  }
}

class _FixesView extends StatelessWidget {
  const _FixesView({required this.fixes});
  final PlateFixes fixes;

  @override
  Widget build(BuildContext context) {
    if (fixes.fixes.isEmpty) {
      return const MessageView(
        icon: Icons.check_circle_outline,
        title: 'This meal already looks balanced',
        message: 'We found no catalog-supported changes to suggest right now.',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(NSpace.pageMargin),
      children: [
        const Text(
          'These are suggestions, not automatic changes. To apply one, go back and correct the '
          'items — nothing here is saved to your diary.',
          style: TextStyle(color: NColors.onSurfaceVariant),
        ),
        const SizedBox(height: NSpace.md),
        for (final fix in fixes.fixes) _PlateActionCard(fix: fix),
        const SizedBox(height: NSpace.md),
        _AfterChangesCard(afterChanges: fixes.afterChanges),
      ],
    );
  }
}

String _actionLabel(PlateActionTypeEnum type) => switch (type) {
  PlateActionTypeEnum.keep => 'Keep',
  PlateActionTypeEnum.reduce => 'Reduce',
  PlateActionTypeEnum.add => 'Add',
  PlateActionTypeEnum.replace => 'Replace',
};

IconData _actionIcon(PlateActionTypeEnum type) => switch (type) {
  PlateActionTypeEnum.keep => Icons.check_circle_outline,
  PlateActionTypeEnum.reduce => Icons.remove_circle_outline,
  PlateActionTypeEnum.add => Icons.add_circle_outline,
  PlateActionTypeEnum.replace => Icons.swap_horiz,
};

class _PlateActionCard extends StatelessWidget {
  const _PlateActionCard({required this.fix});
  final PlateAction fix;

  @override
  Widget build(BuildContext context) {
    final score = fix.projected.mealBalance.score;
    return Card(
      margin: const EdgeInsets.only(bottom: NSpace.sm),
      child: Padding(
        padding: const EdgeInsets.all(NSpace.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_actionIcon(fix.type), color: NColors.secondary),
                const SizedBox(width: NSpace.xs),
                Text(_actionLabel(fix.type), style: NType.labelLg),
                if (fix.proposedGrams != null) ...[const Spacer(), Text('${fix.proposedGrams!.round()} g')],
              ],
            ),
            const SizedBox(height: NSpace.xs),
            Text(fix.reason),
            const SizedBox(height: NSpace.xs),
            Text(
              score == null
                  ? 'Projected balance: not calculable (${fix.projected.mealBalance.missingDataMessage ?? 'incomplete data'}).'
                  : 'Projected balance if applied: $score / 100.',
              style: const TextStyle(color: NColors.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _AfterChangesCard extends StatelessWidget {
  const _AfterChangesCard({required this.afterChanges});
  final AfterChangesScenario afterChanges;

  @override
  Widget build(BuildContext context) {
    final score = afterChanges.mealBalance.score;
    return Card(
      color: NColors.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(NSpace.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('If you applied all of these', style: NType.labelLg),
            const SizedBox(height: NSpace.xs),
            Text(
              score == null
                  ? afterChanges.mealBalance.missingDataMessage ??
                        'A combined projected score is not calculable from the available data.'
                  : 'Projected Meal Balance: $score / 100 (estimated — not your actual intake).',
            ),
            if (afterChanges.assumptions.isNotEmpty) ...[
              const SizedBox(height: NSpace.sm),
              const Text('Assumptions:', style: TextStyle(fontWeight: FontWeight.w600)),
              for (final assumption in afterChanges.assumptions)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text('• $assumption', style: const TextStyle(color: NColors.onSurfaceVariant)),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
