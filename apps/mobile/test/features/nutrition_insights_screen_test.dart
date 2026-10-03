import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noura/core/api/api_failure.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../support/fake_recommendations_repository.dart';
import '../support/harness.dart';

Insights _insights({
  int loggedMeals = 9,
  int daysWithLogs = 5,
  int usableDays = 4,
  List<DateTime> excludedDays = const [],
  bool coverageUncertain = true,
  List<Insight> insights = const [],
  Insight? focus,
}) => Insights(
  periodStart: DateTime.utc(2026, 9, 26),
  periodEnd: DateTime.utc(2026, 10, 2),
  loggedMeals: loggedMeals,
  daysWithLogs: daysWithLogs,
  usableDays: usableDays,
  excludedDays: excludedDays,
  coverageUncertain: coverageUncertain,
  insights: insights,
  focus: focus,
);

Future<void> _open(WidgetTester tester, FakeRecommendationsRepository recommendations) async {
  await pumpNoura(
    tester,
    auth: RecordingAuthRepository(initial: signedIn),
    profiles: FakeProfileRepository(),
    recommendations: recommendations,
  );
  await tester.tap(find.text('Meals'));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(find.text('Seven-day patterns'), 200, scrollable: find.byType(Scrollable).first);
  await tester.tap(find.text('Seven-day patterns'));
  await settle(tester);
}

void main() {
  testWidgets('shows an empty state when nothing has been logged this week', (tester) async {
    final repo = FakeRecommendationsRepository(insights: _insights(loggedMeals: 0, daysWithLogs: 0, usableDays: 0));
    await _open(tester, repo);
    expect(find.text('No meals logged yet'), findsOneWidget);
  });

  testWidgets('names the excluded days and never claims a gap on incomplete coverage', (tester) async {
    final repo = FakeRecommendationsRepository(
      insights: _insights(
        usableDays: 4,
        excludedDays: [DateTime.utc(2026, 9, 28), DateTime.utc(2026, 10, 1)],
        coverageUncertain: true,
        insights: [
          Insight(
            key: 'protein_gap',
            evidence: const {'average_protein_g': 58},
            explanation: 'Average protein across 4 days with complete data is 58g, below your target.',
          ),
        ],
        focus: Insight(
          key: 'protein_gap',
          evidence: const {'average_protein_g': 58},
          explanation: 'Average protein across 4 days with complete data is 58g, below your target.',
        ),
      ),
    );
    await _open(tester, repo);
    expect(find.textContaining('4 of 7 days with complete nutrition data'), findsOneWidget);
    expect(find.textContaining('2 day(s) were excluded'), findsOneWidget);
    expect(find.text('Protein gap'), findsOneWidget);
  });

  testWidgets('a fully-uncertain week says so instead of showing a pattern', (tester) async {
    final repo = FakeRecommendationsRepository(
      insights: _insights(loggedMeals: 2, daysWithLogs: 2, usableDays: 0, coverageUncertain: true),
    );
    await _open(tester, repo);
    expect(find.textContaining("don't have enough complete data"), findsOneWidget);
    expect(find.text('No notable patterns in your logged meals this week.'), findsOneWidget);
  });

  testWidgets('shows a retryable error with the server message', (tester) async {
    final repo = FakeRecommendationsRepository(
      failure: const ApiFailure(kind: ApiFailureKind.unavailable, message: "couldn't load your patterns"),
    );
    await _open(tester, repo);
    expect(find.text("couldn't load your patterns"), findsOneWidget);
  });
}
