import 'package:dio/dio.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../api/api_failure.dart';
import '../profile/profile_repository.dart' show newIdempotencyKey;

/// Server-owned diet plan data (M3: diet-plans and diet-plan-meals). Widgets use this through
/// [DietController]; they never call the generated client directly (same convention as
/// [ProfileRepository]).
abstract interface class DietRepository {
  /// The active 7-day plan, or null when the user has none yet (a 404 is not an error here).
  Future<DietPlan?> fetchCurrentPlan();

  /// Requests generation (first plan) or regeneration (an active plan already exists). Returns the
  /// `generation_requests` job id; the caller polls `/v1/jobs/{id}` (not implemented by this
  /// repository, which only covers the diet-plan endpoints) or simply reloads the plan later.
  Future<String> requestGeneration({required int profileRevision, required DateTime startDate, String? idempotencyKey});

  Future<SwapOptions> swapOptions({required String planMealId, required int expectedRevision});

  Future<PlanMeal> replaceMeal({
    required String planMealId,
    required int expectedRevision,
    required String candidateId,
    String? idempotencyKey,
  });
}

class ApiDietRepository implements DietRepository {
  ApiDietRepository(this._client);
  final NouraApiClient _client;

  DietApi get _api => _client.getDietApi();

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<DietPlan?> fetchCurrentPlan() => _guard(() async {
    try {
      return (await _api.getCurrentDietPlan()).data!.data;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return null;
      rethrow;
    }
  });

  @override
  Future<String> requestGeneration({
    required int profileRevision,
    required DateTime startDate,
    String? idempotencyKey,
  }) => _guard(
    () async => (await _api.generateDietPlan(
      idempotencyKey: idempotencyKey ?? newIdempotencyKey(),
      generatePlanRequest: GeneratePlanRequest(startDate: startDate, profileRevision: profileRevision),
    )).data!.data.jobId,
  );

  @override
  Future<SwapOptions> swapOptions({required String planMealId, required int expectedRevision}) => _guard(
    () async => (await _api.getSwapOptions(
      id: planMealId,
      revisionRequest: RevisionRequest(expectedRevision: expectedRevision),
    )).data!.data,
  );

  @override
  Future<PlanMeal> replaceMeal({
    required String planMealId,
    required int expectedRevision,
    required String candidateId,
    String? idempotencyKey,
  }) => _guard(
    () async => (await _api.replacePlanMeal(
      id: planMealId,
      idempotencyKey: idempotencyKey ?? newIdempotencyKey(),
      replacePlanMealRequest: ReplacePlanMealRequest(expectedRevision: expectedRevision, candidateId: candidateId),
    )).data!.data,
  );
}

/// DEVELOPMENT-ONLY diet source used with mock auth (same convention as [MockProfileRepository]).
/// It never touches real nutrition data: it keeps a small, obviously-fake in-memory plan so the
/// diet screens can be exercised without a server. It is wired only when the app config enables
/// mocks, which production configuration refuses.
class MockDietRepository implements DietRepository {
  DietPlan? _plan;
  int _version = 0;

  static Nutrients _n(num kcal) => Nutrients(energyKcal: kcal, proteinG: 20, carbohydrateG: 40, fatG: 15, fibreG: 6);
  static NutrientTotals _totals(num kcal) =>
      NutrientTotals(nutrients: _n(kcal), coverage: Coverage(itemsTotal: 2, itemsWithNutrition: 2, complete: true));
  static PortionRef _portion(String label) =>
      PortionRef(foodId: null, recipeId: null, label: label, gramsMin: 300, gramsMax: 300);

  DietPlan _buildPlan(DateTime startsOn) {
    _version += 1;
    final names = ['Oat porridge (mock)', 'Rice & lentil bowl (mock)', 'Vegetable stir fry (mock)'];
    final days = List.generate(7, (d) {
      final date = startsOn.add(Duration(days: d));
      final meals = List.generate(
        3,
        (i) => PlanMeal(
          id: 'mock-meal-$d-$i',
          date: date,
          slot: MealSlot.values[i],
          slotOrdinal: 1,
          recipe: RecipeRef(id: 'mock-recipe-$i', name: names[i]),
          portions: [_portion(names[i])],
          nutrition: _totals(400 + i * 50),
          revision: 1,
        ),
      );
      return PlanDay(
        date: date,
        meals: meals,
        totals: _totals(meals.fold<num>(0, (s, m) => s + (m.nutrition.nutrients.energyKcal ?? 0))),
      );
    });
    return DietPlan(
      id: 'mock-plan',
      version: _version,
      startsOn: startsOn,
      status: DietPlanStatusEnum.active,
      targetSnapshotId: 'mock-snapshot',
      days: days,
    );
  }

  @override
  Future<DietPlan?> fetchCurrentPlan() async => _plan;

  @override
  Future<String> requestGeneration({
    required int profileRevision,
    required DateTime startDate,
    String? idempotencyKey,
  }) async {
    _plan = _buildPlan(DateTime(startDate.year, startDate.month, startDate.day));
    return 'mock-job-$_version';
  }

  @override
  Future<SwapOptions> swapOptions({required String planMealId, required int expectedRevision}) async {
    return SwapOptions(
      planMealId: planMealId,
      revision: expectedRevision,
      candidates: [
        SwapCandidate(
          candidateId: 'mock-alt-recipe',
          recipe: RecipeRef(id: 'mock-alt-recipe', name: 'Alternative bowl (mock)'),
          portions: [_portion('Alternative bowl (mock)')],
          nutrition: _totals(420),
          dailyTotalsPreview: _totals(1200),
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
    final plan = _plan;
    if (plan == null) {
      throw const ApiFailure(kind: ApiFailureKind.notFound, message: 'No plan to update.');
    }
    PlanMeal? updated;
    final days = [
      for (final day in plan.days)
        PlanDay(
          date: day.date,
          totals: day.totals,
          meals: [
            for (final meal in day.meals)
              if (meal.id == planMealId)
                updated = PlanMeal(
                  id: meal.id,
                  date: meal.date,
                  slot: meal.slot,
                  slotOrdinal: meal.slotOrdinal,
                  recipe: RecipeRef(id: candidateId, name: 'Swapped meal (mock)'),
                  portions: meal.portions,
                  nutrition: meal.nutrition,
                  revision: meal.revision + 1,
                )
              else
                meal,
          ],
        ),
    ];
    _plan = DietPlan(
      id: plan.id,
      version: plan.version,
      startsOn: plan.startsOn,
      status: plan.status,
      targetSnapshotId: plan.targetSnapshotId,
      days: days,
    );
    if (updated == null) {
      throw const ApiFailure(kind: ApiFailureKind.notFound, message: 'Plan meal not found.');
    }
    return updated;
  }
}
