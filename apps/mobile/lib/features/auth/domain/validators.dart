/// Client-side form checks for fast feedback only. Supabase Auth enforces the real rules
/// (minimum length 8, letters and digits; see supabase/config.toml).
abstract final class AuthValidators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter your email.';
    if (!_email.hasMatch(v)) return 'Enter a valid email address.';
    return null;
  }

  static String? signInPassword(String? value) => (value == null || value.isEmpty) ? 'Enter your password.' : null;

  static String? newPassword(String? value) {
    final v = value ?? '';
    if (v.length < 8) return 'Use at least 8 characters.';
    if (!RegExp('[A-Za-z]').hasMatch(v) || !RegExp('[0-9]').hasMatch(v)) {
      return 'Use both letters and numbers.';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() original) =>
      (value) => value == original() ? null : 'Passwords do not match.';
}
