// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_message_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CoachMessageListResponseCWProxy {
  CoachMessageListResponse data(CoachMessageList data);

  CoachMessageListResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CoachMessageListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CoachMessageListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CoachMessageListResponse call({CoachMessageList data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCoachMessageListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCoachMessageListResponse.copyWith.fieldName(...)`
class _$CoachMessageListResponseCWProxyImpl
    implements _$CoachMessageListResponseCWProxy {
  const _$CoachMessageListResponseCWProxyImpl(this._value);

  final CoachMessageListResponse _value;

  @override
  CoachMessageListResponse data(CoachMessageList data) => this(data: data);

  @override
  CoachMessageListResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CoachMessageListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CoachMessageListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CoachMessageListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return CoachMessageListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as CoachMessageList,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $CoachMessageListResponseCopyWith on CoachMessageListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfCoachMessageListResponse.copyWith(...)` or like so:`instanceOfCoachMessageListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CoachMessageListResponseCWProxy get copyWith =>
      _$CoachMessageListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoachMessageListResponse _$CoachMessageListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CoachMessageListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = CoachMessageListResponse(
    data: $checkedConvert(
      'data',
      (v) => CoachMessageList.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => Meta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$CoachMessageListResponseToJson(
  CoachMessageListResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
