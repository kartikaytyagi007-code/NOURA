// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screening_answers.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ScreeningAnswersCWProxy {
  ScreeningAnswers pregnancyOrBreastfeeding(
    ScreeningAnswer pregnancyOrBreastfeeding,
  );

  ScreeningAnswers eatingDisorderConcern(ScreeningAnswer eatingDisorderConcern);

  ScreeningAnswers medicalDietCondition(ScreeningAnswer medicalDietCondition);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ScreeningAnswers(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ScreeningAnswers(...).copyWith(id: 12, name: "My name")
  /// ````
  ScreeningAnswers call({
    ScreeningAnswer pregnancyOrBreastfeeding,
    ScreeningAnswer eatingDisorderConcern,
    ScreeningAnswer medicalDietCondition,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfScreeningAnswers.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfScreeningAnswers.copyWith.fieldName(...)`
class _$ScreeningAnswersCWProxyImpl implements _$ScreeningAnswersCWProxy {
  const _$ScreeningAnswersCWProxyImpl(this._value);

  final ScreeningAnswers _value;

  @override
  ScreeningAnswers pregnancyOrBreastfeeding(
    ScreeningAnswer pregnancyOrBreastfeeding,
  ) => this(pregnancyOrBreastfeeding: pregnancyOrBreastfeeding);

  @override
  ScreeningAnswers eatingDisorderConcern(
    ScreeningAnswer eatingDisorderConcern,
  ) => this(eatingDisorderConcern: eatingDisorderConcern);

  @override
  ScreeningAnswers medicalDietCondition(ScreeningAnswer medicalDietCondition) =>
      this(medicalDietCondition: medicalDietCondition);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ScreeningAnswers(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ScreeningAnswers(...).copyWith(id: 12, name: "My name")
  /// ````
  ScreeningAnswers call({
    Object? pregnancyOrBreastfeeding = const $CopyWithPlaceholder(),
    Object? eatingDisorderConcern = const $CopyWithPlaceholder(),
    Object? medicalDietCondition = const $CopyWithPlaceholder(),
  }) {
    return ScreeningAnswers(
      pregnancyOrBreastfeeding:
          pregnancyOrBreastfeeding == const $CopyWithPlaceholder()
          ? _value.pregnancyOrBreastfeeding
          // ignore: cast_nullable_to_non_nullable
          : pregnancyOrBreastfeeding as ScreeningAnswer,
      eatingDisorderConcern:
          eatingDisorderConcern == const $CopyWithPlaceholder()
          ? _value.eatingDisorderConcern
          // ignore: cast_nullable_to_non_nullable
          : eatingDisorderConcern as ScreeningAnswer,
      medicalDietCondition: medicalDietCondition == const $CopyWithPlaceholder()
          ? _value.medicalDietCondition
          // ignore: cast_nullable_to_non_nullable
          : medicalDietCondition as ScreeningAnswer,
    );
  }
}

extension $ScreeningAnswersCopyWith on ScreeningAnswers {
  /// Returns a callable class that can be used as follows: `instanceOfScreeningAnswers.copyWith(...)` or like so:`instanceOfScreeningAnswers.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ScreeningAnswersCWProxy get copyWith => _$ScreeningAnswersCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScreeningAnswers _$ScreeningAnswersFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ScreeningAnswers',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'pregnancy_or_breastfeeding',
            'eating_disorder_concern',
            'medical_diet_condition',
          ],
        );
        final val = ScreeningAnswers(
          pregnancyOrBreastfeeding: $checkedConvert(
            'pregnancy_or_breastfeeding',
            (v) => $enumDecode(_$ScreeningAnswerEnumMap, v),
          ),
          eatingDisorderConcern: $checkedConvert(
            'eating_disorder_concern',
            (v) => $enumDecode(_$ScreeningAnswerEnumMap, v),
          ),
          medicalDietCondition: $checkedConvert(
            'medical_diet_condition',
            (v) => $enumDecode(_$ScreeningAnswerEnumMap, v),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'pregnancyOrBreastfeeding': 'pregnancy_or_breastfeeding',
        'eatingDisorderConcern': 'eating_disorder_concern',
        'medicalDietCondition': 'medical_diet_condition',
      },
    );

Map<String, dynamic> _$ScreeningAnswersToJson(ScreeningAnswers instance) =>
    <String, dynamic>{
      'pregnancy_or_breastfeeding':
          _$ScreeningAnswerEnumMap[instance.pregnancyOrBreastfeeding]!,
      'eating_disorder_concern':
          _$ScreeningAnswerEnumMap[instance.eatingDisorderConcern]!,
      'medical_diet_condition':
          _$ScreeningAnswerEnumMap[instance.medicalDietCondition]!,
    };

const _$ScreeningAnswerEnumMap = {
  ScreeningAnswer.yes: 'yes',
  ScreeningAnswer.no: 'no',
  ScreeningAnswer.preferNotToSay: 'prefer_not_to_say',
};
