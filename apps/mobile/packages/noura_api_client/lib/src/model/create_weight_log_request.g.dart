// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_weight_log_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateWeightLogRequestCWProxy {
  CreateWeightLogRequest clientId(String clientId);

  CreateWeightLogRequest measuredAt(DateTime measuredAt);

  CreateWeightLogRequest weightKg(num weightKg);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateWeightLogRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateWeightLogRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateWeightLogRequest call({
    String clientId,
    DateTime measuredAt,
    num weightKg,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateWeightLogRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateWeightLogRequest.copyWith.fieldName(...)`
class _$CreateWeightLogRequestCWProxyImpl
    implements _$CreateWeightLogRequestCWProxy {
  const _$CreateWeightLogRequestCWProxyImpl(this._value);

  final CreateWeightLogRequest _value;

  @override
  CreateWeightLogRequest clientId(String clientId) => this(clientId: clientId);

  @override
  CreateWeightLogRequest measuredAt(DateTime measuredAt) =>
      this(measuredAt: measuredAt);

  @override
  CreateWeightLogRequest weightKg(num weightKg) => this(weightKg: weightKg);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateWeightLogRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateWeightLogRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateWeightLogRequest call({
    Object? clientId = const $CopyWithPlaceholder(),
    Object? measuredAt = const $CopyWithPlaceholder(),
    Object? weightKg = const $CopyWithPlaceholder(),
  }) {
    return CreateWeightLogRequest(
      clientId: clientId == const $CopyWithPlaceholder()
          ? _value.clientId
          // ignore: cast_nullable_to_non_nullable
          : clientId as String,
      measuredAt: measuredAt == const $CopyWithPlaceholder()
          ? _value.measuredAt
          // ignore: cast_nullable_to_non_nullable
          : measuredAt as DateTime,
      weightKg: weightKg == const $CopyWithPlaceholder()
          ? _value.weightKg
          // ignore: cast_nullable_to_non_nullable
          : weightKg as num,
    );
  }
}

extension $CreateWeightLogRequestCopyWith on CreateWeightLogRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateWeightLogRequest.copyWith(...)` or like so:`instanceOfCreateWeightLogRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateWeightLogRequestCWProxy get copyWith =>
      _$CreateWeightLogRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateWeightLogRequest _$CreateWeightLogRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CreateWeightLogRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['client_id', 'measured_at', 'weight_kg'],
    );
    final val = CreateWeightLogRequest(
      clientId: $checkedConvert('client_id', (v) => v as String),
      measuredAt: $checkedConvert(
        'measured_at',
        (v) => DateTime.parse(v as String),
      ),
      weightKg: $checkedConvert('weight_kg', (v) => v as num),
    );
    return val;
  },
  fieldKeyMap: const {
    'clientId': 'client_id',
    'measuredAt': 'measured_at',
    'weightKg': 'weight_kg',
  },
);

Map<String, dynamic> _$CreateWeightLogRequestToJson(
  CreateWeightLogRequest instance,
) => <String, dynamic>{
  'client_id': instance.clientId,
  'measured_at': instance.measuredAt.toIso8601String(),
  'weight_kg': instance.weightKg,
};
