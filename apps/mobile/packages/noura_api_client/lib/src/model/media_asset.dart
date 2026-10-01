//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'media_asset.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MediaAsset {
  /// Returns a new [MediaAsset] instance.
  MediaAsset({
    required this.id,

    required this.purpose,

    required this.status,

    required this.verifiedMime,

    required this.byteSize,

    required this.createdAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'purpose', required: true, includeIfNull: false)
  final MediaAssetPurposeEnum purpose;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final MediaAssetStatusEnum status;

  @JsonKey(name: r'verified_mime', required: true, includeIfNull: true)
  final String? verifiedMime;

  @JsonKey(name: r'byte_size', required: true, includeIfNull: true)
  final int? byteSize;

  @JsonKey(name: r'created_at', required: true, includeIfNull: false)
  final DateTime createdAt;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MediaAsset &&
            runtimeType == other.runtimeType &&
            equals(
              [id, purpose, status, verifiedMime, byteSize, createdAt],
              [
                other.id,
                other.purpose,
                other.status,
                other.verifiedMime,
                other.byteSize,
                other.createdAt,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        id,
        purpose,
        status,
        verifiedMime,
        byteSize,
        createdAt,
      ]);

  factory MediaAsset.fromJson(Map<String, dynamic> json) =>
      _$MediaAssetFromJson(json);

  Map<String, dynamic> toJson() => _$MediaAssetToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum MediaAssetPurposeEnum {
  @JsonValue(r'meal')
  meal(r'meal'),
  @JsonValue(r'progress_photo')
  progressPhoto(r'progress_photo'),
  @JsonValue(r'export')
  export_(r'export');

  const MediaAssetPurposeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum MediaAssetStatusEnum {
  @JsonValue(r'awaiting_upload')
  awaitingUpload(r'awaiting_upload'),
  @JsonValue(r'uploaded')
  uploaded(r'uploaded'),
  @JsonValue(r'verified')
  verified(r'verified'),
  @JsonValue(r'rejected')
  rejected(r'rejected'),
  @JsonValue(r'deleted')
  deleted(r'deleted');

  const MediaAssetStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
