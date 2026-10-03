import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../support/fake_profile_server.dart';
import '../support/harness.dart';

/// A tall surface so every field of the longest form is built without scrolling.
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

Future<void> _chip(WidgetTester tester, String label, {int index = 0}) =>
    _tap(tester, find.widgetWithText(ChoiceChip, label).at(index));

Future<void> _filter(WidgetTester tester, String label) => _tap(tester, find.widgetWithText(FilterChip, label));

Future<void> _field(WidgetTester tester, String label, String text) async {
  await tester.enterText(find.widgetWithText(TextFormField, label), text);
}

Future<void> _continue(WidgetTester tester, [String label = 'Continue']) async {
  await _tap(tester, find.widgetWithText(FilledButton, label));
  await settle(tester);
}

Future<void> _fillBasics(WidgetTester tester) async {
  await _field(tester, 'First name or nickname', 'Asha');
  await _field(tester, 'Age', '30');
  await _chip(tester, 'Female');
  await _field(tester, 'Height', '162.5');
  await _field(tester, 'Weight', '62');
  await _chip(tester, 'Moderately active');
}

Future<void> _fillGoal(WidgetTester tester) async {
  await _chip(tester, 'Lose fat');
  await _field(tester, 'Target weight (optional)', '58');
}

Future<void> _fillDiet(WidgetTester tester) async {
  await _chip(tester, 'Vegetarian');
  await _filter(tester, 'Peanut');
  await _chip(tester, 'Medium');
  await _chip(tester, 'Moderate');
  await _chip(tester, '4');
}

Future<void> _fillTraining(WidgetTester tester) async {
  await _chip(tester, 'Beginner');
  await _chip(tester, 'At home');
  await _filter(tester, 'Bodyweight only');
  for (final day in ['Mon', 'Wed', 'Fri']) {
    await _filter(tester, day);
  }
  await _chip(tester, '3');
  await _chip(tester, '45 min');
}

Future<void> _answerScreening(WidgetTester tester, {int yesIndex = -1}) async {
  for (var i = 0; i < 3; i++) {
    await _chip(tester, i == yesIndex ? 'Yes' : 'No', index: i == yesIndex ? 0 : i);
  }
}

Future<void> _acceptConsents(WidgetTester tester) async {
  for (final box in find.byType(CheckboxListTile).evaluate().toList()) {
    await _tap(tester, find.byWidget(box.widget));
  }
}

