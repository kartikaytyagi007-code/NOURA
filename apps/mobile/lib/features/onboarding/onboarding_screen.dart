import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../../app/routes.dart';
import '../../core/api/api_failure.dart';
import '../../core/providers.dart';
import '../../core/ui/components/n_button.dart';
import '../../core/ui/components/state_views.dart';
import '../../core/ui/tokens.dart';
import '../profile/basics_form.dart';
import '../profile/diet_form.dart';
import '../profile/goal_form.dart';
import '../profile/screening_form.dart';
import '../profile/training_form.dart';
import 'review_step.dart';

/// The six onboarding steps, in order. The server stores the furthest step reached
/// (`onboarding.step`), so the flow resumes there after a restart.
const onboardingSteps = <OnboardingStep>[
  OnboardingStep.basics,
  OnboardingStep.goals,
  OnboardingStep.diet,
  OnboardingStep.training,
  OnboardingStep.eligibility,
  OnboardingStep.review,
];

String onboardingStepTitle(OnboardingStep step) => switch (step) {
  OnboardingStep.basics => 'About you',
  OnboardingStep.goals => 'Your goal',
  OnboardingStep.diet => 'Food preferences',
  OnboardingStep.training => 'Training',
  OnboardingStep.eligibility => 'Eligibility',
  OnboardingStep.review => 'Review and finish',
};

/// Resumable onboarding (blueprint §5, M2): basics → goals → diet/preferences → training →
/// eligibility → review and consent. Each step saves to the server before moving on. Going back
/// never discards saved data and never moves the stored step backwards.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late int _index;

  @override
  void initState() {
    super.initState();
    final stored = ref.read(meControllerProvider).value?.onboarding.step;
    _index = stored == null ? 0 : onboardingSteps.indexOf(stored);
  }

  int _storedIndex(Me me) {
    final stored = me.onboarding.step;
    return stored == null ? 0 : onboardingSteps.indexOf(stored);
  }

  /// The step to record when the current step is saved: the next one, but never earlier than the
  /// furthest step already reached.
  OnboardingStep _advanceTarget(Me me) {
    final next = (_index + 1).clamp(0, onboardingSteps.length - 1);
    return onboardingSteps[next > _storedIndex(me) ? next : _storedIndex(me)];
  }

  void _goTo(int index) => setState(() => _index = index.clamp(0, onboardingSteps.length - 1));

  void _back() => _goTo(_index - 1);

  Widget _stepBody(Me me) {
    final advanceTo = _advanceTarget(me);
    final onBack = _index == 0 ? null : _back;
    void next() => _goTo(_index + 1);
    // A reload (for example after a revision conflict) rebuilds the form with the server's values.
    final key = ValueKey('${onboardingSteps[_index].value}:${ref.watch(meReloadGenerationProvider)}');
    return switch (onboardingSteps[_index]) {
      OnboardingStep.basics => BasicsForm(
        key: key,
        me: me,
        submitLabel: 'Continue',
        advanceTo: advanceTo,
        onSaved: next,
      ),
      OnboardingStep.goals => GoalForm(
        key: key,
        me: me,
        submitLabel: 'Continue',
        advanceTo: advanceTo,
        onBack: onBack,
        onSaved: next,
      ),
      OnboardingStep.diet => DietForm(
        key: key,
        me: me,
        submitLabel: 'Continue',
        advanceTo: advanceTo,
        onBack: onBack,
        onSaved: next,
      ),
      OnboardingStep.training => TrainingForm(
        key: key,
        me: me,
        submitLabel: 'Continue',
        advanceTo: advanceTo,
        onBack: onBack,
        onSaved: next,
      ),
      OnboardingStep.eligibility => ScreeningForm(
        key: key,
        me: me,
        submitLabel: 'Continue',
        advanceTo: advanceTo,
        onBack: onBack,
        onSaved: next,
      ),
      OnboardingStep.review => ReviewStep(key: key, me: me, onBack: onBack),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meState = ref.watch(meControllerProvider);
    final me = meState.value;
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Set up your profile'),
          actions: [
            IconButton(
              tooltip: 'Settings',
              icon: const Icon(Icons.person_outline),
              onPressed: () => context.push(Routes.settings),
            ),
          ],
        ),
        body: me == null
            ? meState.hasError
                  ? ErrorView(
                      message: meState.error is ApiFailure
                          ? (meState.error! as ApiFailure).message
                          : 'Something went wrong.',
                      offline: meState.error is ApiFailure && (meState.error! as ApiFailure).isOffline,
                      onRetry: () => ref.invalidate(meControllerProvider),
                    )
                  : const LoadingView()
            : ListView(
                padding: const EdgeInsets.all(NSpace.pageMargin),
                children: [
                  Semantics(
                    label: 'Step ${_index + 1} of ${onboardingSteps.length}',
                    child: LinearProgressIndicator(value: (_index + 1) / onboardingSteps.length),
                  ),
                  const SizedBox(height: NSpace.sm),
                  Text(
                    'Step ${_index + 1} of ${onboardingSteps.length}',
                    style: theme.textTheme.labelMedium?.copyWith(color: NColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: NSpace.xs),
                  Text(onboardingStepTitle(onboardingSteps[_index]), style: theme.textTheme.headlineSmall),
                  const SizedBox(height: NSpace.lg),
                  _stepBody(me),
                  const SizedBox(height: NSpace.lg),
                  NButton(
                    label: 'Sign out',
                    variant: NButtonVariant.text,
                    onPressed: () => ref.read(authRepositoryProvider).signOut(),
                  ),
                ],
              ),
      ),
    );
  }
}
