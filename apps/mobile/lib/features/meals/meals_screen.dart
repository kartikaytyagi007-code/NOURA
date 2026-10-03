import 'package:flutter/material.dart';

import '../../app/shell.dart';
import '../../core/ui/components/feature_placeholder.dart';

class MealsScreen extends StatelessWidget {
  const MealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPage(
      title: 'Meals',
      children: [
        FeaturePlaceholder(
          title: 'Diet plan',
          milestone: 'M3',
          description: 'Seven-day plan from curated recipes, with swaps you confirm.',
          icon: Icons.calendar_month_outlined,
        ),
        FeaturePlaceholder(
          title: 'Diary and manual entry',
          milestone: 'M4',
          description: 'Log meals by scan or food search.',
          icon: Icons.menu_book_outlined,
        ),
        FeaturePlaceholder(
          title: 'Seven-day patterns',
          milestone: 'M6',
          description: 'Patterns in your logged meals, with coverage shown.',
          icon: Icons.insights_outlined,
        ),
      ],
    );
  }
}
