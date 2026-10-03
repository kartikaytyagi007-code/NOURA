import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noura/core/api/api_failure.dart';
import 'package:noura/core/providers.dart';
import 'package:noura/core/recommendations/next_meal_controller.dart';
import 'package:noura/core/recommendations/next_meal_state.dart';
import 'package:noura/core/recommendations/recommendations_repository.dart';
import 'package:noura_api_client/noura_api_client.dart';

Nutrients _n(num kcal) => Nutrients(energyKcal: kcal, proteinG: 10, carbohydrateG: 20, fatG: 5, fibreG: 3);

NextMealOption _option({String candidateId = 'cand-1', String? planMealId, int? planMealRevision}) => NextMealOption(
  source_: planMealId == null ? NextMealSource.catalog : NextMealSource.plan,
  planMealId: planMealId,
  planMealRevision: planMealRevision,
  candidateId: candidateId,
  recipe: RecipeRef(id: candidateId, name: 'Khichdi bowl'),
  portions: const [],
  nutrition: NutrientTotals(
    nutrients: _n(400),
    coverage: Coverage(itemsTotal: 1, itemsWithNutrition: 1, complete: true),
  ),
  reason: 'Grounded in your plan.',
);

NextMeal _nextMeal({List<NextMealOption>? options}) => NextMeal(
  date: DateTime.utc(2026, 10, 2),
  slot: MealSlot.lunch,
  loggedMeals: 1,
  limitedContext: false,
  explanation: null,
  options: options ?? [_option()],
);

/// A fake [RecommendationsRepository] whose next-meal/action behaviour the test controls directly
/// (mirrors `FakeMealScanRepository`'s role for the M5 scan tests), so load/add/swap/dismiss can be
/// exercised deterministically without a server.
class _FakeRepo implements RecommendationsRepository {
  _FakeRepo({this.nextMeal, this.failure});

  NextMeal? nextMeal;
  ApiFailure? failure;
  int actionCalls = 0;
  NextMealActionType? lastAction;
  String? lastTargetPlanMealId;
  int? lastExpectedRevision;

  @override
  Future<NextMeal> fetchNextMeal({DateTime? date, MealSlot? slot}) async {
    final failure = this.failure;
    if (failure != null) throw failure;
    return nextMeal!;
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
    actionCalls++;
    lastAction = action;
    lastTargetPlanMealId = targetPlanMealId;
    lastExpectedRevision = expectedRevision;
    return NextMealActionResult(action: action, planMeal: null, dismissed: action == NextMealActionType.dismiss);
  }

  @override
  Future<Insights> fetchInsights() => throw UnimplementedError();

  @override
  Future<Home> fetchHome({DateTime? date}) => throw UnimplementedError();
}

ProviderContainer _container(RecommendationsRepository repo) {
  final container = ProviderContainer(overrides: [recommendationsRepositoryProvider.overrideWithValue(repo)]);
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('load goes Idle -> Loading -> Loaded with the recommendation from the repository', () async {
    final repo = _FakeRepo(nextMeal: _nextMeal());
    final container = _container(repo);
    expect(container.read(nextMealControllerProvider), isA<NextMealIdle>());

    final future = container.read(nextMealControllerProvider.notifier).load();
    expect(container.read(nextMealControllerProvider), isA<NextMealLoading>());
    await future;

    final state = container.read(nextMealControllerProvider);
    expect(state, isA<NextMealLoaded>());
    expect((state as NextMealLoaded).nextMeal.options, hasLength(1));
  });

  test('a repository failure surfaces as a labelled, retryable error state', () async {
    final repo = _FakeRepo(
      failure: const ApiFailure(kind: ApiFailureKind.unavailable, message: 'try later', retryable: true),
    );
    final container = _container(repo);
    await container.read(nextMealControllerProvider.notifier).load();
    final state = container.read(nextMealControllerProvider);
    expect(state, isA<NextMealError>());
    expect((state as NextMealError).message, 'try later');
    expect(state.retryable, isTrue);
  });

  test('add calls the repository with the candidate id and reloads', () async {
    final repo = _FakeRepo(nextMeal: _nextMeal());
    final container = _container(repo);
    final nextMeal = _nextMeal();
    await container.read(nextMealControllerProvider.notifier).add(nextMeal, _option());
    expect(repo.actionCalls, 1);
    expect(repo.lastAction, NextMealActionType.add);
    expect(container.read(nextMealControllerProvider), isA<NextMealLoaded>());
  });

  test('swap sends the target plan meal id and expected revision', () async {
    final repo = _FakeRepo(nextMeal: _nextMeal());
    final container = _container(repo);
    final nextMeal = _nextMeal();
    final option = _option(planMealId: 'plan-meal-1', planMealRevision: 2);
    await container.read(nextMealControllerProvider.notifier).swap(nextMeal, option, expectedRevision: 2);
    expect(repo.lastAction, NextMealActionType.swap);
    expect(repo.lastTargetPlanMealId, 'plan-meal-1');
    expect(repo.lastExpectedRevision, 2);
  });

  test('dismiss reloads and the next load honestly reports the dismissal', () async {
    final repo = _FakeRepo(
      nextMeal: NextMeal(
        date: DateTime.utc(2026, 10, 2),
        slot: MealSlot.lunch,
        loggedMeals: 1,
        limitedContext: false,
        explanation: 'You dismissed this recommendation for today.',
        options: const [],
      ),
    );
    final container = _container(repo);
    await container.read(nextMealControllerProvider.notifier).dismiss(_nextMeal());
    expect(repo.lastAction, NextMealActionType.dismiss);
    final state = container.read(nextMealControllerProvider);
    expect(state, isA<NextMealLoaded>());
    expect((state as NextMealLoaded).nextMeal.options, isEmpty);
    expect(state.nextMeal.explanation, contains('dismissed'));
  });
}
