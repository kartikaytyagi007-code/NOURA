import 'package:flutter/material.dart';

import '../../app/shell.dart';
import '../../core/ui/components/feature_placeholder.dart';

class CoachScreen extends StatelessWidget {
  const CoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPage(
      title: 'Coach',
      children: [
        FeaturePlaceholder(
          title: 'Coach chat',
          milestone: 'M9',
          description: 'Ask about your plan. Proposed changes only apply after you confirm them.',
          icon: Icons.chat_bubble_outline,
        ),
      ],
    );
  }
}
