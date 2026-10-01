import 'package:flutter/material.dart';

enum NButtonVariant { primary, secondary, text }

/// Replaceable button primitive. Feature code uses this, not Material buttons directly, so Stitch
/// styling can be swapped in one place. Always at least 48x48 logical pixels.
class NButton extends StatelessWidget {
  const NButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = NButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final NButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final onTap = loading ? null : onPressed;
    final child = loading
        ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
        : Text(label);
    final Widget button = switch (variant) {
      NButtonVariant.primary =>
        icon == null
            ? FilledButton(onPressed: onTap, child: child)
            : FilledButton.icon(onPressed: onTap, icon: Icon(icon), label: child),
      NButtonVariant.secondary =>
        icon == null
            ? OutlinedButton(onPressed: onTap, child: child)
            : OutlinedButton.icon(onPressed: onTap, icon: Icon(icon), label: child),
      NButtonVariant.text => TextButton(onPressed: onTap, child: child),
    };
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: loading ? '$label, in progress' : null,
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}
