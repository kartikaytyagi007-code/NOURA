//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/exercise_ref.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'substitution_candidate.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SubstitutionCandidate {
  /// Returns a new [SubstitutionCandidate] instance.
  SubstitutionCandidate({
    required this.exercise,

    required this.equipmentTags,

    required this.reason,
  });

  @JsonKey(name: r'exercise', required: true, includeIfNull: false)
  final ExerciseRef exercise;

  @JsonKey(name: r'equipment_tags', required: true, includeIfNull: false)
  final List<String> equipmentTags;

  @JsonKey(name: r'reason', required: true, includeIfNull: false)
  final String reason;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SubstitutionCandidate &&
            runtimeType == other.runtimeType &&
            equals(
              [exercise, equipmentTags, reason],
              [other.exercise, other.equipmentTags, other.reason],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([exercise, equipmentTags, reason]);

  factory SubstitutionCandidate.fromJson(Map<String, dynamic> json) =>
      _$SubstitutionCandidateFromJson(json);

  Map<String, dynamic> toJson() => _$SubstitutionCandidateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
