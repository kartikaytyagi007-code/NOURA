// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'number_range.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NumberRangeCWProxy {
  NumberRange min(num min);

  NumberRange max(num max);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NumberRange(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NumberRange(...).copyWith(id: 12, name: "My name")
  /// ````
  NumberRange call({num min, num max});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNumberRange.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNumberRange.copyWith.fieldName(...)`
class _$NumberRangeCWProxyImpl implements _$NumberRangeCWProxy {
  const _$NumberRangeCWProxyImpl(this._value);

  final NumberRange _value;

  @override
  NumberRange min(num min) => this(min: min);

  @override
  NumberRange max(num max) => this(max: max);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NumberRange(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NumberRange(...).copyWith(id: 12, name: "My name")
  /// ````
  NumberRange call({
    Object? min = const $CopyWithPlaceholder(),
    Object? max = const $CopyWithPlaceholder(),
  }) {
    return NumberRange(
      min: min == const $CopyWithPlaceholder()
          ? _value.min
          // ignore: cast_nullable_to_non_nullable
          : min as num,
      max: max == const $CopyWithPlaceholder()
          ? _value.max
          // ignore: cast_nullable_to_non_nullable
          : max as num,
    );
  }
}

extension $NumberRangeCopyWith on NumberRange {
  /// Returns a callable class that can be used as follows: `instanceOfNumberRange.copyWith(...)` or like so:`instanceOfNumberRange.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NumberRangeCWProxy get copyWith => _$NumberRangeCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NumberRange _$NumberRangeFromJson(Map<String, dynamic> json) =>
    $checkedCreate('NumberRange', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['min', 'max']);
      final val = NumberRange(
        min: $checkedConvert('min', (v) => v as num),
        max: $checkedConvert('max', (v) => v as num),
      );
      return val;
    });

Map<String, dynamic> _$NumberRangeToJson(NumberRange instance) =>
    <String, dynamic>{'min': instance.min, 'max': instance.max};
