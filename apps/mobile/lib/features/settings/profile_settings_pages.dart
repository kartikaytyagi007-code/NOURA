import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../../core/providers.dart';
import '../../core/ui/components/state_views.dart';
import '../../core/ui/tokens.dart';
import '../profile/basics_form.dart';
import '../profile/diet_form.dart';
import '../profile/goal_form.dart';
import '../profile/screening_form.dart';
import '../profile/training_form.dart';

/// Wraps one editing form in a page. A successful save returns to Settings, and the server has
/// already incremented the revision. An explicit reload rebuilds the form with fresh values.
class _EditPage extends ConsumerWidget {
  const _EditPage({required this.title, required this.builder});

  final String title;
  final Widget Function(Me me, int generation, VoidCallback done) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meControllerProvider).value;
    void done() {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
      context.pop();
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: me == null
          ? const LoadingView()
          : ListView(
              padding: const EdgeInsets.all(NSpace.pageMargin),
              children: [builder(me, ref.watch(meReloadGenerationProvider), done)],
            ),
    );
  }
}

class ProfileEditPage extends StatelessWidget {
  const ProfileEditPage({super.key});

  @override
  Widget build(BuildContext context) => _EditPage(
    title: 'Profile',
    builder: (me, rev, done) => BasicsForm(key: ValueKey('basics:$rev'), me: me, submitLabel: 'Save', onSaved: done),
  );
}

class GoalEditPage extends StatelessWidget {
  const GoalEditPage({super.key});

  @override
  Widget build(BuildContext context) => _EditPage(
    title: 'Goal',
    builder: (me, rev, done) => GoalForm(key: ValueKey('goal:$rev'), me: me, submitLabel: 'Save', onSaved: done),
  );
}

class PreferencesEditPage extends StatelessWidget {
  const PreferencesEditPage({super.key});

  @override
  Widget build(BuildContext context) => _EditPage(
    title: 'Food preferences',
    builder: (me, rev, done) => DietForm(key: ValueKey('diet:$rev'), me: me, submitLabel: 'Save', onSaved: done),
  );
}

class TrainingEditPage extends StatelessWidget {
  const TrainingEditPage({super.key});

  @override
  Widget build(BuildContext context) => _EditPage(
    title: 'Training',
    builder: (me, rev, done) =>
        TrainingForm(key: ValueKey('training:$rev'), me: me, submitLabel: 'Save', onSaved: done),
  );
}

class EligibilityEditPage extends StatelessWidget {
  const EligibilityEditPage({super.key});

  @override
  Widget build(BuildContext context) => _EditPage(
    title: 'Eligibility',
    builder: (me, rev, done) => ScreeningForm(
      key: ValueKey('screening:$rev'),
      me: me,
      submitLabel: 'Save',
      onSaved: done,
      afterCompletion: true,
    ),
  );
}
