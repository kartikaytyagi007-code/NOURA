import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_state.dart';
import '../../../core/providers.dart';
import '../../../core/ui/components/n_button.dart';
import '../../../core/ui/components/n_text_field.dart';
import '../../../core/ui/tokens.dart';
import '../domain/validators.dart';
import 'auth_layout.dart';

/// Reached from a password-recovery link. Completing it signs the user in normally.
class UpdatePasswordScreen extends ConsumerStatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  ConsumerState<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends ConsumerState<UpdatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).updatePassword(newPassword: _password.text);
    } on AuthFailure catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      showBack: false,
      title: 'Choose a new password',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              NTextField(
                label: 'New password',
                controller: _password,
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                validator: AuthValidators.newPassword,
              ),
              const SizedBox(height: NSpace.md),
              NTextField(
                label: 'Confirm new password',
                controller: _confirm,
                obscureText: true,
                onSubmitted: (_) => _submit(),
                validator: AuthValidators.confirmPassword(() => _password.text),
              ),
            ],
          ),
        ),
        const SizedBox(height: NSpace.md),
        FormErrorText(_error),
        NButton(label: 'Save password', loading: _busy, onPressed: _submit),
        NButton(
          label: 'Cancel and sign out',
          variant: NButtonVariant.text,
          onPressed: () => ref.read(authRepositoryProvider).signOut(),
        ),
      ],
    );
  }
}
