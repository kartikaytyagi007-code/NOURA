import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../../core/api/api_failure.dart';
import '../../core/providers.dart';
import '../../core/telemetry/telemetry_provider.dart';
import '../../core/ui/components/n_button.dart';
import '../../core/ui/components/state_views.dart';
import '../../core/ui/tokens.dart';

/// Local meal/workout reminders (blueprint §18). These are device-local notifications only — opting
/// in here never registers a push token with any server, because there is no push infrastructure in
/// V1. Turning a toggle on records consent and the chosen time on the server (so the preference
/// follows the signed-in user across devices); actually showing the OS notification is
/// [ReminderScheduler]'s job and is a no-op in this build (see docs/release-checklist.md).
class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  NotificationPreferences? _prefs;
  Object? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final prefs = await ref.read(notificationsRepositoryProvider).fetch();
      if (mounted) setState(() => _prefs = prefs);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  Future<void> _save({bool? meal, bool? workout, String? mealTime, String? workoutTime}) async {
    final current = _prefs;
    if (current == null || _saving) return;
    final mealEnabled = meal ?? current.mealRemindersEnabled;
    final workoutEnabled = workout ?? current.workoutRemindersEnabled;
    final grantingConsent = current.consentGrantedAt == null && (mealEnabled || workoutEnabled);
    setState(() => _saving = true);
    try {
      final saved = await ref
          .read(notificationsRepositoryProvider)
          .save(
            NotificationPreferencesInput(
              expectedRevision: current.revision,
              mealRemindersEnabled: mealEnabled,
              workoutRemindersEnabled: workoutEnabled,
              mealReminderTime: mealTime ?? current.mealReminderTime,
              workoutReminderTime: workoutTime ?? current.workoutReminderTime,
              consentGrantedAt: grantingConsent ? DateTime.now().toUtc() : null,
            ),
          );
      if (!mounted) return;
      setState(() {
        _prefs = saved;
        _saving = false;
      });
      final telemetry = ref.read(telemetryProvider);
      telemetry.logEvent(
        mealEnabled || workoutEnabled ? TelemetryEvent.reminderOptedIn : TelemetryEvent.reminderOptedOut,
      );
      // Best-effort: scheduling failures never block saving the preference itself.
      final me = ref.read(meControllerProvider).value;
      await ref.read(reminderSchedulerProvider).applyPreferences(saved, timezone: me?.profile.timezone ?? 'UTC');
    } on ApiFailure catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = _prefs;
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: _error != null
          ? ErrorView(message: 'Could not load reminders', onRetry: _load)
          : prefs == null
          ? const LoadingView()
          : ListView(
              padding: const EdgeInsets.all(NSpace.pageMargin),
              children: [
                Text(
                  'Reminders are local notifications on this device only. Nothing is sent to a push '
                  'server, and you can turn them off at any time.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: NColors.onSurfaceVariant),
                ),
                const SizedBox(height: NSpace.lg),
                SwitchListTile(
                  title: const Text('Meal reminders'),
                  subtitle: Text(prefs.mealReminderTime ?? 'Default time'),
                  value: prefs.mealRemindersEnabled,
                  onChanged: _saving ? null : (value) => _save(meal: value),
                ),
                SwitchListTile(
                  title: const Text('Workout reminders'),
                  subtitle: Text(prefs.workoutReminderTime ?? 'Default time'),
                  value: prefs.workoutRemindersEnabled,
                  onChanged: _saving ? null : (value) => _save(workout: value),
                ),
                const SizedBox(height: NSpace.lg),
                NButton(
                  label: 'Set meal reminder time: 08:00',
                  variant: NButtonVariant.secondary,
                  loading: _saving,
                  onPressed: () => _save(mealTime: '08:00'),
                ),
                const SizedBox(height: NSpace.sm),
                NButton(
                  label: 'Set workout reminder time: 18:00',
                  variant: NButtonVariant.secondary,
                  loading: _saving,
                  onPressed: () => _save(workoutTime: '18:00'),
                ),
              ],
            ),
    );
  }
}
