// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field_error.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FieldErrorCWProxy {
  FieldError field(String field);

  FieldError code(String code);

  FieldError message(String message);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FieldError(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FieldError(...).copyWith(id: 12, name: "My name")
  /// ````
  FieldError call({String field, String code, String message});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFieldError.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFieldError.copyWith.fieldName(...)`
class _$FieldErrorCWProxyImpl implements _$FieldErrorCWProxy {
  const _$FieldErrorCWProxyImpl(this._value);

  final FieldError _value;

  @override
  FieldError field(String field) => this(field: field);

  @override
  FieldError code(String code) => this(code: code);

  @override
  FieldError message(String message) => this(message: message);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FieldError(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FieldError(...).copyWith(id: 12, name: "My name")
  /// ````
  FieldError call({
    Object? field = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
  }) {
    return FieldError(
      field: field == const $CopyWithPlaceholder()
          ? _value.field
          // ignore: cast_nullable_to_non_nullable
          : field as String,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
    );
  }
}

extension $FieldErrorCopyWith on FieldError {
  /// Returns a callable class that can be used as follows: `instanceOfFieldError.copyWith(...)` or like so:`instanceOfFieldError.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FieldErrorCWProxy get copyWith => _$FieldErrorCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FieldError _$FieldErrorFromJson(Map<String, dynamic> json) =>
    $checkedCreate('FieldError', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['field', 'code', 'message']);
      final val = FieldError(
        field: $checkedConvert('field', (v) => v as String),
        code: $checkedConvert('code', (v) => v as String),
        message: $checkedConvert('message', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$FieldErrorToJson(FieldError instance) =>
    <String, dynamic>{
      'field': instance.field,
      'code': instance.code,
      'message': instance.message,
    };
