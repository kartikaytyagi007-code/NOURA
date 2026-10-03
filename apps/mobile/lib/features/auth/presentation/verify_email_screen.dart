import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/providers.dart';
import '../../../core/ui/components/n_button.dart';
import '../../../core/ui/tokens.dart';
import 'auth_layout.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});
  final String email;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _busy = false;
  String? _status;

  Future<void> _resend() async {
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).resendVerificationEmail(email: widget.email);
      if (mounted) setState(() => _status = 'We sent another link.');
    } on AuthFailure catch (failure) {
      if (mounted) setState(() => _status = failure.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      showBack: false,
      title: 'Check your email',
      subtitle:
          'We sent a verification link to ${widget.email.isEmpty ? 'your email' : widget.email}. '
          'Open it on this device to finish creating your account.',
      children: [
        if (_status != null)
          Padding(
            padding: const EdgeInsets.only(bottom: NSpace.md),
            child: Text(_status!),
          ),
        NButton(label: 'Back to sign in', onPressed: () => context.go(Routes.signIn)),
        const SizedBox(height: NSpace.sm),
        NButton(
          label: 'Resend link',
          variant: NButtonVariant.text,
          loading: _busy,
          onPressed: widget.email.isEmpty ? null : _resend,
        ),
      ],
    );
  }
}
