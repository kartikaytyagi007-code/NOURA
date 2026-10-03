import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'auth_repository.dart';
import 'auth_state.dart';

/// Supabase Auth implementation. Session persistence, restoration on cold start and token
/// refresh are handled by supabase_flutter; this class maps them to [AuthStatus].
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client) {
    _subscription = _client.auth.onAuthStateChange.listen(
      _onAuthEvent,
      onError: (Object _) => _emit(const SignedOut(reason: SignOutReason.sessionExpired)),
    );
    final session = _client.auth.currentSession;
    _current = session == null ? const SignedOut() : _signedIn(session.user);
  }

  final sb.SupabaseClient _client;
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

  static SignedIn _signedIn(sb.User user) => SignedIn(userId: user.id, phone: e164(user.phone));

  /// Supabase stores phone numbers without the leading `+`; the app always shows E.164.
  static String? e164(String? phone) {
    if (phone == null || phone.isEmpty) return null;
    return phone.startsWith('+') ? phone : '+$phone';
  }

  void _onAuthEvent(sb.AuthState state) {
    switch (state.event) {
      case sb.AuthChangeEvent.passwordRecovery:
        // Password recovery does not exist with phone-only sign-in (D-033); ignore stray events.
        break;
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
        } else {
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
  Future<void> sendPhoneOtp({required String phone}) =>
      _guard(() => _client.auth.signInWithOtp(phone: phone, shouldCreateUser: true, channel: sb.OtpChannel.sms));

  @override
  Future<void> verifyPhoneOtp({required String phone, required String code}) async {
    final response = await _guard(() => _client.auth.verifyOTP(phone: phone, token: code, type: sb.OtpType.sms));
    final session = response.session;
    if (session == null) throw const AuthFailure('That code did not work. Request a new one and try again.');
    _emit(_signedIn(session.user));
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
      case 'otp_expired':
      case 'invalid_credentials':
        return 'That code is wrong or has expired. Check the SMS or request a new code.';
      case 'validation_failed':
      case 'phone_not_confirmed':
        return 'Enter a valid mobile number.';
      case 'over_sms_send_rate_limit':
      case 'over_request_rate_limit':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'sms_send_failed':
        return 'We could not send the SMS. Check the number and try again.';
      case 'phone_provider_disabled':
      case 'provider_disabled':
      case 'signup_disabled':
        return 'Phone sign-in is not available yet.';
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
