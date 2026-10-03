import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../../app/shell.dart';
import '../../core/api/api_failure.dart';
import '../../core/providers.dart';
import '../../core/ui/components/state_views.dart';
import '../../core/ui/tokens.dart';
import '../../core/workouts/workout_controller.dart';
import 'workout_session_screen.dart';

/// Weekly workout schedule (blueprint §11, M7 ticket): one card per session for the active plan,
/// a "Generate my plan" action when there is none, and the required loading/empty/error states.
class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  bool _requesting = false;

  Future<void> _requestPlan() async {
    final me = ref.read(meControllerProvider).value;
    if (me == null) return;
    final revision = me.trainingPreferences?.revision;
    if (revision == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Set up your training preferences first.')));
      return;
    }
    setState(() => _requesting = true);
    try {
      await ref.read(workoutControllerProvider.notifier).requestGeneration(profileRevision: revision);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("We're building your plan. This can take a moment.")));
      await ref.read(workoutControllerProvider.notifier).reload();
    } on ApiFailure catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final planState = ref.watch(workoutControllerProvider);
    return TabPage(
      title: 'Workout',
      children: [
        if (planState.value != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _requesting ? null : _requestPlan,
              icon: const Icon(Icons.refresh),
              label: const Text('Regenerate plan'),
            ),
          ),
        planState.when(
          loading: () => const SizedBox(height: 240, child: LoadingView(label: 'Loading your workout plan')),
          error: (error, _) => SizedBox(
            height: 240,
            child: ErrorView(
              message: error is ApiFailure ? error.message : 'Something went wrong.',
              offline: error is ApiFailure && error.isOffline,
              onRetry: () => ref.read(workoutControllerProvider.notifier).reload(),
            ),
          ),
          data: (plan) {
            if (plan == null || plan.sessions.isEmpty) {
              return MessageView(
                icon: Icons.fitness_center,
                title: 'No workout plan yet',
                message: 'Generate a weekly plan built from your training preferences and equipment.',
                actionLabel: _requesting ? 'Generating…' : 'Generate my plan',
                onAction: _requesting ? null : _requestPlan,
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [for (final session in plan.sessions) _SessionCard(session: session)],
            );
          },
        ),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});
  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: NSpace.sm),
      child: ListTile(
        contentPadding: const EdgeInsets.all(NSpace.sm),
        leading: Icon(_statusIcon(session.status), color: _statusColor(session.status)),
        title: Text(session.title),
        subtitle: Text('${_weekdayLabel(session.date)} · ${session.exercises.length} exercises'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () =>
            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => WorkoutSessionScreen(session: session))),
      ),
    );
  }
}

String _weekdayLabel(DateTime date) {
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return '${names[date.weekday - 1]} ${date.day}';
}

IconData _statusIcon(WorkoutSessionStatusEnum status) => switch (status) {
  WorkoutSessionStatusEnum.cancelled => Icons.event_busy,
  WorkoutSessionStatusEnum.rescheduled => Icons.event_repeat,
  WorkoutSessionStatusEnum.scheduled => Icons.event_available,
};

Color _statusColor(WorkoutSessionStatusEnum status) => switch (status) {
  WorkoutSessionStatusEnum.cancelled => NColors.outline,
  WorkoutSessionStatusEnum.rescheduled => NColors.secondary,
  WorkoutSessionStatusEnum.scheduled => NColors.primary,
};
