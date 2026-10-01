// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_thread_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CoachThreadResponseCWProxy {
  CoachThreadResponse data(CoachThread data);

  CoachThreadResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CoachThreadResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CoachThreadResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CoachThreadResponse call({CoachThread data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCoachThreadResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCoachThreadResponse.copyWith.fieldName(...)`
class _$CoachThreadResponseCWProxyImpl implements _$CoachThreadResponseCWProxy {
  const _$CoachThreadResponseCWProxyImpl(this._value);

  final CoachThreadResponse _value;

  @override
  CoachThreadResponse data(CoachThread data) => this(data: data);

  @override
  CoachThreadResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CoachThreadResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CoachThreadResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CoachThreadResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return CoachThreadResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as CoachThread,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $CoachThreadResponseCopyWith on CoachThreadResponse {
  /// Returns a callable class that can be used as follows: `instanceOfCoachThreadResponse.copyWith(...)` or like so:`instanceOfCoachThreadResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CoachThreadResponseCWProxy get copyWith =>
      _$CoachThreadResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoachThreadResponse _$CoachThreadResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CoachThreadResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = CoachThreadResponse(
        data: $checkedConvert(
          'data',
          (v) => CoachThread.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => Meta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$CoachThreadResponseToJson(
  CoachThreadResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
