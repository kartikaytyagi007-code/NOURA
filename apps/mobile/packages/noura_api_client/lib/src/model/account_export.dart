//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'account_export.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AccountExport {
  /// Returns a new [AccountExport] instance.
  AccountExport({
    required this.id,

    required this.state,

    required this.downloadUrl,

    required this.expiresAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'state', required: true, includeIfNull: false)
  final AccountExportStateEnum state;

  @JsonKey(name: r'download_url', required: true, includeIfNull: true)
  final String? downloadUrl;

  @JsonKey(name: r'expires_at', required: true, includeIfNull: true)
  final DateTime? expiresAt;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AccountExport &&
            runtimeType == other.runtimeType &&
            equals(
              [id, state, downloadUrl, expiresAt],
              [other.id, other.state, other.downloadUrl, other.expiresAt],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([id, state, downloadUrl, expiresAt]);

  factory AccountExport.fromJson(Map<String, dynamic> json) =>
      _$AccountExportFromJson(json);

  Map<String, dynamic> toJson() => _$AccountExportToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum AccountExportStateEnum {
  @JsonValue(r'queued')
  queued(r'queued'),
  @JsonValue(r'running')
  running(r'running'),
  @JsonValue(r'completed')
  completed(r'completed'),
  @JsonValue(r'failed')
  failed(r'failed'),
  @JsonValue(r'expired')
  expired(r'expired');

  const AccountExportStateEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
