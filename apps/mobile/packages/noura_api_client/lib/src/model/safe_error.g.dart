// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'safe_error.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SafeErrorCWProxy {
  SafeError code(String code);

  SafeError message(String message);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SafeError(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SafeError(...).copyWith(id: 12, name: "My name")
  /// ````
  SafeError call({String code, String message});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSafeError.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSafeError.copyWith.fieldName(...)`
class _$SafeErrorCWProxyImpl implements _$SafeErrorCWProxy {
  const _$SafeErrorCWProxyImpl(this._value);

  final SafeError _value;

  @override
  SafeError code(String code) => this(code: code);

  @override
  SafeError message(String message) => this(message: message);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SafeError(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SafeError(...).copyWith(id: 12, name: "My name")
  /// ````
  SafeError call({
    Object? code = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
  }) {
    return SafeError(
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

extension $SafeErrorCopyWith on SafeError {
  /// Returns a callable class that can be used as follows: `instanceOfSafeError.copyWith(...)` or like so:`instanceOfSafeError.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SafeErrorCWProxy get copyWith => _$SafeErrorCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SafeError _$SafeErrorFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SafeError', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['code', 'message']);
      final val = SafeError(
        code: $checkedConvert('code', (v) => v as String),
        message: $checkedConvert('message', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$SafeErrorToJson(SafeError instance) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
};
