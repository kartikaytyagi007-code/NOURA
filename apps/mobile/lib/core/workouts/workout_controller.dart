import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../profile/profile_repository.dart' show newIdempotencyKey;
import '../providers.dart' show workoutRepositoryProvider;
import 'workout_repository.dart' show WorkoutRepository;

/// The signed-in user's active weekly workout plan (GET /v1/workout-plans/current) and generation.
/// Mirrors [DietController]'s conventions.
class WorkoutController extends AsyncNotifier<WorkoutPlan?> {
  @override
  Future<WorkoutPlan?> build() => ref.watch(workoutRepositoryProvider).fetchCurrentPlan();

  WorkoutRepository get _repository => ref.read(workoutRepositoryProvider);

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.fetchCurrentPlan());
  }

  Future<String> requestGeneration({required int profileRevision}) {
    return _repository.requestGeneration(profileRevision: profileRevision);
  }
}

final workoutControllerProvider = AsyncNotifierProvider<WorkoutController, WorkoutPlan?>(WorkoutController.new);

/// One logged set, as the UI builds it up before it is saved.
class LoggedSet {
  const LoggedSet({required this.exerciseId, required this.setOrdinal, this.reps, this.loadKg, this.skipped = false});
  final String exerciseId;
  final int setOrdinal;
  final int? reps;
  final num? loadKg;
  final bool skipped;

  LoggedSet copyWith({int? reps, num? loadKg, bool? skipped}) => LoggedSet(
    exerciseId: exerciseId,
    setOrdinal: setOrdinal,
    reps: reps ?? this.reps,
    loadKg: loadKg ?? this.loadKg,
    skipped: skipped ?? this.skipped,
  );

  SetLogInput toInput() =>
      SetLogInput(exerciseId: exerciseId, setOrdinal: setOrdinal, reps: reps, loadKg: loadKg, skipped: skipped);
}

enum RestPhase { none, resting, done }

/// An in-progress workout session: which exercise/set is current, the sets logged so far, and a
/// real countdown rest timer between sets (blueprint §11's active-session screen, ticket: "a real
/// timer UI, not a stub"). A plain [Notifier] rather than [AsyncNotifier] because its state changes
/// (timer ticks, set entries) are synchronous; network calls happen explicitly through its methods.
class ActiveSessionState {
  const ActiveSessionState({
    required this.session,
    required this.logId,
    required this.revision,
    required this.exerciseIndex,
    required this.setNumber,
    required this.loggedSets,
    required this.restPhase,
    required this.restSecondsRemaining,
    required this.finished,
  });

  final WorkoutSession session;
  final String logId;
  final int revision;
  final int exerciseIndex;
  final int setNumber;
  final List<LoggedSet> loggedSets;
  final RestPhase restPhase;
  final int restSecondsRemaining;
  final bool finished;

  PrescribedExercise get currentExercise => session.exercises[exerciseIndex];
  bool get isLastExercise => exerciseIndex == session.exercises.length - 1;
  bool get isLastSetOfExercise => setNumber >= currentExercise.sets;

  ActiveSessionState copyWith({
    int? exerciseIndex,
    int? setNumber,
    List<LoggedSet>? loggedSets,
    RestPhase? restPhase,
    int? restSecondsRemaining,
    int? revision,
    bool? finished,
  }) => ActiveSessionState(
    session: session,
    logId: logId,
    revision: revision ?? this.revision,
    exerciseIndex: exerciseIndex ?? this.exerciseIndex,
    setNumber: setNumber ?? this.setNumber,
    loggedSets: loggedSets ?? this.loggedSets,
    restPhase: restPhase ?? this.restPhase,
    restSecondsRemaining: restSecondsRemaining ?? this.restSecondsRemaining,
    finished: finished ?? this.finished,
  );
}

class ActiveSessionController extends Notifier<AsyncValue<ActiveSessionState?>> {
  Timer? _timer;

  @override
  AsyncValue<ActiveSessionState?> build() {
    ref.onDispose(() => _timer?.cancel());
    return const AsyncData(null);
  }

  WorkoutRepository get _repository => ref.read(workoutRepositoryProvider);

