// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coverage.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CoverageCWProxy {
  Coverage itemsTotal(int itemsTotal);

  Coverage itemsWithNutrition(int itemsWithNutrition);

  Coverage complete(bool complete);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Coverage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Coverage(...).copyWith(id: 12, name: "My name")
  /// ````
  Coverage call({int itemsTotal, int itemsWithNutrition, bool complete});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCoverage.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCoverage.copyWith.fieldName(...)`
class _$CoverageCWProxyImpl implements _$CoverageCWProxy {
  const _$CoverageCWProxyImpl(this._value);

  final Coverage _value;

  @override
  Coverage itemsTotal(int itemsTotal) => this(itemsTotal: itemsTotal);

  @override
  Coverage itemsWithNutrition(int itemsWithNutrition) =>
      this(itemsWithNutrition: itemsWithNutrition);

  @override
  Coverage complete(bool complete) => this(complete: complete);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Coverage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Coverage(...).copyWith(id: 12, name: "My name")
  /// ````
  Coverage call({
    Object? itemsTotal = const $CopyWithPlaceholder(),
    Object? itemsWithNutrition = const $CopyWithPlaceholder(),
    Object? complete = const $CopyWithPlaceholder(),
  }) {
    return Coverage(
      itemsTotal: itemsTotal == const $CopyWithPlaceholder()
          ? _value.itemsTotal
          // ignore: cast_nullable_to_non_nullable
          : itemsTotal as int,
      itemsWithNutrition: itemsWithNutrition == const $CopyWithPlaceholder()
          ? _value.itemsWithNutrition
          // ignore: cast_nullable_to_non_nullable
          : itemsWithNutrition as int,
      complete: complete == const $CopyWithPlaceholder()
          ? _value.complete
          // ignore: cast_nullable_to_non_nullable
          : complete as bool,
    );
  }
}

extension $CoverageCopyWith on Coverage {
  /// Returns a callable class that can be used as follows: `instanceOfCoverage.copyWith(...)` or like so:`instanceOfCoverage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CoverageCWProxy get copyWith => _$CoverageCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Coverage _$CoverageFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Coverage',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['items_total', 'items_with_nutrition', 'complete'],
    );
    final val = Coverage(
      itemsTotal: $checkedConvert('items_total', (v) => (v as num).toInt()),
      itemsWithNutrition: $checkedConvert(
        'items_with_nutrition',
        (v) => (v as num).toInt(),
      ),
      complete: $checkedConvert('complete', (v) => v as bool),
    );
    return val;
  },
  fieldKeyMap: const {
    'itemsTotal': 'items_total',
    'itemsWithNutrition': 'items_with_nutrition',
  },
);

Map<String, dynamic> _$CoverageToJson(Coverage instance) => <String, dynamic>{
  'items_total': instance.itemsTotal,
  'items_with_nutrition': instance.itemsWithNutrition,
  'complete': instance.complete,
};
