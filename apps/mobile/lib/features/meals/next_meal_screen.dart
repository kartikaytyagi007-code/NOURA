import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../../core/api/api_failure.dart';
import '../../core/recommendations/next_meal_controller.dart';
import '../../core/recommendations/next_meal_state.dart';
import '../../core/ui/components/n_button.dart';
import '../../core/ui/components/state_views.dart';
import '../../core/ui/tokens.dart';

/// "What should I eat next?" (blueprint §4 "Next meal", §9, §16 M6): the recommendation, its reason,
/// alternatives, and add/swap/dismiss actions — with the required loading/empty/error states and an
/// explicit incomplete-data notice when today's intake can't fully support a reason.
class NextMealScreen extends ConsumerStatefulWidget {
  const NextMealScreen({super.key});

  @override
  ConsumerState<NextMealScreen> createState() => _NextMealScreenState();
}

class _NextMealScreenState extends ConsumerState<NextMealScreen> {
  bool _acting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(nextMealControllerProvider.notifier).load());
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_acting) return;
    setState(() => _acting = true);
    try {
      await action();
    } on ApiFailure catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nextMealControllerProvider);
    final controller = ref.read(nextMealControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('What should I eat next?')),
      body: switch (state) {
        NextMealIdle() || NextMealLoading() => const LoadingView(label: 'Finding your next meal'),
        NextMealError(:final message, :final retryable) => ErrorView(
          message: message,
          offline: !retryable,
          onRetry: controller.reload,
        ),
        NextMealLoaded(:final nextMeal) => _NextMealBody(
          nextMeal: nextMeal,
          busy: _acting,
          onAdd: (option) => _run(() => controller.add(nextMeal, option)),
          onSwap: (option) => _run(() => controller.swap(nextMeal, option, expectedRevision: option.planMealRevision!)),
          onDismiss: () => _run(() => controller.dismiss(nextMeal)),
        ),
      },
    );
  }
}

class _NextMealBody extends StatelessWidget {
  const _NextMealBody({
    required this.nextMeal,
    required this.busy,
    required this.onAdd,
    required this.onSwap,
    required this.onDismiss,
  });

  final NextMeal nextMeal;
  final bool busy;
  final void Function(NextMealOption option) onAdd;
  final void Function(NextMealOption option) onSwap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    if (nextMeal.options.isEmpty) {
      return MessageView(
        icon: Icons.restaurant_outlined,
        title: _slotLabel(nextMeal.slot),
        message: nextMeal.explanation ?? 'Nothing to suggest right now.',
      );
    }
    final primary = nextMeal.options.first;
    final alternatives = nextMeal.options.skip(1).toList();
    return ListView(
      padding: const EdgeInsets.all(NSpace.pageMargin),
      children: [
        if (nextMeal.limitedContext)
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
                      nextMeal.explanation ?? "Today's logged intake is incomplete, so this has limited context.",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: NSpace.md),
        Text(_slotLabel(nextMeal.slot), style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: NSpace.sm),
        _OptionCard(
          option: primary,
          primary: true,
          busy: busy,
          onAdd: () => onAdd(primary),
          onSwap: () => onSwap(primary),
          onDismiss: onDismiss,
        ),
        if (alternatives.isNotEmpty) ...[
          const SizedBox(height: NSpace.md),
          Text('Alternatives', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: NSpace.sm),
          for (final option in alternatives)
            _OptionCard(
              option: option,
              primary: false,
              busy: busy,
              onAdd: () => onAdd(option),
              onSwap: () => onSwap(option),
              onDismiss: onDismiss,
            ),
        ],
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.option,
    required this.primary,
    required this.busy,
    required this.onAdd,
    required this.onSwap,
    required this.onDismiss,
  });

  final NextMealOption option;
  final bool primary;
  final bool busy;
  final VoidCallback onAdd;
  final VoidCallback onSwap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final kcal = option.nutrition.nutrients.energyKcal;
    return Card(
      margin: const EdgeInsets.only(bottom: NSpace.sm),
      child: Padding(
        padding: const EdgeInsets.all(NSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(option.recipe.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: NSpace.xs),
            Text(kcal == null ? '—' : '${kcal.round()} kcal'),
            const SizedBox(height: NSpace.xs),
            Text(option.reason, style: Theme.of(context).textTheme.bodySmall),
            if (!option.nutrition.coverage.complete)
              const Padding(
                padding: EdgeInsets.only(top: NSpace.xs),
                child: Text('Some nutrition data is incomplete.', style: TextStyle(color: NColors.outline)),
              ),
            const SizedBox(height: NSpace.sm),
            Wrap(
              spacing: NSpace.sm,
              runSpacing: NSpace.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // A non-null plan_meal_id means this option can be swapped into that slot; a plan
                // option is already there (nothing to do), so only an alternative needs the button.
                if (option.planMealId != null && option.source_ != NextMealSource.plan)
                  NButton(label: 'Swap in', onPressed: busy ? null : onSwap, expand: false)
                else if (option.planMealId == null)
                  NButton(label: 'Add to plan', onPressed: busy ? null : onAdd, expand: false),
                if (primary)
                  NButton(
                    label: 'Dismiss',
                    onPressed: busy ? null : onDismiss,
                    variant: NButtonVariant.text,
                    expand: false,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _slotLabel(MealSlot slot) => switch (slot) {
  MealSlot.breakfast => 'Breakfast',
  MealSlot.lunch => 'Lunch',
  MealSlot.dinner => 'Dinner',
  MealSlot.snack => 'Snack',
};
