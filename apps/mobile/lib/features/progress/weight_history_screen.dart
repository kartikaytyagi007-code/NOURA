import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_failure.dart';
import '../../core/progress/progress_controller.dart';
import '../../core/ui/components/n_button.dart';
import '../../core/ui/components/state_views.dart';
import '../../core/ui/tokens.dart';

/// Weight history: a simple time series the user can log to and review (blueprint §6, §16 M8).
/// Validation (realistic range, no future dates) is enforced server-side; this screen only surfaces
/// the resulting field error honestly rather than guessing at the rule itself.
class WeightHistoryScreen extends ConsumerWidget {
  const WeightHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weightHistoryControllerProvider);
    final controller = ref.read(weightHistoryControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Weight history')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, controller),
        child: const Icon(Icons.add),
      ),
      body: state.when(
        loading: () => const LoadingView(label: 'Loading your weight history'),
        error: (error, _) => ErrorView(
          message: error is ApiFailure ? error.message : 'Something went wrong.',
          offline: error is ApiFailure && error.isOffline,
          onRetry: controller.reload,
        ),
        data: (list) => list.items.isEmpty
            ? const EmptyView(title: 'No weight entries yet', message: 'Tap + to record your first weight entry.')
            : ListView.builder(
                padding: const EdgeInsets.all(NSpace.pageMargin),
                itemCount: list.items.length,
                itemBuilder: (context, index) {
                  final entry = list.items[index];
                  return Dismissible(
                    key: ValueKey(entry.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: NColors.errorContainer,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: NSpace.md),
                      child: const Icon(Icons.delete_outline),
                    ),
                    onDismissed: (_) => controller.deleteEntry(entry.id),
                    child: Card(
                      child: ListTile(
                        title: Text('${entry.weightKg.toStringAsFixed(1)} kg'),
                        subtitle: Text(_formatDate(entry.measuredAt)),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WeightHistoryController controller) async {
    final weightController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Record weight'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Weight (kg)', errorText: errorText),
                autofocus: true,
              ),
              const SizedBox(height: NSpace.sm),
              Row(
                children: [
                  Expanded(child: Text(_formatDate(selectedDate))),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: dialogContext,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => selectedDate = picked);
                    },
                    child: const Text('Change date'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            NButton(
              label: 'Cancel',
              variant: NButtonVariant.text,
              expand: false,
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            NButton(
              label: 'Save',
              expand: false,
              onPressed: () async {
                final weightKg = double.tryParse(weightController.text);
                if (weightKg == null) {
                  setState(() => errorText = 'Enter a number.');
                  return;
                }
                try {
                  await controller.addEntry(measuredAt: selectedDate, weightKg: weightKg);
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                } on ApiFailure catch (error) {
                  setState(() => errorText = error.message);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _formatDate(DateTime date) => '${_months[date.month - 1]} ${date.day}, ${date.year}';
