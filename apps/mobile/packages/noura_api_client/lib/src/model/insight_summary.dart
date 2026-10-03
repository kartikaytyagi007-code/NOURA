//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'insight_summary.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class InsightSummary {
  /// Returns a new [InsightSummary] instance.
  InsightSummary({required this.key, required this.text});

  @JsonKey(name: r'key', required: true, includeIfNull: false)
  final String key;

  @JsonKey(name: r'text', required: true, includeIfNull: false)
  final String text;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is InsightSummary &&
            runtimeType == other.runtimeType &&
            equals([key, text], [other.key, other.text]);
  }

  @override
  int get hashCode => runtimeType.hashCode ^ mapPropsToHashCode([key, text]);

  factory InsightSummary.fromJson(Map<String, dynamic> json) =>
      _$InsightSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$InsightSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
