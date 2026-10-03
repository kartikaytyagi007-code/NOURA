import 'package:flutter_test/flutter_test.dart';
import 'package:noura/core/auth/auth_state.dart';
import 'package:noura/core/auth/mock_auth_repository.dart';
import 'package:noura/core/auth/supabase_auth_repository.dart';
import 'package:noura/features/auth/domain/validators.dart';

void main() {
  group('AuthValidators.normalizePhone', () {
    test('adds +91 to a bare Indian mobile number and strips formatting', () {
      expect(AuthValidators.normalizePhone('9876543210'), '+919876543210');
      expect(AuthValidators.normalizePhone(' 98765-43210 '), '+919876543210');
      expect(AuthValidators.normalizePhone('09876543210'), '+919876543210');
      expect(AuthValidators.normalizePhone('+91 98765 43210'), '+919876543210');
      expect(AuthValidators.normalizePhone('0091 9876543210'), '+919876543210');
    });

    test('accepts international numbers in E.164 form', () {
      expect(AuthValidators.normalizePhone('+44 7700 900123'), '+447700900123');
      expect(AuthValidators.normalizePhone('+1 (415) 555-0100'), '+14155550100');
    });

    test('rejects numbers that cannot be a mobile number', () {
      for (final bad in ['', '12345', '5876543210', '+91 12345 67890', '+0123456789', 'abc', '+9198765432101']) {
        expect(AuthValidators.normalizePhone(bad), isNull, reason: bad);
      }
    });

    test('code must be exactly six digits', () {
      expect(AuthValidators.otp('123456'), isNull);
      expect(AuthValidators.otp(''), 'Enter the 6-digit code.');
      expect(AuthValidators.otp('12345'), 'The code has 6 digits.');
      expect(AuthValidators.otp('12a456'), 'The code has 6 digits.');
    });
  });

  group('MockAuthRepository', () {
    test('signs in only with the code for the number it was sent to', () async {
      final auth = MockAuthRepository();
      await expectLater(
        auth.verifyPhoneOtp(phone: '+919876543210', code: MockAuthRepository.devOtp),
        throwsA(isA<AuthFailure>()),
        reason: 'no code was requested yet',
      );
      await auth.sendPhoneOtp(phone: '+919876543210');
      await expectLater(auth.verifyPhoneOtp(phone: '+919876543210', code: '654321'), throwsA(isA<AuthFailure>()));
      await expectLater(
        auth.verifyPhoneOtp(phone: '+919999999999', code: MockAuthRepository.devOtp),
        throwsA(isA<AuthFailure>()),
      );
      await auth.verifyPhoneOtp(phone: '+919876543210', code: MockAuthRepository.devOtp);
      expect(auth.current, const SignedIn(userId: MockAuthRepository.mockUserId, phone: '+919876543210'));
    });
  });

  group('SupabaseAuthRepository', () {
    test('shows phone numbers in E.164 form', () {
      expect(SupabaseAuthRepository.e164('919876543210'), '+919876543210');
      expect(SupabaseAuthRepository.e164('+919876543210'), '+919876543210');
      expect(SupabaseAuthRepository.e164(''), isNull);
      expect(SupabaseAuthRepository.e164(null), isNull);
    });

    test('maps OTP errors to user-safe messages', () {
      expect(SupabaseAuthRepository.messageFor('otp_expired', '403'), contains('wrong or has expired'));
      expect(SupabaseAuthRepository.messageFor('over_sms_send_rate_limit', '429'), contains('Too many attempts'));
      expect(SupabaseAuthRepository.messageFor('sms_send_failed', '500'), contains('could not send the SMS'));
      expect(SupabaseAuthRepository.messageFor('phone_provider_disabled', '422'), contains('not available yet'));
      expect(SupabaseAuthRepository.messageFor(null, '503'), contains('could not reach'));
    });
  });
}
