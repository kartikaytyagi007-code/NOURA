// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_scan.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MealScanCWProxy {
  MealScan id(String id);

  MealScan status(MealScanStatus status);

  MealScan recognition(Recognition? recognition);

  MealScan revision(int revision);

  MealScan error(SafeError? error);

  MealScan createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealScan(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealScan(...).copyWith(id: 12, name: "My name")
  /// ````
  MealScan call({
    String id,
    MealScanStatus status,
    Recognition? recognition,
    int revision,
    SafeError? error,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMealScan.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMealScan.copyWith.fieldName(...)`
class _$MealScanCWProxyImpl implements _$MealScanCWProxy {
  const _$MealScanCWProxyImpl(this._value);

  final MealScan _value;

  @override
  MealScan id(String id) => this(id: id);

  @override
  MealScan status(MealScanStatus status) => this(status: status);

  @override
  MealScan recognition(Recognition? recognition) =>
      this(recognition: recognition);

  @override
  MealScan revision(int revision) => this(revision: revision);

  @override
  MealScan error(SafeError? error) => this(error: error);

  @override
  MealScan createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealScan(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealScan(...).copyWith(id: 12, name: "My name")
  /// ````
  MealScan call({
    Object? id = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? recognition = const $CopyWithPlaceholder(),
    Object? revision = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return MealScan(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as MealScanStatus,
      recognition: recognition == const $CopyWithPlaceholder()
          ? _value.recognition
          // ignore: cast_nullable_to_non_nullable
          : recognition as Recognition?,
      revision: revision == const $CopyWithPlaceholder()
          ? _value.revision
          // ignore: cast_nullable_to_non_nullable
          : revision as int,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as SafeError?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $MealScanCopyWith on MealScan {
  /// Returns a callable class that can be used as follows: `instanceOfMealScan.copyWith(...)` or like so:`instanceOfMealScan.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MealScanCWProxy get copyWith => _$MealScanCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealScan _$MealScanFromJson(Map<String, dynamic> json) => $checkedCreate(
  'MealScan',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'status',
        'recognition',
        'revision',
        'error',
        'created_at',
      ],
    );
    final val = MealScan(
      id: $checkedConvert('id', (v) => v as String),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$MealScanStatusEnumMap, v),
      ),
      recognition: $checkedConvert(
        'recognition',
        (v) =>
            v == null ? null : Recognition.fromJson(v as Map<String, dynamic>),
      ),
      revision: $checkedConvert('revision', (v) => (v as num).toInt()),
      error: $checkedConvert(
        'error',
        (v) => v == null ? null : SafeError.fromJson(v as Map<String, dynamic>),
      ),
      createdAt: $checkedConvert(
        'created_at',
        (v) => DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {'createdAt': 'created_at'},
);

Map<String, dynamic> _$MealScanToJson(MealScan instance) => <String, dynamic>{
  'id': instance.id,
  'status': _$MealScanStatusEnumMap[instance.status]!,
  'recognition': instance.recognition?.toJson(),
  'revision': instance.revision,
  'error': instance.error?.toJson(),
  'created_at': instance.createdAt.toIso8601String(),
};

const _$MealScanStatusEnumMap = {
  MealScanStatus.awaitingUpload: 'awaiting_upload',
  MealScanStatus.queued: 'queued',
  MealScanStatus.recognizing: 'recognizing',
  MealScanStatus.needsConfirmation: 'needs_confirmation',
  MealScanStatus.ready: 'ready',
  MealScanStatus.failed: 'failed',
  MealScanStatus.cancelled: 'cancelled',
  MealScanStatus.expired: 'expired',
};
