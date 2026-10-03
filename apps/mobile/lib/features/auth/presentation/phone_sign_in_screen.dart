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

/// Step 1 of phone sign-in (D-033): enter a mobile number and get a one-time code by SMS. New and
/// returning users take the same path; the account is created on first successful verification.
class PhoneSignInScreen extends ConsumerStatefulWidget {
  const PhoneSignInScreen({super.key});

  @override
  ConsumerState<PhoneSignInScreen> createState() => _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends ConsumerState<PhoneSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final phone = AuthValidators.normalizePhone(_phone.text)!;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).sendPhoneOtp(phone: phone);
      if (mounted) await context.push(Uri(path: Routes.verifyOtp, queryParameters: {'phone': phone}).toString());
    } on AuthFailure catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Your mobile number',
      subtitle: 'We\'ll text you a 6-digit code to sign in. No password needed.',
      children: [
        Form(
          key: _formKey,
          child: NTextField(
            label: 'Mobile number',
            controller: _phone,
            keyboardType: TextInputType.phone,
            autofillHints: const [AutofillHints.telephoneNumber],
            textInputAction: TextInputAction.done,
            helperText: 'Indian numbers can skip ${AuthValidators.defaultCountryCode}. Others start with +.',
            onSubmitted: (_) => _submit(),
            validator: AuthValidators.phone,
          ),
        ),
        const SizedBox(height: NSpace.md),
        FormErrorText(_error),
        NButton(label: 'Send code', loading: _busy, onPressed: _busy ? null : _submit),
        const SizedBox(height: NSpace.sm),
        Text(
          'Standard SMS rates may apply.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: NColors.onSurfaceVariant),
        ),
      ],
    );
  }
}
