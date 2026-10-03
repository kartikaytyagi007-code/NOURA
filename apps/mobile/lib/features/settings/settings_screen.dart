import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/auth/auth_state.dart';
import '../../core/profile/session_profile.dart';
import '../../core/providers.dart';
import '../../core/ui/components/feature_placeholder.dart';
import '../../core/ui/components/n_button.dart';
import '../../core/ui/tokens.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final config = ref.watch(appConfigProvider);
    final theme = Theme.of(context);
    final email = auth is SignedIn ? auth.email : null;
    final onboardingDone = ref.watch(sessionProfileProvider).value?.onboarding == OnboardingState.completed;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(NSpace.pageMargin),
        children: [
          Text('Account', style: theme.textTheme.titleMedium),
          const SizedBox(height: NSpace.sm),
          Text(email ?? 'Signed in', style: theme.textTheme.bodyLarge),
          Text(
            'Environment: ${config.environment?.name ?? 'unknown'}${config.useMocks ? ' (development mocks)' : ''}',
            style: theme.textTheme.bodySmall?.copyWith(color: NColors.onSurfaceVariant),
          ),
          const SizedBox(height: NSpace.lg),
          Text('Profile and preferences', style: theme.textTheme.titleMedium),
          const SizedBox(height: NSpace.sm),
          if (!onboardingDone)
            Text(
              'Finish setting up your profile to edit it here.',
              style: theme.textTheme.bodyMedium?.copyWith(color: NColors.onSurfaceVariant),
            )
          else
            Card(
              child: Column(
                children: [
                  for (final (icon, label, route) in const [
                    (Icons.person_outline, 'Profile', Routes.settingsProfile),
                    (Icons.flag_outlined, 'Goal', Routes.settingsGoal),
                    (Icons.restaurant_outlined, 'Food preferences', Routes.settingsPreferences),
                    (Icons.fitness_center, 'Training', Routes.settingsTraining),
                    (Icons.fact_check_outlined, 'Eligibility', Routes.settingsEligibility),
                  ])
                    ListTile(
                      leading: Icon(icon),
                      title: Text(label),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(route),
                    ),
                ],
              ),
            ),
          const SizedBox(height: NSpace.lg),
          const FeaturePlaceholder(
            title: 'Reminders',
            milestone: 'M10',
            description: 'Local meal and workout reminders after you opt in.',
          ),
          const SizedBox(height: NSpace.sm),
          const FeaturePlaceholder(
            title: 'Purchases and restore',
            milestone: 'M10',
            description: 'Subscription status and restoring purchases.',
          ),
          const SizedBox(height: NSpace.sm),
          const FeaturePlaceholder(
            title: 'Export and delete account',
            milestone: 'M10',
            description: 'Download your data or delete your account.',
          ),
          const SizedBox(height: NSpace.lg),
          NButton(
            label: 'Sign out',
            variant: NButtonVariant.secondary,
            icon: Icons.logout,
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
    );
  }
}
