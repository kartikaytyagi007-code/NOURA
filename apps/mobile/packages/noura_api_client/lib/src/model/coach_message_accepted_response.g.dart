// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_message_accepted_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CoachMessageAcceptedResponseCWProxy {
  CoachMessageAcceptedResponse data(CoachMessageAccepted data);

  CoachMessageAcceptedResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CoachMessageAcceptedResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CoachMessageAcceptedResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CoachMessageAcceptedResponse call({CoachMessageAccepted data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCoachMessageAcceptedResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCoachMessageAcceptedResponse.copyWith.fieldName(...)`
class _$CoachMessageAcceptedResponseCWProxyImpl
    implements _$CoachMessageAcceptedResponseCWProxy {
  const _$CoachMessageAcceptedResponseCWProxyImpl(this._value);

  final CoachMessageAcceptedResponse _value;

  @override
  CoachMessageAcceptedResponse data(CoachMessageAccepted data) =>
      this(data: data);

  @override
  CoachMessageAcceptedResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CoachMessageAcceptedResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CoachMessageAcceptedResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CoachMessageAcceptedResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return CoachMessageAcceptedResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as CoachMessageAccepted,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $CoachMessageAcceptedResponseCopyWith
    on CoachMessageAcceptedResponse {
  /// Returns a callable class that can be used as follows: `instanceOfCoachMessageAcceptedResponse.copyWith(...)` or like so:`instanceOfCoachMessageAcceptedResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CoachMessageAcceptedResponseCWProxy get copyWith =>
      _$CoachMessageAcceptedResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoachMessageAcceptedResponse _$CoachMessageAcceptedResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CoachMessageAcceptedResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = CoachMessageAcceptedResponse(
    data: $checkedConvert(
      'data',
      (v) => CoachMessageAccepted.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => Meta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$CoachMessageAcceptedResponseToJson(
  CoachMessageAcceptedResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
