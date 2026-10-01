// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_preferences.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TrainingPreferencesCWProxy {
  TrainingPreferences experience(ExperienceLevel? experience);

  TrainingPreferences location(TrainingLocation? location);

  TrainingPreferences equipmentIds(List<String> equipmentIds);

  TrainingPreferences weekdays(Set<int> weekdays);

  TrainingPreferences daysPerWeek(int? daysPerWeek);

  TrainingPreferences durationMinutes(int? durationMinutes);

  TrainingPreferences limitationTags(List<String> limitationTags);

  TrainingPreferences revision(int revision);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TrainingPreferences(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TrainingPreferences(...).copyWith(id: 12, name: "My name")
  /// ````
  TrainingPreferences call({
    ExperienceLevel? experience,
    TrainingLocation? location,
    List<String> equipmentIds,
    Set<int> weekdays,
    int? daysPerWeek,
    int? durationMinutes,
    List<String> limitationTags,
    int revision,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTrainingPreferences.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTrainingPreferences.copyWith.fieldName(...)`
class _$TrainingPreferencesCWProxyImpl implements _$TrainingPreferencesCWProxy {
  const _$TrainingPreferencesCWProxyImpl(this._value);

  final TrainingPreferences _value;

  @override
  TrainingPreferences experience(ExperienceLevel? experience) =>
      this(experience: experience);

  @override
  TrainingPreferences location(TrainingLocation? location) =>
      this(location: location);

  @override
  TrainingPreferences equipmentIds(List<String> equipmentIds) =>
      this(equipmentIds: equipmentIds);

  @override
  TrainingPreferences weekdays(Set<int> weekdays) => this(weekdays: weekdays);

  @override
  TrainingPreferences daysPerWeek(int? daysPerWeek) =>
      this(daysPerWeek: daysPerWeek);

  @override
  TrainingPreferences durationMinutes(int? durationMinutes) =>
      this(durationMinutes: durationMinutes);

  @override
  TrainingPreferences limitationTags(List<String> limitationTags) =>
      this(limitationTags: limitationTags);

  @override
  TrainingPreferences revision(int revision) => this(revision: revision);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TrainingPreferences(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TrainingPreferences(...).copyWith(id: 12, name: "My name")
  /// ````
  TrainingPreferences call({
    Object? experience = const $CopyWithPlaceholder(),
    Object? location = const $CopyWithPlaceholder(),
    Object? equipmentIds = const $CopyWithPlaceholder(),
    Object? weekdays = const $CopyWithPlaceholder(),
    Object? daysPerWeek = const $CopyWithPlaceholder(),
    Object? durationMinutes = const $CopyWithPlaceholder(),
    Object? limitationTags = const $CopyWithPlaceholder(),
    Object? revision = const $CopyWithPlaceholder(),
  }) {
    return TrainingPreferences(
      experience: experience == const $CopyWithPlaceholder()
          ? _value.experience
          // ignore: cast_nullable_to_non_nullable
          : experience as ExperienceLevel?,
      location: location == const $CopyWithPlaceholder()
          ? _value.location
          // ignore: cast_nullable_to_non_nullable
          : location as TrainingLocation?,
      equipmentIds: equipmentIds == const $CopyWithPlaceholder()
          ? _value.equipmentIds
          // ignore: cast_nullable_to_non_nullable
          : equipmentIds as List<String>,
      weekdays: weekdays == const $CopyWithPlaceholder()
          ? _value.weekdays
          // ignore: cast_nullable_to_non_nullable
          : weekdays as Set<int>,
      daysPerWeek: daysPerWeek == const $CopyWithPlaceholder()
          ? _value.daysPerWeek
          // ignore: cast_nullable_to_non_nullable
          : daysPerWeek as int?,
      durationMinutes: durationMinutes == const $CopyWithPlaceholder()
          ? _value.durationMinutes
          // ignore: cast_nullable_to_non_nullable
          : durationMinutes as int?,
      limitationTags: limitationTags == const $CopyWithPlaceholder()
          ? _value.limitationTags
          // ignore: cast_nullable_to_non_nullable
          : limitationTags as List<String>,
      revision: revision == const $CopyWithPlaceholder()
          ? _value.revision
          // ignore: cast_nullable_to_non_nullable
          : revision as int,
    );
  }
}

extension $TrainingPreferencesCopyWith on TrainingPreferences {
  /// Returns a callable class that can be used as follows: `instanceOfTrainingPreferences.copyWith(...)` or like so:`instanceOfTrainingPreferences.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TrainingPreferencesCWProxy get copyWith =>
      _$TrainingPreferencesCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingPreferences _$TrainingPreferencesFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'TrainingPreferences',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'experience',
            'location',
            'equipment_ids',
            'weekdays',
            'days_per_week',
            'duration_minutes',
            'limitation_tags',
            'revision',
          ],
        );
        final val = TrainingPreferences(
          experience: $checkedConvert(
            'experience',
            (v) => $enumDecodeNullable(_$ExperienceLevelEnumMap, v),
          ),
          location: $checkedConvert(
            'location',
            (v) => $enumDecodeNullable(_$TrainingLocationEnumMap, v),
          ),
          equipmentIds: $checkedConvert(
            'equipment_ids',
            (v) => (v as List<dynamic>).map((e) => e as String).toList(),
          ),
          weekdays: $checkedConvert(
            'weekdays',
            (v) => (v as List<dynamic>).map((e) => (e as num).toInt()).toSet(),
          ),
          daysPerWeek: $checkedConvert(
            'days_per_week',
            (v) => (v as num?)?.toInt(),
          ),
          durationMinutes: $checkedConvert(
            'duration_minutes',
            (v) => (v as num?)?.toInt(),
          ),
          limitationTags: $checkedConvert(
            'limitation_tags',
            (v) => (v as List<dynamic>).map((e) => e as String).toList(),
          ),
          revision: $checkedConvert('revision', (v) => (v as num).toInt()),
        );
        return val;
      },
      fieldKeyMap: const {
        'equipmentIds': 'equipment_ids',
        'daysPerWeek': 'days_per_week',
        'durationMinutes': 'duration_minutes',
        'limitationTags': 'limitation_tags',
      },
    );

Map<String, dynamic> _$TrainingPreferencesToJson(
  TrainingPreferences instance,
) => <String, dynamic>{
  'experience': _$ExperienceLevelEnumMap[instance.experience],
  'location': _$TrainingLocationEnumMap[instance.location],
  'equipment_ids': instance.equipmentIds,
  'weekdays': instance.weekdays.toList(),
  'days_per_week': instance.daysPerWeek,
  'duration_minutes': instance.durationMinutes,
  'limitation_tags': instance.limitationTags,
  'revision': instance.revision,
};

const _$ExperienceLevelEnumMap = {
  ExperienceLevel.beginner: 'beginner',
  ExperienceLevel.intermediate: 'intermediate',
  ExperienceLevel.advanced: 'advanced',
};

const _$TrainingLocationEnumMap = {
  TrainingLocation.home: 'home',
  TrainingLocation.gym: 'gym',
  TrainingLocation.both: 'both',
};
