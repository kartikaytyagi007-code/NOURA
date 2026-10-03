import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../../core/api/api_failure.dart';
import '../../core/meals/meal_scan_controller.dart';
import '../../core/meals/meal_scan_state.dart';
import '../../core/ui/components/n_button.dart';
import '../../core/ui/components/state_views.dart';
import '../../core/ui/tokens.dart';
import 'meal_balance_view.dart';

/// Camera/gallery capture, upload, processing, results, correction and error states for one meal
/// scan (blueprint §8, M4 ticket). The screen is a thin view over [MealScanController]'s state
/// machine; it never computes nutrition itself.
class MealScanScreen extends ConsumerWidget {
  const MealScanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mealScanControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Scan a meal')),
      body: switch (state) {
        MealScanIdle() => const _CaptureView(),
        MealScanUploading() => const LoadingView(label: 'Uploading photo'),
        MealScanProcessing() => const LoadingView(label: 'Analyzing your meal'),
        MealScanReviewing() => _ReviewView(state: state),
        MealScanAnalyzed() => MealBalanceView(state: state),
        MealScanSaving() => const LoadingView(label: 'Saving'),
        MealScanSaved(log: final log) => _SavedView(log: log),
        MealScanFailed() => _FailedView(state: state),
      },
    );
  }
}

ImageMime _mimeFor(XFile file) {
  final path = file.path.toLowerCase();
  if (path.endsWith('.png')) return ImageMime.imageSlashPng;
  if (path.endsWith('.webp')) return ImageMime.imageSlashWebp;
  return ImageMime.imageSlashJpeg;
}

class _CaptureView extends ConsumerWidget {
  const _CaptureView();

  Future<void> _pick(WidgetRef ref, ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, maxWidth: 2048, maxHeight: 2048, imageQuality: 90);
    if (file == null) return;
    final Uint8List bytes = await file.readAsBytes();
    await ref.read(mealScanControllerProvider.notifier).captureAndAnalyze(bytes, mime: _mimeFor(file));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt_outlined, size: 48, color: NColors.secondary),
            const SizedBox(height: NSpace.md),
            const Text('Take or choose a photo of your meal', style: NType.headlineSm, textAlign: TextAlign.center),
            const SizedBox(height: NSpace.sm),
            const Text(
              'We identify foods and estimate portions; you confirm before it is saved.',
              textAlign: TextAlign.center,
              style: TextStyle(color: NColors.onSurfaceVariant),
            ),
            const SizedBox(height: NSpace.lg),
            NButton(label: 'Take photo', icon: Icons.camera_alt, onPressed: () => _pick(ref, ImageSource.camera)),
            const SizedBox(height: NSpace.sm),
            NButton(
              label: 'Choose from gallery',
              icon: Icons.photo_library_outlined,
              variant: NButtonVariant.secondary,
              onPressed: () => _pick(ref, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}

class _FailedView extends ConsumerWidget {
  const _FailedView({required this.state});
  final MealScanFailed state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MessageView(
      icon: state.notFood ? Icons.no_food_outlined : Icons.error_outline,
      title: state.notFood ? 'No food recognized' : 'Scan failed',
      message: state.message,
      actionLabel: state.retryable ? 'Try again' : null,
      onAction: state.retryable ? () => ref.read(mealScanControllerProvider.notifier).reset() : null,
      secondaryLabel: state.retryable ? null : 'Back',
      onSecondary: state.retryable ? null : () => ref.read(mealScanControllerProvider.notifier).reset(),
    );
  }
}

class _SavedView extends ConsumerWidget {
  const _SavedView({required this.log});
  final MealLog log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kcal = log.totals.nutrients.energyKcal;
    return MessageView(
      icon: Icons.check_circle_outline,
      title: 'Meal logged',
      message: kcal == null ? 'Saved to your diary.' : 'Saved to your diary (${kcal.round()} kcal).',
      actionLabel: 'Scan another',
      onAction: () => ref.read(mealScanControllerProvider.notifier).reset(),
      secondaryLabel: 'Done',
      onSecondary: () => Navigator.of(context).maybePop(),
    );
  }
}

class _ReviewView extends ConsumerStatefulWidget {
  const _ReviewView({required this.state});
  final MealScanReviewing state;

  @override
  ConsumerState<_ReviewView> createState() => _ReviewViewState();
}

class _ReviewViewState extends ConsumerState<_ReviewView> {
  bool _saving = false;

  Future<void> _confirm() async {
    setState(() => _saving = true);
    try {
      await ref.read(mealScanControllerProvider.notifier).confirmItems();
    } on ApiFailure catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _editGrams(ReviewItem item) async {
    final controller = TextEditingController(text: item.grams?.round().toString() ?? '');
    final result = await showDialog<num>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.label),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: 'g', labelText: 'Grams'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, num.tryParse(controller.text)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) {
      ref.read(mealScanControllerProvider.notifier).updateItem(item.temporaryId, grams: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.state.items.where((i) => !i.removed).toList();
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(NSpace.pageMargin),
            children: [
              if (widget.state.clarification != null) ...[
                Card(
                  color: NColors.surfaceContainer,
                  child: Padding(padding: const EdgeInsets.all(NSpace.sm), child: Text(widget.state.clarification!)),
                ),
                const SizedBox(height: NSpace.md),
              ],
              const Text('Review what we found', style: NType.headlineSm),
              const SizedBox(height: NSpace.xs),
              const Text(
                'Edit anything that looks wrong before you save it to your diary.',
                style: TextStyle(color: NColors.onSurfaceVariant),
              ),
              const SizedBox(height: NSpace.md),
              for (final item in items) _ReviewItemTile(item: item, onEditGrams: () => _editGrams(item)),
              const SizedBox(height: NSpace.sm),
              OutlinedButton.icon(
                onPressed: () => _promptAddItem(context),
                icon: const Icon(Icons.add),
                label: const Text('Add a missed item'),
              ),
            ],
          ),
        ),
        SafeArea(
          minimum: const EdgeInsets.all(NSpace.pageMargin),
          child: NButton(
            label: items.isEmpty ? 'Add at least one item' : 'See Meal Balance',
            onPressed: items.isEmpty ? null : _confirm,
            loading: _saving,
          ),
        ),
      ],
    );
  }

  Future<void> _promptAddItem(BuildContext context) async {
    final controller = TextEditingController();
    final label = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add an item'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'What is it?'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Add')),
        ],
      ),
    );
    if (label != null && label.isNotEmpty) {
      ref.read(mealScanControllerProvider.notifier).addManualItem(label);
    }
  }
}

class _ReviewItemTile extends ConsumerWidget {
  const _ReviewItemTile({required this.item, required this.onEditGrams});
  final ReviewItem item;
  final VoidCallback onEditGrams;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unmatched = item.uncertainty == Uncertainty.high;
    return Card(
      margin: const EdgeInsets.only(bottom: NSpace.sm),
      child: ListTile(
        contentPadding: const EdgeInsets.all(NSpace.sm),
        title: Text(item.label),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.grams == null ? 'Portion not set' : '${item.grams!.round()} g'),
            if (item.needsConfirmation)
              const Text('Needs your confirmation', style: TextStyle(color: NColors.tertiary)),
            if (unmatched)
              const Text(
                "Not in our food catalog yet — nutrition won't be included for this item.",
                style: TextStyle(color: NColors.outline),
              ),
          ],
        ),
        isThreeLine: item.needsConfirmation || unmatched,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEditGrams),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Remove',
              onPressed: () => ref.read(mealScanControllerProvider.notifier).removeItem(item.temporaryId),
            ),
          ],
        ),
      ),
    );
  }
}
