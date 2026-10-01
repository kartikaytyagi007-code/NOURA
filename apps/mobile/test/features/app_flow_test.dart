import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noura/app/app.dart';
import 'package:noura/core/api/api_failure.dart';
import 'package:noura/core/auth/auth_state.dart';
import 'package:noura/core/config/app_config.dart';
import 'package:noura/core/profile/session_profile.dart';

import '../support/harness.dart';

void main() {
  testWidgets('signed-out cold start shows the welcome screen', (tester) async {
    await pumpNoura(tester, auth: RecordingAuthRepository(), profiles: FakeProfileRepository());
    expect(find.text('NOURA'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('email sign-in with an unfinished profile lands on onboarding', (tester) async {
    final auth = RecordingAuthRepository();
    await pumpNoura(
      tester,
      auth: auth,
      profiles: FakeProfileRepository(onboarding: OnboardingState.notStarted),
    );

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your email.'), findsOneWidget, reason: 'client-side validation runs first');

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'asha@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'secret123');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await settle(tester);

    expect(auth.calls, contains('signIn:asha@example.com'));
    expect(find.text('Set up your profile'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
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
    expect(find.text('asha@example.com'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Sign out'), 200);
    await tester.tap(find.text('Sign out'));
    await settle(tester);

    expect(auth.calls, contains('signOut:null'));
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('an expired session returns to welcome with an explanation', (tester) async {
    final auth = RecordingAuthRepository(initial: signedIn);
    await pumpNoura(tester, auth: auth, profiles: FakeProfileRepository());
    auth.emit(const SignedOut(reason: SignOutReason.sessionExpired));
    await settle(tester);
    expect(find.text('Your session expired. Please sign in again.'), findsOneWidget);
  });

  testWidgets('password reset request and recovery link flow', (tester) async {
    final auth = RecordingAuthRepository();
    await pumpNoura(tester, auth: auth, profiles: FakeProfileRepository());

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'asha@example.com');
    await tester.tap(find.text('Send reset link'));
    await settle(tester);
    expect(auth.calls, contains('reset:asha@example.com'));
    expect(find.text('Check your email'), findsOneWidget);

    // The recovery deep link arrives: the user must choose a new password first.
    auth.emit(const PasswordRecovery());
    await settle(tester);
    expect(find.text('Choose a new password'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, 'New password'), 'newpass12');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirm new password'), 'newpass12');
    await tester.tap(find.text('Save password'));
    await settle(tester);
    expect(auth.calls, contains('updatePassword'));
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('a profile that cannot load shows a recoverable error with retry and sign-out', (tester) async {
    final profiles = FakeProfileRepository(
      error: const ApiFailure(kind: ApiFailureKind.offline, message: "You're offline or the server can't be reached."),
    );
    final auth = RecordingAuthRepository(initial: signedIn);
    await pumpNoura(tester, auth: auth, profiles: profiles);

    expect(find.text("You're offline"), findsOneWidget);
    expect(profiles.calls, 1, reason: 'no silent automatic retries');

    profiles.error = null;
    await tester.tap(find.text('Try again'));
    await settle(tester);
    expect(profiles.calls, 2);
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

    await tester.tap(find.text('Sign in'));
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
