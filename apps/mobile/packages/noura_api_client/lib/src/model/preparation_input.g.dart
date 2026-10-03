// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preparation_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PreparationInputCWProxy {
  PreparationInput method(String? method);

  PreparationInput oilLevel(OilLevel? oilLevel);

  PreparationInput source_(PreparationInputSource_Enum? source_);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PreparationInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PreparationInput(...).copyWith(id: 12, name: "My name")
  /// ````
  PreparationInput call({
    String? method,
    OilLevel? oilLevel,
    PreparationInputSource_Enum? source_,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPreparationInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPreparationInput.copyWith.fieldName(...)`
class _$PreparationInputCWProxyImpl implements _$PreparationInputCWProxy {
  const _$PreparationInputCWProxyImpl(this._value);

  final PreparationInput _value;

  @override
  PreparationInput method(String? method) => this(method: method);

  @override
  PreparationInput oilLevel(OilLevel? oilLevel) => this(oilLevel: oilLevel);

  @override
  PreparationInput source_(PreparationInputSource_Enum? source_) =>
      this(source_: source_);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PreparationInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PreparationInput(...).copyWith(id: 12, name: "My name")
  /// ````
  PreparationInput call({
    Object? method = const $CopyWithPlaceholder(),
    Object? oilLevel = const $CopyWithPlaceholder(),
    Object? source_ = const $CopyWithPlaceholder(),
  }) {
    return PreparationInput(
      method: method == const $CopyWithPlaceholder()
          ? _value.method
          // ignore: cast_nullable_to_non_nullable
          : method as String?,
      oilLevel: oilLevel == const $CopyWithPlaceholder()
          ? _value.oilLevel
          // ignore: cast_nullable_to_non_nullable
          : oilLevel as OilLevel?,
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as PreparationInputSource_Enum?,
    );
  }
}

extension $PreparationInputCopyWith on PreparationInput {
  /// Returns a callable class that can be used as follows: `instanceOfPreparationInput.copyWith(...)` or like so:`instanceOfPreparationInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PreparationInputCWProxy get copyWith => _$PreparationInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreparationInput _$PreparationInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PreparationInput', json, ($checkedConvert) {
      final val = PreparationInput(
        method: $checkedConvert('method', (v) => v as String?),
        oilLevel: $checkedConvert(
          'oil_level',
          (v) => $enumDecodeNullable(_$OilLevelEnumMap, v),
        ),
        source_: $checkedConvert(
          'source',
          (v) => $enumDecodeNullable(_$PreparationInputSource_EnumEnumMap, v),
        ),
      );
      return val;
    }, fieldKeyMap: const {'oilLevel': 'oil_level', 'source_': 'source'});

Map<String, dynamic> _$PreparationInputToJson(PreparationInput instance) =>
    <String, dynamic>{
      'method': ?instance.method,
      'oil_level': ?_$OilLevelEnumMap[instance.oilLevel],
      'source': ?_$PreparationInputSource_EnumEnumMap[instance.source_],
    };

const _$OilLevelEnumMap = {
  OilLevel.none: 'none',
  OilLevel.light: 'light',
  OilLevel.medium: 'medium',
  OilLevel.heavy: 'heavy',
  OilLevel.unknown: 'unknown',
};

const _$PreparationInputSource_EnumEnumMap = {
  PreparationInputSource_Enum.homemade: 'homemade',
  PreparationInputSource_Enum.restaurant: 'restaurant',
  PreparationInputSource_Enum.packaged: 'packaged',
  PreparationInputSource_Enum.unknown: 'unknown',
};
