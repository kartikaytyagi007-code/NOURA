//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'upload_slot.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UploadSlot {
  /// Returns a new [UploadSlot] instance.
  UploadSlot({
    required this.mediaId,

    required this.uploadUrl,

    required this.expiresAt,
  });

  @JsonKey(name: r'media_id', required: true, includeIfNull: false)
  final String mediaId;

  @JsonKey(name: r'upload_url', required: true, includeIfNull: false)
  final String uploadUrl;

  @JsonKey(name: r'expires_at', required: true, includeIfNull: false)
  final DateTime expiresAt;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is UploadSlot &&
            runtimeType == other.runtimeType &&
            equals(
              [mediaId, uploadUrl, expiresAt],
              [other.mediaId, other.uploadUrl, other.expiresAt],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([mediaId, uploadUrl, expiresAt]);

  factory UploadSlot.fromJson(Map<String, dynamic> json) =>
      _$UploadSlotFromJson(json);

  Map<String, dynamic> toJson() => _$UploadSlotToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
