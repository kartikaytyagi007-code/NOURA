import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../../core/providers.dart';
import '../../core/ui/components/n_text_field.dart';
import '../../core/ui/tokens.dart';
import '../../core/units/units.dart';
import 'basics_form.dart' show kMaxWeightKg, kMinWeightKg;
import 'form_support.dart';
import 'labels.dart';

/// Goal: type and an optional target weight. Shared by onboarding step 2 and Settings > Goal.
class GoalForm extends ConsumerStatefulWidget {
  const GoalForm({
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
  ConsumerState<GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends ConsumerState<GoalForm> with SubmitStateMixin<GoalForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _target;
  late GoalType? _type;

  UnitSystem get _units => widget.me.profile.unitSystem;
  double? get _currentKg => widget.me.profile.weightKg?.toDouble();

  @override
  void initState() {
    super.initState();
    _type = widget.me.goal?.goalType;
    final kg = widget.me.goal?.targetWeightKg?.toDouble();
    _target = TextEditingController(
      text: kg == null
          ? ''
          : (_units == UnitSystem.metric ? round1(kg) : round1(kgToLb(kg))).toString().replaceAll(RegExp(r'\.0$'), ''),
    );
  }

  @override
  void dispose() {
    _target.dispose();
    super.dispose();
  }

  double? _targetKg() {
    final value = parseDecimal(_target.text);
    if (value == null) return null;
    return _units == UnitSystem.metric ? value : lbToKg(value);
  }

  String? _validateTarget(String? v) {
    if ((v ?? '').trim().isEmpty) return null; // optional
    final kg = _targetKg();
    if (kg == null) return 'Enter a number, or leave this empty.';
    if (kg < kMinWeightKg || kg > kMaxWeightKg) {
      return 'Enter a weight between ${formatWeight(kMinWeightKg, _units)} and ${formatWeight(kMaxWeightKg, _units)}.';
    }
    final current = _currentKg;
    if (current != null) {
      if (_type == GoalType.loseFat && kg >= current) {
        return 'For fat loss, the target must be below your current weight (${formatWeight(current, _units)}).';
      }
      if (_type == GoalType.gainMuscle && kg <= current) {
        return 'For muscle gain, the target must be above your current weight (${formatWeight(current, _units)}).';
      }
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final kg = _targetKg();
    final saved = await runSubmit(
      () => ref
          .read(meControllerProvider.notifier)
          .patchProfile(
            (revision) => ProfilePatch(
              expectedRevision: revision,
              primaryGoal: GoalInput(
                goalType: _type!,
                targetWeightKg: kg == null ? null : (kg * 100).roundToDouble() / 100,
              ),
              onboardingStep: widget.advanceTo,
            ),
          ),
    );
    if (saved && mounted) widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ChoiceField<GoalType>(
            label: 'Your main goal',
            options: GoalType.values,
            labelOf: goalLabel,
            initialValue: _type,
            onChanged: (v) => setState(() => _type = v),
          ),
          NTextField(
            label: 'Target weight (optional)',
            controller: _target,
            validator: _validateTarget,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            suffixText: _units == UnitSystem.metric ? 'kg' : 'lb',
            helperText: 'You can change this at any time.',
          ),
          const SizedBox(height: NSpace.lg),
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
