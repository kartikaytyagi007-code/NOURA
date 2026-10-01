import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../../core/providers.dart';
import '../../core/ui/tokens.dart';
import 'form_support.dart';

String screeningAnswerLabel(ScreeningAnswer v) => switch (v) {
  ScreeningAnswer.yes => 'Yes',
  ScreeningAnswer.no => 'No',
  ScreeningAnswer.preferNotToSay => 'Prefer not to say',
};

/// Minimal eligibility screening (blueprint §1). Only these three answers are stored. Shared by
/// onboarding step 5 and Settings > Eligibility.
class ScreeningForm extends ConsumerStatefulWidget {
  const ScreeningForm({
    super.key,
    required this.me,
    required this.submitLabel,
    required this.onSaved,
    this.advanceTo,
    this.onBack,
    this.afterCompletion = false,
  });

  final Me me;
  final String submitLabel;
  final VoidCallback onSaved;
  final OnboardingStep? advanceTo;
  final VoidCallback? onBack;

  /// True in Settings: shows that changing an answer can change whether plans are available.
  final bool afterCompletion;

  @override
  ConsumerState<ScreeningForm> createState() => _ScreeningFormState();
}

class _ScreeningFormState extends ConsumerState<ScreeningForm> with SubmitStateMixin<ScreeningForm> {
  final _formKey = GlobalKey<FormState>();
  late ScreeningAnswer? _pregnancy;
  late ScreeningAnswer? _eating;
  late ScreeningAnswer? _medical;

  @override
  void initState() {
    super.initState();
    final s = widget.me.screening;
    _pregnancy = s?.pregnancyOrBreastfeeding;
    _eating = s?.eatingDisorderConcern;
    _medical = s?.medicalDietCondition;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final saved = await runSubmit(
      () => ref
          .read(meControllerProvider.notifier)
          .patchProfile(
            (revision) => ProfilePatch(
              expectedRevision: revision,
              screening: ScreeningAnswers(
                pregnancyOrBreastfeeding: _pregnancy!,
                eatingDisorderConcern: _eating!,
                medicalDietCondition: _medical!,
              ),
              onboardingStep: widget.advanceTo,
            ),
          ),
    );
    if (saved && mounted) widget.onSaved();
  }

  Widget _question(String label, ScreeningAnswer? value, ValueChanged<ScreeningAnswer?> onChanged) {
    return ChoiceField<ScreeningAnswer>(
      label: label,
      options: ScreeningAnswer.values,
      labelOf: screeningAnswerLabel,
      initialValue: value,
      onChanged: onChanged,
      requiredMessage: 'Choose an answer.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: NSpace.lg),
            child: Text(
              'Some people need advice from a qualified professional before following an automated plan. '
              'These answers decide whether NOURA creates meal and workout plans for you. Only your '
              'answers are stored, and you can change them later in Settings.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          if (widget.afterCompletion)
            Padding(
              padding: const EdgeInsets.only(bottom: NSpace.lg),
              child: Text(
                'Changing an answer can change whether automated plans are available to you.',
                style: theme.textTheme.bodyMedium?.copyWith(color: NColors.onSurfaceVariant),
              ),
            ),
          _question('Are you pregnant or breastfeeding?', _pregnancy, (v) => _pregnancy = v),
          _question(
            'Do you have, or are you recovering from, an eating disorder, or are you worried about your relationship with food?',
            _eating,
            (v) => _eating = v,
          ),
          _question(
            'Have you been told to follow a specific medical diet for a health condition?',
            _medical,
            (v) => _medical = v,
          ),
          FormActions(
            submitLabel: widget.submitLabel,
            saving: saving,
            onSubmit: _submit,
            onBack: widget.onBack,
            failure: failure,
            onReload: reloadLatest,
          ),
        ],
      ),
    );
  }
}
