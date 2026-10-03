//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/swap_candidate.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'swap_options.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SwapOptions {
  /// Returns a new [SwapOptions] instance.
  SwapOptions({
    required this.planMealId,

    required this.revision,

    required this.candidates,
  });

  @JsonKey(name: r'plan_meal_id', required: true, includeIfNull: false)
  final String planMealId;

  // minimum: 1
  @JsonKey(name: r'revision', required: true, includeIfNull: false)
  final int revision;

  @JsonKey(name: r'candidates', required: true, includeIfNull: false)
  final List<SwapCandidate> candidates;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SwapOptions &&
            runtimeType == other.runtimeType &&
            equals(
              [planMealId, revision, candidates],
              [other.planMealId, other.revision, other.candidates],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([planMealId, revision, candidates]);

  factory SwapOptions.fromJson(Map<String, dynamic> json) =>
      _$SwapOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$SwapOptionsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
