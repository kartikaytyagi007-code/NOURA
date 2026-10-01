import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../../core/providers.dart';
import '../../core/ui/components/n_text_field.dart';
import '../../core/ui/tokens.dart';
import '../../core/units/units.dart';
import 'form_support.dart';
import 'labels.dart';
import 'timezones.dart';

// Plausibility bounds. They mirror the API contract (the server stays the authority) so the form
// can explain a problem in the user's own units before sending anything.
const double kMinHeightCm = 50;
const double kMaxHeightCm = 272;
const double kMinWeightKg = 20;
const double kMaxWeightKg = 400;

/// Basics: name, age, sex for energy estimates, height, weight, activity and timezone. Shared by
/// onboarding step 1 and Settings > Profile.
class BasicsForm extends ConsumerStatefulWidget {
  const BasicsForm({
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

  /// The onboarding step to record with this save, or null when editing from Settings.
  final OnboardingStep? advanceTo;
  final VoidCallback? onBack;

  @override
  ConsumerState<BasicsForm> createState() => _BasicsFormState();
}

class _BasicsFormState extends ConsumerState<BasicsForm> with SubmitStateMixin<BasicsForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _heightCm;
  late final TextEditingController _heightFt;
  late final TextEditingController _heightIn;
  late final TextEditingController _weight;
  late UnitSystem _units;
  late CalculationSexInput? _sex;
  late ActivityBand? _activity;
  late String _timezone;

  @override
  void initState() {
    super.initState();
    final p = widget.me.profile;
    _units = p.unitSystem;
    _name = TextEditingController(text: p.displayName ?? '');
    _age = TextEditingController(text: p.ageYears?.toString() ?? '');
    _heightCm = TextEditingController();
    _heightFt = TextEditingController();
    _heightIn = TextEditingController();
    _weight = TextEditingController();
    _writeMeasurements(heightCm: p.heightCm?.toDouble(), weightKg: p.weightKg?.toDouble());
    // Basics saved before with no sex means the user declined; never saved means unanswered.
    _sex = switch (p.calculationSex) {
      CalculationSex.female => CalculationSexInput.female,
      CalculationSex.male => CalculationSexInput.male,
      null => p.ageYears == null ? null : CalculationSexInput.declined,
    };
    _activity = p.activityBand;
    final suggested = suggestTimezone(DateTime.now().timeZoneOffset);
    _timezone = p.ageYears == null && p.timezone == 'UTC' && suggested != null ? suggested : p.timezone;
  }

  @override
  void dispose() {
    for (final c in [_name, _age, _heightCm, _heightFt, _heightIn, _weight]) {
      c.dispose();
    }
    super.dispose();
  }

  void _writeMeasurements({double? heightCm, double? weightKg}) {
    if (_units == UnitSystem.metric) {
      _heightCm.text = heightCm == null ? '' : _plain(round1(heightCm));
      _weight.text = weightKg == null ? '' : _plain(round1(weightKg));
      _heightFt.text = '';
      _heightIn.text = '';
    } else {
      if (heightCm == null) {
        _heightFt.text = '';
        _heightIn.text = '';
      } else {
        final parts = cmToFeetInches(heightCm);
        _heightFt.text = parts.feet.toString();
        _heightIn.text = _plain(parts.inches);
      }
      _weight.text = weightKg == null ? '' : _plain(round1(kgToLb(weightKg)));
      _heightCm.text = '';
    }
  }

  static String _plain(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  double? _currentHeightCm() {
    if (_units == UnitSystem.metric) return parseDecimal(_heightCm.text);
    final ft = int.tryParse(_heightFt.text.trim());
    final inches = _heightIn.text.trim().isEmpty ? 0.0 : parseDecimal(_heightIn.text);
    if (ft == null || inches == null) return null;
    return feetInchesToCm(ft, inches);
  }

  double? _currentWeightKg() {
    final value = parseDecimal(_weight.text);
    if (value == null) return null;
    return _units == UnitSystem.metric ? value : lbToKg(value);
  }

  void _switchUnits(UnitSystem next) {
    if (next == _units) return;
    final height = _currentHeightCm();
    final weight = _currentWeightKg();
    setState(() {
      _units = next;
      _writeMeasurements(heightCm: height, weightKg: weight);
    });
  }

  String? _validateName(String? v) {
    final text = (v ?? '').trim();
    if (text.isEmpty) return 'Enter a name.';
    if (text.length > 80) return 'Use 80 characters or fewer.';
    return null;
  }

  String? _validateAge(String? v) {
    final age = int.tryParse((v ?? '').trim());
    if (age == null) return 'Enter your age in whole years.';
    if (age < 1 || age > 120) return 'Enter an age between 1 and 120.';
    return null;
  }

  String? _validateHeight(String? _) {
    final cm = _currentHeightCm();
    if (cm == null) {
      return _units == UnitSystem.metric ? 'Enter your height in cm.' : 'Enter your height in feet and inches.';
    }
    if (cm < kMinHeightCm || cm > kMaxHeightCm) {
      return 'Enter a height between ${formatHeight(kMinHeightCm, _units)} and ${formatHeight(kMaxHeightCm, _units)}.';
    }
    return null;
  }

  String? _validateWeight(String? _) {
    final kg = _currentWeightKg();
    if (kg == null) return _units == UnitSystem.metric ? 'Enter your weight in kg.' : 'Enter your weight in lb.';
    if (kg < kMinWeightKg || kg > kMaxWeightKg) {
      return 'Enter a weight between ${formatWeight(kMinWeightKg, _units)} and ${formatWeight(kMaxWeightKg, _units)}.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final height = round1(_currentHeightCm()!);
    final weight = (_currentWeightKg()! * 100).roundToDouble() / 100;
    final saved = await runSubmit(
      () => ref
          .read(meControllerProvider.notifier)
          .patchProfile(
            (revision) => ProfilePatch(
              expectedRevision: revision,
              displayName: _name.text.trim(),
              ageYears: int.parse(_age.text.trim()),
              calculationSex: _sex,
              heightCm: height,
              weightKg: weight,
              activityBand: _activity,
              timezone: _timezone,
              unitSystem: _units,
              onboardingStep: widget.advanceTo,
            ),
          ),
    );
    if (saved && mounted) widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final timezones = commonTimezones.contains(_timezone) ? commonTimezones : [_timezone, ...commonTimezones];
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NTextField(
            label: 'First name or nickname',
            controller: _name,
            validator: _validateName,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.givenName],
          ),
          const SizedBox(height: NSpace.md),
          NTextField(
            label: 'Age',
            controller: _age,
            validator: _validateAge,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            suffixText: 'years',
          ),
          const SizedBox(height: NSpace.lg),
          ChoiceField<CalculationSexInput>(
            label: 'Sex for calorie estimates',
            hint:
                'Used only in the energy equation, not a statement about gender. If you prefer not to say, '
                'you will see an estimated range instead of a single number.',
            options: CalculationSexInput.values,
            labelOf: (v) => switch (v) {
              CalculationSexInput.female => 'Female',
              CalculationSexInput.male => 'Male',
              CalculationSexInput.declined => 'Prefer not to say',
            },
            initialValue: _sex,
            onChanged: (v) => _sex = v,
            requiredMessage: 'Choose an option.',
          ),
          FormSection(
            title: 'Units',
            child: SegmentedButton<UnitSystem>(
              segments: const [
                ButtonSegment(value: UnitSystem.metric, label: Text('kg · cm')),
                ButtonSegment(value: UnitSystem.imperial, label: Text('lb · ft')),
              ],
              selected: {_units},
              onSelectionChanged: (s) => _switchUnits(s.first),
            ),
          ),
          if (_units == UnitSystem.metric)
            NTextField(
              label: 'Height',
              controller: _heightCm,
              validator: _validateHeight,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              suffixText: 'cm',
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: NTextField(
                    label: 'Height (feet)',
                    controller: _heightFt,
                    validator: _validateHeight,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    suffixText: 'ft',
                  ),
                ),
                const SizedBox(width: NSpace.md),
                Expanded(
                  child: NTextField(
                    label: 'Inches',
                    controller: _heightIn,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    suffixText: 'in',
                  ),
                ),
              ],
            ),
          const SizedBox(height: NSpace.md),
          NTextField(
            label: 'Weight',
            controller: _weight,
            validator: _validateWeight,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            suffixText: _units == UnitSystem.metric ? 'kg' : 'lb',
          ),
          const SizedBox(height: NSpace.lg),
          ChoiceField<ActivityBand>(
            label: 'Activity level',
            options: ActivityBand.values,
            labelOf: activityLabel,
            hintOf: activityHint,
            initialValue: _activity,
            onChanged: (v) => _activity = v,
          ),
          FormSection(
            title: 'Timezone',
            hint: 'Decides where your day starts and ends.',
            child: DropdownButtonFormField<String>(
              initialValue: _timezone,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Timezone'),
              items: [for (final tz in timezones) DropdownMenuItem(value: tz, child: Text(tz.replaceAll('_', ' ')))],
              onChanged: (v) => setState(() => _timezone = v ?? _timezone),
            ),
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
