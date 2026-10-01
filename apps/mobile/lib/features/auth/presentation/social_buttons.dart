import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_state.dart';
import '../../../core/providers.dart';
import '../../../core/ui/components/n_button.dart';
import '../../../core/ui/tokens.dart';

/// Google/Apple buttons. Shown only when the provider is enabled for this build, because it must
/// also be configured in Supabase and with Google/Apple (docs/auth-providers.md).
class SocialSignInButtons extends ConsumerStatefulWidget {
  const SocialSignInButtons({super.key, required this.onError});
  final ValueChanged<String?> onError;

  @override
  ConsumerState<SocialSignInButtons> createState() => _SocialSignInButtonsState();
}

class _SocialSignInButtonsState extends ConsumerState<SocialSignInButtons> {
  SocialProvider? _busy;

  Future<void> _start(SocialProvider provider) async {
    setState(() => _busy = provider);
    widget.onError(null);
    try {
      await ref.read(authRepositoryProvider).signInWithProvider(provider);
    } on AuthFailure catch (failure) {
      widget.onError(failure.message);
    } finally {
      // The browser flow may be cancelled without any callback; never leave a spinner running.
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigProvider);
    final buttons = <Widget>[
      if (config.googleSignInEnabled)
        NButton(
          label: 'Continue with Google',
          icon: Icons.g_mobiledata_rounded,
          variant: NButtonVariant.secondary,
          loading: _busy == SocialProvider.google,
          onPressed: _busy == null ? () => _start(SocialProvider.google) : null,
        ),
      if (config.appleSignInEnabled)
        NButton(
          label: 'Continue with Apple',
          icon: Icons.apple,
          variant: NButtonVariant.secondary,
          loading: _busy == SocialProvider.apple,
          onPressed: _busy == null ? () => _start(SocialProvider.apple) : null,
        ),
    ];
    if (buttons.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        for (final b in buttons)
          Padding(
            padding: const EdgeInsets.only(bottom: NSpace.sm),
            child: b,
          ),
      ],
    );
  }
}
