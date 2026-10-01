import 'auth_state.dart';

/// Authentication boundary. The app talks to Supabase directly only for authentication
/// (blueprint §2); every domain read/write goes through the NOURA API.
abstract interface class AuthRepository {
  /// Current status, available synchronously after initialization (restored session or none).
  AuthStatus get current;

  /// Emits whenever the status changes (sign-in, sign-out, token refresh failure, recovery link).
  Stream<AuthStatus> get changes;

  /// Current access token, or null when signed out. Refreshed automatically by the SDK.
  Future<String?> accessToken();

  /// Forces a token refresh. Returns false when the session can no longer be refreshed.
  Future<bool> refreshSession();

  Future<void> signInWithEmail({required String email, required String password});
  Future<SignUpResult> signUpWithEmail({required String email, required String password});
  Future<void> resendVerificationEmail({required String email});
  Future<void> sendPasswordReset({required String email});
  Future<void> updatePassword({required String newPassword});

  /// Starts a Google/Apple sign-in. Returns when the provider flow was launched; the result
  /// arrives through [changes] (or never, if the user cancels in the browser).
  Future<void> signInWithProvider(SocialProvider provider);

  Future<void> signOut({SignOutReason? reason});
}
