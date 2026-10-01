// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_point.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeightPointCWProxy {
  WeightPoint date(DateTime date);

  WeightPoint weightKg(num weightKg);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightPoint(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightPoint(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightPoint call({DateTime date, num weightKg});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeightPoint.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeightPoint.copyWith.fieldName(...)`
class _$WeightPointCWProxyImpl implements _$WeightPointCWProxy {
  const _$WeightPointCWProxyImpl(this._value);

  final WeightPoint _value;

  @override
  WeightPoint date(DateTime date) => this(date: date);

  @override
  WeightPoint weightKg(num weightKg) => this(weightKg: weightKg);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightPoint(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightPoint(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightPoint call({
    Object? date = const $CopyWithPlaceholder(),
    Object? weightKg = const $CopyWithPlaceholder(),
  }) {
    return WeightPoint(
      date: date == const $CopyWithPlaceholder()
          ? _value.date
          // ignore: cast_nullable_to_non_nullable
          : date as DateTime,
      weightKg: weightKg == const $CopyWithPlaceholder()
          ? _value.weightKg
          // ignore: cast_nullable_to_non_nullable
          : weightKg as num,
    );
  }
}

extension $WeightPointCopyWith on WeightPoint {
  /// Returns a callable class that can be used as follows: `instanceOfWeightPoint.copyWith(...)` or like so:`instanceOfWeightPoint.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeightPointCWProxy get copyWith => _$WeightPointCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightPoint _$WeightPointFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WeightPoint', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['date', 'weight_kg']);
      final val = WeightPoint(
        date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
        weightKg: $checkedConvert('weight_kg', (v) => v as num),
      );
      return val;
    }, fieldKeyMap: const {'weightKg': 'weight_kg'});

Map<String, dynamic> _$WeightPointToJson(WeightPoint instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'weight_kg': instance.weightKg,
    };
