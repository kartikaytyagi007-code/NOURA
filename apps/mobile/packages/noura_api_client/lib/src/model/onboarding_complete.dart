//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/me.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'onboarding_complete.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OnboardingComplete {
  /// Returns a new [OnboardingComplete] instance.
  OnboardingComplete({required this.me, required this.jobIds});

  @JsonKey(name: r'me', required: true, includeIfNull: false)
  final Me me;

  @JsonKey(name: r'job_ids', required: true, includeIfNull: false)
  final List<String> jobIds;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is OnboardingComplete &&
            runtimeType == other.runtimeType &&
            equals([me, jobIds], [other.me, other.jobIds]);
  }

  @override
  int get hashCode => runtimeType.hashCode ^ mapPropsToHashCode([me, jobIds]);

  factory OnboardingComplete.fromJson(Map<String, dynamic> json) =>
      _$OnboardingCompleteFromJson(json);

  Map<String, dynamic> toJson() => _$OnboardingCompleteToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
