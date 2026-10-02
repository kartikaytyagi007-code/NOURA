import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/shell.dart';
import '../../core/ui/components/feature_placeholder.dart';
import '../../core/ui/tokens.dart';

class MealsScreen extends StatelessWidget {
  const MealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TabPage(
      title: 'Meals',
      children: [
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(NSpace.sm),
            leading: const Icon(Icons.calendar_month_outlined),
            title: const Text('Diet plan'),
            subtitle: const Text('Seven-day plan from curated recipes, with swaps you confirm.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.dietPlan),
          ),
        ),
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(NSpace.sm),
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Scan a meal'),
            subtitle: const Text('Photograph a meal to identify foods and log it, with your review.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.mealScan),
          ),
        ),
        const FeaturePlaceholder(
          title: 'Food search',
          milestone: 'planned',
          description: 'Log a meal by searching the catalog directly, without a photo.',
          icon: Icons.menu_book_outlined,
        ),
        const FeaturePlaceholder(
          title: 'Seven-day patterns',
          milestone: 'M6',
          description: 'Patterns in your logged meals, with coverage shown.',
          icon: Icons.insights_outlined,
        ),
      ],
    );
  }
}
