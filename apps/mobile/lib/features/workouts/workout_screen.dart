import 'package:flutter/material.dart';

import '../../app/shell.dart';
import '../../core/ui/components/feature_placeholder.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPage(
      title: 'Workout',
      children: [
        FeaturePlaceholder(
          title: 'Weekly plan and sessions',
          milestone: 'M7',
          description: 'Gym or home sessions with sets, reps, rest and substitutions.',
          icon: Icons.fitness_center,
        ),
        FeaturePlaceholder(
          title: 'Set logging',
          milestone: 'M7',
          description: 'Log reps and load; completed and skipped are tracked separately.',
          icon: Icons.checklist,
        ),
      ],
    );
  }
}
