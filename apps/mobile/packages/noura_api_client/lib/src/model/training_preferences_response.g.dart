// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_preferences_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TrainingPreferencesResponseCWProxy {
  TrainingPreferencesResponse data(TrainingPreferences data);

  TrainingPreferencesResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TrainingPreferencesResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TrainingPreferencesResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  TrainingPreferencesResponse call({TrainingPreferences data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTrainingPreferencesResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTrainingPreferencesResponse.copyWith.fieldName(...)`
class _$TrainingPreferencesResponseCWProxyImpl
    implements _$TrainingPreferencesResponseCWProxy {
  const _$TrainingPreferencesResponseCWProxyImpl(this._value);

  final TrainingPreferencesResponse _value;

  @override
  TrainingPreferencesResponse data(TrainingPreferences data) =>
      this(data: data);

  @override
  TrainingPreferencesResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TrainingPreferencesResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TrainingPreferencesResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  TrainingPreferencesResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return TrainingPreferencesResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as TrainingPreferences,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $TrainingPreferencesResponseCopyWith on TrainingPreferencesResponse {
  /// Returns a callable class that can be used as follows: `instanceOfTrainingPreferencesResponse.copyWith(...)` or like so:`instanceOfTrainingPreferencesResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TrainingPreferencesResponseCWProxy get copyWith =>
      _$TrainingPreferencesResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingPreferencesResponse _$TrainingPreferencesResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('TrainingPreferencesResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = TrainingPreferencesResponse(
    data: $checkedConvert(
      'data',
      (v) => TrainingPreferences.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => Meta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$TrainingPreferencesResponseToJson(
  TrainingPreferencesResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
