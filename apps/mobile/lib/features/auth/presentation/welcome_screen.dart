import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/providers.dart';
import '../../../core/ui/components/n_button.dart';
import '../../../core/ui/tokens.dart';
import 'auth_layout.dart';
import 'social_buttons.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  String? _error;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final expired = auth is SignedOut && auth.reason == SignOutReason.sessionExpired;
    return AuthLayout(
      showBack: false,
      title: 'NOURA',
      subtitle: 'Improve the food you already eat, and connect it with a training plan that fits.',
      children: [
        if (expired) const FormErrorText('Your session expired. Please sign in again.'),
        FormErrorText(_error),
        NButton(label: 'Create account', onPressed: () => context.push(Routes.signUp)),
        const SizedBox(height: NSpace.sm),
        NButton(label: 'Sign in', variant: NButtonVariant.secondary, onPressed: () => context.push(Routes.signIn)),
        const SizedBox(height: NSpace.lg),
        SocialSignInButtons(onError: (message) => setState(() => _error = message)),
      ],
    );
  }
}
