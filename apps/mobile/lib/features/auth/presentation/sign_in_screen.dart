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
import 'social_buttons.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // On success the auth stream changes and the router moves on; no navigation here.
      await ref.read(authRepositoryProvider).signInWithEmail(email: _email.text.trim(), password: _password.text);
    } on AuthFailure catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Sign in',
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
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  validator: AuthValidators.signInPassword,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: NSpace.md),
        FormErrorText(_error),
        NButton(label: 'Sign in', loading: _busy, onPressed: _submit),
        NButton(
          label: 'Forgot password?',
          variant: NButtonVariant.text,
          onPressed: () => context.push(Routes.forgotPassword),
        ),
        const SizedBox(height: NSpace.md),
        SocialSignInButtons(onError: (message) => setState(() => _error = message)),
      ],
    );
  }
}
