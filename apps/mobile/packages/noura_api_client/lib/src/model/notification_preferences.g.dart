// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NotificationPreferencesCWProxy {
  NotificationPreferences revision(int revision);

  NotificationPreferences mealRemindersEnabled(bool mealRemindersEnabled);

  NotificationPreferences workoutRemindersEnabled(bool workoutRemindersEnabled);

  NotificationPreferences mealReminderTime(String? mealReminderTime);

  NotificationPreferences workoutReminderTime(String? workoutReminderTime);

  NotificationPreferences consentGrantedAt(DateTime? consentGrantedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NotificationPreferences(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NotificationPreferences(...).copyWith(id: 12, name: "My name")
  /// ````
  NotificationPreferences call({
    int revision,
    bool mealRemindersEnabled,
    bool workoutRemindersEnabled,
    String? mealReminderTime,
    String? workoutReminderTime,
    DateTime? consentGrantedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNotificationPreferences.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNotificationPreferences.copyWith.fieldName(...)`
class _$NotificationPreferencesCWProxyImpl
    implements _$NotificationPreferencesCWProxy {
  const _$NotificationPreferencesCWProxyImpl(this._value);

  final NotificationPreferences _value;

  @override
  NotificationPreferences revision(int revision) => this(revision: revision);

  @override
  NotificationPreferences mealRemindersEnabled(bool mealRemindersEnabled) =>
      this(mealRemindersEnabled: mealRemindersEnabled);

  @override
  NotificationPreferences workoutRemindersEnabled(
    bool workoutRemindersEnabled,
  ) => this(workoutRemindersEnabled: workoutRemindersEnabled);

  @override
  NotificationPreferences mealReminderTime(String? mealReminderTime) =>
      this(mealReminderTime: mealReminderTime);

  @override
  NotificationPreferences workoutReminderTime(String? workoutReminderTime) =>
      this(workoutReminderTime: workoutReminderTime);

  @override
  NotificationPreferences consentGrantedAt(DateTime? consentGrantedAt) =>
      this(consentGrantedAt: consentGrantedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NotificationPreferences(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NotificationPreferences(...).copyWith(id: 12, name: "My name")
  /// ````
  NotificationPreferences call({
    Object? revision = const $CopyWithPlaceholder(),
    Object? mealRemindersEnabled = const $CopyWithPlaceholder(),
    Object? workoutRemindersEnabled = const $CopyWithPlaceholder(),
    Object? mealReminderTime = const $CopyWithPlaceholder(),
    Object? workoutReminderTime = const $CopyWithPlaceholder(),
    Object? consentGrantedAt = const $CopyWithPlaceholder(),
  }) {
    return NotificationPreferences(
      revision: revision == const $CopyWithPlaceholder()
          ? _value.revision
          // ignore: cast_nullable_to_non_nullable
          : revision as int,
      mealRemindersEnabled: mealRemindersEnabled == const $CopyWithPlaceholder()
          ? _value.mealRemindersEnabled
          // ignore: cast_nullable_to_non_nullable
          : mealRemindersEnabled as bool,
      workoutRemindersEnabled:
          workoutRemindersEnabled == const $CopyWithPlaceholder()
          ? _value.workoutRemindersEnabled
          // ignore: cast_nullable_to_non_nullable
          : workoutRemindersEnabled as bool,
      mealReminderTime: mealReminderTime == const $CopyWithPlaceholder()
          ? _value.mealReminderTime
          // ignore: cast_nullable_to_non_nullable
          : mealReminderTime as String?,
      workoutReminderTime: workoutReminderTime == const $CopyWithPlaceholder()
          ? _value.workoutReminderTime
          // ignore: cast_nullable_to_non_nullable
          : workoutReminderTime as String?,
      consentGrantedAt: consentGrantedAt == const $CopyWithPlaceholder()
          ? _value.consentGrantedAt
          // ignore: cast_nullable_to_non_nullable
          : consentGrantedAt as DateTime?,
    );
  }
}

extension $NotificationPreferencesCopyWith on NotificationPreferences {
  /// Returns a callable class that can be used as follows: `instanceOfNotificationPreferences.copyWith(...)` or like so:`instanceOfNotificationPreferences.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NotificationPreferencesCWProxy get copyWith =>
      _$NotificationPreferencesCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationPreferences _$NotificationPreferencesFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'NotificationPreferences',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'revision',
        'meal_reminders_enabled',
        'workout_reminders_enabled',
        'meal_reminder_time',
        'workout_reminder_time',
        'consent_granted_at',
      ],
    );
    final val = NotificationPreferences(
      revision: $checkedConvert('revision', (v) => (v as num).toInt()),
      mealRemindersEnabled: $checkedConvert(
        'meal_reminders_enabled',
        (v) => v as bool,
      ),
      workoutRemindersEnabled: $checkedConvert(
        'workout_reminders_enabled',
        (v) => v as bool,
      ),
      mealReminderTime: $checkedConvert(
        'meal_reminder_time',
        (v) => v as String?,
      ),
      workoutReminderTime: $checkedConvert(
        'workout_reminder_time',
        (v) => v as String?,
      ),
      consentGrantedAt: $checkedConvert(
        'consent_granted_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'mealRemindersEnabled': 'meal_reminders_enabled',
    'workoutRemindersEnabled': 'workout_reminders_enabled',
    'mealReminderTime': 'meal_reminder_time',
    'workoutReminderTime': 'workout_reminder_time',
    'consentGrantedAt': 'consent_granted_at',
  },
);

Map<String, dynamic> _$NotificationPreferencesToJson(
  NotificationPreferences instance,
) => <String, dynamic>{
  'revision': instance.revision,
  'meal_reminders_enabled': instance.mealRemindersEnabled,
  'workout_reminders_enabled': instance.workoutRemindersEnabled,
  'meal_reminder_time': instance.mealReminderTime,
  'workout_reminder_time': instance.workoutReminderTime,
  'consent_granted_at': instance.consentGrantedAt?.toIso8601String(),
};
