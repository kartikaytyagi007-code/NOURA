// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UsageCWProxy {
  Usage timezone(String timezone);

  Usage features(List<FeatureUsage> features);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Usage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Usage(...).copyWith(id: 12, name: "My name")
  /// ````
  Usage call({String timezone, List<FeatureUsage> features});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUsage.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUsage.copyWith.fieldName(...)`
class _$UsageCWProxyImpl implements _$UsageCWProxy {
  const _$UsageCWProxyImpl(this._value);

  final Usage _value;

  @override
  Usage timezone(String timezone) => this(timezone: timezone);

  @override
  Usage features(List<FeatureUsage> features) => this(features: features);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Usage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Usage(...).copyWith(id: 12, name: "My name")
  /// ````
  Usage call({
    Object? timezone = const $CopyWithPlaceholder(),
    Object? features = const $CopyWithPlaceholder(),
  }) {
    return Usage(
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String,
      features: features == const $CopyWithPlaceholder()
          ? _value.features
          // ignore: cast_nullable_to_non_nullable
          : features as List<FeatureUsage>,
    );
  }
}

extension $UsageCopyWith on Usage {
  /// Returns a callable class that can be used as follows: `instanceOfUsage.copyWith(...)` or like so:`instanceOfUsage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UsageCWProxy get copyWith => _$UsageCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Usage _$UsageFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Usage', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['timezone', 'features']);
      final val = Usage(
        timezone: $checkedConvert('timezone', (v) => v as String),
        features: $checkedConvert(
          'features',
          (v) => (v as List<dynamic>)
              .map((e) => FeatureUsage.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$UsageToJson(Usage instance) => <String, dynamic>{
  'timezone': instance.timezone,
  'features': instance.features.map((e) => e.toJson()).toList(),
};