  /// Starts (or resumes, via a stable client id) a log for this session.
  Future<void> start(WorkoutSession session) async {
    state = const AsyncLoading();
    try {
      final log = await _repository.startLog(clientId: newIdempotencyKey(), sessionId: session.id);
      state = AsyncData(
        ActiveSessionState(
          session: session,
          logId: log.id,
          revision: log.revision,
          exerciseIndex: 0,
          setNumber: 1,
          loggedSets: const [],
          restPhase: RestPhase.none,
          restSecondsRemaining: 0,
          finished: false,
        ),
      );
    } catch (error, stack) {
      state = AsyncError(error, stack);
    }
  }

  void _startRestTimer(int seconds) {
    _timer?.cancel();
    final current = state.value;
    if (current == null) return;
    if (seconds <= 0) {
      state = AsyncData(current.copyWith(restPhase: RestPhase.done, restSecondsRemaining: 0));
      return;
    }
    state = AsyncData(current.copyWith(restPhase: RestPhase.resting, restSecondsRemaining: seconds));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final s = state.value;
      if (s == null || s.restPhase != RestPhase.resting) {
        timer.cancel();
        return;
      }
      final remaining = s.restSecondsRemaining - 1;
      if (remaining <= 0) {
        timer.cancel();
        state = AsyncData(s.copyWith(restPhase: RestPhase.done, restSecondsRemaining: 0));
      } else {
        state = AsyncData(s.copyWith(restSecondsRemaining: remaining));
      }
    });
  }

  void skipRest() {
    _timer?.cancel();
    final s = state.value;
    if (s != null) state = AsyncData(s.copyWith(restPhase: RestPhase.done, restSecondsRemaining: 0));
  }

  /// Records one set (completed or skipped) and advances to the next set/exercise, starting the
  /// rest timer between sets of the same exercise.
  void logSet({int? reps, num? loadKg, bool skipped = false}) {
    final s = state.value;
    if (s == null) return;
    final ex = s.currentExercise;
    final logged = LoggedSet(
      exerciseId: ex.exercise.id,
      setOrdinal: s.setNumber,
      reps: reps,
      loadKg: loadKg,
      skipped: skipped,
    );
    final updatedSets = [...s.loggedSets, logged];

    if (!s.isLastSetOfExercise) {
      state = AsyncData(updatedSets.isEmpty ? s : s.copyWith(loggedSets: updatedSets, setNumber: s.setNumber + 1));
      _startRestTimer(skipped ? 0 : ex.restSec);
      return;
    }
    if (!s.isLastExercise) {
      state = AsyncData(s.copyWith(loggedSets: updatedSets, exerciseIndex: s.exerciseIndex + 1, setNumber: 1));
      _startRestTimer(0);
      return;
    }
    // Last set of the last exercise: nothing left to rest for.
    state = AsyncData(s.copyWith(loggedSets: updatedSets, restPhase: RestPhase.none, restSecondsRemaining: 0));
  }

  /// Saves every logged set, then marks the session completed.
  Future<void> finish() async {
    final s = state.value;
    if (s == null) return;
    state = const AsyncLoading();
    try {
      final saved = await _repository.putSets(
        logId: s.logId,
        expectedRevision: s.revision,
        sets: [for (final l in s.loggedSets) l.toInput()],
      );
      final completed = await _repository.patchLog(
        logId: s.logId,
        expectedRevision: saved.revision,
        status: PatchWorkoutLogRequestStatusEnum.completed,
      );
      state = AsyncData(s.copyWith(revision: completed.revision, finished: true));
    } catch (error, stack) {
      state = AsyncError(error, stack);
    }
  }

  Future<void> abandon() async {
    final s = state.value;
    if (s == null) return;
    try {
      await _repository.patchLog(
        logId: s.logId,
        expectedRevision: s.revision,
        status: PatchWorkoutLogRequestStatusEnum.abandoned,
      );
    } finally {
      _timer?.cancel();
      state = const AsyncData(null);
    }
  }

  void reset() {
    _timer?.cancel();
    state = const AsyncData(null);
  }
}

final activeSessionControllerProvider = NotifierProvider<ActiveSessionController, AsyncValue<ActiveSessionState?>>(
  ActiveSessionController.new,
);
