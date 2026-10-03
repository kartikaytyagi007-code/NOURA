// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_complete.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OnboardingCompleteCWProxy {
  OnboardingComplete me(Me me);

  OnboardingComplete jobIds(List<String> jobIds);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OnboardingComplete(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OnboardingComplete(...).copyWith(id: 12, name: "My name")
  /// ````
  OnboardingComplete call({Me me, List<String> jobIds});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOnboardingComplete.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOnboardingComplete.copyWith.fieldName(...)`
class _$OnboardingCompleteCWProxyImpl implements _$OnboardingCompleteCWProxy {
  const _$OnboardingCompleteCWProxyImpl(this._value);

  final OnboardingComplete _value;

  @override
  OnboardingComplete me(Me me) => this(me: me);

  @override
  OnboardingComplete jobIds(List<String> jobIds) => this(jobIds: jobIds);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OnboardingComplete(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OnboardingComplete(...).copyWith(id: 12, name: "My name")
  /// ````
  OnboardingComplete call({
    Object? me = const $CopyWithPlaceholder(),
    Object? jobIds = const $CopyWithPlaceholder(),
  }) {
    return OnboardingComplete(
      me: me == const $CopyWithPlaceholder()
          ? _value.me
          // ignore: cast_nullable_to_non_nullable
          : me as Me,
      jobIds: jobIds == const $CopyWithPlaceholder()
          ? _value.jobIds
          // ignore: cast_nullable_to_non_nullable
          : jobIds as List<String>,
    );
  }
}

extension $OnboardingCompleteCopyWith on OnboardingComplete {
  /// Returns a callable class that can be used as follows: `instanceOfOnboardingComplete.copyWith(...)` or like so:`instanceOfOnboardingComplete.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OnboardingCompleteCWProxy get copyWith =>
      _$OnboardingCompleteCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OnboardingComplete _$OnboardingCompleteFromJson(Map<String, dynamic> json) =>
    $checkedCreate('OnboardingComplete', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['me', 'job_ids']);
      final val = OnboardingComplete(
        me: $checkedConvert(
          'me',
          (v) => Me.fromJson(v as Map<String, dynamic>),
        ),
        jobIds: $checkedConvert(
          'job_ids',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'jobIds': 'job_ids'});

Map<String, dynamic> _$OnboardingCompleteToJson(OnboardingComplete instance) =>
    <String, dynamic>{'me': instance.me.toJson(), 'job_ids': instance.jobIds};
