// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_check.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HealthCheckCWProxy {
  HealthCheck name(String name);

  HealthCheck ok(bool ok);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HealthCheck(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HealthCheck(...).copyWith(id: 12, name: "My name")
  /// ````
  HealthCheck call({String name, bool ok});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHealthCheck.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHealthCheck.copyWith.fieldName(...)`
class _$HealthCheckCWProxyImpl implements _$HealthCheckCWProxy {
  const _$HealthCheckCWProxyImpl(this._value);

  final HealthCheck _value;

  @override
  HealthCheck name(String name) => this(name: name);

  @override
  HealthCheck ok(bool ok) => this(ok: ok);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HealthCheck(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HealthCheck(...).copyWith(id: 12, name: "My name")
  /// ````
  HealthCheck call({
    Object? name = const $CopyWithPlaceholder(),
    Object? ok = const $CopyWithPlaceholder(),
  }) {
    return HealthCheck(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      ok: ok == const $CopyWithPlaceholder()
          ? _value.ok
          // ignore: cast_nullable_to_non_nullable
          : ok as bool,
    );
  }
}

extension $HealthCheckCopyWith on HealthCheck {
  /// Returns a callable class that can be used as follows: `instanceOfHealthCheck.copyWith(...)` or like so:`instanceOfHealthCheck.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HealthCheckCWProxy get copyWith => _$HealthCheckCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthCheck _$HealthCheckFromJson(Map<String, dynamic> json) =>
    $checkedCreate('HealthCheck', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['name', 'ok']);
      final val = HealthCheck(
        name: $checkedConvert('name', (v) => v as String),
        ok: $checkedConvert('ok', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$HealthCheckToJson(HealthCheck instance) =>
    <String, dynamic>{'name': instance.name, 'ok': instance.ok};
