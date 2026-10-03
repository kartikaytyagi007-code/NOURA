//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'entitlement.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Entitlement {
  /// Returns a new [Entitlement] instance.
  Entitlement({
    required this.key,

    required this.isActive,

    required this.providerStatus,

    required this.expiresAt,

    required this.lastVerifiedAt,
  });

  @JsonKey(name: r'key', required: true, includeIfNull: false)
  final String key;

  @JsonKey(name: r'is_active', required: true, includeIfNull: false)
  final bool isActive;

  @JsonKey(name: r'provider_status', required: true, includeIfNull: false)
  final String providerStatus;

  @JsonKey(name: r'expires_at', required: true, includeIfNull: true)
  final DateTime? expiresAt;

  @JsonKey(name: r'last_verified_at', required: true, includeIfNull: false)
  final DateTime lastVerifiedAt;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Entitlement &&
            runtimeType == other.runtimeType &&
            equals(
              [key, isActive, providerStatus, expiresAt, lastVerifiedAt],
              [
                other.key,
                other.isActive,
                other.providerStatus,
                other.expiresAt,
                other.lastVerifiedAt,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        key,
        isActive,
        providerStatus,
        expiresAt,
        lastVerifiedAt,
      ]);

  factory Entitlement.fromJson(Map<String, dynamic> json) =>
      _$EntitlementFromJson(json);

  Map<String, dynamic> toJson() => _$EntitlementToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
