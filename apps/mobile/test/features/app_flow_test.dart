import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noura/app/app.dart';
import 'package:noura/core/api/api_failure.dart';
import 'package:noura/core/auth/auth_state.dart';
import 'package:noura/core/auth/mock_auth_repository.dart';
import 'package:noura/core/config/app_config.dart';
import 'package:noura/core/profile/session_profile.dart';
import 'package:noura/features/auth/presentation/verify_otp_screen.dart';

import '../support/harness.dart';

void main() {
  testWidgets('signed-out cold start shows the welcome screen', (tester) async {
    await pumpNoura(tester, auth: RecordingAuthRepository(), profiles: FakeProfileRepository());
    expect(find.text('NOURA'), findsOneWidget);
    expect(find.text('Continue with phone number'), findsOneWidget);
    expect(find.textContaining('assword'), findsNothing, reason: 'no password anywhere (D-033)');
    expect(find.textContaining('mail'), findsNothing, reason: 'no email sign-in (D-033)');
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('phone + OTP sign-in with an unfinished profile lands on onboarding', (tester) async {
    final auth = RecordingAuthRepository();
    await pumpNoura(
      tester,
      auth: auth,
      profiles: FakeProfileRepository(onboarding: OnboardingState.notStarted),
    );

    await tester.tap(find.text('Continue with phone number'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Send code'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your mobile number.'), findsOneWidget, reason: 'client-side validation runs first');

    await tester.enterText(find.widgetWithText(TextFormField, 'Mobile number'), '12345');
    await tester.tap(find.widgetWithText(FilledButton, 'Send code'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid mobile number.'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Mobile number'), '98765 43210');
    await tester.tap(find.widgetWithText(FilledButton, 'Send code'));
    await settle(tester);
    expect(auth.calls, contains('sendOtp:+919876543210'), reason: 'a bare Indian number gets +91');
    expect(find.text('Enter the code'), findsOneWidget);
    expect(find.textContaining('+919876543210'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, '6-digit code'), '000000');
    await tester.tap(find.widgetWithText(FilledButton, 'Verify and continue'));
    await settle(tester);
    expect(find.textContaining('wrong or has expired'), findsOneWidget);
    expect(auth.current, isA<SignedOut>());

    await tester.enterText(find.widgetWithText(TextFormField, '6-digit code'), MockAuthRepository.devOtp);
    await tester.tap(find.widgetWithText(FilledButton, 'Verify and continue'));
    await settle(tester);

    expect(auth.calls, contains('verifyOtp:+919876543210:${MockAuthRepository.devOtp}'));
    expect(find.text('Set up your profile'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('a new code can be requested only after the cooldown', (tester) async {
    final auth = RecordingAuthRepository();
    await pumpNoura(tester, auth: auth, profiles: FakeProfileRepository());

    await tester.tap(find.text('Continue with phone number'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Mobile number'), '+447700900123');
    await tester.tap(find.widgetWithText(FilledButton, 'Send code'));
    await settle(tester);
    expect(auth.calls, ['sendOtp:+447700900123']);

    final resend = find.widgetWithText(TextButton, 'Resend code in ${VerifyOtpScreen.resendCooldownSeconds}s');
    expect(tester.widget<TextButton>(resend).onPressed, isNull);
    await tester.pump(const Duration(seconds: VerifyOtpScreen.resendCooldownSeconds));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Resend code'));
    await settle(tester);
    expect(auth.calls, ['sendOtp:+447700900123', 'sendOtp:+447700900123']);
    expect(find.text('We sent a new code.'), findsOneWidget);

    await tester.tap(find.text('Change number'));
    await tester.pumpAndSettle();
    expect(find.text('Your mobile number'), findsOneWidget);
  });

  testWidgets('a restored session with a completed profile opens the five-tab shell', (tester) async {
    await pumpNoura(
      tester,
      auth: RecordingAuthRepository(initial: signedIn),
      profiles: FakeProfileRepository(),
    );

    expect(find.byType(NavigationBar), findsOneWidget);
    for (final label in ['Home', 'Meals', 'Coach', 'Workout', 'Progress']) {
      expect(find.descendant(of: find.byType(NavigationBar), matching: find.text(label)), findsOneWidget);
    }
    expect(find.text('Hi, Asha'), findsOneWidget);

    await tester.tap(find.text('Coach'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.tap(find.text('Progress'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Hi, Asha'), findsOneWidget);
  });

  testWidgets('future features are labelled placeholders, not working actions', (tester) async {
    await pumpNoura(
      tester,
      auth: RecordingAuthRepository(initial: signedIn),
      profiles: FakeProfileRepository(),
    );
    expect(find.textContaining('Not available yet · M'), findsWidgets);
  });

  testWidgets('settings sign-out returns to welcome', (tester) async {
    final auth = RecordingAuthRepository(initial: signedIn);
    await pumpNoura(tester, auth: auth, profiles: FakeProfileRepository());

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('+919876543210'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Sign out'), 200);
    await tester.tap(find.text('Sign out'));
    await settle(tester);

    expect(auth.calls, contains('signOut:null'));
    expect(find.text('Continue with phone number'), findsOneWidget);
  });

  testWidgets('an expired session returns to welcome with an explanation', (tester) async {
    final auth = RecordingAuthRepository(initial: signedIn);
    await pumpNoura(tester, auth: auth, profiles: FakeProfileRepository());
    auth.emit(const SignedOut(reason: SignOutReason.sessionExpired));
    await settle(tester);
    expect(find.text('Your session ended. Verify your number again to continue.'), findsOneWidget);
    expect(find.text('Continue with phone number'), findsOneWidget);
  });

  testWidgets('a profile that cannot load shows a recoverable error with retry and sign-out', (tester) async {
    final profiles = FakeProfileRepository(
      error: const ApiFailure(kind: ApiFailureKind.offline, message: "You're offline or the server can't be reached."),
    );
    final auth = RecordingAuthRepository(initial: signedIn);
    await pumpNoura(tester, auth: auth, profiles: profiles);

    expect(find.text("You're offline"), findsOneWidget);
    expect(profiles.loads, 1, reason: 'no silent automatic retries');

    profiles.error = null;
    await tester.tap(find.text('Try again'));
    await settle(tester);
    expect(profiles.loads, 2);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('development mocks show a persistent banner', (tester) async {
    await pumpNoura(
      tester,
      auth: RecordingAuthRepository(),
      profiles: FakeProfileRepository(),
      config: testConfig(useMocks: true),
    );
    expect(find.textContaining('DEVELOPMENT MOCKS'), findsOneWidget);
  });

  testWidgets('unsafe production configuration shows the configuration error app', (tester) async {
    final issues = testConfig(environment: AppEnvironment.production, useMocks: true).validate(releaseMode: true);
    await tester.pumpWidget(ConfigErrorApp(issues: issues));
    expect(find.text('App configuration problem'), findsOneWidget);
    expect(find.textContaining('NOURA_USE_MOCKS'), findsOneWidget);
  });

  testWidgets('auth and shell screens meet tap-target and contrast guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpNoura(tester, auth: RecordingAuthRepository(), profiles: FakeProfileRepository());
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    await tester.tap(find.text('Continue with phone number'));
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });

  testWidgets('shell meets tap-target and contrast guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpNoura(
      tester,
      auth: RecordingAuthRepository(initial: signedIn),
      profiles: FakeProfileRepository(),
    );
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });
}
