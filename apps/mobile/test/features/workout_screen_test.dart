import 'package:flutter_test/flutter_test.dart';
import 'package:noura/core/workouts/workout_repository.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../support/harness.dart';

PrescribedExercise _exercise(String id) => PrescribedExercise(
  id: 'pe-$id',
  exercise: ExerciseRef(id: id, name: 'Exercise $id'),
  ordinal: 1,
  sets: 2,
  repsMin: 8,
  repsMax: 12,
  restSec: 0,
  effortCue: null,
);

/// A fake [WorkoutRepository] the test controls directly, mirroring [FakeDietRepository].
class FakeWorkoutRepository implements WorkoutRepository {
  FakeWorkoutRepository({this.initial});
  WorkoutPlan? initial;
  WorkoutPlan? _plan;
  bool initialized = false;
  int generateCalls = 0;

  @override
  Future<WorkoutPlan?> fetchCurrentPlan() async {
    if (!initialized) {
      _plan = initial;
      initialized = true;
    }
    return _plan;
  }

  @override
  Future<String> requestGeneration({required int profileRevision, DateTime? startDate, String? idempotencyKey}) async {
    generateCalls += 1;
    final date = DateTime(2026, 10, 5);
    _plan = WorkoutPlan(
      id: 'plan-1',
      version: 1,
      startsOn: date,
      revision: 1,
      sessions: [
        WorkoutSession(
          id: 'session-1',
          date: date,
          order: 1,
          title: 'Full-body session',
          status: WorkoutSessionStatusEnum.scheduled,
          exercises: [_exercise('a')],
        ),
      ],
    );
    return 'job-1';
  }

  @override
  Future<Substitutions> getSubstitutions(String exerciseId) async =>
      Substitutions(exerciseId: exerciseId, candidates: const []);

  @override
  Future<WorkoutLog> startLog({required String clientId, required String sessionId, DateTime? startedAt}) async =>
      WorkoutLog(
        id: 'log-1',
        clientId: clientId,
        sessionId: sessionId,
        status: WorkoutLogStatusEnum.inProgress,
        startedAt: startedAt,
        completedAt: null,
        sets: const [],
        revision: 1,
      );

  @override
  Future<WorkoutLog> putSets({
    required String logId,
    required int expectedRevision,
    required List<SetLogInput> sets,
    String? idempotencyKey,
  }) async => WorkoutLog(
    id: logId,
    clientId: 'c',
    sessionId: 's',
    status: WorkoutLogStatusEnum.inProgress,
    startedAt: null,
    completedAt: null,
    sets: sets,
    revision: expectedRevision + 1,
  );

  @override
  Future<WorkoutLog> patchLog({
    required String logId,
    required int expectedRevision,
    required PatchWorkoutLogRequestStatusEnum status,
    DateTime? completedAt,
    String? idempotencyKey,
  }) async => WorkoutLog(
    id: logId,
    clientId: 'c',
    sessionId: 's',
    status: WorkoutLogStatusEnum.completed,
    startedAt: null,
    completedAt: completedAt ?? DateTime.now(),
    sets: const [],
    revision: expectedRevision + 1,
  );
}

void main() {
  testWidgets('shows an empty state and generates a plan on request', (tester) async {
    final workouts = FakeWorkoutRepository();
    await pumpNoura(
      tester,
      auth: RecordingAuthRepository(initial: signedIn),
      profiles: FakeProfileRepository(),
      workouts: workouts,
    );

    await tester.tap(find.text('Workout'));
    await tester.pumpAndSettle();
    expect(find.text('No workout plan yet'), findsOneWidget);

    await tester.tap(find.text('Generate my plan'));
    await settle(tester);

    expect(workouts.generateCalls, 1);
    expect(find.text('Full-body session'), findsOneWidget);
  });

  testWidgets('shows an active plan with its sessions, and opens a session on tap', (tester) async {
    final date = DateTime(2026, 10, 5);
    final workouts = FakeWorkoutRepository(
      initial: WorkoutPlan(
        id: 'plan-1',
        version: 1,
        startsOn: date,
        revision: 1,
        sessions: [
          WorkoutSession(
            id: 'session-1',
            date: date,
            order: 1,
            title: 'Full-body session',
            status: WorkoutSessionStatusEnum.scheduled,
            exercises: [_exercise('a')],
          ),
        ],
      ),
    );
    await pumpNoura(
      tester,
      auth: RecordingAuthRepository(initial: signedIn),
      profiles: FakeProfileRepository(),
      workouts: workouts,
    );

    await tester.tap(find.text('Workout'));
    await tester.pumpAndSettle();
    expect(find.text('Full-body session'), findsOneWidget);

    await tester.tap(find.text('Full-body session'));
    await tester.pumpAndSettle();
    expect(find.text('Exercise a'), findsOneWidget);
    expect(find.text('Start session'), findsOneWidget);
  });
}
