//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/recognition_item.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'recognition.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Recognition {
  /// Returns a new [Recognition] instance.
  Recognition({
    required this.schemaVersion,

    required this.imageIsFood,

    required this.quality,

    required this.items,

    required this.clarification,
  });

  @JsonKey(name: r'schema_version', required: true, includeIfNull: false)
  final RecognitionSchemaVersionEnum schemaVersion;

  @JsonKey(name: r'image_is_food', required: true, includeIfNull: false)
  final bool imageIsFood;

  @JsonKey(name: r'quality', required: true, includeIfNull: false)
  final RecognitionQualityEnum quality;

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<RecognitionItem> items;

  @JsonKey(name: r'clarification', required: true, includeIfNull: true)
  final String? clarification;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Recognition &&
            runtimeType == other.runtimeType &&
            equals(
              [schemaVersion, imageIsFood, quality, items, clarification],
              [
                other.schemaVersion,
                other.imageIsFood,
                other.quality,
                other.items,
                other.clarification,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        schemaVersion,
        imageIsFood,
        quality,
        items,
        clarification,
      ]);

  factory Recognition.fromJson(Map<String, dynamic> json) =>
      _$RecognitionFromJson(json);

  Map<String, dynamic> toJson() => _$RecognitionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum RecognitionSchemaVersionEnum {
  @JsonValue(r'1')
  n1(r'1');

  const RecognitionSchemaVersionEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum RecognitionQualityEnum {
  @JsonValue(r'usable')
  usable(r'usable'),
  @JsonValue(r'blurry')
  blurry(r'blurry'),
  @JsonValue(r'too_dark')
  tooDark(r'too_dark'),
  @JsonValue(r'ambiguous')
  ambiguous(r'ambiguous'),
  @JsonValue(r'unusable')
  unusable(r'unusable');

  const RecognitionQualityEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
