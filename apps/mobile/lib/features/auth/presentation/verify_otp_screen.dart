import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_state.dart';
import '../../../core/providers.dart';
import '../../../core/ui/components/n_button.dart';
import '../../../core/ui/components/n_text_field.dart';
import '../../../core/ui/tokens.dart';
import '../domain/validators.dart';
import 'auth_layout.dart';

/// Step 2 of phone sign-in: enter the SMS code. On success the auth stream changes and the router
/// moves on; this screen never navigates into the app itself.
class VerifyOtpScreen extends ConsumerStatefulWidget {
  const VerifyOtpScreen({super.key, required this.phone});

  final String phone;

  /// Seconds before another code may be requested (Supabase also rate-limits server-side).
  static const resendCooldownSeconds = 30;

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  Timer? _timer;
  int _cooldown = VerifyOtpScreen.resendCooldownSeconds;
  bool _busy = false;
  bool _resending = false;
  String? _error;
  String? _info;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    _cooldown = VerifyOtpScreen.resendCooldownSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _cooldown--);
      if (_cooldown <= 0) timer.cancel();
    });
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    try {
      await ref.read(authRepositoryProvider).verifyPhoneOtp(phone: widget.phone, code: _code.text.trim());
    } on AuthFailure catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    setState(() {
      _resending = true;
      _error = null;
      _info = null;
    });
    try {
      await ref.read(authRepositoryProvider).sendPhoneOtp(phone: widget.phone);
      if (!mounted) return;
      _code.clear();
      setState(() => _info = 'We sent a new code.');
      _startCooldown();
    } on AuthFailure catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AuthLayout(
      title: 'Enter the code',
      subtitle: 'We sent a 6-digit code by SMS to ${widget.phone}.',
      children: [
        Form(
          key: _formKey,
          child: NTextField(
            label: '6-digit code',
            controller: _code,
            keyboardType: TextInputType.number,
            autofillHints: const [AutofillHints.oneTimeCode],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _verify(),
            validator: AuthValidators.otp,
          ),
        ),
        const SizedBox(height: NSpace.md),
        FormErrorText(_error),
        if (_info != null)
          Padding(
            padding: const EdgeInsets.only(bottom: NSpace.md),
            child: Semantics(liveRegion: true, child: Text(_info!, style: theme.textTheme.bodyMedium)),
          ),
        NButton(label: 'Verify and continue', loading: _busy, onPressed: _busy ? null : _verify),
        const SizedBox(height: NSpace.sm),
        NButton(
          label: _cooldown > 0 ? 'Resend code in ${_cooldown}s' : 'Resend code',
          variant: NButtonVariant.text,
          loading: _resending,
          onPressed: _cooldown > 0 || _resending ? null : _resend,
        ),
        NButton(label: 'Change number', variant: NButtonVariant.text, onPressed: () => context.pop()),
      ],
    );
  }
}
