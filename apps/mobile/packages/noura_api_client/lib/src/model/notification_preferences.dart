//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'notification_preferences.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NotificationPreferences {
  /// Returns a new [NotificationPreferences] instance.
  NotificationPreferences({
    required this.revision,

    required this.mealRemindersEnabled,

    required this.workoutRemindersEnabled,

    required this.mealReminderTime,

    required this.workoutReminderTime,

    required this.consentGrantedAt,
  });

  /// Preferences revision; 0 when none exist yet.
  // minimum: 0
  @JsonKey(name: r'revision', required: true, includeIfNull: false)
  final int revision;

  @JsonKey(
    name: r'meal_reminders_enabled',
    required: true,
    includeIfNull: false,
  )
  final bool mealRemindersEnabled;

  @JsonKey(
    name: r'workout_reminders_enabled',
    required: true,
    includeIfNull: false,
  )
  final bool workoutRemindersEnabled;

  /// Local 24-hour HH:MM, scheduled on the device in the profile timezone.
  @JsonKey(name: r'meal_reminder_time', required: true, includeIfNull: true)
  final String? mealReminderTime;

  @JsonKey(name: r'workout_reminder_time', required: true, includeIfNull: true)
  final String? workoutReminderTime;

  @JsonKey(name: r'consent_granted_at', required: true, includeIfNull: true)
  final DateTime? consentGrantedAt;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NotificationPreferences &&
            runtimeType == other.runtimeType &&
            equals(
              [
                revision,
                mealRemindersEnabled,
                workoutRemindersEnabled,
                mealReminderTime,
                workoutReminderTime,
                consentGrantedAt,
              ],
              [
                other.revision,
                other.mealRemindersEnabled,
                other.workoutRemindersEnabled,
                other.mealReminderTime,
                other.workoutReminderTime,
                other.consentGrantedAt,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        revision,
        mealRemindersEnabled,
        workoutRemindersEnabled,
        mealReminderTime,
        workoutReminderTime,
        consentGrantedAt,
      ]);

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationPreferencesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
