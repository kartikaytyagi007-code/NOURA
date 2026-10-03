import 'package:dio/dio.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../api/api_failure.dart';
import '../profile/profile_repository.dart' show newIdempotencyKey;

/// Server-owned workout data (M7: workout plans, sessions, exercises, substitutions and logging).
/// Widgets use this through [WorkoutController]/[ActiveSessionController]; they never call the
/// generated client directly (same convention as [DietRepository]).
abstract interface class WorkoutRepository {
  /// The active weekly plan, or null when the user has none yet (a 404 is not an error here).
  Future<WorkoutPlan?> fetchCurrentPlan();

  /// Requests generation (first plan) or regeneration. Returns the `generation_requests` job id.
  Future<String> requestGeneration({required int profileRevision, DateTime? startDate, String? idempotencyKey});

  Future<Substitutions> getSubstitutions(String exerciseId);

  /// Starts (or replays, by [clientId]) a workout log for a session.
  Future<WorkoutLog> startLog({required String clientId, required String sessionId, DateTime? startedAt});

  Future<WorkoutLog> putSets({
    required String logId,
    required int expectedRevision,
    required List<SetLogInput> sets,
    String? idempotencyKey,
  });

  Future<WorkoutLog> patchLog({
    required String logId,
    required int expectedRevision,
    required PatchWorkoutLogRequestStatusEnum status,
    DateTime? completedAt,
    String? idempotencyKey,
  });
}

class ApiWorkoutRepository implements WorkoutRepository {
  ApiWorkoutRepository(this._client);
  final NouraApiClient _client;

  WorkoutsApi get _api => _client.getWorkoutsApi();

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<WorkoutPlan?> fetchCurrentPlan() => _guard(() async {
    try {
      return (await _api.getCurrentWorkoutPlan()).data!.data;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return null;
      rethrow;
    }
  });

  @override
  Future<String> requestGeneration({required int profileRevision, DateTime? startDate, String? idempotencyKey}) =>
      _guard(
        () async => (await _api.generateWorkoutPlan(
          idempotencyKey: idempotencyKey ?? newIdempotencyKey(),
          generatePlanRequest: GeneratePlanRequest(
            startDate: startDate ?? DateTime.now(),
            profileRevision: profileRevision,
          ),
        )).data!.data.jobId,
      );

  @override
  Future<Substitutions> getSubstitutions(String exerciseId) =>
      _guard(() async => (await _api.getExerciseSubstitutions(id: exerciseId)).data!.data);

  @override
  Future<WorkoutLog> startLog({required String clientId, required String sessionId, DateTime? startedAt}) => _guard(
    () async => (await _api.createWorkoutLog(
      idempotencyKey: newIdempotencyKey(),
      createWorkoutLogRequest: CreateWorkoutLogRequest(clientId: clientId, sessionId: sessionId, startedAt: startedAt),
    )).data!.data,
  );

  @override
  Future<WorkoutLog> putSets({
    required String logId,
    required int expectedRevision,
    required List<SetLogInput> sets,
    String? idempotencyKey,
  }) => _guard(
    () async => (await _api.putWorkoutSets(
      id: logId,
      idempotencyKey: idempotencyKey ?? newIdempotencyKey(),
      putWorkoutSetsRequest: PutWorkoutSetsRequest(expectedRevision: expectedRevision, sets: sets),
    )).data!.data,
  );

  @override
  Future<WorkoutLog> patchLog({
    required String logId,
    required int expectedRevision,
    required PatchWorkoutLogRequestStatusEnum status,
    DateTime? completedAt,
    String? idempotencyKey,
  }) => _guard(
    () async => (await _api.patchWorkoutLog(
      id: logId,
      idempotencyKey: idempotencyKey ?? newIdempotencyKey(),
      patchWorkoutLogRequest: PatchWorkoutLogRequest(
        expectedRevision: expectedRevision,
        status: status,
        completedAt: completedAt,
      ),
    )).data!.data,
  );
}

/// DEVELOPMENT-ONLY workout source used with mock auth (same convention as [MockDietRepository]).
/// It never invents a real exercise-science claim: it keeps a small, obviously-fake in-memory plan
/// built only from clearly `(mock)`-labelled names, wired only when the app config enables mocks.
class MockWorkoutRepository implements WorkoutRepository {
  WorkoutPlan? _plan;
  int _version = 0;
  final Map<String, WorkoutLog> _logs = {};

  static final _squat = ExerciseRef(id: 'mock-ex-squat', name: 'Bodyweight squat (mock)');
  static final _pushUp = ExerciseRef(id: 'mock-ex-pushup', name: 'Push-up (mock)');
  static final _row = ExerciseRef(id: 'mock-ex-row', name: 'Dumbbell row (mock)');
  static final _plank = ExerciseRef(id: 'mock-ex-plank', name: 'Plank (mock)');

