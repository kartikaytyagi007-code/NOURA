// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serving_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ServingInputCWProxy {
  ServingInput unit(String unit);

  ServingInput quantity(num quantity);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ServingInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ServingInput(...).copyWith(id: 12, name: "My name")
  /// ````
  ServingInput call({String unit, num quantity});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfServingInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfServingInput.copyWith.fieldName(...)`
class _$ServingInputCWProxyImpl implements _$ServingInputCWProxy {
  const _$ServingInputCWProxyImpl(this._value);

  final ServingInput _value;

  @override
  ServingInput unit(String unit) => this(unit: unit);

  @override
  ServingInput quantity(num quantity) => this(quantity: quantity);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ServingInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ServingInput(...).copyWith(id: 12, name: "My name")
  /// ````
  ServingInput call({
    Object? unit = const $CopyWithPlaceholder(),
    Object? quantity = const $CopyWithPlaceholder(),
  }) {
    return ServingInput(
      unit: unit == const $CopyWithPlaceholder()
          ? _value.unit
          // ignore: cast_nullable_to_non_nullable
          : unit as String,
      quantity: quantity == const $CopyWithPlaceholder()
          ? _value.quantity
          // ignore: cast_nullable_to_non_nullable
          : quantity as num,
    );
  }
}

extension $ServingInputCopyWith on ServingInput {
  /// Returns a callable class that can be used as follows: `instanceOfServingInput.copyWith(...)` or like so:`instanceOfServingInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ServingInputCWProxy get copyWith => _$ServingInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServingInput _$ServingInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ServingInput', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['unit', 'quantity']);
      final val = ServingInput(
        unit: $checkedConvert('unit', (v) => v as String),
        quantity: $checkedConvert('quantity', (v) => v as num),
      );
      return val;
    });

Map<String, dynamic> _$ServingInputToJson(ServingInput instance) =>
    <String, dynamic>{'unit': instance.unit, 'quantity': instance.quantity};
