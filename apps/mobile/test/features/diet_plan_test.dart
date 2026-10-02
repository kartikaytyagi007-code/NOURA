import 'package:flutter_test/flutter_test.dart';
import 'package:noura/core/api/api_failure.dart';
import 'package:noura/core/diet/diet_repository.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../support/harness.dart';

Nutrients _n(num kcal) => Nutrients(energyKcal: kcal, proteinG: 10, carbohydrateG: 20, fatG: 5, fibreG: 3);
NutrientTotals _totals(num kcal) =>
    NutrientTotals(nutrients: _n(kcal), coverage: Coverage(itemsTotal: 1, itemsWithNutrition: 1, complete: true));
PortionRef _portion(String label) =>
    PortionRef(foodId: null, recipeId: null, label: label, gramsMin: 200, gramsMax: 200);

PlanMeal _meal(String id, MealSlot slot, String recipeName, DateTime date, {int revision = 1}) => PlanMeal(
  id: id,
  date: date,
  slot: slot,
  slotOrdinal: 1,
  recipe: RecipeRef(id: '$id-recipe', name: recipeName),
  portions: [_portion(recipeName)],
  nutrition: _totals(400),
  revision: revision,
);

/// A fake [DietRepository] whose behaviour the test controls directly, mirroring
/// [FakeProfileServer]'s role for profile tests.
class FakeDietRepository implements DietRepository {
  FakeDietRepository({this.initial});
  DietPlan? initial;
  DietPlan? _plan;
  bool initialized = false;
  int generateCalls = 0;
  final calls = <String>[];

  DietPlan? get plan => _plan;

  @override
  Future<DietPlan?> fetchCurrentPlan() async {
    calls.add('fetchCurrentPlan');
    if (!initialized) {
      _plan = initial;
      initialized = true;
    }
    return _plan;
  }

  @override
  Future<String> requestGeneration({
    required int profileRevision,
    required DateTime startDate,
    String? idempotencyKey,
  }) async {
    generateCalls += 1;
    final date = DateTime(startDate.year, startDate.month, startDate.day);
    _plan = DietPlan(
      id: 'plan-1',
      version: 1,
      startsOn: date,
      status: DietPlanStatusEnum.active,
      targetSnapshotId: 'snap-1',
      days: [
        PlanDay(date: date, meals: [_meal('meal-1', MealSlot.breakfast, 'Oat porridge', date)], totals: _totals(400)),
      ],
    );
    return 'job-1';
  }

  @override
  Future<SwapOptions> swapOptions({required String planMealId, required int expectedRevision}) async {
    calls.add('swapOptions:$planMealId:$expectedRevision');
    return SwapOptions(
      planMealId: planMealId,
      revision: expectedRevision,
      candidates: [
        SwapCandidate(
          candidateId: 'alt-1',
          recipe: RecipeRef(id: 'alt-1', name: 'Vegetable khichdi'),
          portions: [_portion('Vegetable khichdi')],
          nutrition: _totals(380),
          dailyTotalsPreview: _totals(380),
        ),
      ],
    );
  }

  @override
  Future<PlanMeal> replaceMeal({
    required String planMealId,
    required int expectedRevision,
    required String candidateId,
    String? idempotencyKey,
  }) async {
    calls.add('replaceMeal:$planMealId:$candidateId');
    final plan = _plan;
    if (plan == null) throw const ApiFailure(kind: ApiFailureKind.notFound, message: 'no plan');
    PlanMeal? updated;
    _plan = DietPlan(
      id: plan.id,
      version: plan.version,
      startsOn: plan.startsOn,
      status: plan.status,
      targetSnapshotId: plan.targetSnapshotId,
      days: [
        for (final day in plan.days)
          PlanDay(
            date: day.date,
            totals: day.totals,
            meals: [
              for (final m in day.meals)
                if (m.id == planMealId)
                  updated = _meal(m.id, m.slot, 'Vegetable khichdi', m.date, revision: m.revision + 1)
                else
                  m,
            ],
          ),
      ],
    );
    return updated!;
  }
}

void main() {
  testWidgets('shows an empty state and generates a plan on request', (tester) async {
    final diet = FakeDietRepository();
    await pumpNoura(
      tester,
      auth: RecordingAuthRepository(initial: signedIn),
      profiles: FakeProfileRepository(),
      diet: diet,
    );

    await tester.tap(find.text('Meals'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Diet plan'));
    await tester.pumpAndSettle();
    expect(find.text('No plan yet'), findsOneWidget);

    await tester.tap(find.text('Generate my plan'));
    await settle(tester);

    expect(diet.generateCalls, 1);
    expect(find.text('Oat porridge'), findsOneWidget);
  });

  testWidgets('shows an active plan with meals and totals', (tester) async {
    final date = DateTime(2026, 10, 5);
    final diet = FakeDietRepository(
      initial: DietPlan(
        id: 'plan-1',
        version: 1,
        startsOn: date,
        status: DietPlanStatusEnum.active,
        targetSnapshotId: 'snap-1',
        days: [
          PlanDay(date: date, meals: [_meal('meal-1', MealSlot.breakfast, 'Oat porridge', date)], totals: _totals(400)),
        ],
      ),
    );
    await pumpNoura(
      tester,
      auth: RecordingAuthRepository(initial: signedIn),
      profiles: FakeProfileRepository(),
      diet: diet,
    );

    await tester.tap(find.text('Meals'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Diet plan'));
    await tester.pumpAndSettle();

    expect(find.text('Oat porridge'), findsOneWidget);
    expect(find.textContaining('400 kcal'), findsWidgets);
  });

  testWidgets('swapping a meal shows candidates and replaces the slot on confirm', (tester) async {
    final date = DateTime(2026, 10, 5);
    final diet = FakeDietRepository(
      initial: DietPlan(
        id: 'plan-1',
        version: 1,
        startsOn: date,
        status: DietPlanStatusEnum.active,
        targetSnapshotId: 'snap-1',
        days: [
          PlanDay(date: date, meals: [_meal('meal-1', MealSlot.breakfast, 'Oat porridge', date)], totals: _totals(400)),
        ],
      ),
    );
    await pumpNoura(
      tester,
      auth: RecordingAuthRepository(initial: signedIn),
      profiles: FakeProfileRepository(),
      diet: diet,
    );

    await tester.tap(find.text('Meals'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Diet plan'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Swap'));
    await settle(tester);
    expect(find.text('Vegetable khichdi'), findsOneWidget);

    await tester.tap(find.text('Vegetable khichdi'));
    await settle(tester);

    expect(diet.calls, contains('replaceMeal:meal-1:alt-1'));
    expect(find.text('Meal swapped'), findsOneWidget);
  });
}
