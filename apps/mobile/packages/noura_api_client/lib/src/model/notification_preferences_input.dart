//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'notification_preferences_input.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NotificationPreferencesInput {
  /// Returns a new [NotificationPreferencesInput] instance.
  NotificationPreferencesInput({
    required this.expectedRevision,

    required this.mealRemindersEnabled,

    required this.workoutRemindersEnabled,

    this.mealReminderTime,

    this.workoutReminderTime,

    this.consentGrantedAt,
  });

  // minimum: 0
  @JsonKey(name: r'expected_revision', required: true, includeIfNull: false)
  final int expectedRevision;

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

  @JsonKey(name: r'meal_reminder_time', required: false, includeIfNull: false)
  final String? mealReminderTime;

  @JsonKey(
    name: r'workout_reminder_time',
    required: false,
    includeIfNull: false,
  )
  final String? workoutReminderTime;

  /// Send a timestamp only when the user just opted in; omit/null otherwise.
  @JsonKey(name: r'consent_granted_at', required: false, includeIfNull: false)
  final DateTime? consentGrantedAt;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NotificationPreferencesInput &&
            runtimeType == other.runtimeType &&
            equals(
              [
                expectedRevision,
                mealRemindersEnabled,
                workoutRemindersEnabled,
                mealReminderTime,
                workoutReminderTime,
                consentGrantedAt,
              ],
              [
                other.expectedRevision,
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
        expectedRevision,
        mealRemindersEnabled,
        workoutRemindersEnabled,
        mealReminderTime,
        workoutReminderTime,
        consentGrantedAt,
      ]);

  factory NotificationPreferencesInput.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesInputFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationPreferencesInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