  PrescribedExercise _exercise(String id, ExerciseRef ref, int ordinal) => PrescribedExercise(
    id: id,
    exercise: ref,
    ordinal: ordinal,
    sets: 3,
    repsMin: 8,
    repsMax: 12,
    restSec: 60,
    effortCue: 'Controlled tempo (mock).',
  );

  WorkoutPlan _buildPlan(DateTime startsOn) {
    _version += 1;
    final sessions = List.generate(3, (i) {
      final date = startsOn.add(Duration(days: i * 2));
      return WorkoutSession(
        id: 'mock-session-$i',
        date: date,
        order: i + 1,
        title: 'Full-body session (mock)',
        status: WorkoutSessionStatusEnum.scheduled,
        exercises: [
          _exercise('mock-pe-$i-0', _squat, 1),
          _exercise('mock-pe-$i-1', _pushUp, 2),
          _exercise('mock-pe-$i-2', _row, 3),
          _exercise('mock-pe-$i-3', _plank, 4),
        ],
      );
    });
    return WorkoutPlan(id: 'mock-plan', version: _version, startsOn: startsOn, revision: 1, sessions: sessions);
  }

  @override
  Future<WorkoutPlan?> fetchCurrentPlan() async => _plan;

  @override
  Future<String> requestGeneration({required int profileRevision, DateTime? startDate, String? idempotencyKey}) async {
    final start = startDate ?? DateTime.now();
    _plan = _buildPlan(DateTime(start.year, start.month, start.day));
    return 'mock-job-$_version';
  }

  @override
  Future<Substitutions> getSubstitutions(String exerciseId) async {
    return Substitutions(
      exerciseId: exerciseId,
      candidates: [
        SubstitutionCandidate(
          exercise: ExerciseRef(id: 'mock-ex-alt', name: 'Alternative movement (mock)'),
          equipmentTags: const [],
          reason: 'Trains the same movement pattern with no equipment required (mock).',
        ),
      ],
    );
  }

  @override
  Future<WorkoutLog> startLog({required String clientId, required String sessionId, DateTime? startedAt}) async {
    final existing = _logs.values.where((l) => l.clientId == clientId).firstOrNull;
    if (existing != null) return existing;
    final log = WorkoutLog(
      id: 'mock-log-${_logs.length}',
      clientId: clientId,
      sessionId: sessionId,
      status: WorkoutLogStatusEnum.inProgress,
      startedAt: startedAt ?? DateTime.now(),
      completedAt: null,
      sets: const [],
      revision: 1,
    );
    _logs[log.id] = log;
    return log;
  }

  @override
  Future<WorkoutLog> putSets({
    required String logId,
    required int expectedRevision,
    required List<SetLogInput> sets,
    String? idempotencyKey,
  }) async {
    final current = _logs[logId];
    if (current == null) throw const ApiFailure(kind: ApiFailureKind.notFound, message: 'Workout log not found.');
    if (current.revision != expectedRevision) {
      throw const ApiFailure(kind: ApiFailureKind.conflict, message: 'This session changed. Reload and try again.');
    }
    final updated = WorkoutLog(
      id: current.id,
      clientId: current.clientId,
      sessionId: current.sessionId,
      status: current.status,
      startedAt: current.startedAt,
      completedAt: current.completedAt,
      sets: sets,
      revision: current.revision + 1,
    );
    _logs[logId] = updated;
    return updated;
  }

  @override
  Future<WorkoutLog> patchLog({
    required String logId,
    required int expectedRevision,
    required PatchWorkoutLogRequestStatusEnum status,
    DateTime? completedAt,
    String? idempotencyKey,
  }) async {
    final current = _logs[logId];
    if (current == null) throw const ApiFailure(kind: ApiFailureKind.notFound, message: 'Workout log not found.');
    if (current.revision != expectedRevision) {
      throw const ApiFailure(kind: ApiFailureKind.conflict, message: 'This session changed. Reload and try again.');
    }
    final mappedStatus = switch (status) {
      PatchWorkoutLogRequestStatusEnum.completed => WorkoutLogStatusEnum.completed,
      PatchWorkoutLogRequestStatusEnum.skipped => WorkoutLogStatusEnum.skipped,
      PatchWorkoutLogRequestStatusEnum.abandoned => WorkoutLogStatusEnum.abandoned,
    };
    final updated = WorkoutLog(
      id: current.id,
      clientId: current.clientId,
      sessionId: current.sessionId,
      status: mappedStatus,
      startedAt: current.startedAt,
      completedAt: completedAt ?? DateTime.now(),
      sets: current.sets,
      revision: current.revision + 1,
    );
    _logs[logId] = updated;
    return updated;
  }
}
