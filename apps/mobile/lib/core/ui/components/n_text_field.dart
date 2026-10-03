import 'package:flutter/material.dart';

/// Replaceable text input primitive with a visible label (not placeholder-only) for accessibility.
class NTextField extends StatelessWidget {
  const NTextField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.autofillHints,
    this.textInputAction,
    this.onSubmitted,
    this.helperText,
    this.suffixText,
    this.enabled = true,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final String? helperText;
  final String? suffixText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      autofillHints: autofillHints,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      autocorrect: false,
      enableSuggestions: !obscureText,
      enabled: enabled,
      decoration: InputDecoration(labelText: label, helperText: helperText, suffixText: suffixText),
    );
  }
}
