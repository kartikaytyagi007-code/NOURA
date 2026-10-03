import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../../app/routes.dart';
import '../../app/shell.dart';
import '../../core/providers.dart';
import '../../core/recommendations/home_controller.dart';
import '../../core/ui/components/feature_placeholder.dart';
import '../../core/ui/tokens.dart';
import 'plan_status_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meControllerProvider).value;
    final name = me?.profile.displayName;
    final planning = me?.planning;
    final homeState = ref.watch(homeControllerProvider);
    return TabPage(
      title: "Today's progress",
      children: [
        if (name != null)
          Padding(
            padding: const EdgeInsets.only(bottom: NSpace.md),
            child: Text('Hi, $name', style: Theme.of(context).textTheme.headlineSmall),
          ),
        if (planning != null) PlanStatusCard(planning: planning),
        const FeaturePlaceholder(
          title: 'Scan a meal',
          milestone: 'M4',
          description: 'Photograph a meal, confirm foods and portions, then see Meal Balance.',
          icon: Icons.photo_camera_outlined,
        ),
        homeState.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: NSpace.md),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(NSpace.sm),
              leading: const Icon(Icons.error_outline, color: NColors.error),
              title: const Text("Couldn't load today's summary"),
              trailing: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.read(homeControllerProvider.notifier).reload(),
              ),
            ),
          ),
          data: (home) => home == null
              ? const SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(NSpace.sm),
                        leading: const Icon(Icons.restaurant_outlined),
                        title: Text(home.nextMeal == null ? 'Next meal' : home.nextMeal!.title),
                        subtitle: Text(
                          home.nextMeal == null
                              ? 'See a recommendation based on your plan and today\'s log.'
                              : _slotLabel(home.nextMeal!.slot),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(Routes.nextMeal),
                      ),
                    ),
                    const SizedBox(height: NSpace.sm),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(NSpace.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Nutrition summary', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: NSpace.xs),
                            Text(_nutritionLine(home.nutrition)),
                            if (!home.nutrition.coverage.complete)
                              const Padding(
                                padding: EdgeInsets.only(top: NSpace.xs),
                                child: Text(
                                  'Based on what has been logged so far today; some data may be incomplete.',
                                  style: TextStyle(color: NColors.outline),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: NSpace.sm),
                    Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(NSpace.sm),
                        leading: const Icon(Icons.fitness_center),
                        title: Text(home.todaysWorkout?.title ?? "Today's workout"),
                        subtitle: Text(
                          home.todaysWorkout == null
                              ? 'No session is scheduled today.'
                              : _workoutStatusLabel(home.todaysWorkout!.status),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(Routes.workout),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

String _slotLabel(MealSlot slot) => switch (slot) {
  MealSlot.breakfast => 'Breakfast',
  MealSlot.lunch => 'Lunch',
  MealSlot.dinner => 'Dinner',
  MealSlot.snack => 'Snack',
};

String _workoutStatusLabel(WorkoutSessionPreviewStatusEnum status) => switch (status) {
  WorkoutSessionPreviewStatusEnum.completed => 'Completed',
  WorkoutSessionPreviewStatusEnum.skipped => 'Skipped',
  WorkoutSessionPreviewStatusEnum.cancelled => 'Cancelled',
  WorkoutSessionPreviewStatusEnum.rescheduled => 'Rescheduled',
  WorkoutSessionPreviewStatusEnum.scheduled => 'Scheduled',
};

String _nutritionLine(NutrientTotals totals) {
  final n = totals.nutrients;
  if (n.energyKcal == null) return 'No meals logged yet today.';
  return '${n.energyKcal!.round()} kcal · ${n.proteinG ?? '—'}g protein · ${n.fibreG ?? '—'}g fibre';
}
