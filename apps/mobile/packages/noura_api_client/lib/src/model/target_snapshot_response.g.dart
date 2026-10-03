// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'target_snapshot_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TargetSnapshotResponseCWProxy {
  TargetSnapshotResponse data(TargetSnapshot data);

  TargetSnapshotResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TargetSnapshotResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TargetSnapshotResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  TargetSnapshotResponse call({TargetSnapshot data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTargetSnapshotResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTargetSnapshotResponse.copyWith.fieldName(...)`
class _$TargetSnapshotResponseCWProxyImpl
    implements _$TargetSnapshotResponseCWProxy {
  const _$TargetSnapshotResponseCWProxyImpl(this._value);

  final TargetSnapshotResponse _value;

  @override
  TargetSnapshotResponse data(TargetSnapshot data) => this(data: data);

  @override
  TargetSnapshotResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TargetSnapshotResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TargetSnapshotResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  TargetSnapshotResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return TargetSnapshotResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as TargetSnapshot,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $TargetSnapshotResponseCopyWith on TargetSnapshotResponse {
  /// Returns a callable class that can be used as follows: `instanceOfTargetSnapshotResponse.copyWith(...)` or like so:`instanceOfTargetSnapshotResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TargetSnapshotResponseCWProxy get copyWith =>
      _$TargetSnapshotResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TargetSnapshotResponse _$TargetSnapshotResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('TargetSnapshotResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = TargetSnapshotResponse(
    data: $checkedConvert(
      'data',
      (v) => TargetSnapshot.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => Meta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$TargetSnapshotResponseToJson(
  TargetSnapshotResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
