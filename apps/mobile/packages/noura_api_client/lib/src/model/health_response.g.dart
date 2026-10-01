// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HealthResponseCWProxy {
  HealthResponse status(HealthResponseStatusEnum status);

  HealthResponse service(HealthResponseServiceEnum service);

  HealthResponse version(String version);

  HealthResponse checks(List<HealthCheck> checks);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HealthResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HealthResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  HealthResponse call({
    HealthResponseStatusEnum status,
    HealthResponseServiceEnum service,
    String version,
    List<HealthCheck> checks,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHealthResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHealthResponse.copyWith.fieldName(...)`
class _$HealthResponseCWProxyImpl implements _$HealthResponseCWProxy {
  const _$HealthResponseCWProxyImpl(this._value);

  final HealthResponse _value;

  @override
  HealthResponse status(HealthResponseStatusEnum status) =>
      this(status: status);

  @override
  HealthResponse service(HealthResponseServiceEnum service) =>
      this(service: service);

  @override
  HealthResponse version(String version) => this(version: version);

  @override
  HealthResponse checks(List<HealthCheck> checks) => this(checks: checks);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HealthResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HealthResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  HealthResponse call({
    Object? status = const $CopyWithPlaceholder(),
    Object? service = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? checks = const $CopyWithPlaceholder(),
  }) {
    return HealthResponse(
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as HealthResponseStatusEnum,
      service: service == const $CopyWithPlaceholder()
          ? _value.service
          // ignore: cast_nullable_to_non_nullable
          : service as HealthResponseServiceEnum,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as String,
      checks: checks == const $CopyWithPlaceholder()
          ? _value.checks
          // ignore: cast_nullable_to_non_nullable
          : checks as List<HealthCheck>,
    );
  }
}

extension $HealthResponseCopyWith on HealthResponse {
  /// Returns a callable class that can be used as follows: `instanceOfHealthResponse.copyWith(...)` or like so:`instanceOfHealthResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HealthResponseCWProxy get copyWith => _$HealthResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthResponse _$HealthResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('HealthResponse', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['status', 'service', 'version', 'checks'],
      );
      final val = HealthResponse(
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$HealthResponseStatusEnumEnumMap, v),
        ),
        service: $checkedConvert(
          'service',
          (v) => $enumDecode(_$HealthResponseServiceEnumEnumMap, v),
        ),
        version: $checkedConvert('version', (v) => v as String),
        checks: $checkedConvert(
          'checks',
          (v) => (v as List<dynamic>)
              .map((e) => HealthCheck.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$HealthResponseToJson(HealthResponse instance) =>
    <String, dynamic>{
      'status': _$HealthResponseStatusEnumEnumMap[instance.status]!,
      'service': _$HealthResponseServiceEnumEnumMap[instance.service]!,
      'version': instance.version,
      'checks': instance.checks.map((e) => e.toJson()).toList(),
    };

const _$HealthResponseStatusEnumEnumMap = {
  HealthResponseStatusEnum.ok: 'ok',
  HealthResponseStatusEnum.unavailable: 'unavailable',
};

const _$HealthResponseServiceEnumEnumMap = {
  HealthResponseServiceEnum.api: 'api',
  HealthResponseServiceEnum.worker: 'worker',
};
