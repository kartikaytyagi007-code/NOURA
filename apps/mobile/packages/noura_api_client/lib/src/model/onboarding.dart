//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/onboarding_status.dart';
import 'package:noura_api_client/src/model/onboarding_step.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'onboarding.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Onboarding {
  /// Returns a new [Onboarding] instance.
  Onboarding({required this.status, required this.step});

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final OnboardingStatus status;

  @JsonKey(name: r'step', required: true, includeIfNull: true)
  final OnboardingStep? step;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Onboarding &&
            runtimeType == other.runtimeType &&
            equals([status, step], [other.status, other.step]);
  }

  @override
  int get hashCode => runtimeType.hashCode ^ mapPropsToHashCode([status, step]);

  factory Onboarding.fromJson(Map<String, dynamic> json) =>
      _$OnboardingFromJson(json);

  Map<String, dynamic> toJson() => _$OnboardingToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
