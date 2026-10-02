import 'package:flutter_test/flutter_test.dart';
import 'package:noura/core/api/api_failure.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../support/fake_recommendations_repository.dart';
import '../support/harness.dart';

Nutrients _n(num kcal) => Nutrients(energyKcal: kcal, proteinG: 10, carbohydrateG: 20, fatG: 5, fibreG: 3);
NutrientTotals _totals(num kcal, {bool complete = true}) => NutrientTotals(
  nutrients: _n(kcal),
  coverage: Coverage(itemsTotal: 1, itemsWithNutrition: complete ? 1 : 0, complete: complete),
);

NextMealOption _option({
  String candidateId = 'cand-1',
  String name = 'Khichdi bowl',
  String? planMealId,
  int? planMealRevision,
  bool complete = true,
}) => NextMealOption(
  source_: planMealId == null ? NextMealSource.catalog : NextMealSource.plan,
  planMealId: planMealId,
  planMealRevision: planMealRevision,
  candidateId: candidateId,
  recipe: RecipeRef(id: candidateId, name: name),
  portions: const [],
  nutrition: _totals(400, complete: complete),
  reason: 'Grounded in your plan and today\'s log.',
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
  await tester.tap(find.text('What should I eat next?'));
  await settle(tester);
}

void main() {
  testWidgets('shows the recommendation with its primary option and an alternative', (tester) async {
    final repo = FakeRecommendationsRepository(
      nextMeal: NextMeal(
        date: DateTime.utc(2026, 10, 2),
        slot: MealSlot.lunch,
        loggedMeals: 1,
        limitedContext: false,
        explanation: null,
        options: [
          _option(),
          _option(candidateId: 'cand-2', name: 'Paneer tikka bowl'),
        ],
      ),
    );
    await _open(tester, repo);
    expect(find.text('Khichdi bowl'), findsOneWidget);
    expect(find.text('Paneer tikka bowl'), findsOneWidget);
    expect(find.textContaining("Grounded in your plan"), findsWidgets);
  });

  testWidgets('shows a limited-context notice when today\'s log is sparse', (tester) async {
    final repo = FakeRecommendationsRepository(
      nextMeal: NextMeal(
        date: DateTime.utc(2026, 10, 2),
        slot: MealSlot.breakfast,
        loggedMeals: 0,
        limitedContext: true,
        explanation: null,
        options: [_option()],
      ),
    );
    await _open(tester, repo);
    expect(find.textContaining('limited'), findsOneWidget);
  });

  testWidgets('shows an empty state with the explanation when the recommendation was dismissed', (tester) async {
    final repo = FakeRecommendationsRepository(
      nextMeal: NextMeal(
        date: DateTime.utc(2026, 10, 2),
        slot: MealSlot.lunch,
        loggedMeals: 1,
        limitedContext: false,
        explanation: 'You dismissed this recommendation for today.',
        options: const [],
      ),
    );
    await _open(tester, repo);
    expect(find.text('You dismissed this recommendation for today.'), findsOneWidget);
  });

  testWidgets('shows a retryable error with the server message', (tester) async {
    final repo = FakeRecommendationsRepository(
      failure: const ApiFailure(kind: ApiFailureKind.unavailable, message: "couldn't load your recommendation"),
    );
    await _open(tester, repo);
    expect(find.text("couldn't load your recommendation"), findsOneWidget);

    repo.failure = null;
    repo.nextMeal = NextMeal(
      date: DateTime.utc(2026, 10, 2),
      slot: MealSlot.lunch,
      loggedMeals: 1,
      limitedContext: false,
      explanation: null,
      options: [_option()],
    );
    await tester.tap(find.text('Try again'));
    await settle(tester);
    expect(find.text('Khichdi bowl'), findsOneWidget);
  });

  testWidgets('dismissing calls the repository with the dismiss action', (tester) async {
    final repo = FakeRecommendationsRepository(
      nextMeal: NextMeal(
        date: DateTime.utc(2026, 10, 2),
        slot: MealSlot.lunch,
        loggedMeals: 1,
        limitedContext: false,
        explanation: null,
        options: [_option()],
      ),
    );
    await _open(tester, repo);
    await tester.tap(find.text('Dismiss'));
    await settle(tester);
    expect(repo.actions, [NextMealActionType.dismiss]);
  });
}
