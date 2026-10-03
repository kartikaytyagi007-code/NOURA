// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OnboardingCWProxy {
  Onboarding status(OnboardingStatus status);

  Onboarding step(OnboardingStep? step);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Onboarding(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Onboarding(...).copyWith(id: 12, name: "My name")
  /// ````
  Onboarding call({OnboardingStatus status, OnboardingStep? step});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOnboarding.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOnboarding.copyWith.fieldName(...)`
class _$OnboardingCWProxyImpl implements _$OnboardingCWProxy {
  const _$OnboardingCWProxyImpl(this._value);

  final Onboarding _value;

  @override
  Onboarding status(OnboardingStatus status) => this(status: status);

  @override
  Onboarding step(OnboardingStep? step) => this(step: step);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Onboarding(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Onboarding(...).copyWith(id: 12, name: "My name")
  /// ````
  Onboarding call({
    Object? status = const $CopyWithPlaceholder(),
    Object? step = const $CopyWithPlaceholder(),
  }) {
    return Onboarding(
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as OnboardingStatus,
      step: step == const $CopyWithPlaceholder()
          ? _value.step
          // ignore: cast_nullable_to_non_nullable
          : step as OnboardingStep?,
    );
  }
}

extension $OnboardingCopyWith on Onboarding {
  /// Returns a callable class that can be used as follows: `instanceOfOnboarding.copyWith(...)` or like so:`instanceOfOnboarding.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OnboardingCWProxy get copyWith => _$OnboardingCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Onboarding _$OnboardingFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Onboarding', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['status', 'step']);
      final val = Onboarding(
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$OnboardingStatusEnumMap, v),
        ),
        step: $checkedConvert(
          'step',
          (v) => $enumDecodeNullable(_$OnboardingStepEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$OnboardingToJson(Onboarding instance) =>
    <String, dynamic>{
      'status': _$OnboardingStatusEnumMap[instance.status]!,
      'step': _$OnboardingStepEnumMap[instance.step],
    };

const _$OnboardingStatusEnumMap = {
  OnboardingStatus.notStarted: 'not_started',
  OnboardingStatus.inProgress: 'in_progress',
  OnboardingStatus.completed: 'completed',
};

const _$OnboardingStepEnumMap = {
  OnboardingStep.basics: 'basics',
  OnboardingStep.goals: 'goals',
  OnboardingStep.diet: 'diet',
  OnboardingStep.training: 'training',
  OnboardingStep.eligibility: 'eligibility',
  OnboardingStep.review: 'review',
};
