//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'adherence_summary.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdherenceSummary {
  /// Returns a new [AdherenceSummary] instance.
  AdherenceSummary({
    required this.planActive,

    required this.planned,

    required this.logged,
  });

  @JsonKey(name: r'plan_active', required: true, includeIfNull: false)
  final bool planActive;

  // minimum: 0
  @JsonKey(name: r'planned', required: true, includeIfNull: true)
  final int? planned;

  // minimum: 0
  @JsonKey(name: r'logged', required: true, includeIfNull: true)
  final int? logged;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AdherenceSummary &&
            runtimeType == other.runtimeType &&
            equals(
              [planActive, planned, logged],
              [other.planActive, other.planned, other.logged],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([planActive, planned, logged]);

  factory AdherenceSummary.fromJson(Map<String, dynamic> json) =>
      _$AdherenceSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$AdherenceSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
