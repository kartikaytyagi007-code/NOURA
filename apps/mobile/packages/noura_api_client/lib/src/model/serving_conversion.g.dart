// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serving_conversion.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ServingConversionCWProxy {
  ServingConversion unit(String unit);

  ServingConversion gramsMin(num gramsMin);

  ServingConversion gramsMax(num gramsMax);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ServingConversion(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ServingConversion(...).copyWith(id: 12, name: "My name")
  /// ````
  ServingConversion call({String unit, num gramsMin, num gramsMax});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfServingConversion.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfServingConversion.copyWith.fieldName(...)`
class _$ServingConversionCWProxyImpl implements _$ServingConversionCWProxy {
  const _$ServingConversionCWProxyImpl(this._value);

  final ServingConversion _value;

  @override
  ServingConversion unit(String unit) => this(unit: unit);

  @override
  ServingConversion gramsMin(num gramsMin) => this(gramsMin: gramsMin);

  @override
  ServingConversion gramsMax(num gramsMax) => this(gramsMax: gramsMax);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ServingConversion(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ServingConversion(...).copyWith(id: 12, name: "My name")
  /// ````
  ServingConversion call({
    Object? unit = const $CopyWithPlaceholder(),
    Object? gramsMin = const $CopyWithPlaceholder(),
    Object? gramsMax = const $CopyWithPlaceholder(),
  }) {
    return ServingConversion(
      unit: unit == const $CopyWithPlaceholder()
          ? _value.unit
          // ignore: cast_nullable_to_non_nullable
          : unit as String,
      gramsMin: gramsMin == const $CopyWithPlaceholder()
          ? _value.gramsMin
          // ignore: cast_nullable_to_non_nullable
          : gramsMin as num,
      gramsMax: gramsMax == const $CopyWithPlaceholder()
          ? _value.gramsMax
          // ignore: cast_nullable_to_non_nullable
          : gramsMax as num,
    );
  }
}

extension $ServingConversionCopyWith on ServingConversion {
  /// Returns a callable class that can be used as follows: `instanceOfServingConversion.copyWith(...)` or like so:`instanceOfServingConversion.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ServingConversionCWProxy get copyWith =>
      _$ServingConversionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServingConversion _$ServingConversionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ServingConversion', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['unit', 'grams_min', 'grams_max']);
      final val = ServingConversion(
        unit: $checkedConvert('unit', (v) => v as String),
        gramsMin: $checkedConvert('grams_min', (v) => v as num),
        gramsMax: $checkedConvert('grams_max', (v) => v as num),
      );
      return val;
    }, fieldKeyMap: const {'gramsMin': 'grams_min', 'gramsMax': 'grams_max'});

Map<String, dynamic> _$ServingConversionToJson(ServingConversion instance) =>
    <String, dynamic>{
      'unit': instance.unit,
      'grams_min': instance.gramsMin,
      'grams_max': instance.gramsMax,
    };
