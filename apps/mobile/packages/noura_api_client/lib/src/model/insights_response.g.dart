// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insights_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$InsightsResponseCWProxy {
  InsightsResponse data(Insights data);

  InsightsResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `InsightsResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// InsightsResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  InsightsResponse call({Insights data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfInsightsResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfInsightsResponse.copyWith.fieldName(...)`
class _$InsightsResponseCWProxyImpl implements _$InsightsResponseCWProxy {
  const _$InsightsResponseCWProxyImpl(this._value);

  final InsightsResponse _value;

  @override
  InsightsResponse data(Insights data) => this(data: data);

  @override
  InsightsResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `InsightsResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// InsightsResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  InsightsResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return InsightsResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as Insights,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $InsightsResponseCopyWith on InsightsResponse {
  /// Returns a callable class that can be used as follows: `instanceOfInsightsResponse.copyWith(...)` or like so:`instanceOfInsightsResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$InsightsResponseCWProxy get copyWith => _$InsightsResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InsightsResponse _$InsightsResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('InsightsResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = InsightsResponse(
        data: $checkedConvert(
          'data',
          (v) => Insights.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => Meta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$InsightsResponseToJson(InsightsResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
