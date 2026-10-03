import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/providers.dart';
import '../../../core/ui/components/n_button.dart';
import 'auth_layout.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final expired = auth is SignedOut && auth.reason == SignOutReason.sessionExpired;
    return AuthLayout(
      showBack: false,
      title: 'NOURA',
      subtitle: 'Improve the food you already eat, and connect it with a training plan that fits.',
      children: [
        if (expired) const FormErrorText('Your session ended. Verify your number again to continue.'),
        NButton(label: 'Continue with phone number', onPressed: () => context.push(Routes.signIn)),
      ],
    );
  }
}
