import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/providers.dart';
import '../../core/ui/components/feature_placeholder.dart';
import '../../core/ui/components/n_button.dart';
import '../../core/ui/tokens.dart';

/// M1 placeholder. The router sends signed-in users here until the server reports onboarding as
/// completed. The resumable onboarding flow (basics → goals → diet → training → eligibility/consent
/// → review) is implemented in M2.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set up your profile'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(NSpace.pageMargin),
        children: [
          Text('Your profile setup is not available in this build yet.', style: theme.textTheme.bodyLarge),
          const SizedBox(height: NSpace.lg),
          const FeaturePlaceholder(
            title: 'Profile and preferences',
            milestone: 'M2',
            description: 'Basics, goals, diet preferences, training, eligibility and consent, then review.',
            icon: Icons.assignment_outlined,
          ),
          const SizedBox(height: NSpace.lg),
          NButton(
            label: 'Sign out',
            variant: NButtonVariant.secondary,
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
    );
  }
}
