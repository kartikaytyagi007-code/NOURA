// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_preferences_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TrainingPreferencesInputCWProxy {
  TrainingPreferencesInput expectedRevision(int expectedRevision);

  TrainingPreferencesInput experience(ExperienceLevel experience);

  TrainingPreferencesInput location(TrainingLocation location);

  TrainingPreferencesInput equipmentIds(Set<String> equipmentIds);

  TrainingPreferencesInput weekdays(Set<int> weekdays);

  TrainingPreferencesInput daysPerWeek(int daysPerWeek);

  TrainingPreferencesInput durationMinutes(int durationMinutes);

  TrainingPreferencesInput limitationTags(Set<String> limitationTags);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TrainingPreferencesInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TrainingPreferencesInput(...).copyWith(id: 12, name: "My name")
  /// ````
  TrainingPreferencesInput call({
    int expectedRevision,
    ExperienceLevel experience,
    TrainingLocation location,
    Set<String> equipmentIds,
    Set<int> weekdays,
    int daysPerWeek,
    int durationMinutes,
    Set<String> limitationTags,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTrainingPreferencesInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTrainingPreferencesInput.copyWith.fieldName(...)`
class _$TrainingPreferencesInputCWProxyImpl
    implements _$TrainingPreferencesInputCWProxy {
  const _$TrainingPreferencesInputCWProxyImpl(this._value);

  final TrainingPreferencesInput _value;

  @override
  TrainingPreferencesInput expectedRevision(int expectedRevision) =>
      this(expectedRevision: expectedRevision);

  @override
  TrainingPreferencesInput experience(ExperienceLevel experience) =>
      this(experience: experience);

  @override
  TrainingPreferencesInput location(TrainingLocation location) =>
      this(location: location);

  @override
  TrainingPreferencesInput equipmentIds(Set<String> equipmentIds) =>
      this(equipmentIds: equipmentIds);

  @override
  TrainingPreferencesInput weekdays(Set<int> weekdays) =>
      this(weekdays: weekdays);

  @override
  TrainingPreferencesInput daysPerWeek(int daysPerWeek) =>
      this(daysPerWeek: daysPerWeek);

  @override
  TrainingPreferencesInput durationMinutes(int durationMinutes) =>
      this(durationMinutes: durationMinutes);

  @override
  TrainingPreferencesInput limitationTags(Set<String> limitationTags) =>
      this(limitationTags: limitationTags);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TrainingPreferencesInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TrainingPreferencesInput(...).copyWith(id: 12, name: "My name")
  /// ````
  TrainingPreferencesInput call({
    Object? expectedRevision = const $CopyWithPlaceholder(),
    Object? experience = const $CopyWithPlaceholder(),
    Object? location = const $CopyWithPlaceholder(),
    Object? equipmentIds = const $CopyWithPlaceholder(),
    Object? weekdays = const $CopyWithPlaceholder(),
    Object? daysPerWeek = const $CopyWithPlaceholder(),
    Object? durationMinutes = const $CopyWithPlaceholder(),
    Object? limitationTags = const $CopyWithPlaceholder(),
  }) {
    return TrainingPreferencesInput(
      expectedRevision: expectedRevision == const $CopyWithPlaceholder()
          ? _value.expectedRevision
          // ignore: cast_nullable_to_non_nullable
          : expectedRevision as int,
      experience: experience == const $CopyWithPlaceholder()
          ? _value.experience
          // ignore: cast_nullable_to_non_nullable
          : experience as ExperienceLevel,
      location: location == const $CopyWithPlaceholder()
          ? _value.location
          // ignore: cast_nullable_to_non_nullable
          : location as TrainingLocation,
      equipmentIds: equipmentIds == const $CopyWithPlaceholder()
          ? _value.equipmentIds
          // ignore: cast_nullable_to_non_nullable
          : equipmentIds as Set<String>,
      weekdays: weekdays == const $CopyWithPlaceholder()
          ? _value.weekdays
          // ignore: cast_nullable_to_non_nullable
          : weekdays as Set<int>,
      daysPerWeek: daysPerWeek == const $CopyWithPlaceholder()
          ? _value.daysPerWeek
          // ignore: cast_nullable_to_non_nullable
          : daysPerWeek as int,
      durationMinutes: durationMinutes == const $CopyWithPlaceholder()
          ? _value.durationMinutes
          // ignore: cast_nullable_to_non_nullable
          : durationMinutes as int,
      limitationTags: limitationTags == const $CopyWithPlaceholder()
          ? _value.limitationTags
          // ignore: cast_nullable_to_non_nullable
          : limitationTags as Set<String>,
    );
  }
}

extension $TrainingPreferencesInputCopyWith on TrainingPreferencesInput {
  /// Returns a callable class that can be used as follows: `instanceOfTrainingPreferencesInput.copyWith(...)` or like so:`instanceOfTrainingPreferencesInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TrainingPreferencesInputCWProxy get copyWith =>
      _$TrainingPreferencesInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingPreferencesInput _$TrainingPreferencesInputFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'TrainingPreferencesInput',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'expected_revision',
        'experience',
        'location',
        'equipment_ids',
        'weekdays',
        'days_per_week',
        'duration_minutes',
        'limitation_tags',
      ],
    );
    final val = TrainingPreferencesInput(
      expectedRevision: $checkedConvert(
        'expected_revision',
        (v) => (v as num).toInt(),
      ),
      experience: $checkedConvert(
        'experience',
        (v) => $enumDecode(_$ExperienceLevelEnumMap, v),
      ),
      location: $checkedConvert(
        'location',
        (v) => $enumDecode(_$TrainingLocationEnumMap, v),
      ),
      equipmentIds: $checkedConvert(
        'equipment_ids',
        (v) => (v as List<dynamic>).map((e) => e as String).toSet(),
      ),
      weekdays: $checkedConvert(
        'weekdays',
        (v) => (v as List<dynamic>).map((e) => (e as num).toInt()).toSet(),
      ),
      daysPerWeek: $checkedConvert('days_per_week', (v) => (v as num).toInt()),
      durationMinutes: $checkedConvert(
        'duration_minutes',
        (v) => (v as num).toInt(),
      ),
      limitationTags: $checkedConvert(
        'limitation_tags',
        (v) => (v as List<dynamic>).map((e) => e as String).toSet(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'expectedRevision': 'expected_revision',
    'equipmentIds': 'equipment_ids',
    'daysPerWeek': 'days_per_week',
    'durationMinutes': 'duration_minutes',
    'limitationTags': 'limitation_tags',
  },
);

Map<String, dynamic> _$TrainingPreferencesInputToJson(
  TrainingPreferencesInput instance,
) => <String, dynamic>{
  'expected_revision': instance.expectedRevision,
  'experience': _$ExperienceLevelEnumMap[instance.experience]!,
  'location': _$TrainingLocationEnumMap[instance.location]!,
  'equipment_ids': instance.equipmentIds.toList(),
  'weekdays': instance.weekdays.toList(),
  'days_per_week': instance.daysPerWeek,
  'duration_minutes': instance.durationMinutes,
  'limitation_tags': instance.limitationTags.toList(),
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
