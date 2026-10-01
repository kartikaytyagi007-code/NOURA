import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../support/fake_profile_server.dart';
import '../support/harness.dart';

const _tall = Size(1080, 7200);

Future<void> _pump(WidgetTester tester, FakeProfileServer server) => pumpNoura(
  tester,
  auth: RecordingAuthRepository(initial: signedIn),
  profiles: server,
  size: _tall,
);

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _openSettingsPage(WidgetTester tester, String label) async {
  await _tap(tester, find.byTooltip('Settings'));
  await _tap(tester, find.widgetWithText(ListTile, label));
}

void main() {
  testWidgets('editing the profile in Settings saves, increments the revision and shows the new value', (tester) async {
    final server = FakeProfileServer(initial: FakeProfileServer.completedMe());
    await _pump(tester, server);
    await _openSettingsPage(tester, 'Profile');

    final weight = find.widgetWithText(TextFormField, 'Weight');
    expect(tester.widget<TextFormField>(weight).controller!.text, '62', reason: 'prefilled from the server');
    await tester.enterText(weight, '64.5');
    await _tap(tester, find.widgetWithText(FilledButton, 'Save'));
    await settle(tester);

    expect(server.me.profile.weightKg, 64.5);
    expect(server.me.profile.revision, 10, reason: 'revision 9 -> 10');
    expect(server.patches.single.expectedRevision, 9);
    expect(server.patches.single.onboardingStep, isNull, reason: 'Settings edits never move the onboarding step');
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Profile and preferences'), findsOneWidget, reason: 'back on Settings');
  });

  testWidgets('a stale edit in Settings conflicts instead of overwriting', (tester) async {
    final server = FakeProfileServer(initial: FakeProfileServer.completedMe());
    await _pump(tester, server);
    await _openSettingsPage(tester, 'Profile');

    server.me = server.me.copyWith(
      profile: server.me.profile.copyWith(weightKg: 70, revision: server.me.profile.revision + 1),
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Weight'), '64.5');
    await _tap(tester, find.widgetWithText(FilledButton, 'Save'));
    await settle(tester);

    expect(find.text('This changed somewhere else'), findsOneWidget);
    expect(server.me.profile.weightKg, 70, reason: 'the other device keeps its write');
    await _tap(tester, find.widgetWithText(OutlinedButton, 'Load latest'));
    expect(tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Weight')).controller!.text, '70');
  });

  testWidgets('food and training preferences are edited with their own revisions', (tester) async {
    final server = FakeProfileServer(initial: FakeProfileServer.completedMe());
    await _pump(tester, server);

    await _openSettingsPage(tester, 'Food preferences');
    expect(tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Vegetarian')).selected, isTrue);
    await _tap(tester, find.widgetWithText(ChoiceChip, 'Vegan'));
    await _tap(tester, find.widgetWithText(FilledButton, 'Save'));
    await settle(tester);
    expect(server.me.preferences!.dietType, DietType.vegan);
    expect(server.me.preferences!.revision, 3, reason: 'preferences revision 2 -> 3');
    expect(server.me.profile.revision, 9, reason: 'the profile revision is independent');

    await _tap(tester, find.widgetWithText(ListTile, 'Training'));
    await _tap(tester, find.widgetWithText(ChoiceChip, '60 min'));
    await _tap(tester, find.widgetWithText(FilledButton, 'Save'));
    await settle(tester);
    expect(server.me.trainingPreferences!.durationMinutes, 60);
    expect(server.me.trainingPreferences!.revision, 2);
  });

  testWidgets('changing eligibility answers in Settings updates what Home offers', (tester) async {
    final server = FakeProfileServer(initial: FakeProfileServer.completedMe());
    await _pump(tester, server);
    expect(find.text('Plan requested'), findsOneWidget);

    await _openSettingsPage(tester, 'Eligibility');
    expect(find.textContaining('can change whether automated plans are available'), findsOneWidget);
    await _tap(tester, find.widgetWithText(ChoiceChip, 'Yes').first);
    await _tap(tester, find.widgetWithText(FilledButton, 'Save'));
    await settle(tester);
    expect(server.me.eligibilityStatus, EligibilityStatus.trackingOnly);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Tracking only'), findsOneWidget);
    expect(find.text('Plan requested'), findsNothing);
  });

  testWidgets('Home explains each planning state without showing nutrition numbers', (tester) async {
    for (final (planning, title) in [
      (PlanningStatus.unavailablePolicy, 'Plans are not available yet'),
      (PlanningStatus.unavailableNeedsReview, 'Plans are off for now'),
    ]) {
      final server = FakeProfileServer(initial: FakeProfileServer.completedMe(planning: planning));
      await _pump(tester, server);
      expect(find.text(title), findsOneWidget);
      expect(find.textContaining('kcal'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('Settings does not offer profile editing before onboarding is complete', (tester) async {
    await _pump(tester, FakeProfileServer());
    await _tap(tester, find.byTooltip('Settings'));
    expect(find.text('Finish setting up your profile to edit it here.'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Profile'), findsNothing);
  });

  testWidgets('imperial users see their own units when editing', (tester) async {
    final base = FakeProfileServer.completedMe();
    final server = FakeProfileServer(
      initial: base.copyWith(profile: base.profile.copyWith(unitSystem: UnitSystem.imperial)),
    );
    await _pump(tester, server);
    await _openSettingsPage(tester, 'Profile');
    expect(tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Height (feet)')).controller!.text, '5');
    expect(tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Inches')).controller!.text, '4');
    expect(tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Weight')).controller!.text, '136.7');
  });

  testWidgets('onboarding and settings forms meet tap-target and label guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    final server = FakeProfileServer();
    await pumpNoura(
      tester,
      auth: RecordingAuthRepository(initial: signedIn),
      profiles: server,
    );
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });
}
