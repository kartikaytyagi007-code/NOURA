import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/api/api_failure.dart';
import '../../core/providers.dart';
import '../../core/telemetry/telemetry_provider.dart';
import '../../core/ui/components/n_button.dart';
import '../../core/ui/tokens.dart';

/// Export and delete account (blueprint §14). Both actions are 202-accepted async jobs: this screen
/// only starts them and reports what the server says, never a locally-fabricated "done" state.
/// Deletion is irreversible and asks for an explicit confirmation before the request is sent; the
/// server itself also requires a recently-issued token (see apps/api's `requireRecentAuth`), so a
/// stale session is rejected even if this confirmation is bypassed.
class AccountDataScreen extends ConsumerStatefulWidget {
  const AccountDataScreen({super.key});

  @override
  ConsumerState<AccountDataScreen> createState() => _AccountDataScreenState();
}

class _AccountDataScreenState extends ConsumerState<AccountDataScreen> {
  bool _exporting = false;
  bool _deleting = false;
  String? _exportStatus;

  Future<void> _requestExport() async {
    setState(() => _exporting = true);
    try {
      final accepted = await ref.read(accountRepositoryProvider).requestExport();
      ref.read(telemetryProvider).logEvent(TelemetryEvent.accountExportRequested);
      if (!mounted) return;
      setState(() {
        _exporting = false;
        _exportStatus =
            'Export requested (job ${accepted.jobId}). We\'ll prepare your data in the '
            'background; check back here shortly.';
      });
    } on ApiFailure catch (error) {
      if (!mounted) return;
      setState(() => _exporting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _confirmAndDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text('This permanently deletes your profile, plans, logs and photos, and cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete my account')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await ref.read(accountRepositoryProvider).deleteAccount();
      ref.read(telemetryProvider).logEvent(TelemetryEvent.accountDeletionRequested);
      if (!mounted) return;
      await ref.read(authRepositoryProvider).signOut();
      if (!mounted) return;
      context.go(Routes.welcome);
    } on ApiFailure catch (error) {
      if (!mounted) return;
      setState(() => _deleting = false);
      final message = error.kind == ApiFailureKind.unauthenticated
          ? 'Please sign in again and retry to confirm this is really you.'
          : error.message;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Export and delete account')),
      body: ListView(
        padding: const EdgeInsets.all(NSpace.pageMargin),
        children: [
          Text('Export your data', style: theme.textTheme.titleMedium),
          const SizedBox(height: NSpace.sm),
          Text(
            'Includes your profile, plans, logs and a manifest of your photos. Never includes '
            'passwords or provider secrets.',
            style: theme.textTheme.bodyMedium?.copyWith(color: NColors.onSurfaceVariant),
          ),
          const SizedBox(height: NSpace.sm),
          NButton(label: 'Request data export', loading: _exporting, onPressed: _requestExport),
          if (_exportStatus != null) ...[
            const SizedBox(height: NSpace.sm),
            Text(_exportStatus!, style: theme.textTheme.bodySmall),
          ],
          const SizedBox(height: NSpace.xl),
          Text('Delete account', style: theme.textTheme.titleMedium),
          const SizedBox(height: NSpace.sm),
          Text(
            'Permanently deletes your account and all associated data. This cannot be undone.',
            style: theme.textTheme.bodyMedium?.copyWith(color: NColors.onSurfaceVariant),
          ),
          const SizedBox(height: NSpace.sm),
          NButton(
            label: 'Delete my account',
            variant: NButtonVariant.secondary,
            loading: _deleting,
            onPressed: _confirmAndDelete,
          ),
        ],
      ),
    );
  }
}
