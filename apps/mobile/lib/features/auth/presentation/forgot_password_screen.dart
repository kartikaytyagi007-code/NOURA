import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_state.dart';
import '../../../core/providers.dart';
import '../../../core/ui/components/n_button.dart';
import '../../../core/ui/components/n_text_field.dart';
import '../../../core/ui/tokens.dart';
import '../domain/validators.dart';
import 'auth_layout.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _busy = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(email: _email.text.trim());
      if (mounted) setState(() => _sent = true);
    } on AuthFailure catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) {
      return const AuthLayout(
        title: 'Check your email',
        // Same message whether or not the account exists, to avoid account enumeration.
        subtitle: 'If an account exists for that email, we sent a link to reset your password.',
        children: [],
      );
    }
    return AuthLayout(
      title: 'Reset password',
      subtitle: "Enter your account email and we'll send you a reset link.",
      children: [
        Form(
          key: _formKey,
          child: NTextField(
            label: 'Email',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            validator: AuthValidators.email,
          ),
        ),
        const SizedBox(height: NSpace.md),
        FormErrorText(_error),
        NButton(label: 'Send reset link', loading: _busy, onPressed: _submit),
      ],
    );
  }
}
