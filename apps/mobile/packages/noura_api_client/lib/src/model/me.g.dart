// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeCWProxy {
  Me userId(String userId);

  Me profile(Profile profile);

  Me preferences(Preferences? preferences);

  Me trainingPreferences(TrainingPreferences? trainingPreferences);

  Me eligibilityStatus(EligibilityStatus? eligibilityStatus);

  Me onboarding(Onboarding onboarding);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Me(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Me(...).copyWith(id: 12, name: "My name")
  /// ````
  Me call({
    String userId,
    Profile profile,
    Preferences? preferences,
    TrainingPreferences? trainingPreferences,
    EligibilityStatus? eligibilityStatus,
    Onboarding onboarding,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMe.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMe.copyWith.fieldName(...)`
class _$MeCWProxyImpl implements _$MeCWProxy {
  const _$MeCWProxyImpl(this._value);

  final Me _value;

  @override
  Me userId(String userId) => this(userId: userId);

  @override
  Me profile(Profile profile) => this(profile: profile);

  @override
  Me preferences(Preferences? preferences) => this(preferences: preferences);

  @override
  Me trainingPreferences(TrainingPreferences? trainingPreferences) =>
      this(trainingPreferences: trainingPreferences);

  @override
  Me eligibilityStatus(EligibilityStatus? eligibilityStatus) =>
      this(eligibilityStatus: eligibilityStatus);

  @override
  Me onboarding(Onboarding onboarding) => this(onboarding: onboarding);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Me(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Me(...).copyWith(id: 12, name: "My name")
  /// ````
  Me call({
    Object? userId = const $CopyWithPlaceholder(),
    Object? profile = const $CopyWithPlaceholder(),
    Object? preferences = const $CopyWithPlaceholder(),
    Object? trainingPreferences = const $CopyWithPlaceholder(),
    Object? eligibilityStatus = const $CopyWithPlaceholder(),
    Object? onboarding = const $CopyWithPlaceholder(),
  }) {
    return Me(
      userId: userId == const $CopyWithPlaceholder()
          ? _value.userId
          // ignore: cast_nullable_to_non_nullable
          : userId as String,
      profile: profile == const $CopyWithPlaceholder()
          ? _value.profile
          // ignore: cast_nullable_to_non_nullable
          : profile as Profile,
      preferences: preferences == const $CopyWithPlaceholder()
          ? _value.preferences
          // ignore: cast_nullable_to_non_nullable
          : preferences as Preferences?,
      trainingPreferences: trainingPreferences == const $CopyWithPlaceholder()
          ? _value.trainingPreferences
          // ignore: cast_nullable_to_non_nullable
          : trainingPreferences as TrainingPreferences?,
      eligibilityStatus: eligibilityStatus == const $CopyWithPlaceholder()
          ? _value.eligibilityStatus
          // ignore: cast_nullable_to_non_nullable
          : eligibilityStatus as EligibilityStatus?,
      onboarding: onboarding == const $CopyWithPlaceholder()
          ? _value.onboarding
          // ignore: cast_nullable_to_non_nullable
          : onboarding as Onboarding,
    );
  }
}

extension $MeCopyWith on Me {
  /// Returns a callable class that can be used as follows: `instanceOfMe.copyWith(...)` or like so:`instanceOfMe.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeCWProxy get copyWith => _$MeCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Me _$MeFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Me',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'user_id',
        'profile',
        'preferences',
        'training_preferences',
        'eligibility_status',
        'onboarding',
      ],
    );
    final val = Me(
      userId: $checkedConvert('user_id', (v) => v as String),
      profile: $checkedConvert(
        'profile',
        (v) => Profile.fromJson(v as Map<String, dynamic>),
      ),
      preferences: $checkedConvert(
        'preferences',
        (v) =>
            v == null ? null : Preferences.fromJson(v as Map<String, dynamic>),
      ),
      trainingPreferences: $checkedConvert(
        'training_preferences',
        (v) => v == null
            ? null
            : TrainingPreferences.fromJson(v as Map<String, dynamic>),
      ),
      eligibilityStatus: $checkedConvert(
        'eligibility_status',
        (v) => $enumDecodeNullable(_$EligibilityStatusEnumMap, v),
      ),
      onboarding: $checkedConvert(
        'onboarding',
        (v) => Onboarding.fromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'userId': 'user_id',
    'trainingPreferences': 'training_preferences',
    'eligibilityStatus': 'eligibility_status',
  },
);

Map<String, dynamic> _$MeToJson(Me instance) => <String, dynamic>{
  'user_id': instance.userId,
  'profile': instance.profile.toJson(),
  'preferences': instance.preferences?.toJson(),
  'training_preferences': instance.trainingPreferences?.toJson(),
  'eligibility_status': _$EligibilityStatusEnumMap[instance.eligibilityStatus],
  'onboarding': instance.onboarding.toJson(),
};

const _$EligibilityStatusEnumMap = {
  EligibilityStatus.eligible: 'eligible',
  EligibilityStatus.trackingOnly: 'tracking_only',
  EligibilityStatus.needsReview: 'needs_review',
};
