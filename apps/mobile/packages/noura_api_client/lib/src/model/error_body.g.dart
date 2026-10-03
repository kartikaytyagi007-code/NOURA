// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_body.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ErrorBodyCWProxy {
  ErrorBody code(ErrorCode code);

  ErrorBody message(String message);

  ErrorBody fieldErrors(List<FieldError> fieldErrors);

  ErrorBody retryable(bool retryable);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ErrorBody(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ErrorBody(...).copyWith(id: 12, name: "My name")
  /// ````
  ErrorBody call({
    ErrorCode code,
    String message,
    List<FieldError> fieldErrors,
    bool retryable,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfErrorBody.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfErrorBody.copyWith.fieldName(...)`
class _$ErrorBodyCWProxyImpl implements _$ErrorBodyCWProxy {
  const _$ErrorBodyCWProxyImpl(this._value);

  final ErrorBody _value;

  @override
  ErrorBody code(ErrorCode code) => this(code: code);

  @override
  ErrorBody message(String message) => this(message: message);

  @override
  ErrorBody fieldErrors(List<FieldError> fieldErrors) =>
      this(fieldErrors: fieldErrors);

  @override
  ErrorBody retryable(bool retryable) => this(retryable: retryable);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ErrorBody(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ErrorBody(...).copyWith(id: 12, name: "My name")
  /// ````
  ErrorBody call({
    Object? code = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? fieldErrors = const $CopyWithPlaceholder(),
    Object? retryable = const $CopyWithPlaceholder(),
  }) {
    return ErrorBody(
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as ErrorCode,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
      fieldErrors: fieldErrors == const $CopyWithPlaceholder()
          ? _value.fieldErrors
          // ignore: cast_nullable_to_non_nullable
          : fieldErrors as List<FieldError>,
      retryable: retryable == const $CopyWithPlaceholder()
          ? _value.retryable
          // ignore: cast_nullable_to_non_nullable
          : retryable as bool,
    );
  }
}

extension $ErrorBodyCopyWith on ErrorBody {
  /// Returns a callable class that can be used as follows: `instanceOfErrorBody.copyWith(...)` or like so:`instanceOfErrorBody.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ErrorBodyCWProxy get copyWith => _$ErrorBodyCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorBody _$ErrorBodyFromJson(Map<String, dynamic> json) => $checkedCreate(
  'ErrorBody',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['code', 'message', 'field_errors', 'retryable'],
    );
    final val = ErrorBody(
      code: $checkedConvert('code', (v) => $enumDecode(_$ErrorCodeEnumMap, v)),
      message: $checkedConvert('message', (v) => v as String),
      fieldErrors: $checkedConvert(
        'field_errors',
        (v) => (v as List<dynamic>)
            .map((e) => FieldError.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      retryable: $checkedConvert('retryable', (v) => v as bool),
    );
    return val;
  },
  fieldKeyMap: const {'fieldErrors': 'field_errors'},
);

Map<String, dynamic> _$ErrorBodyToJson(ErrorBody instance) => <String, dynamic>{
  'code': _$ErrorCodeEnumMap[instance.code]!,
  'message': instance.message,
  'field_errors': instance.fieldErrors.map((e) => e.toJson()).toList(),
  'retryable': instance.retryable,
};

const _$ErrorCodeEnumMap = {
  ErrorCode.VALIDATION_ERROR: 'VALIDATION_ERROR',
  ErrorCode.UNAUTHENTICATED: 'UNAUTHENTICATED',
  ErrorCode.NOT_FOUND: 'NOT_FOUND',
  ErrorCode.REVISION_CONFLICT: 'REVISION_CONFLICT',
  ErrorCode.QUOTA_EXCEEDED: 'QUOTA_EXCEEDED',
  ErrorCode.PROVIDER_UNAVAILABLE: 'PROVIDER_UNAVAILABLE',
  ErrorCode.UNSUPPORTED_INPUT: 'UNSUPPORTED_INPUT',
  ErrorCode.CONSTRAINT_CONFLICT: 'CONSTRAINT_CONFLICT',
  ErrorCode.INTERNAL_ERROR: 'INTERNAL_ERROR',
};
