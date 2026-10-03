// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recognition_item.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RecognitionItemCWProxy {
  RecognitionItem temporaryId(String temporaryId);

  RecognitionItem label(String label);

  RecognitionItem alternativeLabels(List<String> alternativeLabels);

  RecognitionItem confidenceBand(
    RecognitionItemConfidenceBandEnum confidenceBand,
  );

  RecognitionItem estimatedGrams(NumberRange? estimatedGrams);

  RecognitionItem preparationQuestions(List<String> preparationQuestions);

  RecognitionItem needsConfirmation(bool needsConfirmation);

  RecognitionItem catalogCandidates(List<String> catalogCandidates);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RecognitionItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RecognitionItem(...).copyWith(id: 12, name: "My name")
  /// ````
  RecognitionItem call({
    String temporaryId,
    String label,
    List<String> alternativeLabels,
    RecognitionItemConfidenceBandEnum confidenceBand,
    NumberRange? estimatedGrams,
    List<String> preparationQuestions,
    bool needsConfirmation,
    List<String> catalogCandidates,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRecognitionItem.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRecognitionItem.copyWith.fieldName(...)`
class _$RecognitionItemCWProxyImpl implements _$RecognitionItemCWProxy {
  const _$RecognitionItemCWProxyImpl(this._value);

  final RecognitionItem _value;

  @override
  RecognitionItem temporaryId(String temporaryId) =>
      this(temporaryId: temporaryId);

  @override
  RecognitionItem label(String label) => this(label: label);

  @override
  RecognitionItem alternativeLabels(List<String> alternativeLabels) =>
      this(alternativeLabels: alternativeLabels);

  @override
  RecognitionItem confidenceBand(
    RecognitionItemConfidenceBandEnum confidenceBand,
  ) => this(confidenceBand: confidenceBand);

  @override
  RecognitionItem estimatedGrams(NumberRange? estimatedGrams) =>
      this(estimatedGrams: estimatedGrams);

  @override
  RecognitionItem preparationQuestions(List<String> preparationQuestions) =>
      this(preparationQuestions: preparationQuestions);

  @override
  RecognitionItem needsConfirmation(bool needsConfirmation) =>
      this(needsConfirmation: needsConfirmation);

  @override
  RecognitionItem catalogCandidates(List<String> catalogCandidates) =>
      this(catalogCandidates: catalogCandidates);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RecognitionItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RecognitionItem(...).copyWith(id: 12, name: "My name")
  /// ````
  RecognitionItem call({
    Object? temporaryId = const $CopyWithPlaceholder(),
    Object? label = const $CopyWithPlaceholder(),
    Object? alternativeLabels = const $CopyWithPlaceholder(),
    Object? confidenceBand = const $CopyWithPlaceholder(),
    Object? estimatedGrams = const $CopyWithPlaceholder(),
    Object? preparationQuestions = const $CopyWithPlaceholder(),
    Object? needsConfirmation = const $CopyWithPlaceholder(),
    Object? catalogCandidates = const $CopyWithPlaceholder(),
  }) {
    return RecognitionItem(
      temporaryId: temporaryId == const $CopyWithPlaceholder()
          ? _value.temporaryId
          // ignore: cast_nullable_to_non_nullable
          : temporaryId as String,
      label: label == const $CopyWithPlaceholder()
          ? _value.label
          // ignore: cast_nullable_to_non_nullable
          : label as String,
      alternativeLabels: alternativeLabels == const $CopyWithPlaceholder()
          ? _value.alternativeLabels
          // ignore: cast_nullable_to_non_nullable
          : alternativeLabels as List<String>,
      confidenceBand: confidenceBand == const $CopyWithPlaceholder()
          ? _value.confidenceBand
          // ignore: cast_nullable_to_non_nullable
          : confidenceBand as RecognitionItemConfidenceBandEnum,
      estimatedGrams: estimatedGrams == const $CopyWithPlaceholder()
          ? _value.estimatedGrams
          // ignore: cast_nullable_to_non_nullable
          : estimatedGrams as NumberRange?,
      preparationQuestions: preparationQuestions == const $CopyWithPlaceholder()
          ? _value.preparationQuestions
          // ignore: cast_nullable_to_non_nullable
          : preparationQuestions as List<String>,
      needsConfirmation: needsConfirmation == const $CopyWithPlaceholder()
          ? _value.needsConfirmation
          // ignore: cast_nullable_to_non_nullable
          : needsConfirmation as bool,
      catalogCandidates: catalogCandidates == const $CopyWithPlaceholder()
          ? _value.catalogCandidates
          // ignore: cast_nullable_to_non_nullable
          : catalogCandidates as List<String>,
    );
  }
}

extension $RecognitionItemCopyWith on RecognitionItem {
  /// Returns a callable class that can be used as follows: `instanceOfRecognitionItem.copyWith(...)` or like so:`instanceOfRecognitionItem.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RecognitionItemCWProxy get copyWith => _$RecognitionItemCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecognitionItem _$RecognitionItemFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'RecognitionItem',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'temporary_id',
            'label',
            'alternative_labels',
            'confidence_band',
            'estimated_grams',
            'preparation_questions',
            'needs_confirmation',
            'catalog_candidates',
          ],
        );
        final val = RecognitionItem(
          temporaryId: $checkedConvert('temporary_id', (v) => v as String),
          label: $checkedConvert('label', (v) => v as String),
          alternativeLabels: $checkedConvert(
            'alternative_labels',
            (v) => (v as List<dynamic>).map((e) => e as String).toList(),
          ),
          confidenceBand: $checkedConvert(
            'confidence_band',
            (v) => $enumDecode(_$RecognitionItemConfidenceBandEnumEnumMap, v),
          ),
          estimatedGrams: $checkedConvert(
            'estimated_grams',
            (v) => v == null
                ? null
                : NumberRange.fromJson(v as Map<String, dynamic>),
          ),
          preparationQuestions: $checkedConvert(
            'preparation_questions',
            (v) => (v as List<dynamic>).map((e) => e as String).toList(),
          ),
          needsConfirmation: $checkedConvert(
            'needs_confirmation',
            (v) => v as bool,
          ),
          catalogCandidates: $checkedConvert(
            'catalog_candidates',
            (v) => (v as List<dynamic>).map((e) => e as String).toList(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'temporaryId': 'temporary_id',
        'alternativeLabels': 'alternative_labels',
        'confidenceBand': 'confidence_band',
        'estimatedGrams': 'estimated_grams',
        'preparationQuestions': 'preparation_questions',
        'needsConfirmation': 'needs_confirmation',
        'catalogCandidates': 'catalog_candidates',
      },
    );

Map<String, dynamic> _$RecognitionItemToJson(RecognitionItem instance) =>
    <String, dynamic>{
      'temporary_id': instance.temporaryId,
      'label': instance.label,
      'alternative_labels': instance.alternativeLabels,
      'confidence_band':
          _$RecognitionItemConfidenceBandEnumEnumMap[instance.confidenceBand]!,
      'estimated_grams': instance.estimatedGrams?.toJson(),
      'preparation_questions': instance.preparationQuestions,
      'needs_confirmation': instance.needsConfirmation,
      'catalog_candidates': instance.catalogCandidates,
    };

const _$RecognitionItemConfidenceBandEnumEnumMap = {
  RecognitionItemConfidenceBandEnum.low: 'low',
  RecognitionItemConfidenceBandEnum.medium: 'medium',
  RecognitionItemConfidenceBandEnum.high: 'high',
};
