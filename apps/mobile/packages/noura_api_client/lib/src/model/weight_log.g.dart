// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_log.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeightLogCWProxy {
  WeightLog id(String id);

  WeightLog clientId(String clientId);

  WeightLog measuredAt(DateTime measuredAt);

  WeightLog weightKg(num weightKg);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightLog(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightLog(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightLog call({
    String id,
    String clientId,
    DateTime measuredAt,
    num weightKg,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeightLog.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeightLog.copyWith.fieldName(...)`
class _$WeightLogCWProxyImpl implements _$WeightLogCWProxy {
  const _$WeightLogCWProxyImpl(this._value);

  final WeightLog _value;

  @override
  WeightLog id(String id) => this(id: id);

  @override
  WeightLog clientId(String clientId) => this(clientId: clientId);

  @override
  WeightLog measuredAt(DateTime measuredAt) => this(measuredAt: measuredAt);

  @override
  WeightLog weightKg(num weightKg) => this(weightKg: weightKg);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightLog(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightLog(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightLog call({
    Object? id = const $CopyWithPlaceholder(),
    Object? clientId = const $CopyWithPlaceholder(),
    Object? measuredAt = const $CopyWithPlaceholder(),
    Object? weightKg = const $CopyWithPlaceholder(),
  }) {
    return WeightLog(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
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

extension $WeightLogCopyWith on WeightLog {
  /// Returns a callable class that can be used as follows: `instanceOfWeightLog.copyWith(...)` or like so:`instanceOfWeightLog.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeightLogCWProxy get copyWith => _$WeightLogCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightLog _$WeightLogFromJson(Map<String, dynamic> json) => $checkedCreate(
  'WeightLog',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['id', 'client_id', 'measured_at', 'weight_kg'],
    );
    final val = WeightLog(
      id: $checkedConvert('id', (v) => v as String),
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

Map<String, dynamic> _$WeightLogToJson(WeightLog instance) => <String, dynamic>{
  'id': instance.id,
  'client_id': instance.clientId,
  'measured_at': instance.measuredAt.toIso8601String(),
  'weight_kg': instance.weightKg,
};
