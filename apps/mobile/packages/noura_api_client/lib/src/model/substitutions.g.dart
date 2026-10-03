// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'substitutions.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SubstitutionsCWProxy {
  Substitutions exerciseId(String exerciseId);

  Substitutions candidates(List<SubstitutionCandidate> candidates);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Substitutions(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Substitutions(...).copyWith(id: 12, name: "My name")
  /// ````
  Substitutions call({
    String exerciseId,
    List<SubstitutionCandidate> candidates,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSubstitutions.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSubstitutions.copyWith.fieldName(...)`
class _$SubstitutionsCWProxyImpl implements _$SubstitutionsCWProxy {
  const _$SubstitutionsCWProxyImpl(this._value);

  final Substitutions _value;

  @override
  Substitutions exerciseId(String exerciseId) => this(exerciseId: exerciseId);

  @override
  Substitutions candidates(List<SubstitutionCandidate> candidates) =>
      this(candidates: candidates);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Substitutions(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Substitutions(...).copyWith(id: 12, name: "My name")
  /// ````
  Substitutions call({
    Object? exerciseId = const $CopyWithPlaceholder(),
    Object? candidates = const $CopyWithPlaceholder(),
  }) {
    return Substitutions(
      exerciseId: exerciseId == const $CopyWithPlaceholder()
          ? _value.exerciseId
          // ignore: cast_nullable_to_non_nullable
          : exerciseId as String,
      candidates: candidates == const $CopyWithPlaceholder()
          ? _value.candidates
          // ignore: cast_nullable_to_non_nullable
          : candidates as List<SubstitutionCandidate>,
    );
  }
}

extension $SubstitutionsCopyWith on Substitutions {
  /// Returns a callable class that can be used as follows: `instanceOfSubstitutions.copyWith(...)` or like so:`instanceOfSubstitutions.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SubstitutionsCWProxy get copyWith => _$SubstitutionsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Substitutions _$SubstitutionsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Substitutions', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['exercise_id', 'candidates']);
      final val = Substitutions(
        exerciseId: $checkedConvert('exercise_id', (v) => v as String),
        candidates: $checkedConvert(
          'candidates',
          (v) => (v as List<dynamic>)
              .map(
                (e) =>
                    SubstitutionCandidate.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'exerciseId': 'exercise_id'});

Map<String, dynamic> _$SubstitutionsToJson(Substitutions instance) =>
    <String, dynamic>{
      'exercise_id': instance.exerciseId,
      'candidates': instance.candidates.map((e) => e.toJson()).toList(),
    };
