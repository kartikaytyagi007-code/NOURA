import 'dart:async';

import 'auth_repository.dart';
import 'auth_state.dart';

/// DEVELOPMENT-ONLY in-memory auth. Lets designers and developers walk the app without a Supabase
/// project. It verifies nothing and is refused by [AppConfig.validate] outside development debug
/// builds. The UI shows a persistent "development mocks" banner while it is active.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository({AuthStatus initial = const SignedOut()}) : _current = initial;

  static const mockUserId = '00000000-0000-4000-8000-000000000001';

  final _controller = StreamController<AuthStatus>.broadcast();
  AuthStatus _current;

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
  Future<void> signInWithEmail({required String email, required String password}) async {
    emit(SignedIn(userId: mockUserId, email: email));
  }

  @override
  Future<SignUpResult> signUpWithEmail({required String email, required String password}) async =>
      const SignUpResult(needsEmailVerification: true);

  @override
  Future<void> resendVerificationEmail({required String email}) async {}

  @override
  Future<void> sendPasswordReset({required String email}) async {}

  @override
  Future<void> updatePassword({required String newPassword}) async {
    emit(const SignedIn(userId: mockUserId, email: 'mock@noura.invalid'));
  }

  @override
  Future<void> signInWithProvider(SocialProvider provider) async {
    emit(SignedIn(userId: mockUserId, email: '${provider.name}-mock@noura.invalid'));
  }

  @override
  Future<void> signOut({SignOutReason? reason}) async => emit(SignedOut(reason: reason));
}
