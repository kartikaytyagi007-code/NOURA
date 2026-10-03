// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'int_range.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$IntRangeCWProxy {
  IntRange min(int min);

  IntRange max(int max);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IntRange(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IntRange(...).copyWith(id: 12, name: "My name")
  /// ````
  IntRange call({int min, int max});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfIntRange.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfIntRange.copyWith.fieldName(...)`
class _$IntRangeCWProxyImpl implements _$IntRangeCWProxy {
  const _$IntRangeCWProxyImpl(this._value);

  final IntRange _value;

  @override
  IntRange min(int min) => this(min: min);

  @override
  IntRange max(int max) => this(max: max);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IntRange(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IntRange(...).copyWith(id: 12, name: "My name")
  /// ````
  IntRange call({
    Object? min = const $CopyWithPlaceholder(),
    Object? max = const $CopyWithPlaceholder(),
  }) {
    return IntRange(
      min: min == const $CopyWithPlaceholder()
          ? _value.min
          // ignore: cast_nullable_to_non_nullable
          : min as int,
      max: max == const $CopyWithPlaceholder()
          ? _value.max
          // ignore: cast_nullable_to_non_nullable
          : max as int,
    );
  }
}

extension $IntRangeCopyWith on IntRange {
  /// Returns a callable class that can be used as follows: `instanceOfIntRange.copyWith(...)` or like so:`instanceOfIntRange.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$IntRangeCWProxy get copyWith => _$IntRangeCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IntRange _$IntRangeFromJson(Map<String, dynamic> json) =>
    $checkedCreate('IntRange', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['min', 'max']);
      final val = IntRange(
        min: $checkedConvert('min', (v) => (v as num).toInt()),
        max: $checkedConvert('max', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$IntRangeToJson(IntRange instance) => <String, dynamic>{
  'min': instance.min,
  'max': instance.max,
};
