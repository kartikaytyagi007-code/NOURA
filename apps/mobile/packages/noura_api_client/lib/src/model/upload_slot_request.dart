//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/media_purpose.dart';
import 'package:noura_api_client/src/model/image_mime.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'upload_slot_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UploadSlotRequest {
  /// Returns a new [UploadSlotRequest] instance.
  UploadSlotRequest({
    required this.purpose,

    required this.mime,

    required this.sizeBytes,
  });

  @JsonKey(name: r'purpose', required: true, includeIfNull: false)
  final MediaPurpose purpose;

  @JsonKey(name: r'mime', required: true, includeIfNull: false)
  final ImageMime mime;

  // minimum: 1
  // maximum: 10485760
  @JsonKey(name: r'size_bytes', required: true, includeIfNull: false)
  final int sizeBytes;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is UploadSlotRequest &&
            runtimeType == other.runtimeType &&
            equals(
              [purpose, mime, sizeBytes],
              [other.purpose, other.mime, other.sizeBytes],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([purpose, mime, sizeBytes]);

  factory UploadSlotRequest.fromJson(Map<String, dynamic> json) =>
      _$UploadSlotRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UploadSlotRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
