import 'package:flutter/material.dart';

import '../../app/shell.dart';
import '../../core/ui/components/feature_placeholder.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPage(
      title: 'Progress',
      children: [
        FeaturePlaceholder(
          title: 'Weight trend',
          milestone: 'M8',
          description: 'Your logged weight over time.',
          icon: Icons.show_chart,
        ),
        FeaturePlaceholder(
          title: 'Consistency',
          milestone: 'M8',
          description: 'Meal logging and completed sessions against scheduled sessions.',
          icon: Icons.event_available_outlined,
        ),
        FeaturePlaceholder(
          title: 'Progress photos',
          milestone: 'M8',
          description: 'Private front, side and back photos for side-by-side comparison only.',
          icon: Icons.photo_library_outlined,
        ),
      ],
    );
  }
}
