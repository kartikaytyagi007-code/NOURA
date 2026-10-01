import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_failure.dart';
import '../../core/providers.dart';
import '../../core/ui/components/n_button.dart';
import '../../core/ui/tokens.dart';

/// Shared submit handling for the profile forms: a busy flag, the last failure, and conflict reload.
/// Inputs stay on screen when a save fails, so offline users never lose what they typed.
mixin SubmitStateMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool saving = false;
  ApiFailure? failure;

  /// Runs [action]. Returns true when it completed; false when it failed with an [ApiFailure]
  /// (shown in the banner). Programming errors are not swallowed.
  Future<bool> runSubmit(Future<void> Function() action) async {
    setState(() {
      saving = true;
      failure = null;
    });
    try {
      await action();
      if (mounted) setState(() => saving = false);
      return true;
    } on ApiFailure catch (error) {
      if (mounted) {
        setState(() {
          saving = false;
          failure = error;
        });
      }
      return false;
    }
  }

  Future<void> reloadLatest() async {
    try {
      await ref.read(meControllerProvider.notifier).reload();
      if (mounted) setState(() => failure = null);
    } on ApiFailure catch (error) {
      if (mounted) setState(() => failure = error);
    }
  }
}

/// Shows the last save failure with the right next action.
class FailureBanner extends StatelessWidget {
  const FailureBanner({super.key, required this.failure, required this.onReload});

  final ApiFailure failure;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (title, body) = switch (failure.kind) {
      ApiFailureKind.offline ||
      ApiFailureKind.timeout => ("You're offline", 'Your answers are still here. Check your connection and try again.'),
      ApiFailureKind.conflict => (
        'This changed somewhere else',
        'Load the latest version to continue. Your unsaved changes on this screen will be replaced.',
      ),
      ApiFailureKind.validation => ('Please check your answers', failure.message),
      _ => ('That did not work', failure.message),
    };
    return Semantics(
      liveRegion: true,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(color: NColors.errorContainer, borderRadius: BorderRadius.circular(NRadius.md)),
        child: Padding(
          padding: const EdgeInsets.all(NSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleSmall?.copyWith(color: NColors.onErrorContainer)),
              const SizedBox(height: NSpace.xs),
              Text(body, style: theme.textTheme.bodyMedium?.copyWith(color: NColors.onErrorContainer)),
              for (final field in failure.fieldErrors)
                Padding(
                  padding: const EdgeInsets.only(top: NSpace.xs),
                  child: Text(
                    '• ${field.message}',
                    style: theme.textTheme.bodyMedium?.copyWith(color: NColors.onErrorContainer),
                  ),
                ),
              if (failure.kind == ApiFailureKind.conflict) ...[
                const SizedBox(height: NSpace.sm),
                NButton(label: 'Load latest', onPressed: onReload, variant: NButtonVariant.secondary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A titled block of a form.
class FormSection extends StatelessWidget {
  const FormSection({super.key, required this.title, this.hint, required this.child});

  final String title;
  final String? hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: NSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          if (hint != null)
            Padding(
              padding: const EdgeInsets.only(top: NSpace.xs),
              child: Text(hint!, style: theme.textTheme.bodySmall?.copyWith(color: NColors.onSurfaceVariant)),
            ),
          const SizedBox(height: NSpace.sm),
          child,
        ],
      ),
    );
  }
}

/// Single choice shown as chips, with validation ("Choose one") like any other form field.
class ChoiceField<T> extends FormField<T> {
  ChoiceField({
    super.key,
    required String label,
    String? hint,
    required List<T> options,
    required String Function(T) labelOf,
    String Function(T)? hintOf,
    super.initialValue,
    required ValueChanged<T?> onChanged,
    bool required = true,
    String requiredMessage = 'Choose one.',
  }) : super(
         validator: (value) => required && value == null ? requiredMessage : null,
         builder: (state) {
           final theme = Theme.of(state.context);
           return FormSection(
             title: label,
             hint: hint,
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Wrap(
                   spacing: NSpace.sm,
                   runSpacing: NSpace.xs,
                   children: [
                     for (final option in options)
                       ChoiceChip(
                         label: Text(labelOf(option)),
                         selected: state.value == option,
                         onSelected: (selected) {
                           final next = selected ? option : (required ? state.value : null);
                           state.didChange(next);
                           onChanged(next);
                         },
                       ),
                   ],
                 ),
                 if (hintOf != null && state.value != null)
                   Padding(
                     padding: const EdgeInsets.only(top: NSpace.xs),
                     child: Text(
                       hintOf(state.value as T),
                       style: theme.textTheme.bodySmall?.copyWith(color: NColors.onSurfaceVariant),
                     ),
                   ),
                 if (state.hasError)
                   Padding(
                     padding: const EdgeInsets.only(top: NSpace.xs),
                     child: Text(state.errorText!, style: theme.textTheme.bodySmall?.copyWith(color: NColors.error)),
                   ),
               ],
             ),
           );
         },
       );
}

/// Multiple choice shown as chips. Optionally requires at least one selection.
class MultiChoiceField<T> extends FormField<Set<T>> {
  MultiChoiceField({
    super.key,
    required String label,
    String? hint,
    required List<T> options,
    required String Function(T) labelOf,
    required Set<T> initial,
    required ValueChanged<Set<T>> onChanged,
    bool requireOne = false,
    String requiredMessage = 'Choose at least one.',
  }) : super(
         initialValue: initial,
         validator: (value) => requireOne && (value == null || value.isEmpty) ? requiredMessage : null,
         builder: (state) {
           final theme = Theme.of(state.context);
           final selected = state.value ?? <T>{};
           return FormSection(
             title: label,
             hint: hint,
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Wrap(
                   spacing: NSpace.sm,
                   runSpacing: NSpace.xs,
                   children: [
                     for (final option in options)
                       FilterChip(
                         label: Text(labelOf(option)),
                         selected: selected.contains(option),
                         onSelected: (on) {
                           final next = {...selected};
                           on ? next.add(option) : next.remove(option);
                           state.didChange(next);
                           onChanged(next);
                         },
                       ),
                   ],
                 ),
                 if (state.hasError)
                   Padding(
                     padding: const EdgeInsets.only(top: NSpace.xs),
                     child: Text(state.errorText!, style: theme.textTheme.bodySmall?.copyWith(color: NColors.error)),
                   ),
               ],
             ),
           );
         },
       );
}

/// Primary action plus optional back, with the failure banner above them.
class FormActions extends StatelessWidget {
  const FormActions({
    super.key,
    required this.submitLabel,
    required this.saving,
    required this.onSubmit,
    this.onBack,
    this.failure,
    required this.onReload,
  });

  final String submitLabel;
  final bool saving;
  final VoidCallback onSubmit;
  final VoidCallback? onBack;
  final ApiFailure? failure;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (failure != null) ...[
          FailureBanner(failure: failure!, onReload: onReload),
          const SizedBox(height: NSpace.md),
        ],
        NButton(label: submitLabel, onPressed: onSubmit, loading: saving),
        if (onBack != null) ...[
          const SizedBox(height: NSpace.sm),
          NButton(label: 'Back', onPressed: saving ? null : onBack, variant: NButtonVariant.text),
        ],
      ],
    );
  }
}
