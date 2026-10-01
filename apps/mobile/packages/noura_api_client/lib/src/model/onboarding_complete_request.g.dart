// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_complete_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OnboardingCompleteRequestCWProxy {
  OnboardingCompleteRequest expectedRevision(int expectedRevision);

  OnboardingCompleteRequest consents(List<ConsentInput> consents);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OnboardingCompleteRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OnboardingCompleteRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  OnboardingCompleteRequest call({
    int expectedRevision,
    List<ConsentInput> consents,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOnboardingCompleteRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOnboardingCompleteRequest.copyWith.fieldName(...)`
class _$OnboardingCompleteRequestCWProxyImpl
    implements _$OnboardingCompleteRequestCWProxy {
  const _$OnboardingCompleteRequestCWProxyImpl(this._value);

  final OnboardingCompleteRequest _value;

  @override
  OnboardingCompleteRequest expectedRevision(int expectedRevision) =>
      this(expectedRevision: expectedRevision);

  @override
  OnboardingCompleteRequest consents(List<ConsentInput> consents) =>
      this(consents: consents);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OnboardingCompleteRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OnboardingCompleteRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  OnboardingCompleteRequest call({
    Object? expectedRevision = const $CopyWithPlaceholder(),
    Object? consents = const $CopyWithPlaceholder(),
  }) {
    return OnboardingCompleteRequest(
      expectedRevision: expectedRevision == const $CopyWithPlaceholder()
          ? _value.expectedRevision
          // ignore: cast_nullable_to_non_nullable
          : expectedRevision as int,
      consents: consents == const $CopyWithPlaceholder()
          ? _value.consents
          // ignore: cast_nullable_to_non_nullable
          : consents as List<ConsentInput>,
    );
  }
}

extension $OnboardingCompleteRequestCopyWith on OnboardingCompleteRequest {
  /// Returns a callable class that can be used as follows: `instanceOfOnboardingCompleteRequest.copyWith(...)` or like so:`instanceOfOnboardingCompleteRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OnboardingCompleteRequestCWProxy get copyWith =>
      _$OnboardingCompleteRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OnboardingCompleteRequest _$OnboardingCompleteRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('OnboardingCompleteRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['expected_revision', 'consents']);
  final val = OnboardingCompleteRequest(
    expectedRevision: $checkedConvert(
      'expected_revision',
      (v) => (v as num).toInt(),
    ),
    consents: $checkedConvert(
      'consents',
      (v) => (v as List<dynamic>)
          .map((e) => ConsentInput.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
}, fieldKeyMap: const {'expectedRevision': 'expected_revision'});

Map<String, dynamic> _$OnboardingCompleteRequestToJson(
  OnboardingCompleteRequest instance,
) => <String, dynamic>{
  'expected_revision': instance.expectedRevision,
  'consents': instance.consents.map((e) => e.toJson()).toList(),
};
