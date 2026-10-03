//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'insight.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Insight {
  /// Returns a new [Insight] instance.
  Insight({
    required this.key,

    required this.evidence,

    required this.explanation,
  });

  @JsonKey(name: r'key', required: true, includeIfNull: false)
  final String key;

  @JsonKey(name: r'evidence', required: true, includeIfNull: false)
  final Map<String, Object> evidence;

  @JsonKey(name: r'explanation', required: true, includeIfNull: true)
  final String? explanation;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Insight &&
            runtimeType == other.runtimeType &&
            equals(
              [key, evidence, explanation],
              [other.key, other.evidence, other.explanation],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([key, evidence, explanation]);

  factory Insight.fromJson(Map<String, dynamic> json) =>
      _$InsightFromJson(json);

  Map<String, dynamic> toJson() => _$InsightToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
