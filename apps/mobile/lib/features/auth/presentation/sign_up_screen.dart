import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/providers.dart';
import '../../../core/ui/components/n_button.dart';
import '../../../core/ui/components/n_text_field.dart';
import '../../../core/ui/tokens.dart';
import '../domain/validators.dart';
import 'auth_layout.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
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
      final email = _email.text.trim();
      final result = await ref.read(authRepositoryProvider).signUpWithEmail(email: email, password: _password.text);
      if (result.needsEmailVerification && mounted) {
        context.go(Uri(path: Routes.verifyEmail, queryParameters: {'email': email}).toString());
      }
    } on AuthFailure catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Create account',
      subtitle: 'NOURA is for adults. You can review how your data is used before setting up your plan.',
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              children: [
                NTextField(
                  label: 'Email',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  validator: AuthValidators.email,
                ),
                const SizedBox(height: NSpace.md),
                NTextField(
                  label: 'Password',
                  controller: _password,
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.next,
                  validator: AuthValidators.newPassword,
                ),
                const SizedBox(height: NSpace.md),
                NTextField(
                  label: 'Confirm password',
                  controller: _confirm,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  validator: AuthValidators.confirmPassword(() => _password.text),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: NSpace.md),
        FormErrorText(_error),
        NButton(label: 'Create account', loading: _busy, onPressed: _submit),
      ],
    );
  }
}
