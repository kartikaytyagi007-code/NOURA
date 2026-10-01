//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/meal_balance_component.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'meal_balance.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MealBalance {
  /// Returns a new [MealBalance] instance.
  MealBalance({
    required this.score,

    required this.policyVersion,

    required this.components,

    required this.missingDataMessage,
  });

  // minimum: 0
  // maximum: 100
  @JsonKey(name: r'score', required: true, includeIfNull: true)
  final int? score;

  @JsonKey(name: r'policy_version', required: true, includeIfNull: false)
  final String policyVersion;

  @JsonKey(name: r'components', required: true, includeIfNull: false)
  final List<MealBalanceComponent> components;

  @JsonKey(name: r'missing_data_message', required: true, includeIfNull: true)
  final String? missingDataMessage;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MealBalance &&
            runtimeType == other.runtimeType &&
            equals(
              [score, policyVersion, components, missingDataMessage],
              [
                other.score,
                other.policyVersion,
                other.components,
                other.missingDataMessage,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        score,
        policyVersion,
        components,
        missingDataMessage,
      ]);

  factory MealBalance.fromJson(Map<String, dynamic> json) =>
      _$MealBalanceFromJson(json);

  Map<String, dynamic> toJson() => _$MealBalanceToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
