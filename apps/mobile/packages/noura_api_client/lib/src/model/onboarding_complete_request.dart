//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/consent_input.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'onboarding_complete_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OnboardingCompleteRequest {
  /// Returns a new [OnboardingCompleteRequest] instance.
  OnboardingCompleteRequest({
    required this.expectedRevision,

    required this.consents,
  });

  // minimum: 1
  @JsonKey(name: r'expected_revision', required: true, includeIfNull: false)
  final int expectedRevision;

  @JsonKey(name: r'consents', required: true, includeIfNull: false)
  final List<ConsentInput> consents;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is OnboardingCompleteRequest &&
            runtimeType == other.runtimeType &&
            equals(
              [expectedRevision, consents],
              [other.expectedRevision, other.consents],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([expectedRevision, consents]);

  factory OnboardingCompleteRequest.fromJson(Map<String, dynamic> json) =>
      _$OnboardingCompleteRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OnboardingCompleteRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
