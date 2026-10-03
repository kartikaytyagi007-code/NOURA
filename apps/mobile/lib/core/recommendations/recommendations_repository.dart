import 'package:dio/dio.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../api/api_failure.dart';
import '../profile/profile_repository.dart' show newIdempotencyKey;

/// "What should I eat next?" and nutrition-insights data (M6: GET /v1/recommendations/next-meal,
/// POST .../actions, GET /v1/insights, GET /v1/home). Widgets use this through the M6 controllers;
/// they never call the generated client directly (same convention as [DietRepository]).
abstract interface class RecommendationsRepository {
  Future<NextMeal> fetchNextMeal({DateTime? date, MealSlot? slot});

  Future<NextMealActionResult> performAction({
    required DateTime date,
    required MealSlot slot,
    required NextMealActionType action,
    String? candidateId,
    String? targetPlanMealId,
    int? expectedRevision,
    String? idempotencyKey,
  });

  Future<Insights> fetchInsights();

  Future<Home> fetchHome({DateTime? date});
}

class ApiRecommendationsRepository implements RecommendationsRepository {
  ApiRecommendationsRepository(this._client);
  final NouraApiClient _client;

  DietApi get _diet => _client.getDietApi();
  InsightsApi get _insights => _client.getInsightsApi();
  HomeApi get _home => _client.getHomeApi();

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<NextMeal> fetchNextMeal({DateTime? date, MealSlot? slot}) =>
      _guard(() async => (await _diet.getNextMeal(date: date, slot: slot)).data!.data);

  @override
  Future<NextMealActionResult> performAction({
    required DateTime date,
    required MealSlot slot,
    required NextMealActionType action,
    String? candidateId,
    String? targetPlanMealId,
    int? expectedRevision,
    String? idempotencyKey,
  }) => _guard(
    () async => (await _diet.nextMealAction(
      idempotencyKey: idempotencyKey ?? newIdempotencyKey(),
      nextMealActionRequest: NextMealActionRequest(
        date: date,
        slot: slot,
        action: action,
        candidateId: candidateId,
        targetPlanMealId: targetPlanMealId,
        expectedRevision: expectedRevision,
      ),
    )).data!.data,
  );

  @override
  Future<Insights> fetchInsights() => _guard(() async => (await _insights.getInsights(period: '7d')).data!.data);

  @override
  Future<Home> fetchHome({DateTime? date}) => _guard(() async => (await _home.getHome(date: date)).data!.data);
}

/// DEVELOPMENT-ONLY source used with mock auth (same convention as [MockDietRepository]). Every
/// value is clearly labelled "(mock)"; no nutrition value here is real.
class MockRecommendationsRepository implements RecommendationsRepository {
  final Set<String> _dismissed = {};

  static NutrientTotals _totals(num kcal, {bool complete = true}) => NutrientTotals(
    nutrients: Nutrients(energyKcal: kcal, proteinG: 18, carbohydrateG: 35, fatG: 10, fibreG: 6),
    coverage: Coverage(itemsTotal: 2, itemsWithNutrition: complete ? 2 : 1, complete: complete),
  );

  String _key(DateTime date, MealSlot slot) => '${date.toIso8601String().substring(0, 10)}|$slot';

  @override
  Future<NextMeal> fetchNextMeal({DateTime? date, MealSlot? slot}) async {
    final d = date ?? DateTime.now();
    final targetSlot = slot ?? MealSlot.lunch;
    if (_dismissed.contains(_key(d, targetSlot))) {
      return NextMeal(
        date: d,
        slot: targetSlot,
        loggedMeals: 1,
        limitedContext: false,
        explanation: 'You dismissed this recommendation for today. (mock)',
        options: const [],
      );
    }
    return NextMeal(
      date: d,
      slot: targetSlot,
      loggedMeals: 1,
      limitedContext: false,
      explanation: null,
      options: [
        NextMealOption(
          source_: NextMealSource.catalog,
          planMealId: null,
          planMealRevision: null,
          candidateId: 'mock-recipe-1',
          recipe: RecipeRef(id: 'mock-recipe-1', name: 'Paneer tikka bowl (mock)'),
          portions: [
            PortionRef(
              foodId: null,
              recipeId: 'mock-recipe-1',
              label: 'Paneer tikka bowl (mock)',
              gramsMin: 300,
              gramsMax: 300,
            ),
          ],
          nutrition: _totals(420),
          reason: 'High in protein, which your day is currently low on. (mock)',
        ),
        NextMealOption(
          source_: NextMealSource.catalog,
          planMealId: null,
          planMealRevision: null,
          candidateId: 'mock-recipe-2',
          recipe: RecipeRef(id: 'mock-recipe-2', name: 'Mixed vegetable rice bowl (mock)'),
          portions: [
            PortionRef(
              foodId: null,
              recipeId: 'mock-recipe-2',
              label: 'Mixed vegetable rice bowl (mock)',
              gramsMin: 300,
              gramsMax: 300,
            ),
          ],
          nutrition: _totals(380),
          reason: 'A suitable alternative. (mock)',
        ),
      ],
    );
  }

  @override
  Future<NextMealActionResult> performAction({
    required DateTime date,
    required MealSlot slot,
    required NextMealActionType action,
    String? candidateId,
    String? targetPlanMealId,
    int? expectedRevision,
    String? idempotencyKey,
  }) async {
    if (action == NextMealActionType.dismiss) {
      _dismissed.add(_key(date, slot));
      return NextMealActionResult(action: action, planMeal: null, dismissed: true);
    }
    return NextMealActionResult(
      action: action,
      planMeal: PlanMeal(
        id: targetPlanMealId ?? 'mock-new-meal',
        date: date,
        slot: slot,
        slotOrdinal: 1,
        recipe: RecipeRef(id: candidateId ?? 'mock-recipe-1', name: 'Updated meal (mock)'),
        portions: const [],
        nutrition: _totals(400),
        revision: (expectedRevision ?? 0) + 1,
      ),
      dismissed: false,
    );
  }

  @override
  Future<Insights> fetchInsights() async {
    final today = DateTime.now();
    return Insights(
      periodStart: today.subtract(const Duration(days: 6)),
      periodEnd: today,
      loggedMeals: 9,
      daysWithLogs: 5,
      usableDays: 4,
      excludedDays: [today.subtract(const Duration(days: 2)), today.subtract(const Duration(days: 5))],
      coverageUncertain: true,
      insights: [
        Insight(
          key: 'protein_gap',
          evidence: {'average_protein_g': 58, 'target_protein_g': 90},
          explanation: 'Average protein across 4 days with complete data is 58g, below your target. (mock)',
        ),
      ],
      focus: Insight(
        key: 'protein_gap',
        evidence: {'average_protein_g': 58, 'target_protein_g': 90},
        explanation: 'Average protein across 4 days with complete data is 58g, below your target. (mock)',
      ),
    );
  }

  @override
  Future<Home> fetchHome({DateTime? date}) async {
    final d = date ?? DateTime.now();
    return Home(
      date: d,
      nutrition: _totals(950, complete: false),
      nextMeal: PlanMealPreview(planMealId: 'mock-plan-meal', slot: MealSlot.lunch, title: 'Paneer tikka bowl (mock)'),
      todaysWorkout: null,
      insight: null,
      planGeneration: null,
    );
  }
}
