//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/eligibility_status.dart';
import 'package:noura_api_client/src/model/onboarding.dart';
import 'package:noura_api_client/src/model/profile.dart';
import 'package:noura_api_client/src/model/training_preferences.dart';
import 'package:noura_api_client/src/model/preferences.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'me.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Me {
  /// Returns a new [Me] instance.
  Me({
    required this.userId,

    required this.profile,

    required this.preferences,

    required this.trainingPreferences,

    required this.eligibilityStatus,

    required this.onboarding,
  });

  @JsonKey(name: r'user_id', required: true, includeIfNull: false)
  final String userId;

  @JsonKey(name: r'profile', required: true, includeIfNull: false)
  final Profile profile;

  @JsonKey(name: r'preferences', required: true, includeIfNull: true)
  final Preferences? preferences;

  @JsonKey(name: r'training_preferences', required: true, includeIfNull: true)
  final TrainingPreferences? trainingPreferences;

  @JsonKey(name: r'eligibility_status', required: true, includeIfNull: true)
  final EligibilityStatus? eligibilityStatus;

  @JsonKey(name: r'onboarding', required: true, includeIfNull: false)
  final Onboarding onboarding;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Me &&
            runtimeType == other.runtimeType &&
            equals(
              [
                userId,
                profile,
                preferences,
                trainingPreferences,
                eligibilityStatus,
                onboarding,
              ],
              [
                other.userId,
                other.profile,
                other.preferences,
                other.trainingPreferences,
                other.eligibilityStatus,
                other.onboarding,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        userId,
        profile,
        preferences,
        trainingPreferences,
        eligibilityStatus,
        onboarding,
      ]);

  factory Me.fromJson(Map<String, dynamic> json) => _$MeFromJson(json);

  Map<String, dynamic> toJson() => _$MeToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
