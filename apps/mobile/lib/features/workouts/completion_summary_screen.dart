import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui/components/n_button.dart';
import '../../core/ui/tokens.dart';
import '../../core/workouts/workout_controller.dart';

/// Completion summary shown after a finished session: sets completed vs skipped, per exercise
/// (blueprint §11, M7 ticket).
class CompletionSummaryScreen extends ConsumerWidget {
  const CompletionSummaryScreen({super.key, required this.state});
  final ActiveSessionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = state.loggedSets.where((s) => !s.skipped).length;
    final skipped = state.loggedSets.where((s) => s.skipped).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Session complete'), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(NSpace.pageMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle, color: NColors.primary, size: 48),
            const SizedBox(height: NSpace.md),
            Text(state.session.title, style: NType.headlineSm),
            const SizedBox(height: NSpace.xs),
            Text('$completed sets completed · $skipped skipped'),
            const SizedBox(height: NSpace.lg),
            Expanded(
              child: ListView(
                children: [
                  for (final exercise in state.session.exercises)
                    _ExerciseSummaryTile(
                      name: exercise.exercise.name,
                      sets: [
                        for (final s in state.loggedSets)
                          if (s.exerciseId == exercise.exercise.id) s,
                      ],
                    ),
                ],
              ),
            ),
            NButton(
              label: 'Done',
              onPressed: () {
                ref.read(activeSessionControllerProvider.notifier).reset();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseSummaryTile extends StatelessWidget {
  const _ExerciseSummaryTile({required this.name, required this.sets});
  final String name;
  final List<LoggedSet> sets;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: NSpace.sm),
      child: ListTile(
        contentPadding: const EdgeInsets.all(NSpace.sm),
        title: Text(name),
        subtitle: Text(
          sets.isEmpty
              ? 'Not logged'
              : sets
                    .map(
                      (s) => s.skipped
                          ? 'Set ${s.setOrdinal}: skipped'
                          : 'Set ${s.setOrdinal}: ${s.reps ?? '—'} reps${s.loadKg != null ? ' @ ${s.loadKg}kg' : ''}',
                    )
                    .join(' · '),
        ),
      ),
    );
  }
}
