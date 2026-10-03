//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/experience_level.dart';
import 'package:noura_api_client/src/model/equipment_tag.dart';
import 'package:noura_api_client/src/model/limitation_tag.dart';
import 'package:noura_api_client/src/model/training_location.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'training_preferences_input.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TrainingPreferencesInput {
  /// Returns a new [TrainingPreferencesInput] instance.
  TrainingPreferencesInput({
    required this.expectedRevision,

    required this.experience,

    required this.location,

    required this.equipmentIds,

    required this.weekdays,

    required this.daysPerWeek,

    required this.durationMinutes,

    required this.limitationTags,
  });

  /// Current training-preferences revision; 0 when none exist yet.
  // minimum: 0
  @JsonKey(name: r'expected_revision', required: true, includeIfNull: false)
  final int expectedRevision;

  @JsonKey(name: r'experience', required: true, includeIfNull: false)
  final ExperienceLevel experience;

  @JsonKey(name: r'location', required: true, includeIfNull: false)
  final TrainingLocation location;

  @JsonKey(name: r'equipment_ids', required: true, includeIfNull: false)
  final Set<EquipmentTag> equipmentIds;

  @JsonKey(name: r'weekdays', required: true, includeIfNull: false)
  final Set<int> weekdays;

  // minimum: 1
  // maximum: 7
  @JsonKey(name: r'days_per_week', required: true, includeIfNull: false)
  final int daysPerWeek;

  // minimum: 10
  // maximum: 180
  @JsonKey(name: r'duration_minutes', required: true, includeIfNull: false)
  final int durationMinutes;

  @JsonKey(name: r'limitation_tags', required: true, includeIfNull: false)
  final Set<LimitationTag> limitationTags;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TrainingPreferencesInput &&
            runtimeType == other.runtimeType &&
            equals(
              [
                expectedRevision,
                experience,
                location,
                equipmentIds,
                weekdays,
                daysPerWeek,
                durationMinutes,
                limitationTags,
              ],
              [
                other.expectedRevision,
                other.experience,
                other.location,
                other.equipmentIds,
                other.weekdays,
                other.daysPerWeek,
                other.durationMinutes,
                other.limitationTags,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        expectedRevision,
        experience,
        location,
        equipmentIds,
        weekdays,
        daysPerWeek,
        durationMinutes,
        limitationTags,
      ]);

  factory TrainingPreferencesInput.fromJson(Map<String, dynamic> json) =>
      _$TrainingPreferencesInputFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingPreferencesInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
