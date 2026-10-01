import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../../core/api/api_failure.dart';
import '../../core/profile/profile_repository.dart';
import '../../core/providers.dart';
import '../../core/ui/tokens.dart';
import '../../core/units/units.dart';
import '../profile/form_support.dart';
import '../profile/labels.dart';

/// The consents required to finish onboarding. Optional consents (meal photos, progress photos)
/// are asked where they are used.
const requiredConsents = <({ConsentType type, String label})>[
  (type: ConsentType.terms, label: 'I agree to the Terms of Service'),
  (type: ConsentType.privacy, label: 'I have read the Privacy Policy'),
  (type: ConsentType.healthDataProcessing, label: 'I agree to NOURA processing the health data I enter'),
];

/// Explains an eligibility outcome in neutral terms. Copy is provisional pending legal and clinical
/// review (docs/decisions.md D-019); it makes no medical claim.
({String title, String body})? eligibilityNotice(EligibilityStatus? status) => switch (status) {
  EligibilityStatus.trackingOnly => (
    title: 'Tracking only',
    body:
        'Based on your answers, NOURA will not create automated meal or workout plans for you. You can still '
        'log meals and workouts and follow your progress.',
  ),
  EligibilityStatus.needsReview => (
    title: 'Plans are off for now',
    body:
        'You chose not to answer a screening question, so NOURA cannot confirm automated plans are suitable. '
        'Tracking is available now, and you can update your answers any time in Settings.',
  ),
  _ => null,
};

/// Final onboarding step: a summary in the user's units, the eligibility outcome, consent, and the
/// one action that completes onboarding. Completing is a single server transaction; if plan
/// generation fails later, the profile stays saved.
class ReviewStep extends ConsumerStatefulWidget {
  const ReviewStep({super.key, required this.me, this.onBack});

  final Me me;
  final VoidCallback? onBack;

  @override
  ConsumerState<ReviewStep> createState() => _ReviewStepState();
}

class _ReviewStepState extends ConsumerState<ReviewStep> with SubmitStateMixin<ReviewStep> {
  final Set<ConsentType> _accepted = {};
  String _key = newIdempotencyKey();
  String? _consentError;

  void _toggle(ConsentType type, bool on) {
    setState(() {
      on ? _accepted.add(type) : _accepted.remove(type);
      _consentError = null;
      // A different request body needs a different idempotency key.
      _key = newIdempotencyKey();
    });
  }

  Future<void> _complete() async {
    if (requiredConsents.any((c) => !_accepted.contains(c.type))) {
      setState(() => _consentError = 'Please accept all three to continue.');
      return;
    }
    final controller = ref.read(meControllerProvider.notifier);
    var alreadyComplete = false;
    final ok = await runSubmit(() async {
      try {
        await controller.completeOnboarding([
          for (final c in requiredConsents) ConsentInput(consentType: c.type, version: kDraftConsentVersion),
        ], idempotencyKey: _key);
      } on ApiFailure catch (error) {
        // A lost response can leave onboarding completed on the server: reload to find out.
        if (error.code == 'CONSTRAINT_CONFLICT') {
          alreadyComplete = true;
        } else {
          rethrow;
        }
      }
    });
    if (ok && alreadyComplete) await reloadLatest();
    if (!ok && failure != null && failure!.kind != ApiFailureKind.conflict && !failure!.retryable) {
      // The server rejected this exact request; the next attempt is a new one.
      _key = newIdempotencyKey();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final me = widget.me;
    final p = me.profile;
    final units = p.unitSystem;
    final notice = eligibilityNotice(me.eligibilityStatus);
    final rows = <(String, String)>[
      ('Name', p.displayName ?? 'Not set'),
      ('Age', p.ageYears == null ? 'Not set' : '${p.ageYears} years'),
      ('Height', p.heightCm == null ? 'Not set' : formatHeight(p.heightCm!.toDouble(), units)),
      ('Weight', p.weightKg == null ? 'Not set' : formatWeight(p.weightKg!.toDouble(), units)),
      ('Activity', p.activityBand == null ? 'Not set' : activityLabel(p.activityBand!)),
      ('Timezone', p.timezone.replaceAll('_', ' ')),
      ('Goal', me.goal == null ? 'Not set' : goalLabel(me.goal!.goalType)),
      if (me.goal?.targetWeightKg != null) ('Target weight', formatWeight(me.goal!.targetWeightKg!.toDouble(), units)),
      ('Diet', me.preferences?.dietType == null ? 'Not set' : dietLabel(me.preferences!.dietType!)),
      (
        'Training',
        me.trainingPreferences?.daysPerWeek == null
            ? 'Not set'
            : '${me.trainingPreferences!.daysPerWeek} days a week, ${me.trainingPreferences!.durationMinutes} min',
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(NSpace.md),
            child: Column(
              children: [
                for (final (label, value) in rows)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: NSpace.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 112,
                          child: Text(
                            label,
                            style: theme.textTheme.bodyMedium?.copyWith(color: NColors.onSurfaceVariant),
                          ),
                        ),
                        Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: NSpace.md),
        if (notice != null) ...[
          Semantics(
            container: true,
            child: DecoratedBox(
              decoration: BoxDecoration(color: NColors.tonalInset, borderRadius: BorderRadius.circular(NRadius.md)),
              child: Padding(
                padding: const EdgeInsets.all(NSpace.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notice.title, style: theme.textTheme.titleSmall),
                    const SizedBox(height: NSpace.xs),
                    Text(notice.body, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: NSpace.md),
        ],
        Text('Before you start', style: theme.textTheme.titleMedium),
        const SizedBox(height: NSpace.xs),
        Text(
          'Draft placeholder wording. The final legal documents are pending review.',
          style: theme.textTheme.bodySmall?.copyWith(color: NColors.onSurfaceVariant),
        ),
        for (final c in requiredConsents)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _accepted.contains(c.type),
            title: Text(c.label),
            onChanged: saving ? null : (v) => _toggle(c.type, v ?? false),
          ),
        if (_consentError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: NSpace.sm),
            child: Text(_consentError!, style: theme.textTheme.bodySmall?.copyWith(color: NColors.error)),
          ),
        const SizedBox(height: NSpace.md),
        FormActions(
          submitLabel: 'Finish setup',
          saving: saving,
          onSubmit: _complete,
          onBack: widget.onBack,
          failure: failure,
          onReload: reloadLatest,
        ),
      ],
    );
  }
}
