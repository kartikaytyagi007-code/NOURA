// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'source_ref.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SourceRefCWProxy {
  SourceRef sourceId(String sourceId);

  SourceRef sourceName(String sourceName);

  SourceRef sourceVersion(String sourceVersion);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SourceRef(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SourceRef(...).copyWith(id: 12, name: "My name")
  /// ````
  SourceRef call({String sourceId, String sourceName, String sourceVersion});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSourceRef.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSourceRef.copyWith.fieldName(...)`
class _$SourceRefCWProxyImpl implements _$SourceRefCWProxy {
  const _$SourceRefCWProxyImpl(this._value);

  final SourceRef _value;

  @override
  SourceRef sourceId(String sourceId) => this(sourceId: sourceId);

  @override
  SourceRef sourceName(String sourceName) => this(sourceName: sourceName);

  @override
  SourceRef sourceVersion(String sourceVersion) =>
      this(sourceVersion: sourceVersion);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SourceRef(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SourceRef(...).copyWith(id: 12, name: "My name")
  /// ````
  SourceRef call({
    Object? sourceId = const $CopyWithPlaceholder(),
    Object? sourceName = const $CopyWithPlaceholder(),
    Object? sourceVersion = const $CopyWithPlaceholder(),
  }) {
    return SourceRef(
      sourceId: sourceId == const $CopyWithPlaceholder()
          ? _value.sourceId
          // ignore: cast_nullable_to_non_nullable
          : sourceId as String,
      sourceName: sourceName == const $CopyWithPlaceholder()
          ? _value.sourceName
          // ignore: cast_nullable_to_non_nullable
          : sourceName as String,
      sourceVersion: sourceVersion == const $CopyWithPlaceholder()
          ? _value.sourceVersion
          // ignore: cast_nullable_to_non_nullable
          : sourceVersion as String,
    );
  }
}

extension $SourceRefCopyWith on SourceRef {
  /// Returns a callable class that can be used as follows: `instanceOfSourceRef.copyWith(...)` or like so:`instanceOfSourceRef.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SourceRefCWProxy get copyWith => _$SourceRefCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SourceRef _$SourceRefFromJson(Map<String, dynamic> json) => $checkedCreate(
  'SourceRef',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['source_id', 'source_name', 'source_version'],
    );
    final val = SourceRef(
      sourceId: $checkedConvert('source_id', (v) => v as String),
      sourceName: $checkedConvert('source_name', (v) => v as String),
      sourceVersion: $checkedConvert('source_version', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'sourceId': 'source_id',
    'sourceName': 'source_name',
    'sourceVersion': 'source_version',
  },
);

Map<String, dynamic> _$SourceRefToJson(SourceRef instance) => <String, dynamic>{
  'source_id': instance.sourceId,
  'source_name': instance.sourceName,
  'source_version': instance.sourceVersion,
};
