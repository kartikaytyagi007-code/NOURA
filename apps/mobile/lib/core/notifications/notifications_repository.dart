import 'package:dio/dio.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../api/api_failure.dart';
import '../profile/profile_repository.dart' show newIdempotencyKey;

/// Local-reminder consent and preferences (GET/PUT /v1/me/notification-preferences).
///
/// Reminders are LOCAL DEVICE notifications only, after explicit opt-in (blueprint §18: "No push
/// infrastructure needed for V1") — there is no server-held push token and never will be for V1.
/// This repository is the server-truth half (consent + the chosen times); actually scheduling the OS
/// notification is [ReminderScheduler]'s job, and that one still needs a real
/// `flutter_local_notifications` (or equivalent) plugin wired into the native Android/iOS projects —
/// see docs/decisions.md and docs/release-checklist.md. Nothing here ever talks to Firebase/APNs.
abstract interface class NotificationsRepository {
  Future<NotificationPreferences> fetch();
  Future<NotificationPreferences> save(NotificationPreferencesInput input);
}

class ApiNotificationsRepository implements NotificationsRepository {
  ApiNotificationsRepository(this._client);
  final NouraApiClient _client;

  ProfileApi get _api => _client.getProfileApi();

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<NotificationPreferences> fetch() => _guard(() async => (await _api.getNotificationPreferences()).data!.data);

  @override
  Future<NotificationPreferences> save(NotificationPreferencesInput input) => _guard(
    () async => (await _api.putNotificationPreferences(
      idempotencyKey: newIdempotencyKey(),
      notificationPreferencesInput: input,
    )).data!.data,
  );
}

class MockNotificationsRepository implements NotificationsRepository {
  NotificationPreferences _prefs = NotificationPreferences(
    revision: 0,
    mealRemindersEnabled: false,
    workoutRemindersEnabled: false,
    mealReminderTime: null,
    workoutReminderTime: null,
    consentGrantedAt: null,
  );

  @override
  Future<NotificationPreferences> fetch() async => _prefs;

  @override
  Future<NotificationPreferences> save(NotificationPreferencesInput input) async {
    _prefs = NotificationPreferences(
      revision: _prefs.revision + 1,
      mealRemindersEnabled: input.mealRemindersEnabled,
      workoutRemindersEnabled: input.workoutRemindersEnabled,
      mealReminderTime: input.mealReminderTime ?? _prefs.mealReminderTime,
      workoutReminderTime: input.workoutReminderTime ?? _prefs.workoutReminderTime,
      consentGrantedAt: input.consentGrantedAt ?? _prefs.consentGrantedAt,
    );
    return _prefs;
  }
}

/// Schedules (or cancels) the actual OS-level local notifications for the saved preferences, and is
/// called again whenever the active diet/workout plan or the profile timezone changes (blueprint
/// §18: "reschedule when plans/timezone change"). [NoOpReminderScheduler] is the only implementation
/// in this milestone: wiring a real local-notifications plugin needs native Android/iOS project
/// changes this sandboxed environment cannot build/verify a real device test for (see
/// docs/release-checklist.md). It fails safely — it schedules nothing rather than guessing at a
/// plugin API — never crashes, and never claims a notification was scheduled when it was not.
abstract interface class ReminderScheduler {
  Future<void> applyPreferences(NotificationPreferences preferences, {required String timezone});
  Future<void> cancelAll();
}

class NoOpReminderScheduler implements ReminderScheduler {
  const NoOpReminderScheduler();

  @override
  Future<void> applyPreferences(NotificationPreferences preferences, {required String timezone}) async {}

  @override
  Future<void> cancelAll() async {}
}
