import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'auth_repository.dart';
import 'auth_state.dart';

/// Supabase Auth implementation. Session persistence, restoration on cold start and token
/// refresh are handled by supabase_flutter; this class maps them to [AuthStatus].
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client, {required this.redirectUrl}) {
    _subscription = _client.auth.onAuthStateChange.listen(
      _onAuthEvent,
      onError: (Object _) => _emit(const SignedOut(reason: SignOutReason.sessionExpired)),
    );
    final session = _client.auth.currentSession;
    _current = session == null ? const SignedOut() : _signedIn(session.user);
  }

  final sb.SupabaseClient _client;
  final String redirectUrl;
  final _controller = StreamController<AuthStatus>.broadcast();
  late final StreamSubscription<sb.AuthState> _subscription;
  late AuthStatus _current;
  SignOutReason? _pendingSignOutReason;

  @override
  AuthStatus get current => _current;

  @override
  Stream<AuthStatus> get changes => _controller.stream;

  void _emit(AuthStatus status) {
    _current = status;
    _controller.add(status);
  }

  static SignedIn _signedIn(sb.User user) => SignedIn(userId: user.id, email: user.email);

  void _onAuthEvent(sb.AuthState state) {
    switch (state.event) {
      case sb.AuthChangeEvent.passwordRecovery:
        _emit(const PasswordRecovery());
      case sb.AuthChangeEvent.signedOut:
        _emit(SignedOut(reason: _pendingSignOutReason));
        _pendingSignOutReason = null;
      case sb.AuthChangeEvent.initialSession:
      case sb.AuthChangeEvent.signedIn:
      case sb.AuthChangeEvent.tokenRefreshed:
      case sb.AuthChangeEvent.userUpdated:
      case sb.AuthChangeEvent.mfaChallengeVerified:
        final session = state.session;
        if (session == null) {
          if (_current is! SignedOut) _emit(const SignedOut());
        } else if (_current is! PasswordRecovery || state.event == sb.AuthChangeEvent.userUpdated) {
          _emit(_signedIn(session.user));
        }
      // ignore: deprecated_member_use
      case sb.AuthChangeEvent.userDeleted:
        _emit(const SignedOut());
    }
  }

  @override
  Future<String?> accessToken() async => _client.auth.currentSession?.accessToken;

  @override
  Future<bool> refreshSession() async {
    try {
      final response = await _client.auth.refreshSession();
      return response.session != null;
    } on sb.AuthException {
      return false;
    }
  }

  @override
  Future<void> signInWithEmail({required String email, required String password}) =>
      _guard(() => _client.auth.signInWithPassword(email: email, password: password));

  @override
  Future<SignUpResult> signUpWithEmail({required String email, required String password}) async {
    final response = await _guard(
      () => _client.auth.signUp(email: email, password: password, emailRedirectTo: redirectUrl),
    );
    return SignUpResult(needsEmailVerification: response.session == null);
  }

  @override
  Future<void> resendVerificationEmail({required String email}) =>
      _guard(() => _client.auth.resend(type: sb.OtpType.signup, email: email, emailRedirectTo: redirectUrl));

  @override
  Future<void> sendPasswordReset({required String email}) =>
      _guard(() => _client.auth.resetPasswordForEmail(email, redirectTo: redirectUrl));

  @override
  Future<void> updatePassword({required String newPassword}) async {
    await _guard(() => _client.auth.updateUser(sb.UserAttributes(password: newPassword)));
    final session = _client.auth.currentSession;
    if (session != null) _emit(_signedIn(session.user));
  }

  @override
  Future<void> signInWithProvider(SocialProvider provider) async {
    final launched = await _guard(
      () => _client.auth.signInWithOAuth(
        provider == SocialProvider.google ? sb.OAuthProvider.google : sb.OAuthProvider.apple,
        redirectTo: redirectUrl,
        authScreenLaunchMode: sb.LaunchMode.externalApplication,
      ),
    );
    if (!launched) throw const AuthFailure('Could not open the sign-in page. Please try again.');
  }

  @override
  Future<void> signOut({SignOutReason? reason}) async {
    _pendingSignOutReason = reason;
    try {
      await _client.auth.signOut();
    } on sb.AuthException {
      // Local session is cleared even if the revoke call fails (for example offline).
      _emit(SignedOut(reason: reason));
    }
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on sb.AuthException catch (error) {
      throw AuthFailure(messageFor(error.code, error.statusCode), code: error.code);
    }
  }

  /// Maps Supabase Auth error codes to short user-facing messages without leaking internals.
  static String messageFor(String? code, String? statusCode) {
    switch (code) {
      case 'invalid_credentials':
        return 'That email and password do not match.';
      case 'email_not_confirmed':
        return 'Please verify your email first. Check your inbox for the link.';
      case 'user_already_exists':
      case 'email_exists':
        return 'An account with this email already exists. Try signing in.';
      case 'weak_password':
        return 'Choose a stronger password: at least 8 characters with letters and numbers.';
      case 'over_email_send_rate_limit':
      case 'over_request_rate_limit':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'same_password':
        return 'Choose a password you have not used before.';
      case 'provider_disabled':
        return 'This sign-in method is not available yet.';
      default:
        if (statusCode == null || statusCode.startsWith('5')) {
          return 'We could not reach the sign-in service. Check your connection and try again.';
        }
        return 'Something went wrong. Please try again.';
    }
  }

  Future<void> dispose() async {
    await _subscription.cancel();
    await _controller.close();
  }
}
