import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../../core/api/api_failure.dart';
import '../../core/providers.dart';
import '../../core/telemetry/telemetry_provider.dart';
import '../../core/ui/components/n_button.dart';
import '../../core/ui/components/state_views.dart';
import '../../core/ui/tokens.dart';

/// Subscription status and restore-purchases (blueprint §13). The app never decides premium access
/// itself: everything shown here is exactly what the server last verified with the billing provider.
/// There is no "buy" button — presenting a real purchase sheet needs the RevenueCat `purchases_flutter`
/// SDK wired against a real store/RevenueCat project, which this build does not have (see
/// docs/release-checklist.md); "Restore purchases" still works end-to-end against the mock/real
/// billing provider the API is configured with.
class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  Entitlements? _entitlements;
  Usage? _usage;
  Object? _error;
  bool _restoring = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final repo = ref.read(billingRepositoryProvider);
      final results = await (repo.fetchEntitlements(), repo.fetchUsage()).wait;
      if (!mounted) return;
      setState(() {
        _entitlements = results.$1;
        _usage = results.$2;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  Future<void> _restore() async {
    setState(() => _restoring = true);
    try {
      final entitlements = await ref.read(billingRepositoryProvider).restorePurchases();
      if (!mounted) return;
      setState(() {
        _entitlements = entitlements;
        _restoring = false;
      });
      ref.read(telemetryProvider).logEvent(TelemetryEvent.restorePurchasesTapped);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Purchases restored and synced')));
    } on ApiFailure catch (error) {
      if (!mounted) return;
      setState(() => _restoring = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  bool get _isPremium =>
      _entitlements?.entitlements.any((entitlement) => entitlement.key == 'premium' && entitlement.isActive) ?? false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Purchases')),
        body: ErrorView(message: 'Could not load subscription status', onRetry: _load),
      );
    }
    final usage = _usage;
    if (usage == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Purchases')),
        body: const LoadingView(),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Purchases')),
      body: ListView(
        padding: const EdgeInsets.all(NSpace.pageMargin),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(NSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_isPremium ? 'Premium' : 'Free', style: theme.textTheme.titleLarge),
                  const SizedBox(height: NSpace.xs),
                  Text(
                    _isPremium
                        ? 'Verified by the server from your active subscription.'
                        : 'Upgrade through the app store to unlock higher daily limits.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: NColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: NSpace.lg),
          Text('Today\'s usage', style: theme.textTheme.titleMedium),
          const SizedBox(height: NSpace.sm),
          Card(
            child: Column(
              children: [
                for (final feature in usage.features)
                  ListTile(
                    title: Text(_featureLabel(feature.feature)),
                    trailing: Text(
                      feature.limit == null ? '${feature.used} used' : '${feature.used} / ${feature.limit}',
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: NSpace.lg),
          NButton(label: 'Restore purchases', loading: _restoring, onPressed: _restore),
        ],
      ),
    );
  }

  String _featureLabel(FeatureUsageFeatureEnum feature) => switch (feature) {
    FeatureUsageFeatureEnum.mealScan => 'Meal scans',
    FeatureUsageFeatureEnum.coachReply => 'Coach messages',
    FeatureUsageFeatureEnum.dietPlan => 'Diet plans',
    FeatureUsageFeatureEnum.workoutPlan => 'Workout plans',
    FeatureUsageFeatureEnum.planRegeneration => 'Plan regenerations',
  };
}
