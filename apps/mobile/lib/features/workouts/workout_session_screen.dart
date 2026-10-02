import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../../core/ui/components/n_button.dart';
import '../../core/ui/tokens.dart';
import '../../core/workouts/workout_controller.dart';
import 'active_session_screen.dart';
import 'exercise_replacement_screen.dart';

/// One day's session plan: every prescribed exercise with its sets/reps/rest and effort cue, a way
/// to see catalog-backed substitutions, and a "Start session" action (blueprint §11, M7 ticket).
class WorkoutSessionScreen extends ConsumerWidget {
  const WorkoutSessionScreen({super.key, required this.session});
  final WorkoutSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(session.title)),
      body: ListView(
        padding: const EdgeInsets.all(NSpace.pageMargin),
        children: [
          Text('${_weekdayLabel(session.date)} · ${session.exercises.length} exercises', style: NType.bodyMd),
          const SizedBox(height: NSpace.md),
          for (final exercise in session.exercises) _ExerciseTile(exercise: exercise),
          const SizedBox(height: NSpace.lg),
          NButton(
            label: 'Start session',
            onPressed: () async {
              await ref.read(activeSessionControllerProvider.notifier).start(session);
              if (!context.mounted) return;
              Navigator.of(context)
                  .push(MaterialPageRoute<void>(builder: (_) => ActiveSessionScreen(session: session)));
            },
          ),
        ],
      ),
    );
  }
}

String _weekdayLabel(DateTime date) {
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return '${names[date.weekday - 1]} ${date.day}';
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({required this.exercise});
  final PrescribedExercise exercise;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: NSpace.sm),
      child: ListTile(
        contentPadding: const EdgeInsets.all(NSpace.sm),
        title: Text(exercise.exercise.name),
        subtitle: Text(
          '${exercise.sets} sets × ${exercise.repsMin}-${exercise.repsMax} reps · ${exercise.restSec}s rest'
          '${exercise.effortCue != null ? '\n${exercise.effortCue}' : ''}',
        ),
        isThreeLine: exercise.effortCue != null,
        trailing: TextButton(
          onPressed: () async {
            final replacement = await Navigator.of(context).push<ExerciseRef>(
              MaterialPageRoute<ExerciseRef>(builder: (_) => ExerciseReplacementScreen(exercise: exercise.exercise)),
            );
            if (replacement != null && context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Use ${replacement.name} instead for this session.')));
            }
          },
          child: const Text('Replace'),
        ),
      ),
    );
  }
}
