import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../../core/providers.dart';
import '../../core/ui/components/n_text_field.dart';
import '../../core/ui/tokens.dart';
import 'form_support.dart';
import 'labels.dart';

const List<int> kMealsPerDayOptions = [2, 3, 4, 5, 6];

/// Food preferences. Shared by onboarding step 3 and Settings > Food preferences.
class DietForm extends ConsumerStatefulWidget {
  const DietForm({
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
  ConsumerState<DietForm> createState() => _DietFormState();
}

class _DietFormState extends ConsumerState<DietForm> with SubmitStateMixin<DietForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _dislikes;
  late DietType? _diet;
  late Set<AllergyTag> _allergies;
  late Set<ExclusionTag> _exclusions;
  late Set<CuisineTag> _cuisines;
  late BudgetBand? _budget;
  late CookingTime? _cooking;
  late int? _meals;

  @override
  void initState() {
    super.initState();
    final p = widget.me.preferences;
    _diet = p?.dietType;
    _allergies = knownTags(p?.allergyIds ?? const [], AllergyTag.values, (t) => t.value);
    _exclusions = knownTags(p?.exclusionIds ?? const [], ExclusionTag.values, (t) => t.value);
    _cuisines = knownTags(p?.cuisines ?? const [], CuisineTag.values, (t) => t.value);
    _budget = p?.budgetBand;
    _cooking = p?.cookingTime;
    _meals = p?.mealsPerDay;
    _dislikes = TextEditingController(text: (p?.dislikes ?? const []).join(', '));
  }

  @override
  void dispose() {
    _dislikes.dispose();
    super.dispose();
  }

  Set<String> _parseDislikes() => {
    for (final part in _dislikes.text.split(','))
      if (part.trim().isNotEmpty) part.trim(),
  };

  String? _validateDislikes(String? _) {
    final items = _parseDislikes();
    if (items.length > 50) return 'List up to 50 foods.';
    if (items.any((e) => e.length > 80)) return 'Keep each food under 80 characters.';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = ref.read(meControllerProvider.notifier);
    final saved = await runSubmit(() async {
      await controller.savePreferences(
        (revision) => PreferencesInput(
          expectedRevision: revision,
          dietType: _diet!,
          allergyIds: _allergies,
          exclusionIds: _exclusions,
          dislikes: _parseDislikes(),
          cuisines: _cuisines,
          budgetBand: _budget!,
          cookingTime: _cooking!,
          mealsPerDay: _meals!,
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
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ChoiceField<DietType>(
            label: 'How do you eat?',
            options: DietType.values,
            labelOf: dietLabel,
            initialValue: _diet,
            onChanged: (v) => _diet = v,
          ),
          MultiChoiceField<AllergyTag>(
            label: 'Allergies',
            hint: 'Choose any that apply. Plans will avoid them. This is a food filter, not medical advice.',
            options: AllergyTag.values,
            labelOf: allergyLabel,
            initial: _allergies,
            onChanged: (v) => _allergies = v,
          ),
          MultiChoiceField<ExclusionTag>(
            label: 'Foods you do not eat',
            options: ExclusionTag.values,
            labelOf: exclusionLabel,
            initial: _exclusions,
            onChanged: (v) => _exclusions = v,
          ),
          NTextField(
            label: 'Other foods you dislike (optional)',
            controller: _dislikes,
            validator: _validateDislikes,
            helperText: 'Separate with commas.',
          ),
          const SizedBox(height: NSpace.lg),
          MultiChoiceField<CuisineTag>(
            label: 'Cuisines you enjoy',
            options: CuisineTag.values,
            labelOf: cuisineLabel,
            initial: _cuisines,
            onChanged: (v) => _cuisines = v,
          ),
          ChoiceField<BudgetBand>(
            label: 'Food budget',
            options: BudgetBand.values,
            labelOf: budgetLabel,
            initialValue: _budget,
            onChanged: (v) => _budget = v,
          ),
          ChoiceField<CookingTime>(
            label: 'Time you can spend cooking',
            options: CookingTime.values,
            labelOf: cookingLabel,
            initialValue: _cooking,
            onChanged: (v) => _cooking = v,
          ),
          ChoiceField<int>(
            label: 'Meals per day',
            options: kMealsPerDayOptions,
            labelOf: (v) => '$v',
            initialValue: _meals,
            onChanged: (v) => _meals = v,
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
