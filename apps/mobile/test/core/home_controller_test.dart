import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noura/core/auth/auth_state.dart';
import 'package:noura/core/auth/mock_auth_repository.dart';
import 'package:noura/core/providers.dart';
import 'package:noura/core/recommendations/home_controller.dart';
import 'package:noura/core/recommendations/recommendations_repository.dart';
import 'package:noura_api_client/noura_api_client.dart';

Nutrients _n(num kcal) => Nutrients(energyKcal: kcal, proteinG: 10, carbohydrateG: 20, fatG: 5, fibreG: 3);

/// A fake [RecommendationsRepository] whose home payload the test controls directly; the other
/// members are unused by [HomeController] and throw if ever called.
class _FakeRepo implements RecommendationsRepository {
  _FakeRepo({this.home});

  Home? home;
  int calls = 0;

  @override
  Future<Home> fetchHome({DateTime? date}) async {
    calls++;
    return home!;
  }

  @override
  Future<NextMeal> fetchNextMeal({DateTime? date, MealSlot? slot}) => throw UnimplementedError();

  @override
  Future<NextMealActionResult> performAction({
    required DateTime date,
    required MealSlot slot,
    required NextMealActionType action,
    String? candidateId,
    String? targetPlanMealId,
    int? expectedRevision,
    String? idempotencyKey,
  }) => throw UnimplementedError();

  @override
  Future<Insights> fetchInsights() => throw UnimplementedError();
}

Home _home({bool complete = true}) => Home(
  date: DateTime.utc(2026, 10, 2),
  nutrition: NutrientTotals(
    nutrients: _n(900),
    coverage: Coverage(itemsTotal: 2, itemsWithNutrition: complete ? 2 : 1, complete: complete),
  ),
  nextMeal: PlanMealPreview(planMealId: 'plan-meal-1', slot: MealSlot.lunch, title: 'Khichdi bowl'),
  todaysWorkout: null,
  insight: null,
  planGeneration: null,
);

ProviderContainer _container({required RecommendationsRepository repo, AuthStatus auth = const SignedOut()}) {
  final container = ProviderContainer(
    overrides: [
      recommendationsRepositoryProvider.overrideWithValue(repo),
      authRepositoryProvider.overrideWithValue(MockAuthRepository(initial: auth)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('build returns null without a signed-in session, and never calls the repository', () async {
    final repo = _FakeRepo(home: _home());
    final container = _container(repo: repo);
    final home = await container.read(homeControllerProvider.future);
    expect(home, isNull);
    expect(repo.calls, 0);
  });

  test('build fetches home for a signed-in session', () async {
    final repo = _FakeRepo(home: _home());
    final container = _container(
      repo: repo,
      auth: const SignedIn(userId: 'user-1', email: 'a@example.com'),
    );
    final home = await container.read(homeControllerProvider.future);
    expect(home, isNotNull);
    expect(home!.nutrition.coverage.complete, isTrue);
    expect(repo.calls, 1);
  });

  test('incomplete coverage is passed through honestly, never hidden', () async {
    final repo = _FakeRepo(home: _home(complete: false));
    final container = _container(
      repo: repo,
      auth: const SignedIn(userId: 'user-1', email: 'a@example.com'),
    );
    final home = await container.read(homeControllerProvider.future);
    expect(home!.nutrition.coverage.complete, isFalse);
  });

  // Error-state behaviour (a repository failure surfacing as a retryable message) is covered at
  // the screen level in `home_screen_test.dart`, exercised through a pumped widget tree.

  test('reload re-fetches', () async {
    final repo = _FakeRepo(home: _home());
    final container = _container(
      repo: repo,
      auth: const SignedIn(userId: 'user-1', email: 'a@example.com'),
    );
    await container.read(homeControllerProvider.future);
    await container.read(homeControllerProvider.notifier).reload();
    expect(repo.calls, 2);
  });
}
