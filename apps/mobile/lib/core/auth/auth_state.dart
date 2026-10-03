import 'package:flutter/foundation.dart';

/// Authentication status the router and UI react to.
@immutable
sealed class AuthStatus {
  const AuthStatus();
}

/// Session restoration has not finished yet.
final class AuthRestoring extends AuthStatus {
  const AuthRestoring();
}

final class SignedOut extends AuthStatus {
  const SignedOut({this.reason});

  /// Why the user was signed out, when it was not their own action (e.g. session expired).
  final SignOutReason? reason;
}

final class SignedIn extends AuthStatus {
  const SignedIn({required this.userId, required this.email});
  final String userId;
  final String? email;

  @override
  bool operator ==(Object other) => other is SignedIn && other.userId == userId && other.email == email;

  @override
  int get hashCode => Object.hash(userId, email);
}

/// The user opened a password-recovery link and must choose a new password.
final class PasswordRecovery extends AuthStatus {
  const PasswordRecovery();
}

enum SignOutReason { sessionExpired }

enum SocialProvider { google, apple }

@immutable
class SignUpResult {
  const SignUpResult({required this.needsEmailVerification});
  final bool needsEmailVerification;
}

/// A user-safe authentication failure. [message] is shown in the UI as is.
class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => 'AuthFailure($code)';
}
