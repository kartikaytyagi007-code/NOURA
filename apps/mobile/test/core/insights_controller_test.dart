import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noura/core/providers.dart';
import 'package:noura/core/recommendations/insights_controller.dart';
import 'package:noura/core/recommendations/recommendations_repository.dart';
import 'package:noura_api_client/noura_api_client.dart';

/// A fake [RecommendationsRepository] whose insights behaviour the test controls directly; the
/// other members are unused by [InsightsController] and throw if ever called.
class _FakeRepo implements RecommendationsRepository {
  _FakeRepo({this.insights});

  Insights? insights;

  @override
  Future<Insights> fetchInsights() async => insights!;

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
  Future<Home> fetchHome({DateTime? date}) => throw UnimplementedError();
}

Insights _insights({int usableDays = 4, List<DateTime> excludedDays = const [], bool coverageUncertain = true}) =>
    Insights(
      periodStart: DateTime.utc(2026, 9, 26),
      periodEnd: DateTime.utc(2026, 10, 2),
      loggedMeals: 9,
      daysWithLogs: 5,
      usableDays: usableDays,
      excludedDays: excludedDays,
      coverageUncertain: coverageUncertain,
      insights: const [],
      focus: null,
    );

ProviderContainer _container(RecommendationsRepository repo) {
  final container = ProviderContainer(overrides: [recommendationsRepositoryProvider.overrideWithValue(repo)]);
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('build loads insights from the repository', () async {
    final repo = _FakeRepo(insights: _insights());
    final container = _container(repo);
    final insights = await container.read(insightsControllerProvider.future);
    expect(insights.usableDays, 4);
    expect(container.read(insightsControllerProvider).value, isNotNull);
  });

  test('a zero-usable-days week is still delivered, not hidden as an error', () async {
    final repo = _FakeRepo(insights: _insights(usableDays: 0, excludedDays: [DateTime.utc(2026, 10, 1)]));
    final container = _container(repo);
    final insights = await container.read(insightsControllerProvider.future);
    expect(insights.usableDays, 0);
    expect(insights.coverageUncertain, isTrue);
    expect(insights.excludedDays, hasLength(1));
  });

  // Error-state behaviour (a repository failure surfacing as a labelled, retryable message) is
  // covered at the screen level in `nutrition_insights_screen_test.dart`, exercised through a
  // pumped widget tree rather than reading an AsyncNotifier's `.future` directly from a bare
  // ProviderContainer.

  test("reload re-fetches with the repository's latest data", () async {
    final repo = _FakeRepo(insights: _insights(usableDays: 4));
    final container = _container(repo);
    await container.read(insightsControllerProvider.future);

    repo.insights = _insights(usableDays: 7, coverageUncertain: false);
    await container.read(insightsControllerProvider.notifier).reload();
    final state = container.read(insightsControllerProvider);
    expect(state.value?.usableDays, 7);
  });
}
