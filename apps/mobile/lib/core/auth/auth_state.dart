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
  const SignedIn({required this.userId, required this.phone});
  final String userId;

  /// The verified phone number in E.164 form, when the auth provider returns it.
  final String? phone;

  @override
  bool operator ==(Object other) => other is SignedIn && other.userId == userId && other.phone == phone;

  @override
  int get hashCode => Object.hash(userId, phone);
}

enum SignOutReason { sessionExpired }

/// A user-safe authentication failure. [message] is shown in the UI as is.
class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => 'AuthFailure($code)';
}
