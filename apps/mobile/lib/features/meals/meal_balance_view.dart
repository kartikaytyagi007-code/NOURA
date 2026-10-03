import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../../core/api/api_failure.dart';
import '../../core/meals/meal_scan_controller.dart';
import '../../core/meals/meal_scan_state.dart';
import '../../core/providers.dart';
import '../../core/ui/components/n_button.dart';
import '../../core/ui/tokens.dart';
import 'fix_my_plate_screen.dart';

/// Meal Balance results step (blueprint §8 step 7, §7 "Meal Balance policy v1"; M5). Shown right
/// after the user confirms items, before anything is logged. Offers "Fix My Plate", a way back to
/// correct items (M5 ticket's "user-correction state" — reuses M4's review screen rather than
/// duplicating it), and logging the meal as confirmed.
class MealBalanceView extends ConsumerStatefulWidget {
  const MealBalanceView({super.key, required this.state});
  final MealScanAnalyzed state;

  @override
  ConsumerState<MealBalanceView> createState() => _MealBalanceViewState();
}

class _MealBalanceViewState extends ConsumerState<MealBalanceView> {
  MealSlot _slot = _defaultSlot();
  bool _saving = false;

  static MealSlot _defaultSlot() {
    final hour = DateTime.now().hour;
    if (hour < 11) return MealSlot.breakfast;
    if (hour < 16) return MealSlot.lunch;
    if (hour < 21) return MealSlot.dinner;
    return MealSlot.snack;
  }

  Future<void> _log() async {
    final me = ref.read(meControllerProvider).value;
    final timezone = me?.profile.timezone ?? 'UTC';
    setState(() => _saving = true);
    try {
      await ref
          .read(mealScanControllerProvider.notifier)
          .logConfirmedMeal(consumedAt: DateTime.now(), timezone: timezone, slot: _slot);
    } on ApiFailure catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final balance = widget.state.analysis.mealBalance;
    final kcal = widget.state.analysis.totals.nutrients.energyKcal;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(NSpace.pageMargin),
            children: [
              const Text('Meal Balance', style: NType.headlineSm),
              const SizedBox(height: NSpace.xs),
              Text(
                kcal == null ? 'Approximate nutrition unavailable.' : 'Approximately ${kcal.round()} kcal.',
                style: const TextStyle(color: NColors.onSurfaceVariant),
              ),
              const SizedBox(height: NSpace.md),
              _BalanceScoreCard(balance: balance),
              const SizedBox(height: NSpace.md),
              if (balance.score != null)
                NButton(
                  label: 'Fix My Plate',
                  icon: Icons.auto_fix_high_outlined,
                  variant: NButtonVariant.secondary,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          FixMyPlateScreen(scanId: widget.state.scanId, expectedRevision: widget.state.revision),
                    ),
                  ),
                ),
              const SizedBox(height: NSpace.sm),
              OutlinedButton.icon(
                onPressed: () => ref.read(mealScanControllerProvider.notifier).backToReview(),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Correct the foods or portions'),
              ),
            ],
          ),
        ),
        SafeArea(
          minimum: const EdgeInsets.all(NSpace.pageMargin),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<MealSlot>(
                  initialValue: _slot,
                  decoration: const InputDecoration(labelText: 'Meal'),
                  items: const [
                    DropdownMenuItem(value: MealSlot.breakfast, child: Text('Breakfast')),
                    DropdownMenuItem(value: MealSlot.lunch, child: Text('Lunch')),
                    DropdownMenuItem(value: MealSlot.dinner, child: Text('Dinner')),
                    DropdownMenuItem(value: MealSlot.snack, child: Text('Snack')),
                  ],
                  onChanged: (v) => setState(() => _slot = v ?? _slot),
                ),
              ),
              const SizedBox(width: NSpace.sm),
              NButton(label: 'Log to diary', onPressed: _saving ? null : _log, loading: _saving),
            ],
          ),
        ),
      ],
    );
  }
}

class _BalanceScoreCard extends StatelessWidget {
  const _BalanceScoreCard({required this.balance});
  final MealBalance balance;

  @override
  Widget build(BuildContext context) {
    if (balance.score == null) {
      return Card(
        color: NColors.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.all(NSpace.sm),
          child: Text(balance.missingDataMessage ?? "A balance score isn't available for this meal yet."),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(NSpace.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${balance.score}', style: NType.headlineSm),
                const Text(' / 100', style: TextStyle(color: NColors.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: NSpace.xs),
            const Text(
              'A balance heuristic, not a medical score.',
              style: TextStyle(color: NColors.onSurfaceVariant, fontSize: 12),
            ),
            const SizedBox(height: NSpace.sm),
            for (final component in balance.components) _ComponentRow(component: component),
          ],
        ),
      ),
    );
  }
}

class _ComponentRow extends StatelessWidget {
  const _ComponentRow({required this.component});
  final MealBalanceComponent component;

  String get _label => switch (component.key) {
    MealBalanceComponentKeyEnum.protein => 'Protein',
    MealBalanceComponentKeyEnum.fibre => 'Fibre',
    MealBalanceComponentKeyEnum.vegetableFruit => 'Vegetable / fruit',
    MealBalanceComponentKeyEnum.variety => 'Variety',
  };

  String get _bandLabel => switch (component.band) {
    MealBalanceComponentBandEnum.low => 'Low',
    MealBalanceComponentBandEnum.adequate => 'Adequate',
    MealBalanceComponentBandEnum.good => 'Good',
    _ => '—',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(_label)),
          Text('${component.score ?? 0}/${component.maxScore}'),
          const SizedBox(width: NSpace.sm),
          Text(_bandLabel, style: const TextStyle(color: NColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}
