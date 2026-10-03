// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'substitution_candidate.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SubstitutionCandidateCWProxy {
  SubstitutionCandidate exercise(ExerciseRef exercise);

  SubstitutionCandidate equipmentTags(List<String> equipmentTags);

  SubstitutionCandidate reason(String reason);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SubstitutionCandidate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SubstitutionCandidate(...).copyWith(id: 12, name: "My name")
  /// ````
  SubstitutionCandidate call({
    ExerciseRef exercise,
    List<String> equipmentTags,
    String reason,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSubstitutionCandidate.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSubstitutionCandidate.copyWith.fieldName(...)`
class _$SubstitutionCandidateCWProxyImpl
    implements _$SubstitutionCandidateCWProxy {
  const _$SubstitutionCandidateCWProxyImpl(this._value);

  final SubstitutionCandidate _value;

  @override
  SubstitutionCandidate exercise(ExerciseRef exercise) =>
      this(exercise: exercise);

  @override
  SubstitutionCandidate equipmentTags(List<String> equipmentTags) =>
      this(equipmentTags: equipmentTags);

  @override
  SubstitutionCandidate reason(String reason) => this(reason: reason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SubstitutionCandidate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SubstitutionCandidate(...).copyWith(id: 12, name: "My name")
  /// ````
  SubstitutionCandidate call({
    Object? exercise = const $CopyWithPlaceholder(),
    Object? equipmentTags = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
  }) {
    return SubstitutionCandidate(
      exercise: exercise == const $CopyWithPlaceholder()
          ? _value.exercise
          // ignore: cast_nullable_to_non_nullable
          : exercise as ExerciseRef,
      equipmentTags: equipmentTags == const $CopyWithPlaceholder()
          ? _value.equipmentTags
          // ignore: cast_nullable_to_non_nullable
          : equipmentTags as List<String>,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String,
    );
  }
}

extension $SubstitutionCandidateCopyWith on SubstitutionCandidate {
  /// Returns a callable class that can be used as follows: `instanceOfSubstitutionCandidate.copyWith(...)` or like so:`instanceOfSubstitutionCandidate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SubstitutionCandidateCWProxy get copyWith =>
      _$SubstitutionCandidateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubstitutionCandidate _$SubstitutionCandidateFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SubstitutionCandidate', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['exercise', 'equipment_tags', 'reason'],
  );
  final val = SubstitutionCandidate(
    exercise: $checkedConvert(
      'exercise',
      (v) => ExerciseRef.fromJson(v as Map<String, dynamic>),
    ),
    equipmentTags: $checkedConvert(
      'equipment_tags',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    reason: $checkedConvert('reason', (v) => v as String),
  );
  return val;
}, fieldKeyMap: const {'equipmentTags': 'equipment_tags'});

Map<String, dynamic> _$SubstitutionCandidateToJson(
  SubstitutionCandidate instance,
) => <String, dynamic>{
  'exercise': instance.exercise.toJson(),
  'equipment_tags': instance.equipmentTags,
  'reason': instance.reason,
};
