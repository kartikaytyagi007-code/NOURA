import 'dart:async';

import 'auth_repository.dart';
import 'auth_state.dart';

/// DEVELOPMENT-ONLY in-memory auth. Lets designers and developers walk the app without a Supabase
/// project or an SMS provider. It sends no SMS and accepts only [devOtp], and it is refused by
/// [AppConfig.validate] outside development debug builds. The UI shows a persistent
/// "development mocks" banner while it is active.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository({AuthStatus initial = const SignedOut()}) : _current = initial;

  static const mockUserId = '00000000-0000-4000-8000-000000000001';

  /// The only code the mock accepts. Never valid against a real Supabase project.
  static const devOtp = '123456';

  final _controller = StreamController<AuthStatus>.broadcast();
  AuthStatus _current;
  String? _pendingPhone;

  @override
  AuthStatus get current => _current;

  @override
  Stream<AuthStatus> get changes => _controller.stream;

  void emit(AuthStatus status) {
    _current = status;
    _controller.add(status);
  }

  @override
  Future<String?> accessToken() async => _current is SignedIn ? 'mock-token' : null;

  @override
  Future<bool> refreshSession() async => _current is SignedIn;

  @override
  Future<void> sendPhoneOtp({required String phone}) async => _pendingPhone = phone;

  @override
  Future<void> verifyPhoneOtp({required String phone, required String code}) async {
    if (phone != _pendingPhone || code != devOtp) {
      throw const AuthFailure('That code is wrong or has expired. Check the SMS or request a new code.');
    }
    _pendingPhone = null;
    emit(SignedIn(userId: mockUserId, phone: phone));
  }

  @override
  Future<void> signOut({SignOutReason? reason}) async => emit(SignedOut(reason: reason));
}
