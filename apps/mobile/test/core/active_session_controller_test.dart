import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noura/core/providers.dart';
import 'package:noura/core/workouts/workout_controller.dart';
import 'package:noura/core/workouts/workout_repository.dart';
import 'package:noura_api_client/noura_api_client.dart';

PrescribedExercise _exercise(String id, {int sets = 2, int restSec = 30}) => PrescribedExercise(
  id: 'pe-$id',
  exercise: ExerciseRef(id: id, name: 'Exercise $id'),
  ordinal: 1,
  sets: sets,
  repsMin: 8,
  repsMax: 12,
  restSec: restSec,
  effortCue: null,
);

WorkoutSession _session() => WorkoutSession(
  id: 'session-1',
  date: DateTime(2026, 10, 5),
  order: 1,
  title: 'Full-body',
  status: WorkoutSessionStatusEnum.scheduled,
  exercises: [_exercise('a'), _exercise('b', sets: 1)],
);

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(overrides: [workoutRepositoryProvider.overrideWithValue(MockWorkoutRepository())]);
  });
  tearDown(() => container.dispose());

  test('starting a session creates a log and begins at exercise 0, set 1', () async {
    final notifier = container.read(activeSessionControllerProvider.notifier);
    await notifier.start(_session());
    final state = container.read(activeSessionControllerProvider).value!;
    expect(state.exerciseIndex, 0);
    expect(state.setNumber, 1);
    expect(state.logId, isNotEmpty);
    expect(state.restPhase, RestPhase.none);
  });

  test('logging a non-final set starts a rest timer and advances the set number', () async {
    final notifier = container.read(activeSessionControllerProvider.notifier);
    await notifier.start(_session());
    notifier.logSet(reps: 10, loadKg: null);
    final state = container.read(activeSessionControllerProvider).value!;
    expect(state.setNumber, 2);
    expect(state.exerciseIndex, 0);
    expect(state.loggedSets, hasLength(1));
    expect(state.restPhase, RestPhase.resting);
    expect(state.restSecondsRemaining, 30);
    notifier.reset();
  });

  test('logging the final set of an exercise advances to the next exercise at set 1', () async {
    final notifier = container.read(activeSessionControllerProvider.notifier);
    await notifier.start(_session());
    notifier.logSet(reps: 10, loadKg: null); // exercise a, set 1 of 2
    notifier.logSet(reps: 9, loadKg: null); // exercise a, set 2 of 2 (last)
    final state = container.read(activeSessionControllerProvider).value!;
    expect(state.exerciseIndex, 1);
    expect(state.setNumber, 1);
    expect(state.loggedSets, hasLength(2));
    notifier.reset();
  });

  test('skipping a set starts no rest timer', () async {
    final notifier = container.read(activeSessionControllerProvider.notifier);
    await notifier.start(_session());
    notifier.logSet(skipped: true);
    final state = container.read(activeSessionControllerProvider).value!;
    expect(state.restPhase, RestPhase.done);
    expect(state.loggedSets.single.skipped, isTrue);
    notifier.reset();
  });

  test('skipRest ends the rest phase immediately', () async {
    final notifier = container.read(activeSessionControllerProvider.notifier);
    await notifier.start(_session());
    notifier.logSet(reps: 10, loadKg: null);
    expect(container.read(activeSessionControllerProvider).value!.restPhase, RestPhase.resting);
    notifier.skipRest();
    expect(container.read(activeSessionControllerProvider).value!.restPhase, RestPhase.done);
    notifier.reset();
  });

  test('finishing the last exercise, then finish(), saves sets and marks the session finished', () async {
    final notifier = container.read(activeSessionControllerProvider.notifier);
    await notifier.start(_session());
    notifier.logSet(reps: 10, loadKg: null); // a 1/2
    notifier.logSet(reps: 9, loadKg: null); // a 2/2 -> moves to b
    notifier.logSet(reps: 8, loadKg: 20); // b 1/1, last exercise last set
    var state = container.read(activeSessionControllerProvider).value!;
    expect(state.loggedSets, hasLength(3));
    expect(state.finished, isFalse);

    await notifier.finish();
    state = container.read(activeSessionControllerProvider).value!;
    expect(state.finished, isTrue);
    notifier.reset();
  });
}
