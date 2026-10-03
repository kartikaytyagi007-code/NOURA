// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_export.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AccountExportCWProxy {
  AccountExport id(String id);

  AccountExport state(AccountExportStateEnum state);

  AccountExport downloadUrl(String? downloadUrl);

  AccountExport expiresAt(DateTime? expiresAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AccountExport(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AccountExport(...).copyWith(id: 12, name: "My name")
  /// ````
  AccountExport call({
    String id,
    AccountExportStateEnum state,
    String? downloadUrl,
    DateTime? expiresAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAccountExport.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAccountExport.copyWith.fieldName(...)`
class _$AccountExportCWProxyImpl implements _$AccountExportCWProxy {
  const _$AccountExportCWProxyImpl(this._value);

  final AccountExport _value;

  @override
  AccountExport id(String id) => this(id: id);

  @override
  AccountExport state(AccountExportStateEnum state) => this(state: state);

  @override
  AccountExport downloadUrl(String? downloadUrl) =>
      this(downloadUrl: downloadUrl);

  @override
  AccountExport expiresAt(DateTime? expiresAt) => this(expiresAt: expiresAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AccountExport(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AccountExport(...).copyWith(id: 12, name: "My name")
  /// ````
  AccountExport call({
    Object? id = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
    Object? downloadUrl = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
  }) {
    return AccountExport(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      state: state == const $CopyWithPlaceholder()
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as AccountExportStateEnum,
      downloadUrl: downloadUrl == const $CopyWithPlaceholder()
          ? _value.downloadUrl
          // ignore: cast_nullable_to_non_nullable
          : downloadUrl as String?,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime?,
    );
  }
}

extension $AccountExportCopyWith on AccountExport {
  /// Returns a callable class that can be used as follows: `instanceOfAccountExport.copyWith(...)` or like so:`instanceOfAccountExport.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AccountExportCWProxy get copyWith => _$AccountExportCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountExport _$AccountExportFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'AccountExport',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['id', 'state', 'download_url', 'expires_at'],
        );
        final val = AccountExport(
          id: $checkedConvert('id', (v) => v as String),
          state: $checkedConvert(
            'state',
            (v) => $enumDecode(_$AccountExportStateEnumEnumMap, v),
          ),
          downloadUrl: $checkedConvert('download_url', (v) => v as String?),
          expiresAt: $checkedConvert(
            'expires_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'downloadUrl': 'download_url',
        'expiresAt': 'expires_at',
      },
    );

Map<String, dynamic> _$AccountExportToJson(AccountExport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'state': _$AccountExportStateEnumEnumMap[instance.state]!,
      'download_url': instance.downloadUrl,
      'expires_at': instance.expiresAt?.toIso8601String(),
    };

const _$AccountExportStateEnumEnumMap = {
  AccountExportStateEnum.queued: 'queued',
  AccountExportStateEnum.running: 'running',
  AccountExportStateEnum.completed: 'completed',
  AccountExportStateEnum.failed: 'failed',
  AccountExportStateEnum.expired: 'expired',
};
