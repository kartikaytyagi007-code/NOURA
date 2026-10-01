//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/experience_level.dart';
import 'package:noura_api_client/src/model/training_location.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'training_preferences.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TrainingPreferences {
  /// Returns a new [TrainingPreferences] instance.
  TrainingPreferences({
    required this.experience,

    required this.location,

    required this.equipmentIds,

    required this.weekdays,

    required this.daysPerWeek,

    required this.durationMinutes,

    required this.limitationTags,

    required this.revision,
  });

  @JsonKey(name: r'experience', required: true, includeIfNull: true)
  final ExperienceLevel? experience;

  @JsonKey(name: r'location', required: true, includeIfNull: true)
  final TrainingLocation? location;

  @JsonKey(name: r'equipment_ids', required: true, includeIfNull: false)
  final List<String> equipmentIds;

  @JsonKey(name: r'weekdays', required: true, includeIfNull: false)
  final Set<int> weekdays;

  // minimum: 1
  // maximum: 7
  @JsonKey(name: r'days_per_week', required: true, includeIfNull: true)
  final int? daysPerWeek;

  // minimum: 10
  // maximum: 180
  @JsonKey(name: r'duration_minutes', required: true, includeIfNull: true)
  final int? durationMinutes;

  @JsonKey(name: r'limitation_tags', required: true, includeIfNull: false)
  final List<String> limitationTags;

  // minimum: 1
  @JsonKey(name: r'revision', required: true, includeIfNull: false)
  final int revision;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TrainingPreferences &&
            runtimeType == other.runtimeType &&
            equals(
              [
                experience,
                location,
                equipmentIds,
                weekdays,
                daysPerWeek,
                durationMinutes,
                limitationTags,
                revision,
              ],
              [
                other.experience,
                other.location,
                other.equipmentIds,
                other.weekdays,
                other.daysPerWeek,
                other.durationMinutes,
                other.limitationTags,
                other.revision,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        experience,
        location,
        equipmentIds,
        weekdays,
        daysPerWeek,
        durationMinutes,
        limitationTags,
        revision,
      ]);

  factory TrainingPreferences.fromJson(Map<String, dynamic> json) =>
      _$TrainingPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingPreferencesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
