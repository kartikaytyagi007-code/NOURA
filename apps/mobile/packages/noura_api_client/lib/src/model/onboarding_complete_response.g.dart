// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_complete_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OnboardingCompleteResponseCWProxy {
  OnboardingCompleteResponse data(OnboardingComplete data);

  OnboardingCompleteResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OnboardingCompleteResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OnboardingCompleteResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  OnboardingCompleteResponse call({OnboardingComplete data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOnboardingCompleteResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOnboardingCompleteResponse.copyWith.fieldName(...)`
class _$OnboardingCompleteResponseCWProxyImpl
    implements _$OnboardingCompleteResponseCWProxy {
  const _$OnboardingCompleteResponseCWProxyImpl(this._value);

  final OnboardingCompleteResponse _value;

  @override
  OnboardingCompleteResponse data(OnboardingComplete data) => this(data: data);

  @override
  OnboardingCompleteResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OnboardingCompleteResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OnboardingCompleteResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  OnboardingCompleteResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return OnboardingCompleteResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as OnboardingComplete,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $OnboardingCompleteResponseCopyWith on OnboardingCompleteResponse {
  /// Returns a callable class that can be used as follows: `instanceOfOnboardingCompleteResponse.copyWith(...)` or like so:`instanceOfOnboardingCompleteResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OnboardingCompleteResponseCWProxy get copyWith =>
      _$OnboardingCompleteResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OnboardingCompleteResponse _$OnboardingCompleteResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('OnboardingCompleteResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = OnboardingCompleteResponse(
    data: $checkedConvert(
      'data',
      (v) => OnboardingComplete.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => Meta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$OnboardingCompleteResponseToJson(
  OnboardingCompleteResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
