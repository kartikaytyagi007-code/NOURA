import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/shell.dart';
import '../../core/providers.dart';
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
        const FeaturePlaceholder(
          title: 'Next meal',
          milestone: 'M6',
          description: 'Three options based on what you have logged and your preferences.',
          icon: Icons.restaurant_outlined,
        ),
        const FeaturePlaceholder(
          title: 'Nutrition summary',
          milestone: 'M6',
          description: 'Totals from meals you confirmed today, with coverage shown.',
          icon: Icons.pie_chart_outline,
        ),
        const FeaturePlaceholder(
          title: "Today's workout",
          milestone: 'M7',
          description: 'Your scheduled session from the weekly plan.',
          icon: Icons.fitness_center,
        ),
      ],
    );
  }
}
