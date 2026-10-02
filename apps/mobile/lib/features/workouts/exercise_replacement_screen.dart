import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../../core/api/api_failure.dart';
import '../../core/providers.dart';
import '../../core/ui/components/state_views.dart';
import '../../core/ui/tokens.dart';

/// Exercise substitution (blueprint §11, M7 ticket): every candidate shown here comes only from the
/// approved exercise catalog's own declared substitution relationships
/// (GET /v1/exercises/{id}/substitutions), already filtered to what the user's equipment, location,
/// limitations and experience can support — never an invented "similar" exercise.
class ExerciseReplacementScreen extends ConsumerStatefulWidget {
  const ExerciseReplacementScreen({super.key, required this.exercise});
  final ExerciseRef exercise;

  @override
  ConsumerState<ExerciseReplacementScreen> createState() => _ExerciseReplacementScreenState();
}

class _ExerciseReplacementScreenState extends ConsumerState<ExerciseReplacementScreen> {
  late Future<Substitutions> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = ref.read(workoutRepositoryProvider).getSubstitutions(widget.exercise.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Replace ${widget.exercise.name}')),
      body: FutureBuilder<Substitutions>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingView(label: 'Loading substitutions');
          }
          if (snapshot.hasError) {
            final error = snapshot.error;
            return ErrorView(
              message: error is ApiFailure ? error.message : 'Something went wrong.',
              offline: error is ApiFailure && error.isOffline,
              onRetry: () => setState(_load),
            );
          }
          final candidates = snapshot.data!.candidates;
          if (candidates.isEmpty) {
            return const MessageView(
              icon: Icons.swap_horiz,
              title: 'No substitution available',
              message:
                  'There is no catalog-approved alternative for your current equipment, location and '
                  'recorded limitations.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(NSpace.pageMargin),
            itemCount: candidates.length,
            separatorBuilder: (_, _) => const SizedBox(height: NSpace.sm),
            itemBuilder: (context, i) {
              final candidate = candidates[i];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(NSpace.sm),
                  title: Text(candidate.exercise.name),
                  subtitle: Text(candidate.reason),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).pop(candidate.exercise),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
