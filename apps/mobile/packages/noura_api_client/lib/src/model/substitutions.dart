//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/substitution_candidate.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'substitutions.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Substitutions {
  /// Returns a new [Substitutions] instance.
  Substitutions({required this.exerciseId, required this.candidates});

  @JsonKey(name: r'exercise_id', required: true, includeIfNull: false)
  final String exerciseId;

  @JsonKey(name: r'candidates', required: true, includeIfNull: false)
  final List<SubstitutionCandidate> candidates;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Substitutions &&
            runtimeType == other.runtimeType &&
            equals(
              [exerciseId, candidates],
              [other.exerciseId, other.candidates],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([exerciseId, candidates]);

  factory Substitutions.fromJson(Map<String, dynamic> json) =>
      _$SubstitutionsFromJson(json);

  Map<String, dynamic> toJson() => _$SubstitutionsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
