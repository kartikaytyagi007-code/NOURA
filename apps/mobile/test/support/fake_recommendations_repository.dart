import 'package:noura/core/api/api_failure.dart';
import 'package:noura/core/recommendations/recommendations_repository.dart';
import 'package:noura_api_client/noura_api_client.dart';

/// A fake [RecommendationsRepository] whose next-meal/insights/home behaviour the test controls
/// directly, mirroring `FakeDietRepository`'s role for diet-plan tests. Each fetch throws the
/// shared [failure] when set, regardless of which payload field a particular test cares about, so
/// a single instance can drive any of the three M6 screens.
class FakeRecommendationsRepository implements RecommendationsRepository {
  FakeRecommendationsRepository({this.nextMeal, this.insights, this.home, this.failure});

  NextMeal? nextMeal;
  Insights? insights;
  Home? home;
  ApiFailure? failure;
  final actions = <NextMealActionType>[];

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
    actions.add(action);
    return NextMealActionResult(action: action, planMeal: null, dismissed: action == NextMealActionType.dismiss);
  }

  @override
  Future<Insights> fetchInsights() async {
    final failure = this.failure;
    if (failure != null) throw failure;
    return insights!;
  }

  @override
  Future<Home> fetchHome({DateTime? date}) async {
    final failure = this.failure;
    if (failure != null) throw failure;
    return home!;
  }
}
