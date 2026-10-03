//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/planning.dart';
import 'package:noura_api_client/src/model/eligibility_status.dart';
import 'package:noura_api_client/src/model/onboarding.dart';
import 'package:noura_api_client/src/model/goal.dart';
import 'package:noura_api_client/src/model/profile.dart';
import 'package:noura_api_client/src/model/screening_answers.dart';
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

    required this.goal,

    required this.preferences,

    required this.trainingPreferences,

    required this.eligibilityStatus,

    required this.screening,

    required this.onboarding,

    required this.planning,
  });

  @JsonKey(name: r'user_id', required: true, includeIfNull: false)
  final String userId;

  @JsonKey(name: r'profile', required: true, includeIfNull: false)
  final Profile profile;

  @JsonKey(name: r'goal', required: true, includeIfNull: true)
  final Goal? goal;

  @JsonKey(name: r'preferences', required: true, includeIfNull: true)
  final Preferences? preferences;

  @JsonKey(name: r'training_preferences', required: true, includeIfNull: true)
  final TrainingPreferences? trainingPreferences;

  @JsonKey(name: r'eligibility_status', required: true, includeIfNull: true)
  final EligibilityStatus? eligibilityStatus;

  /// The stored screening answers, or null until the user has answered.
  @JsonKey(name: r'screening', required: true, includeIfNull: true)
  final ScreeningAnswers? screening;

  @JsonKey(name: r'onboarding', required: true, includeIfNull: false)
  final Onboarding onboarding;

  /// Null until onboarding is completed.
  @JsonKey(name: r'planning', required: true, includeIfNull: true)
  final Planning? planning;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Me &&
            runtimeType == other.runtimeType &&
            equals(
              [
                userId,
                profile,
                goal,
                preferences,
                trainingPreferences,
                eligibilityStatus,
                screening,
                onboarding,
                planning,
              ],
              [
                other.userId,
                other.profile,
                other.goal,
                other.preferences,
                other.trainingPreferences,
                other.eligibilityStatus,
                other.screening,
                other.onboarding,
                other.planning,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        userId,
        profile,
        goal,
        preferences,
        trainingPreferences,
        eligibilityStatus,
        screening,
        onboarding,
        planning,
      ]);

  factory Me.fromJson(Map<String, dynamic> json) => _$MeFromJson(json);

  Map<String, dynamic> toJson() => _$MeToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
