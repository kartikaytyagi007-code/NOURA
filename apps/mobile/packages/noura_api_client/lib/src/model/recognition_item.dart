//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/number_range.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'recognition_item.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RecognitionItem {
  /// Returns a new [RecognitionItem] instance.
  RecognitionItem({
    required this.temporaryId,

    required this.label,

    required this.alternativeLabels,

    required this.confidenceBand,

    required this.estimatedGrams,

    required this.preparationQuestions,

    required this.needsConfirmation,

    required this.catalogCandidates,
  });

  @JsonKey(name: r'temporary_id', required: true, includeIfNull: false)
  final String temporaryId;

  @JsonKey(name: r'label', required: true, includeIfNull: false)
  final String label;

  @JsonKey(name: r'alternative_labels', required: true, includeIfNull: false)
  final List<String> alternativeLabels;

  @JsonKey(name: r'confidence_band', required: true, includeIfNull: false)
  final RecognitionItemConfidenceBandEnum confidenceBand;

  @JsonKey(name: r'estimated_grams', required: true, includeIfNull: true)
  final NumberRange? estimatedGrams;

  @JsonKey(name: r'preparation_questions', required: true, includeIfNull: false)
  final List<String> preparationQuestions;

  @JsonKey(name: r'needs_confirmation', required: true, includeIfNull: false)
  final bool needsConfirmation;

  @JsonKey(name: r'catalog_candidates', required: true, includeIfNull: false)
  final List<String> catalogCandidates;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is RecognitionItem &&
            runtimeType == other.runtimeType &&
            equals(
              [
                temporaryId,
                label,
                alternativeLabels,
                confidenceBand,
                estimatedGrams,
                preparationQuestions,
                needsConfirmation,
                catalogCandidates,
              ],
              [
                other.temporaryId,
                other.label,
                other.alternativeLabels,
                other.confidenceBand,
                other.estimatedGrams,
                other.preparationQuestions,
                other.needsConfirmation,
                other.catalogCandidates,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        temporaryId,
        label,
        alternativeLabels,
        confidenceBand,
        estimatedGrams,
        preparationQuestions,
        needsConfirmation,
        catalogCandidates,
      ]);

  factory RecognitionItem.fromJson(Map<String, dynamic> json) =>
      _$RecognitionItemFromJson(json);

  Map<String, dynamic> toJson() => _$RecognitionItemToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum RecognitionItemConfidenceBandEnum {
  @JsonValue(r'low')
  low(r'low'),
  @JsonValue(r'medium')
  medium(r'medium'),
  @JsonValue(r'high')
  high(r'high');

  const RecognitionItemConfidenceBandEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
