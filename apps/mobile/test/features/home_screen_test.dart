import 'package:flutter_test/flutter_test.dart';
import 'package:noura/core/api/api_failure.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../support/fake_recommendations_repository.dart';
import '../support/harness.dart';

Nutrients _n(num kcal) => Nutrients(energyKcal: kcal, proteinG: 10, carbohydrateG: 20, fatG: 5, fibreG: 3);

Home _home({bool complete = true, num kcal = 900}) => Home(
  date: DateTime.utc(2026, 10, 2),
  nutrition: NutrientTotals(
    nutrients: _n(kcal),
    coverage: Coverage(itemsTotal: 2, itemsWithNutrition: complete ? 2 : 1, complete: complete),
  ),
  nextMeal: PlanMealPreview(planMealId: 'plan-meal-1', slot: MealSlot.lunch, title: 'Khichdi bowl'),
  todaysWorkout: null,
  insight: null,
  planGeneration: null,
);

void main() {
  testWidgets('shows the next-meal preview and the nutrition summary', (tester) async {
    await pumpNoura(
      tester,
      auth: RecordingAuthRepository(initial: signedIn),
      profiles: FakeProfileRepository(),
      recommendations: FakeRecommendationsRepository(home: _home()),
    );
    await settle(tester);
    expect(find.text('Khichdi bowl'), findsOneWidget);
    expect(find.textContaining('900 kcal'), findsOneWidget);
    expect(find.textContaining('incomplete'), findsNothing);
  });

  testWidgets('shows an incomplete-coverage notice honestly instead of a clean number', (tester) async {
    await pumpNoura(
      tester,
      auth: RecordingAuthRepository(initial: signedIn),
      profiles: FakeProfileRepository(),
      recommendations: FakeRecommendationsRepository(home: _home(complete: false)),
    );
    await settle(tester);
    expect(find.textContaining('incomplete'), findsOneWidget);
  });

  testWidgets('shows a retryable error with the server message, without crashing the rest of Home', (tester) async {
    await pumpNoura(
      tester,
      auth: RecordingAuthRepository(initial: signedIn),
      profiles: FakeProfileRepository(),
      recommendations: FakeRecommendationsRepository(
        failure: const ApiFailure(kind: ApiFailureKind.unavailable, message: "couldn't load today's summary"),
      ),
    );
    await settle(tester);
    expect(find.text("Couldn't load today's summary"), findsOneWidget);
    expect(find.text('Plan requested'), findsOneWidget, reason: 'the rest of Home still renders');
  });
}
