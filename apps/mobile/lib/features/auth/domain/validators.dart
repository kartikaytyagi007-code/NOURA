/// Client-side form checks for fast feedback only. Supabase Auth and the SMS provider enforce the
/// real rules (D-033).
abstract final class AuthValidators {
  /// Country code assumed when the user types a bare national number.
  static const defaultCountryCode = '+91';

  static final _e164 = RegExp(r'^\+[1-9][0-9]{7,14}$');
  static final _indianMobile = RegExp(r'^[6-9][0-9]{9}$');
  static final _code = RegExp(r'^[0-9]{6}$');

  /// Normalizes what the user typed to E.164, or returns null when it is not a usable number.
  /// A 10-digit Indian mobile number (optionally with a leading 0) gets [defaultCountryCode];
  /// anything starting with `+` is taken as an international number.
  static String? normalizePhone(String? value) {
    var v = (value ?? '').replaceAll(RegExp(r'[\s\-().]'), '');
    if (v.startsWith('00')) v = '+${v.substring(2)}';
    if (v.startsWith('+')) {
      if (v.startsWith('+91') && !_indianMobile.hasMatch(v.substring(3))) return null;
      return _e164.hasMatch(v) ? v : null;
    }
    if (v.length == 11 && v.startsWith('0')) v = v.substring(1);
    return _indianMobile.hasMatch(v) ? '$defaultCountryCode$v' : null;
  }

  static String? phone(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Enter your mobile number.';
    return normalizePhone(value) == null ? 'Enter a valid mobile number.' : null;
  }

  static String? otp(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter the 6-digit code.';
    return _code.hasMatch(v) ? null : 'The code has 6 digits.';
  }
}
