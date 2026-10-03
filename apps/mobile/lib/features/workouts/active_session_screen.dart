import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../../core/api/api_failure.dart';
import '../../core/ui/components/n_button.dart';
import '../../core/ui/components/state_views.dart';
import '../../core/ui/tokens.dart';
import '../../core/workouts/workout_controller.dart';
import 'completion_summary_screen.dart';

/// Active workout session: the current exercise/set, reps and load entry, a real countdown rest
/// timer between sets, and skip/finish actions (blueprint §11, M7 ticket: "a real timer UI, not a
/// stub"). Reads [activeSessionControllerProvider], started by [WorkoutSessionScreen].
class ActiveSessionScreen extends ConsumerStatefulWidget {
  const ActiveSessionScreen({super.key, required this.session});
  final WorkoutSession session;

  @override
  ConsumerState<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends ConsumerState<ActiveSessionScreen> {
  final _repsController = TextEditingController();
  final _loadController = TextEditingController();

  @override
  void dispose() {
    _repsController.dispose();
    _loadController.dispose();
    super.dispose();
  }

  Future<bool> _confirmAbandon() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave this session?'),
        content: const Text('Sets you have already logged are kept, but the session will be marked abandoned.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep going')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Leave')),
        ],
      ),
    );
    return confirmed ?? false;
  }

  void _logSet({required bool skipped}) {
    final reps = skipped ? null : int.tryParse(_repsController.text.trim());
    final load = skipped ? null : num.tryParse(_loadController.text.trim());
    ref.read(activeSessionControllerProvider.notifier).logSet(reps: reps, loadKg: load, skipped: skipped);
    _repsController.clear();
    _loadController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeSessionControllerProvider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmAbandon()) {
          await ref.read(activeSessionControllerProvider.notifier).abandon();
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.session.title)),
        body: state.when(
          loading: () => const LoadingView(label: 'Starting session'),
          error: (error, _) => ErrorView(
            message: error is ApiFailure ? error.message : 'Something went wrong.',
            offline: error is ApiFailure && error.isOffline,
            onRetry: () => ref.read(activeSessionControllerProvider.notifier).start(widget.session),
          ),
          data: (active) {
            if (active == null) {
              return const MessageView(icon: Icons.fitness_center, title: 'Session not started', message: '');
            }
            if (active.finished) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                Navigator.of(context)
                    .pushReplacement(MaterialPageRoute<void>(builder: (_) => CompletionSummaryScreen(state: active)));
              });
              return const LoadingView(label: 'Saving your session');
            }
            if (active.restPhase == RestPhase.resting) {
              return _RestTimerView(
                secondsRemaining: active.restSecondsRemaining,
                onSkip: () => ref.read(activeSessionControllerProvider.notifier).skipRest(),
              );
            }
            final exercise = active.currentExercise;
            final isLastSet = active.setNumber > exercise.sets || active.loggedSets.length >= _totalSets(active);
            return Padding(
              padding: const EdgeInsets.all(NSpace.pageMargin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Exercise ${active.exerciseIndex + 1} of ${active.session.exercises.length}'),
                  const SizedBox(height: NSpace.xs),
                  Text(exercise.exercise.name, style: NType.headlineSm),
                  const SizedBox(height: NSpace.xs),
                  Text(
                    'Set ${active.setNumber} of ${exercise.sets} · target ${exercise.repsMin}-${exercise.repsMax} reps',
                  ),
                  if (exercise.effortCue != null) ...[
                    const SizedBox(height: NSpace.xs),
                    Text(exercise.effortCue!, style: const TextStyle(color: NColors.outline)),
                  ],
                  const SizedBox(height: NSpace.lg),
                  TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Reps completed'),
                  ),
                  const SizedBox(height: NSpace.sm),
                  TextField(
                    controller: _loadController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Load (kg, optional)'),
                  ),
                  const SizedBox(height: NSpace.lg),
                  NButton(label: 'Log set', onPressed: () => _logSet(skipped: false)),
                  const SizedBox(height: NSpace.sm),
                  NButton(
                    label: 'Skip this exercise',
                    variant: NButtonVariant.text,
                    onPressed: () => _logSet(skipped: true),
                  ),
                  if (isLastSet) ...[
                    const SizedBox(height: NSpace.lg),
                    NButton(
                      label: 'Finish session',
                      onPressed: () => ref.read(activeSessionControllerProvider.notifier).finish(),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  int _totalSets(ActiveSessionState active) => active.session.exercises.fold<int>(0, (sum, e) => sum + e.sets);
}

class _RestTimerView extends StatelessWidget {
  const _RestTimerView({required this.secondsRemaining, required this.onSkip});
  final int secondsRemaining;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Rest', style: NType.headlineSm),
          const SizedBox(height: NSpace.md),
          Text('$secondsRemaining', style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold)),
          const SizedBox(height: NSpace.lg),
          TextButton(onPressed: onSkip, child: const Text('Skip rest')),
        ],
      ),
    );
  }
}
