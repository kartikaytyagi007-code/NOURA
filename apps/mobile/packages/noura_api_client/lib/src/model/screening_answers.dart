//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/screening_answer.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'screening_answers.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ScreeningAnswers {
  /// Returns a new [ScreeningAnswers] instance.
  ScreeningAnswers({
    required this.pregnancyOrBreastfeeding,

    required this.eatingDisorderConcern,

    required this.medicalDietCondition,
  });

  @JsonKey(
    name: r'pregnancy_or_breastfeeding',
    required: true,
    includeIfNull: false,
  )
  final ScreeningAnswer pregnancyOrBreastfeeding;

  @JsonKey(
    name: r'eating_disorder_concern',
    required: true,
    includeIfNull: false,
  )
  final ScreeningAnswer eatingDisorderConcern;

  @JsonKey(
    name: r'medical_diet_condition',
    required: true,
    includeIfNull: false,
  )
  final ScreeningAnswer medicalDietCondition;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ScreeningAnswers &&
            runtimeType == other.runtimeType &&
            equals(
              [
                pregnancyOrBreastfeeding,
                eatingDisorderConcern,
                medicalDietCondition,
              ],
              [
                other.pregnancyOrBreastfeeding,
                other.eatingDisorderConcern,
                other.medicalDietCondition,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        pregnancyOrBreastfeeding,
        eatingDisorderConcern,
        medicalDietCondition,
      ]);

  factory ScreeningAnswers.fromJson(Map<String, dynamic> json) =>
      _$ScreeningAnswersFromJson(json);

  Map<String, dynamic> toJson() => _$ScreeningAnswersToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
