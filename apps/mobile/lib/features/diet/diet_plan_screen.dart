import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../../core/api/api_failure.dart';
import '../../core/diet/diet_controller.dart';
import '../../core/providers.dart';
import '../../core/ui/components/n_button.dart';
import '../../core/ui/components/state_views.dart';
import '../../core/ui/tokens.dart';

/// The active 7-day diet plan: a day selector, that day's meals with portions and nutrition, swap
/// and regenerate actions, and the required loading/empty/error states (blueprint §4, M3 ticket).
class DietPlanScreen extends ConsumerStatefulWidget {
  const DietPlanScreen({super.key});

  @override
  ConsumerState<DietPlanScreen> createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends ConsumerState<DietPlanScreen> {
  int _selectedDay = 0;
  bool _requesting = false;

  Future<void> _requestPlan({required bool regenerate}) async {
    final me = ref.read(meControllerProvider).value;
    if (me == null) return;
    if (regenerate) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Regenerate your plan?'),
          content: const Text(
            'This replaces your current 7-day plan. Meals you already logged are kept; the plan itself is not.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Regenerate')),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    setState(() => _requesting = true);
    try {
      await ref.read(dietControllerProvider.notifier).requestGeneration(profileRevision: me.profile.revision);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("We're building your plan. This can take a moment.")));
      await ref.read(dietControllerProvider.notifier).reload();
    } on ApiFailure catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  Future<void> _openSwapSheet(PlanMeal meal) async {
    final controller = ref.read(dietControllerProvider.notifier);
    try {
      final options = await controller.swapOptions(meal);
      if (!mounted) return;
      final chosen = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        builder: (context) => _SwapSheet(meal: meal, options: options),
      );
      if (chosen == null) return;
      await controller.replaceMeal(meal, chosen);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meal swapped')));
    } on ApiFailure catch (error) {
      if (!mounted) return;
      if (error.kind == ApiFailureKind.conflict) {
        await ref.read(dietControllerProvider.notifier).reload();
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('This plan changed. Showing the latest version.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final planState = ref.watch(dietControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet plan'),
        actions: [
          if (planState.value != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Regenerate plan',
              onPressed: _requesting ? null : () => _requestPlan(regenerate: true),
            ),
        ],
      ),
      body: planState.when(
        loading: () => const LoadingView(label: 'Loading your plan'),
        error: (error, _) => ErrorView(
          message: error is ApiFailure ? error.message : 'Something went wrong.',
          offline: error is ApiFailure && error.isOffline,
          onRetry: () => ref.read(dietControllerProvider.notifier).reload(),
        ),
        data: (plan) {
          if (plan == null) {
            return MessageView(
              icon: Icons.restaurant_menu_outlined,
              title: 'No plan yet',
              message: 'Generate a 7-day plan built from your food preferences and targets.',
              actionLabel: _requesting ? 'Generating…' : 'Generate my plan',
              onAction: _requesting ? null : () => _requestPlan(regenerate: false),
            );
          }
          final dayIndex = _selectedDay.clamp(0, plan.days.length - 1);
          final day = plan.days[dayIndex];
          return Column(
            children: [
              SizedBox(
                height: 56,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: NSpace.pageMargin, vertical: NSpace.sm),
                  scrollDirection: Axis.horizontal,
                  itemCount: plan.days.length,
                  separatorBuilder: (_, _) => const SizedBox(width: NSpace.sm),
                  itemBuilder: (context, i) {
                    final d = plan.days[i];
                    final selected = i == dayIndex;
                    return ChoiceChip(
                      label: Text(_weekdayLabel(d.date)),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedDay = i),
                    );
                  },
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(NSpace.pageMargin),
                  children: [
                    _DayTotals(totals: day.totals),
                    const SizedBox(height: NSpace.md),
                    for (final meal in day.meals) _MealCard(meal: meal, onSwap: () => _openSwapSheet(meal)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _weekdayLabel(DateTime date) {
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return '${names[date.weekday - 1]} ${date.day}';
}

String _kcalLabel(num? kcal) => kcal == null ? '—' : '${kcal.round()} kcal';

class _DayTotals extends StatelessWidget {
  const _DayTotals({required this.totals});
  final NutrientTotals totals;

  @override
  Widget build(BuildContext context) {
    final n = totals.nutrients;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(NSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Today's totals", style: NType.headlineSm),
            const SizedBox(height: NSpace.xs),
            Text(
              '${_kcalLabel(n.energyKcal)} · ${n.proteinG ?? '—'}g protein · ${n.carbohydrateG ?? '—'}g carbs · '
              '${n.fatG ?? '—'}g fat',
            ),
            if (!totals.coverage.complete)
              const Padding(
                padding: EdgeInsets.only(top: NSpace.xs),
                child: Text('Some meals have incomplete nutrition data.', style: TextStyle(color: NColors.outline)),
              ),
          ],
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal, required this.onSwap});
  final PlanMeal meal;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: NSpace.sm),
      child: ListTile(
        contentPadding: const EdgeInsets.all(NSpace.sm),
        title: Text(meal.recipe?.name ?? 'Recipe unavailable'),
        subtitle: Text('${_slotLabel(meal.slot)} · ${_kcalLabel(meal.nutrition.nutrients.energyKcal)}'),
        trailing: NButton(label: 'Swap', onPressed: onSwap, variant: NButtonVariant.text, expand: false),
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

class _SwapSheet extends StatelessWidget {
  const _SwapSheet({required this.meal, required this.options});
  final PlanMeal meal;
  final SwapOptions options;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(NSpace.pageMargin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Swap ${meal.recipe?.name ?? 'this meal'}', style: NType.headlineSm),
            const SizedBox(height: NSpace.sm),
            if (options.candidates.isEmpty) const Text('No alternative is available right now.'),
            for (final c in options.candidates)
              ListTile(
                title: Text(c.recipe.name),
                subtitle: Text(_kcalLabel(c.nutrition.nutrients.energyKcal)),
                onTap: () => Navigator.pop(context, c.candidateId),
              ),
          ],
        ),
      ),
    );
  }
}