void main() {
  testWidgets('a new user completes all six steps and lands on Home with the plan requested', (tester) async {
    final server = FakeProfileServer();
    await _pump(tester, server);

    expect(find.text('Step 1 of 6'), findsOneWidget);
    expect(find.text('About you'), findsOneWidget);

    // Client-side validation runs first and nothing is sent.
    await _continue(tester);
    expect(find.text('Enter a name.'), findsOneWidget);
    expect(find.text('Enter your age in whole years.'), findsOneWidget);
    expect(find.text('Enter your height in cm.'), findsOneWidget);
    expect(find.text('Enter your weight in kg.'), findsOneWidget);
    expect(server.calls.where((c) => c == 'patchProfile'), isEmpty);

    await _fillBasics(tester);
    await _continue(tester);
    expect(find.text('Step 2 of 6'), findsOneWidget);
    final basics = server.patches.single;
    expect(basics.expectedRevision, 1);
    expect(basics.displayName, 'Asha');
    expect(basics.ageYears, 30);
    expect(basics.calculationSex, CalculationSexInput.female);
    expect(basics.heightCm, 162.5);
    expect(basics.weightKg, 62);
    expect(basics.activityBand, ActivityBand.moderate);
    expect(basics.unitSystem, UnitSystem.metric);
    expect(basics.onboardingStep, OnboardingStep.goals);

    await _fillGoal(tester);
    await _continue(tester);
    expect(find.text('Step 3 of 6'), findsOneWidget);
    expect(server.me.goal!.targetWeightKg, 58);

    await _fillDiet(tester);
    await _continue(tester);
    expect(find.text('Step 4 of 6'), findsOneWidget);
    expect(server.me.preferences!.revision, 1);
    expect(server.me.preferences!.allergyIds, ['peanut']);
    expect(server.me.onboarding.step, OnboardingStep.training);

    await _fillTraining(tester);
    await _continue(tester);
    expect(find.text('Step 5 of 6'), findsOneWidget);
    expect(server.me.trainingPreferences!.weekdays, {1, 3, 5});
    expect(server.me.onboarding.step, OnboardingStep.eligibility);

    await _answerScreening(tester);
    await _continue(tester);
    expect(find.text('Step 6 of 6'), findsOneWidget);
    expect(find.text('Review and finish'), findsOneWidget);
    expect(find.text('162.5 cm'), findsOneWidget);
    expect(find.text('62 kg'), findsOneWidget);
    expect(find.text('Tracking only'), findsNothing);

    // Consent is required, and nothing is sent without it.
    await _continue(tester, 'Finish setup');
    expect(find.text('Please accept all three to continue.'), findsOneWidget);
    expect(server.completions, isEmpty);

    await _acceptConsents(tester);
    await _continue(tester, 'Finish setup');

    expect(server.completions, hasLength(1));
    expect(server.completions.single.consents.map((c) => c.consentType).toSet(), {
      ConsentType.terms,
      ConsentType.privacy,
      ConsentType.healthDataProcessing,
    });
    expect(server.completions.single.consents.every((c) => c.version == 'v0-draft'), isTrue);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Plan requested'), findsOneWidget);
  });

  testWidgets('onboarding resumes at the saved step after an app restart, with saved answers', (tester) async {
    final server = FakeProfileServer();
    await _pump(tester, server);
    await _fillBasics(tester);
    await _continue(tester);
    await _fillGoal(tester);
    await _continue(tester);
    expect(find.text('Step 3 of 6'), findsOneWidget);

    // "Restart": a brand new widget tree and providers, talking to the same server state.
    await tester.pumpWidget(const SizedBox());
    await _pump(tester, server);
    expect(find.text('Step 3 of 6'), findsOneWidget);
    expect(find.text('Food preferences'), findsOneWidget);

    // Earlier steps still hold what was saved.
    await _tap(tester, find.widgetWithText(TextButton, 'Back'));
    expect(find.text('Your goal'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Target weight (optional)')).controller!.text,
      '58',
    );
    expect(tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Lose fat')).selected, isTrue);

    // Saving an earlier step again must not move the stored step backwards, even two steps back.
    await _tap(tester, find.widgetWithText(TextButton, 'Back'));
    expect(find.text('About you'), findsOneWidget);
    await _continue(tester);
    expect(find.text('Your goal'), findsOneWidget);
    expect(server.patches.last.onboardingStep, OnboardingStep.diet);
    expect(server.me.onboarding.step, OnboardingStep.diet);
  });

  testWidgets('a fresh sign-in on another device resumes from the server state', (tester) async {
    final server = FakeProfileServer();
    final seed = server.me;
    server.me = seed.copyWith(
      profile: seed.profile.copyWith(
        displayName: 'Asha',
        ageYears: 30,
        calculationSex: CalculationSex.female,
        heightCm: 162.5,
        weightKg: 62,
        activityBand: ActivityBand.moderate,
        revision: 4,
      ),
      goal: Goal(goalType: GoalType.maintain, targetWeightKg: null),
      onboarding: Onboarding(status: OnboardingStatus.inProgress, step: OnboardingStep.training),
    );
    await _pump(tester, server);
    expect(find.text('Step 4 of 6'), findsOneWidget);
    expect(find.text('Training'), findsWidgets);
  });

  testWidgets('a revision conflict explains itself and recovers with the latest data', (tester) async {
    final server = FakeProfileServer();
    await _pump(tester, server);
    await _fillBasics(tester);

    // Another device saved first.
    server.me = server.me.copyWith(
      profile: server.me.profile.copyWith(displayName: 'Asha R', revision: server.me.profile.revision + 1),
    );
    await _continue(tester);
    expect(find.text('This changed somewhere else'), findsOneWidget);
    expect(find.text('Step 1 of 6'), findsOneWidget);
    expect(server.patches, isEmpty);

    await _tap(tester, find.widgetWithText(OutlinedButton, 'Load latest'));
    expect(find.text('This changed somewhere else'), findsNothing);
    expect(
      tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'First name or nickname')).controller!.text,
      'Asha R',
    );

    await _fillBasics(tester);
    await _continue(tester);
    expect(find.text('Step 2 of 6'), findsOneWidget);
    expect(server.patches.single.expectedRevision, 2);
  });

  testWidgets('offline keeps the inputs on screen and retries cleanly', (tester) async {
    final server = FakeProfileServer()..offline = true;
    await _pump(tester, server);
    await _fillBasics(tester);
    await _continue(tester);

    expect(find.text("You're offline"), findsOneWidget);
    expect(find.text('Step 1 of 6'), findsOneWidget);
    expect(tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Age')).controller!.text, '30');

    server.offline = false;
    await _continue(tester);
    expect(find.text('Step 2 of 6'), findsOneWidget);
    expect(find.text("You're offline"), findsNothing);
  });

  testWidgets('validates ranges in the unit the user typed, and sends metric values', (tester) async {
    final server = FakeProfileServer();
    await _pump(tester, server);

    await _field(tester, 'First name or nickname', 'Asha');
    await _field(tester, 'Age', 'abc');
    await _field(tester, 'Height', '10');
    await _field(tester, 'Weight', '5000');
    await _continue(tester);
    expect(find.text('Enter your age in whole years.'), findsOneWidget);
    expect(find.text('Enter a height between 50 cm and 272 cm.'), findsOneWidget);
    expect(find.text('Enter a weight between 20 kg and 400 kg.'), findsOneWidget);

    await _tap(tester, find.text('lb · ft'));
    expect(find.text('Height (feet)'), findsOneWidget);
    await _field(tester, 'Age', '30');
    await _field(tester, 'Height (feet)', '5');
    await _field(tester, 'Inches', '4');
    await _field(tester, 'Weight', '10');
    await _continue(tester);
    expect(find.textContaining('Enter a weight between 44'), findsOneWidget);

    await _field(tester, 'Weight', '140');
    await _chip(tester, 'Prefer not to say');
    await _chip(tester, 'Lightly active');
    await _continue(tester);

    final sent = server.patches.single;
    expect(sent.unitSystem, UnitSystem.imperial);
    expect(sent.heightCm, 162.6);
    expect(sent.weightKg, 63.5);
    expect(sent.calculationSex, CalculationSexInput.declined);
    expect(find.text('Step 2 of 6'), findsOneWidget);
  });

  testWidgets('training needs enough days and equipment before anything is sent', (tester) async {
    final server = FakeProfileServer();
    await _pump(tester, server);
    await _fillBasics(tester);
    await _continue(tester);
    await _fillGoal(tester);
    await _continue(tester);
    await _fillDiet(tester);
    await _continue(tester);

    await _chip(tester, 'Beginner');
    await _chip(tester, 'At home');
    await _filter(tester, 'Mon');
    await _chip(tester, '3');
    await _chip(tester, '45 min');
    await _continue(tester);
    expect(find.textContaining('Choose your equipment'), findsOneWidget);
    expect(find.text('Choose at least 3 days to train 3 days a week.'), findsOneWidget);
    expect(server.calls.where((c) => c == 'saveTraining'), isEmpty);
  });

  testWidgets('a tracking-only outcome is explained and never shows a plan', (tester) async {
    final server = FakeProfileServer();
    await _pump(tester, server);
    await _fillBasics(tester);
    await _continue(tester);
    await _fillGoal(tester);
    await _continue(tester);
    await _fillDiet(tester);
    await _continue(tester);
    await _fillTraining(tester);
    await _continue(tester);
    await _answerScreening(tester, yesIndex: 0);
    await _continue(tester);

    expect(find.text('Tracking only'), findsOneWidget);
    expect(find.textContaining('will not create automated meal or workout plans'), findsOneWidget);

    await _acceptConsents(tester);
    await _continue(tester, 'Finish setup');
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Tracking only'), findsOneWidget);
    expect(find.text('Plan requested'), findsNothing);
    expect(server.me.planning!.jobId, isNull);
  });

  testWidgets('a declined screening answer needs review and says why', (tester) async {
    final server = FakeProfileServer();
    await _pump(tester, server);
    await _fillBasics(tester);
    await _continue(tester);
    await _fillGoal(tester);
    await _continue(tester);
    await _fillDiet(tester);
    await _continue(tester);
    await _fillTraining(tester);
    await _continue(tester);
    await _chip(tester, 'No', index: 0);
    await _chip(tester, 'Prefer not to say', index: 1);
    await _chip(tester, 'No', index: 2);
    await _continue(tester);
    expect(find.text('Plans are off for now'), findsOneWidget);
  });

  testWidgets('Finish setup retries safely: the same request keeps its idempotency key', (tester) async {
    final server = FakeProfileServer();
    await _pump(tester, server);
    await _fillBasics(tester);
    await _continue(tester);
    await _fillGoal(tester);
    await _continue(tester);
    await _fillDiet(tester);
    await _continue(tester);
    await _fillTraining(tester);
    await _continue(tester);
    await _answerScreening(tester);
    await _continue(tester);
    await _acceptConsents(tester);

    server.offline = true;
    await _continue(tester, 'Finish setup');
    expect(find.text("You're offline"), findsOneWidget);
    server.offline = false;
    await _continue(tester, 'Finish setup');
    expect(server.completions, hasLength(1));
    expect(server.completionAttemptKeys, hasLength(2));
    expect(server.completionAttemptKeys[0], isNotNull);
    expect(server.completionAttemptKeys[1], server.completionAttemptKeys[0], reason: 'a retry reuses its key');
  });
}
