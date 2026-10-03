import 'auth_state.dart';

/// Authentication boundary. The app talks to Supabase directly only for authentication
/// (blueprint §2); every domain read/write goes through the NOURA API.
///
/// Sign-in is phone number + one-time SMS code only (decision D-033): there are no passwords, no
/// email accounts and no social providers. The same two calls create the account on first use.
abstract interface class AuthRepository {
  /// Current status, available synchronously after initialization (restored session or none).
  AuthStatus get current;

  /// Emits whenever the status changes (sign-in, sign-out, token refresh failure).
  Stream<AuthStatus> get changes;

  /// Current access token, or null when signed out. Refreshed automatically by the SDK.
  Future<String?> accessToken();

  /// Forces a token refresh. Returns false when the session can no longer be refreshed.
  Future<bool> refreshSession();

  /// Sends a one-time code by SMS to [phone] (E.164, e.g. `+919876543210`). Creates the account on
  /// first use, so there is no separate sign-up step.
  Future<void> sendPhoneOtp({required String phone});

  /// Verifies the code sent to [phone]. On success the session arrives through [changes].
  Future<void> verifyPhoneOtp({required String phone, required String code});

  Future<void> signOut({SignOutReason? reason});
}
