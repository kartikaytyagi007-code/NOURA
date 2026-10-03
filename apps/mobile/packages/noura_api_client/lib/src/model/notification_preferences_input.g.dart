// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NotificationPreferencesInputCWProxy {
  NotificationPreferencesInput expectedRevision(int expectedRevision);

  NotificationPreferencesInput mealRemindersEnabled(bool mealRemindersEnabled);

  NotificationPreferencesInput workoutRemindersEnabled(
    bool workoutRemindersEnabled,
  );

  NotificationPreferencesInput mealReminderTime(String? mealReminderTime);

  NotificationPreferencesInput workoutReminderTime(String? workoutReminderTime);

  NotificationPreferencesInput consentGrantedAt(DateTime? consentGrantedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NotificationPreferencesInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NotificationPreferencesInput(...).copyWith(id: 12, name: "My name")
  /// ````
  NotificationPreferencesInput call({
    int expectedRevision,
    bool mealRemindersEnabled,
    bool workoutRemindersEnabled,
    String? mealReminderTime,
    String? workoutReminderTime,
    DateTime? consentGrantedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNotificationPreferencesInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNotificationPreferencesInput.copyWith.fieldName(...)`
class _$NotificationPreferencesInputCWProxyImpl
    implements _$NotificationPreferencesInputCWProxy {
  const _$NotificationPreferencesInputCWProxyImpl(this._value);

  final NotificationPreferencesInput _value;

  @override
  NotificationPreferencesInput expectedRevision(int expectedRevision) =>
      this(expectedRevision: expectedRevision);

  @override
  NotificationPreferencesInput mealRemindersEnabled(
    bool mealRemindersEnabled,
  ) => this(mealRemindersEnabled: mealRemindersEnabled);

  @override
  NotificationPreferencesInput workoutRemindersEnabled(
    bool workoutRemindersEnabled,
  ) => this(workoutRemindersEnabled: workoutRemindersEnabled);

  @override
  NotificationPreferencesInput mealReminderTime(String? mealReminderTime) =>
      this(mealReminderTime: mealReminderTime);

  @override
  NotificationPreferencesInput workoutReminderTime(
    String? workoutReminderTime,
  ) => this(workoutReminderTime: workoutReminderTime);

  @override
  NotificationPreferencesInput consentGrantedAt(DateTime? consentGrantedAt) =>
      this(consentGrantedAt: consentGrantedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NotificationPreferencesInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NotificationPreferencesInput(...).copyWith(id: 12, name: "My name")
  /// ````
  NotificationPreferencesInput call({
    Object? expectedRevision = const $CopyWithPlaceholder(),
    Object? mealRemindersEnabled = const $CopyWithPlaceholder(),
    Object? workoutRemindersEnabled = const $CopyWithPlaceholder(),
    Object? mealReminderTime = const $CopyWithPlaceholder(),
    Object? workoutReminderTime = const $CopyWithPlaceholder(),
    Object? consentGrantedAt = const $CopyWithPlaceholder(),
  }) {
    return NotificationPreferencesInput(
      expectedRevision: expectedRevision == const $CopyWithPlaceholder()
          ? _value.expectedRevision
          // ignore: cast_nullable_to_non_nullable
          : expectedRevision as int,
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

extension $NotificationPreferencesInputCopyWith
    on NotificationPreferencesInput {
  /// Returns a callable class that can be used as follows: `instanceOfNotificationPreferencesInput.copyWith(...)` or like so:`instanceOfNotificationPreferencesInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NotificationPreferencesInputCWProxy get copyWith =>
      _$NotificationPreferencesInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationPreferencesInput _$NotificationPreferencesInputFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'NotificationPreferencesInput',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'expected_revision',
        'meal_reminders_enabled',
        'workout_reminders_enabled',
      ],
    );
    final val = NotificationPreferencesInput(
      expectedRevision: $checkedConvert(
        'expected_revision',
        (v) => (v as num).toInt(),
      ),
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
    'expectedRevision': 'expected_revision',
    'mealRemindersEnabled': 'meal_reminders_enabled',
    'workoutRemindersEnabled': 'workout_reminders_enabled',
    'mealReminderTime': 'meal_reminder_time',
    'workoutReminderTime': 'workout_reminder_time',
    'consentGrantedAt': 'consent_granted_at',
  },
);

Map<String, dynamic> _$NotificationPreferencesInputToJson(
  NotificationPreferencesInput instance,
) => <String, dynamic>{
  'expected_revision': instance.expectedRevision,
  'meal_reminders_enabled': instance.mealRemindersEnabled,
  'workout_reminders_enabled': instance.workoutRemindersEnabled,
  'meal_reminder_time': ?instance.mealReminderTime,
  'workout_reminder_time': ?instance.workoutReminderTime,
  'consent_granted_at': ?instance.consentGrantedAt?.toIso8601String(),
};
