import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../../core/providers.dart';
import '../../core/ui/tokens.dart';
import 'form_support.dart';
import 'labels.dart';

const List<int> kSessionMinutesOptions = [20, 30, 45, 60, 90];

/// Training preferences. Shared by onboarding step 4 and Settings > Training.
class TrainingForm extends ConsumerStatefulWidget {
  const TrainingForm({
    super.key,
    required this.me,
    required this.submitLabel,
    required this.onSaved,
    this.advanceTo,
    this.onBack,
  });

  final Me me;
  final String submitLabel;
  final VoidCallback onSaved;
  final OnboardingStep? advanceTo;
  final VoidCallback? onBack;

  @override
  ConsumerState<TrainingForm> createState() => _TrainingFormState();
}

class _TrainingFormState extends ConsumerState<TrainingForm> with SubmitStateMixin<TrainingForm> {
  final _formKey = GlobalKey<FormState>();
  late ExperienceLevel? _experience;
  late TrainingLocation? _location;
  late Set<EquipmentTag> _equipment;
  late Set<int> _weekdays;
  late int? _days;
  late int? _minutes;
  late Set<LimitationTag> _limits;
  String? _weekdayError;

  @override
  void initState() {
    super.initState();
    final t = widget.me.trainingPreferences;
    _experience = t?.experience;
    _location = t?.location;
    _equipment = knownTags(t?.equipmentIds ?? const [], EquipmentTag.values, (v) => v.value);
    _weekdays = {...?t?.weekdays};
    _days = t?.daysPerWeek;
    _minutes = t?.durationMinutes;
    _limits = knownTags(t?.limitationTags ?? const [], LimitationTag.values, (v) => v.value);
  }

  bool _validateExtra() {
    String? error;
    if (_weekdays.isEmpty) {
      error = 'Choose the days you can train.';
    } else if (_days != null && _weekdays.length < _days!) {
      error = 'Choose at least $_days days to train $_days days a week.';
    }
    setState(() => _weekdayError = error);
    return error == null;
  }

  Future<void> _submit() async {
    final fieldsOk = _formKey.currentState!.validate();
    final extraOk = _validateExtra();
    if (!fieldsOk || !extraOk) return;
    final controller = ref.read(meControllerProvider.notifier);
    final saved = await runSubmit(() async {
      await controller.saveTraining(
        (revision) => TrainingPreferencesInput(
          expectedRevision: revision,
          experience: _experience!,
          location: _location!,
          equipmentIds: _equipment,
          weekdays: _weekdays,
          daysPerWeek: _days!,
          durationMinutes: _minutes!,
          limitationTags: _limits,
        ),
      );
      final step = widget.advanceTo;
      if (step != null) {
        await controller.patchProfile((revision) => ProfilePatch(expectedRevision: revision, onboardingStep: step));
      }
    });
    if (saved && mounted) widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final needsEquipment = _location != null && _location != TrainingLocation.gym;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ChoiceField<ExperienceLevel>(
            label: 'Training experience',
            options: ExperienceLevel.values,
            labelOf: experienceLabel,
            initialValue: _experience,
            onChanged: (v) => _experience = v,
          ),
          ChoiceField<TrainingLocation>(
            label: 'Where do you train?',
            options: TrainingLocation.values,
            labelOf: locationLabel,
            initialValue: _location,
            onChanged: (v) => setState(() => _location = v),
          ),
          if (needsEquipment)
            MultiChoiceField<EquipmentTag>(
              label: 'Equipment you have at home',
              hint: 'Choose "Bodyweight only" if you have none.',
              options: EquipmentTag.values,
              labelOf: equipmentLabel,
              initial: _equipment,
              requireOne: true,
              requiredMessage: 'Choose your equipment, or "Bodyweight only".',
              onChanged: (v) => _equipment = v,
            ),
          FormSection(
            title: 'Days you can train',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: NSpace.sm,
                  runSpacing: NSpace.xs,
                  children: [
                    for (var day = 1; day <= 7; day++)
                      FilterChip(
                        label: Text(weekdayShortNames[day - 1]),
                        selected: _weekdays.contains(day),
                        onSelected: (on) => setState(() {
                          on ? _weekdays.add(day) : _weekdays.remove(day);
                          _weekdayError = null;
                        }),
                      ),
                  ],
                ),
                if (_weekdayError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: NSpace.xs),
                    child: Text(_weekdayError!, style: theme.textTheme.bodySmall?.copyWith(color: NColors.error)),
                  ),
              ],
            ),
          ),
          ChoiceField<int>(
            label: 'Sessions per week',
            options: const [1, 2, 3, 4, 5, 6, 7],
            labelOf: (v) => '$v',
            initialValue: _days,
            onChanged: (v) => setState(() => _days = v),
          ),
          ChoiceField<int>(
            label: 'Session length',
            options: kSessionMinutesOptions,
            labelOf: (v) => '$v min',
            initialValue: _minutes,
            onChanged: (v) => _minutes = v,
          ),
          MultiChoiceField<LimitationTag>(
            label: 'Areas to go easy on (optional)',
            hint: 'Exercises will favour gentler options. This is not a medical assessment.',
            options: LimitationTag.values,
            labelOf: limitationLabel,
            initial: _limits,
            onChanged: (v) => _limits = v,
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
